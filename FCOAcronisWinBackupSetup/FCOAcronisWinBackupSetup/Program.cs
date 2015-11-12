/// <summary>
/// (c) 2015 Flexiant Limited
/// 
/// This application requires that 7zip (7z) be installed for full functionality
/// 
/// This application will download, install, and register the machine with the backup service
/// 
/// It is possible to perform all or some of these actions by passing an action name as the first parameter
/// 
/// All - Performs a full install and registers the machine
/// FullInstall - Downloads the Backup Client for Windows, uses 7zip to extract the BackupClient.msi, install the client and then registers the machine.
/// Install - This action requires the Backup Client for Windows executable, or the BackupClient.msi, to be specified as the second parameter. 
/// 			This will extract the BackupClient.msi from the Backup Client executable if specified then install the client using the BackupClient.msi
/// Register - This will register the machine with the Backup Service. This can only take place after an install or full install.
/// Check - This will check if the machine is register with the Backup Service. This can only take place after an install or full install.
/// Details - This will display the configuration details that would be used to register the machine with the backup service.
/// 
/// Example 1.
/// .\FCOAcronisWinBackupSertup.exe all
/// 
/// Example 2.
/// .\FCOAcronisWinBackupSertup.exe install .\BackupClient.msi
/// 
/// Example 3.
/// .\FCOAcronisWinBackupSertup.exe register
/// </summary>
#region Using.

using System;
using System.IO;
using System.Net;
using System.Diagnostics;
using System.Xml;

#endregion

namespace FCOAcronisWinBackupSetup
{
	class MainClass
	{
		private const string AGENT_DOWNLOAD_ADDRESS = "http://dl.managed-protection.com/u/baas/4.0/12.0.1299/Backup_Client_for_Windows_en-US.exe";

		#region Enum.

		/// <summary>
		/// An enum that represents the possible actions defined by the first argument.
		/// </summary>
		public enum Action{
			All,
			FullInstall,
			Install,
			Register,
			Check,
			Details
		}

		#endregion
		#region Main.

		public static void Main (string[] args)
		{
			Action action = Action.All;

			if (args.Length > 0) {
				try{
					action = (Action) Enum.Parse (typeof(Action), args [0], true);
				}catch{
					Console.WriteLine (String.Format("Invalid action {0}", args[0]));
					return;
				}
			}

			string backupAgent = null;
			if (args.Length > 1) {
				backupAgent = args [1];
			}

			bool clean = true;

			bool setup = false;
			bool install = false;
			bool register = false;
			bool details = false;
			bool check = false;

			switch (action) {
			case Action.All:
				setup = true;
				install = true;
				register = true;
				details = true;
				break;
			case Action.FullInstall:
				setup = true;
				install = true;
				break;
			case Action.Install:
				install = true;
				break;
			case Action.Register:
				register = true;
				details = true;
				break;
			case Action.Details:
				details = true;
				break;
			case Action.Check:
				check = true;
				break;
			}

			string tempDirectory = "C:\\BackupTemp\\";
			if (Directory.Exists (tempDirectory)) {
				Directory.Delete (tempDirectory, true);
			}
			Directory.CreateDirectory (tempDirectory);

			string defaultAgentFile = Path.Combine (tempDirectory, "Backup_Client_for_Windows.exe");
			string msiFile = Path.Combine (tempDirectory, "BackupClient64.msi");

			if (setup && backupAgent == null) {

				Console.WriteLine (String.Format ("Downloading the Backup Client for Windows to '{0}'", defaultAgentFile));
				using (WebClient webClient = new WebClient ()) {
					try {
						webClient.DownloadFile (AGENT_DOWNLOAD_ADDRESS, defaultAgentFile);
					} catch (Exception e) {
						Console.WriteLine (String.Format ("Error when downloading client, please try again. {0}", e.Message));
						return;
					}
				}
				Console.WriteLine ("Download Complete");

				bool cont = unpackageBackupAgent (defaultAgentFile, tempDirectory);
				if (!cont) {
					return;
				}

			} else if(install) {

				// If we do not download the agent, we must be supplied it. Either the .msi or the .exe it can be extracted from
				if (string.IsNullOrEmpty (backupAgent)) {
					Console.WriteLine ("You cannot install the client without specifing either the .exe or .msi file");
					return;
				}

				if(File.Exists(backupAgent)){
					if (backupAgent.EndsWith (".msi")) {
						msiFile = backupAgent;
					} else {
						bool cont = unpackageBackupAgent (backupAgent, tempDirectory);
						if (!cont) {
							return;
						}
					}
				}else{
					Console.WriteLine ("Invalid file path");
					return;
				}

			}
				
			string managementURL = "";
			string username = "";
			string password = "";

			if (register || details || check) {
				bool success = readMetadata (ref managementURL, ref username, ref password);

				if (!success) {
					Console.WriteLine ("Failed to retreive the configuration details.");
					return;
				}

				if (details) {
					Console.WriteLine ("Backup Service Configuration");
					Console.WriteLine ("Management URL " + managementURL);
					Console.WriteLine ("Username " + username);
					Console.WriteLine ("Password " + password);
				}
			}

			if (install) {
				string msiLog = Path.Combine (tempDirectory, "Log.log");

				if (File.Exists (msiLog)) {
					File.Delete (msiLog);
				}
				FileStream msiFileStream = File.Create (msiLog);
				msiFileStream.Close ();

				if (!File.Exists (msiFile)) {
					msiFile = Path.Combine (tempDirectory, "BackupClient.msi");
				}

				string[] formatArgs = new string[register ? 5 : 2];
				formatArgs [0] = msiFile;
				formatArgs [1] = msiLog;
				if (register) {
					formatArgs [2] = managementURL;
					formatArgs [3] = username;
					formatArgs [4] = password;
				}

				string installArguments = String.Format (
					                          "/i \"{0}\" " +
					                          "/qb /l*v \"{1}\" " +
					                          "REBOOT=ReallySuppress " +
					                          "ENABLE_COMMON_ERRORS=\"1\" " +
					                          "ADDLOCAL=\"VssProviderUpgradeInvisible,TrayMonitor,MmsMspComponents,BackupAndRecoveryAgent\" " +
					                          "ALLUSERS=2 " +
					                          "CREATE_NEW_ACCOUNT=\"1\" " +
					                          "ACEP_AGREEMENT=\"0\" " +
					                          (register ? "RAIN_ADDRESS=\"{2}\" " : "") +
					                          (register ? "LOGIN_FOR_RAIN=\"{3}\" " : "") +
					                          (register ? "PASSWORD_FOR_RAIN=\"{4}\" " : "") +
					                          "MMS_MUST_BE_REGISTERED=0", 
					                          formatArgs);

				clean = invokeCommand ("msiexec", installArguments);
			} else if (register) {

				Console.WriteLine ("Registering machine with backup service");

				string registerApplication = "C:\\Program Files (x86)\\BackupClient\\BackupAndRecovery\\register_msp_mms.exe";
				if (!File.Exists (registerApplication)) {
					registerApplication = "C:\\Program Files\\BackupClient\\BackupAndRecovery\\register_msp_mms.exe";
					if (!File.Exists (registerApplication)) {
						Console.WriteLine ("Cannot find the register_msp_mms.exe normally in the BackupClient/BackupAndRecovery program file, please confirm location or hit enter to quit");
						registerApplication = Console.ReadLine ();
						if (registerApplication == null || registerApplication.Length == 0) {
							Console.WriteLine ("Quitting");
							return;
						}
						if (!File.Exists (registerApplication)) {
							Console.WriteLine ("Invalid file path, quitting");
							return;
						}
					}
				}

				string registerArgs = String.Format ("register {0} {1} {2}", managementURL, username, password);
				invokeCommand (registerApplication, registerArgs);

				Console.WriteLine ("Complete");
			}else if(check){
				Console.WriteLine ("Checking machine registration with backup service");

				string registerApplication = "C:\\Program Files (x86)\\BackupClient\\BackupAndRecovery\\register_msp_mms.exe";
				if (!File.Exists (registerApplication)) {
					registerApplication = "C:\\Program Files\\BackupClient\\BackupAndRecovery\\register_msp_mms.exe";
					if (!File.Exists (registerApplication)) {
						Console.WriteLine ("Cannot find the register_msp_mms.exe normally in the BackupClient/BackupAndRecovery program file, please confirm location or hit enter to quit");
						registerApplication = Console.ReadLine ();
						if (registerApplication == null || registerApplication.Length == 0) {
							Console.WriteLine ("Quitting");
							return;
						}
						if (!File.Exists (registerApplication)) {
							Console.WriteLine ("Invalid file path, quitting");
							return;
						}
					}
				}

				string registerArgs = String.Format ("check {0} {1} {2}", managementURL, username, password);
				invokeCommand (registerApplication, registerArgs);

				Console.WriteLine ("Complete");
			}

			if (clean) {
				Directory.Delete (tempDirectory, true);
			}
			Console.WriteLine ("Complete");
		}

		#endregion
		#region Helper Methods.

		private static bool unpackageBackupAgent(string agentFile, string tempDirectory){
			Console.WriteLine ("Extracting required files from backup client executable");

			string application = "C:\\Program Files (x86)\\7-Zip\\7z.exe";
			if (!File.Exists (application)) {
				application = "C:\\Program Files\\7-Zip\\7z.exe";
				if (!File.Exists (application)) {
					Console.WriteLine ("This application requires the archive tool 7z to extract the required .msi from the Backup Client for Windows executable");
					Console.WriteLine ("Please enter full path and filename to 7x.exe, alternatively hit enter to quit.");
					Console.WriteLine ("If you do not want to install 7z then you can extract the backupClient.msi from the executable and pass it as an argument for the 'install' action");
					application = Console.ReadLine ();
					if (application == null || application.Length == 0) {
						Console.WriteLine ("Quitting");
						return false;
					}
					if (!File.Exists (application)) {
						Console.WriteLine ("Invalid file path, quitting");
						return false;
					}
				}
			}

			String arguments = String.Format ("e {0} -o{1} *.msi", agentFile, tempDirectory);
			invokeCommand (application, arguments);

			Console.WriteLine ("Complete");
			return true;
		}

		private static bool readMetadata(ref string url, ref string username, ref string password){

			try {
				HttpWebRequest webRequest = (HttpWebRequest)HttpWebRequest.Create ("http://169.254.169.254/metadata");
				webRequest.Accept = "*/*";
				webRequest.Method = "GET";
			
				HttpWebResponse httpResponse = (HttpWebResponse)webRequest.GetResponse ();
			
				string xmlString = "";
				using (StreamReader streamReader = new StreamReader (httpResponse.GetResponseStream ())) {
					xmlString = streamReader.ReadToEnd ();
				}
			
				XmlDocument doc = new XmlDocument ();
				doc.LoadXml (xmlString);
			
				XmlNode fcoAcronisNode = doc.SelectSingleNode ("CONFIG/meta/server/system/fco-acronis");
				if (fcoAcronisNode == null) {
					Console.WriteLine ("No FCO/Acronis configuration data found");
					return false;
				}

				url = fcoAcronisNode.SelectSingleNode ("url").InnerText;
				username = fcoAcronisNode.SelectSingleNode ("username").InnerText;
				password = fcoAcronisNode.SelectSingleNode ("password").InnerText;

				return true;
			} catch {
				return false;
			}
		}

		private static bool invokeCommand(string file, string arguments){
			ProcessStartInfo processStartInfo = new ProcessStartInfo (file, arguments);
			processStartInfo.RedirectStandardOutput = true;
			processStartInfo.RedirectStandardError = true;
			processStartInfo.UseShellExecute = false;
			processStartInfo.WindowStyle = ProcessWindowStyle.Hidden;

			string output, error;

			Process process = Process.Start(processStartInfo);

			using (StreamReader streamReader = process.StandardOutput)
			{
				output = streamReader.ReadToEnd();
			}

			using (StreamReader streamReader = process.StandardError)
			{
				error = streamReader.ReadToEnd();
			}

			Console.WriteLine("The following output was detected:");
			Console.WriteLine(output);

			if (!string.IsNullOrEmpty(error))
			{
				Console.WriteLine("The following error was detected:");
				Console.WriteLine(error);
				return false;
			}

			return true;
		}

		#endregion
	}
}