'	(c) 2015 Flexiant Limited
'
'	This script will download the Backup Client for Windows and retrieve the username and
'	password necessary for registering the machine with the backup service
'
'	Input to this script will be the type of action that is to be performed, 
'	with additional parameters depending on the invoked action
'
'	download - This will download the Backup Client for Windows, and save it in the folder specified by the second parameter. 
'	 			If a folder is not specified, the file will be downloaded to the same folder as this script
'	information - This will retrive and display the configuration information used when registering the machine with the backup service
'
'	Example 1.
'	cscript.exe fco-acronis-setup-script.vbs download C://
'
'	Example 2.
'	cscript.exe fco-acronis-setup-script.vbs information
'

Option Explicit

If WScript.Arguments.Count = 0 Then
    WScript.Echo "Missing action parameter"
    WScript.Quit
End If

Dim action : action = WScript.Arguments(0)

If(action = "download") Then
	Dim saveFile : saveFile = "Backup_Client_for_Windows.exe"

	If WScript.Arguments.Count > 1 Then
    	saveFile = WScript.Arguments(1) & "/Backup_Client_for_Windows.exe"
	End If

	Dim serverXMLHTTP
	Set serverXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP")
	serverXMLHTTP.open "GET", "http://dl.managed-protection.com/u/baas/Backup_Client_for_Windows_en-US.exe", false
	serverXMLHTTP.setOption 2, 13056
	serverXMLHTTP.send()

	If serverXMLHTTP.Status = 200 Then
		Dim adodbStream
		Set adodbStream = CreateObject("ADODB.Stream")
		adodbStream.Open
		adodbStream.Type = 1
 
		adodbStream.Write serverXMLHTTP.ResponseBody
		adodbStream.Position = 0
 
 		Dim fileSystemObject
		Set fileSystemObject = Createobject("Scripting.FileSystemObject")
		If fileSystemObject.FileExists(saveFile) Then 
			fileSystemObject.DeleteFile saveFile
		End If
		Set fileSystemObject = Nothing
 
		adodbStream.SaveToFile saveFile
		adodbStream.Close
		Set adodbStream = Nothing
	End if
	Set serverXMLHTTP = Nothing
	
ElseIf(action = "information") Then

	Function getConfig()
		Dim serverXMLHTTP
		Set serverXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP")
		serverXMLHTTP.open "GET", "http://169.254.169.254/metadata", false
		serverXMLHTTP.setOption 2, 13056
		serverXMLHTTP.send ""

		getConfig = serverXMLHTTP.responseText
		Set serverXMLHTTP = nothing
	End Function

	Dim xmlDoc
	Set xmlDoc = CreateObject("Microsoft.XMLDOM")

	xmlDoc.async = false
	
	If xmlDoc.loadXML(getConfig) Then
		
		Dim fcoAcronisNode : fcoAcronisNode = xmlDoc.selectSingleNode("CONFIG/meta/server/system/fco-acronis")
	
		If (fcoAcronisNode Is Nothing) Then
			Wscript.Echo "No FCO/Acronis configuration data found"
		Else
			Dim url : url = fcoAcronisNode.selectSingleNode("url").text
			Dim username : username = fcoAcronisNode.selectSingleNode("username").text
			Dim password : password = fcoAcronisNode.selectSingleNode("password").text
			
			Script.Echo "Backup Service Configuration"
			Script.Echo "Management URL " & url
			Script.Echo "Username " & username
			Script.Echo "Password " & password
		End If
		
		Set fcoAcronisNode = Nothing
	Else
		WScript.Echo "No configuration data available"
	End If
	
	xmlDoc = Nothing
Else
	WScript.Echo "Invalid action " & action
End If

WScript.Echo "Complete"
WScript.Quit