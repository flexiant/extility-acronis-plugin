--[[
FCO Acronis Plugin
© 2015 Flexiant Ltd

This FDL code block defines a configuration provider, and billing method,
that allows the use of Acronis BaaS within FCO

{"FDLINFO":{"NAME":"Acronis Plugin","VERSION":"1.0.0"}}
]]

function register()
  return { "acronis_backup_provider", "acronis_server_billing" }
end

function init()

  local subJobs = {};

  local adminAPI = new("AdminAPI", "5.0");
  
  local linuxBlobUUID = getLinuxScriptBlobUUID();
  local blob = adminAPI:getResource(linuxBlobUUID, false);
  if(blob ~= nil) then
    if(blob:isPublicResource() == false) then
      blob:setPublicResource(true)
      local job = adminAPI:modifyBlob(blob, nil)
      if(job ~= nil) then
        table.insert(subJobs, job:getResourceUUID());
      end
    end
  end

  local windowsBlobUUID = getWindowExecutableBlobUUID();
  local blob = adminAPI:getResource(windowsBlobUUID, false);
  if(blob ~= nil) then
    if(blob:isPublicResource() == false) then
      blob:setPublicResource(true)
      local job = adminAPI:modifyBlob(blob, nil)
      if(job ~= nil) then
        table.insert(subJobs, job:getResourceUUID());
      end
    end
  end

  return { jobs=subJobs }

end

--[[ Configuration Provider ]]
function acronis_backup_provider()
  return{
    ref="acronis_backup_provider",
    name="#__ACRONIS_BACKUP_NAME",
    description="#__ACRONIS_BACKUP_DESCRIPTION",
    providerType="ACRONIS_BACKUP",
    providerGroup="FCO_EXTENSION",
    api="CONFIG_PROVIDER",
    version=1,
    measurementFunctions={"server_measurement_function"},
    triggerFunctions={
      "post_job_state_change_trigger",
      "pre_server_metadata_update_trigger",
      "post_create_server_trigger",
      "post_server_state_change_trigger",
      "pre_create_server_trigger",
      "pre_modify_server_trigger",
      "scheduled_trigger" 
    },
    resourceConfigs={
      {
        associatedResourceType="BILLING_ENTITY",
        useWithBilling=false,
        productComponentTypes={
          {
            resourceName="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_NAME",
            referenceField="BE_SETTINGS",
            configurableList={
              {
                key="serviceURL",
                name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_SERVICE_URL_NAME",
                description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_SERVICE_URL_DESCRIPTION",
                readOnly=true
              },
              {
                key="username",
                name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_NAME",
                description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_DESCRIPTION",
                readOnly=true
              },
              {
                key = "backupGroup",
                name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_GROUP_NAME",
                description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_GROUP_DESCRIPTION",
                readOnly = true
              }
            },
            actionFunctions={
              {
                key="setup_account",
                name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_LINK_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_LINK_ACCOUNT_DESCRIPTION",
                returnType="FUNCTION",
                executionFunction="action_function_link_account",
                order=0,
                parameters={
                  {
                    key="serviceURL",
                    name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_SERVICE_URL_NAME",
                    description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_SERVICE_URL_DESCRIPTION",
                    required=true,
                    defaultValue="https://baas.acronis.com",
                    validator={
                      validatorType="REGEX",
                      validateString="\\b(https?|ftp|file|ezos)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]",
                      errorMessage="VALIDATION_TYPE_IP_ADDR"
                    },
                  },
                  {
                    key="username",
                    name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_NAME",
                    description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_DESCRIPTION",
                    required=true
                  },
                  {
                    key="password",
                    name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_PASSWORD_NAME",
                    description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_PASSWORD_DESCRIPTION",
                    validator={
                      validatorType="PASSWORD"
                    },
                    required=true
                  },
                  {
                    key = "backupGroup",
                    name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_GROUP_NAME",
                    description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_GROUP_DESCRIPTION",
                    required = true
                  }
                }
              },
              {
                key="unlink_account",
                name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_UNLINK_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_UNLINK_ACCOUNT_DESCRIPTION",
                returnType="FUNCTION",
                executionFunction="action_function_unlink_account",
                order=1,
                parameters={
                  {
                    key="confirm",
                    name="Confirm Action",
                    description="Hidden field use to display confirmation dialogue in UI",
                    required=false,
                    hidden=true,
                    validator={
                      validatorType="ENUM",
                      validateString="TRUE"
                    }
                  }
                }
              }
            }
          }
        }
      },
      {
        associatedResourceType="CUSTOMER",
        useWithBilling=false,
        productComponentTypes={
          {
            resourceName="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_NAME",
            referenceField="CUSTOMER_SETTINGS",
            configurableList={
              {
                key="acronisID",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ID_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ID_DESCRIPTION",
                readOnly=true
              }
            },
            actionFunctions={
              {
                key="login",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_ACCOUNT_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_function_sigin",
                order=0,
                synchronous=true
              },
              {
                key="login_webrestore",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_function_signin_webrestore",
                order=1,
                synchronous=true
              },
              {
                key="display_details",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_DESCRIPTION",
                returnType="DIALOGUE",
                executionFunction="action_function_display_details",
                order=2,
                synchronous=true
              },
              {
                key="download_setup",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_download_setup_scripts",
                order=3,
                parameters={
                  {
                    key="osType",
                    name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_OS_TYPE_NAME",
                    description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_OS_TYPE_DESCRIPTION",
                    validator={
                      validatorType="ENUM",
                      validateString="#__ACRONIS_BACKUP_OS_TYPE_LINUX,#__ACRONIS_BACKUP_OS_TYPE_WINDOWS"
                    },
                    required=true,
                    defaultValue="#__ACRONIS_BACKUP_OS_TYPE_LINUX"
                  }
                }
              }
            }
          }
        }
      },
      {
        associatedResourceType="SERVER",
        useWithBilling=true,
        productComponentTypes={
          {
            resourceName="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_NAME",
            referenceField="SERVER_SETTINGS",
            configurableList={
              {
                key="enabled",
                name="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_ENABLED_NAME",
                description="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_ENABLED_DESCRIPTION",
                validator={
                  validatorType="ENUM",
                  validatorString="TRUE,FALSE"
                },
                required=true
              },
              {
                key="retention",
                name="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_RETENTION_NAME",
                description="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_RETENTION_DESCRIPTION",
                validator={
                  validatorType="ENUM",
                  validatorString="#__ACRONIS_BACKUP_RETENTION_OPTION_1,#__ACRONIS_BACKUP_RETENTION_OPTION_2"
                },
                required=true
              },
              {
                key="frequency",
                name="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_FREQUENCY_NAME",
                description="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_FREQUENCY_DESCRIPTION",
                validator={
                  validatorType="ENUM",
                  validateString="2,4,6,12,24"
                },
                measureType="HOUR",
                required=true
              },
              {
                key="password",
                name="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_PASSWORD_NAME",
                description="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_PASSWORD_DESCRIPTION",
                validator={
                  validatorType="PASSWORD"
                },
                required=false,
                defaultText="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_PASSWORD_PLACEHOLDER",
                defaultValue=""
              }
            },
            actionFunctions={
              {
                key="login",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_ACCOUNT_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_function_sigin",
                order=0,
                synchronous=true
              },
              {
                key="login_webrestore",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_function_signin_webrestore",
                order=1,
                synchronous=true
              },
              {
                key="display_details",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_DESCRIPTION",
                returnType="DIALOGUE",
                executionFunction="action_function_display_details",
                order=2,
                synchronous=true
              },
              {
                key="download_setup",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_download_setup_scripts",
                order=3,
                parameters={
                  {
                    key="osType",
                    name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_OS_TYPE_NAME",
                    description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DOWNLOAD_SETUP_OS_TYPE_DESCRIPTION",
                    validator={
                      validatorType="ENUM",
                      validateString="#__ACRONIS_BACKUP_OS_TYPE_LINUX,#__ACRONIS_BACKUP_OS_TYPE_WINDOWS"
                    },
                    required=true,
                    defaultValue="#__ACRONIS_BACKUP_OS_TYPE_LINUX"
                  }
                }
              },
              --[[ TODO : remove this action, used only for debug
              {
                key="delete_all_backups",
                name="Delete all backups",
                description="Delete all the backups for the given server",
                returnType="FUNCTION",
                executionFunction="action_delete_all_backups",
                order="10"
              }
              --]]
            }
          }
        }
      }
    }
  }
end

--[[ Acronis Server Billing Method ]]

function acronis_server_billing(p)
  if(p == nil) then
    return {
      ref="server_billing_function",
      name="#__ACRONIS_BACKUP_BILLING_METHOD_SERVER_NAME",
      description="#__ACRONIS_BACKUP_BILLING_METHOD_SERVER_DESCRIPTION",
      permittedPCT={"ACRONIS_BACKUP_SERVER_SETTINGS"},
      configuredValues={
        {
          key="charge_measurement_type",
          name="#__BILLING_KEY_CHARGE_MEASUREMENT_TYPE_NAME",
          description="#__BILLING_KEY_CHARGE_MEASUREMENT_TYPE_DESCRIPTION",
          validator={validatorType="ENUM", validateString="GB,TB"},
          measureType="NUMERIC",
          required=true
        },
        {
          key="repeat_units",
          name="#__BILLING_KEY_REPEAT_UNITS_NAME",
          description="#__BILLING_KEY_REPEAT_UNITS_DESCRIPTION",
          measureType="UNIT",
          validator={validatorType="NUMERIC_DOUBLE"},
          required=true
        }
      },
      api="BILLING",
      version=1
    }
  end

  local units=0;

  local measureType=nil;
  local measureSize=nil;

  local measureHash=p.measureComp:getMAXMeasureBetween(p.lastBillingTime, p.currentBillingTime, "providers.ACRONIS_BACKUP.acronisUsage");
  if(measureHash ~= nil and measureHash:size()) then
    local usageValue=measureHash:get("providers.ACRONIS_BACKUP.acronisUsage");
    if(usageValue ~= nil) then
      measureType=usageValue:getMeasurementType():name();
      measureSize=usageValue:getMeasurement();
    end
  end

  if(measureSize == nil or measureType == nil) then
    return { { units=0, description=translate.string("LBL_NO_CHARGE") } };
  end

  local chargeUnits=nil;
  local chargeMeasureType=nil;

  local chargeMeasureTypeValue=p.billingComp:getBillingValue("charge_measurement_type");
  if(chargeMeasureTypeValue ~= nil) then
    chargeMeasureType=chargeMeasureTypeValue:getValue();
  end
  local chargeUnitsValue=p.billingComp:getBillingValue("repeat_units");
  if(chargeUnitsValue ~= nil) then
    chargeUnits=tonumber(chargeUnitsValue:getValue());
  end

  if(chargeUnits == nil or chargeMeasureType == nil) then
    return { { units=0, description=translate.string("LBL_NO_CHARGE") } };
  end

  units=chargeUnits * tonumber(measureSize) * (convert_mtype(measureType,chargeMeasureType)) * -1 * p.billingFactor;

  local measureSizeString = new("Utils"):roundNumber(tonumber(measureSize), 5);

  return { { units=units, description=translate.string("#__ACRONIS_BACKUP_BILLING_DESC_BACKUP_CHARGE", measureSizeString, translate.measureType(measureType)) } }
end

--[[ Measurement Functions ]]

function server_measurement_function(p)
  if (p == nil) then
    return {
      ref="server_measurement_function",
      name="Acronis Measurement Function",
      description="Measurement function to get disk usage from Acronis backup system",
      measuredValues={
        {
          key="acronisUsage",
          name="Acronis usage measurement",
          description="The disk usage measurement from Acronis, in GB",
          measureType="GB"
        }
      },
      associatedType="SERVER",
      api="MEASURE",
      version=1
    }
  end

  local acronisUsage=0;
  local server=p.resource;

  local serverValues=getServerValues(server);

  local billingEntityValues=getBillingEntityValues(server:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    return { { key="acronisUsage", value=acronisUsage } }
  end

  local json=new("JSON");

  local def={ enable_cookie=true, ssl_verify=true }
  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection(def)

  local loginResult=loginToAcronis(connection, billingEntityValues.serviceURL, billingEntityValues.username, billingEntityValues.password)
  if(loginResult == nil or loginResult.url == nil) then
    return { { key="acronisUsage", value=acronisUsage } }
  end

  local backupAccess=accessBackup(connection, loginResult.url, billingEntityValues.groupID);
  if(backupAccess == nil) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Failed to get backup access to measure server " .. serverValues.uuid);
    syslog.closelog();
    logout(connection, loginResult.url);
    return { { key="acronisUsage", value=acronisUsage } }
  end

  local machine=getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress)
  if(machine == nil) then
    logout(connection, loginResult.url);
    return { { key="acronisUsage", value=acronisUsage } }
  end

  local backupPlanID = getBackupPlanID(connection, backupAccess.url, backupAccess.hostName, machine.id, false);

  if(serverValues.enabled) then
    -- Backup is enabled

    if(backupPlanID == nil) then
      -- Does not have backup plan
      local success = createBackupPlan(connection, backupAccess.url, backupAccess.hostName, "Backup-"..server:getCustomerName().."-"..serverValues.ipAddress, machine.id, serverValues.retention, serverValues.frequency, serverValues.password, false);
      if(success) then
        local syslog = new("syslog");
        syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
        syslog.syslog("LOG_INFO", "Backup plan created for machine " .. serverValues.ipAddress);
        syslog.closelog();
      else
        local syslog = new("syslog");
        syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
        syslog.syslog("LOG_ERR", "Failed to create backup plan");
        syslog.closelog();
      end
    end

  elseif(backupPlanID ~= nil) then
    -- Backup is not enabled but we have a backup plan id, we need to delete it. We don't care about the result
    deleteBackupPlan(connection, backupAccess.url, backupAccess.hostName, backupPlanID)
  end

  if(machine.lastBackup ~= nil) then
    logout(connection, loginResult.url);

    local customerValues=getCustomerValues(server:getCustomerUUID());

     acronisUsage=getAcronisStorageUsage(billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword, machine.instanceID, false);
  end

  if(acronisUsage > 0.0) then

    local usageString = new("Utils"):roundNumber(acronisUsage, 5);

    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_INFO", "Acronis storage usage is: "..usageString.." GB for server "..serverValues.ipAddress.."");
    syslog.closelog();
  end

  logout(connection, loginResult.url);
  return { { key="acronisUsage", value=acronisUsage } }
end

--[[ End of Measurement Functions ]]
--[[ Trigger Functions ]]

function post_job_state_change_trigger(p)
  if(p == nil) then
    return{
      ref="acronis_delete_trigger",
      name="Customer Job State Change Trigger",
      description="Job state change trigger for customer create and delete",
      priority=0,
      triggerType="POST_JOB_STATE_CHANGE",
      triggerOptions={"SUCCESSFUL"},
      api="TRIGGER",
      version=1
    }
  end
  -- This will be called for every customer that belongs to a BE that has been setup to use the acronis plugin

  if(p.input:getItemType():name() ~= "CUSTOMER") then
    return { exitState="CONTINUE" }
  end

  if(p.input:getJobType():name() == "CREATE_CUSTOMER") then
    -- Create Acronis account for Customer as BE is setup to use Acronis plugin.
    local customerValues=getCustomerValues(p.input:getItemUUID());

    if(customerValues.success) then
      local billingEntityValues=getBillingEntityValues(customerValues.beuuid);
      if(billingEntityValues.success == false) then
        local syslog = new("syslog");
        syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
        syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
        syslog.closelog();
        return { exitState="CONTINUE" }
      end

      local simplehttp=new("simplehttp");
      local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

      local loginResult=loginToAcronis(connection, billingEntityValues.serviceURL, billingEntityValues.username, billingEntityValues.password)
      if(loginResult == nil or loginResult.url == nil) then
        return { exitState="CONTINUE" }
      end

      local createUserAccount=createUserAccount(connection, loginResult.url, customerValues, billingEntityValues.password, billingEntityValues.groupID);
      logout(connection, loginResult.url);

      if(createUserAccount == nil) then
        return { exitState="CONTINUE" }
      end

      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      if(createUserAccount) then
        syslog.syslog("LOG_INFO", "New user account created on Acronis");
      else
        syslog.syslog("LOG_INFO", "User account exists on Acronis");
      end
      syslog.closelog();

      return { exitState="SUCCESS" }
    end

  elseif(p.input:getJobType():name() == "DELETE_RESOURCE") then

    local customerValues=getCustomerValues(p.input:getItemUUID());

    -- Delete customer data from the datastore after getting customer values as the resource has been deleted anyway
    dataStore:resetPrivateDataMap(customerValues.uuid, nil);

    if(customerValues.acronisID == nil or #customerValues.acronisID == 0) then
      return { exitState="CONTINUE" }
    end

    local billingEntityValues=getBillingEntityValues(customerValues.beuuid);

    if(billingEntityValues.success) then
      local simplehttp=new("simplehttp");
      local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

      local loginResult=loginToAcronis(connection, billingEntityValues.serviceURL, billingEntityValues.username, billingEntityValues.password)
      if(loginResult == nil or loginResult.url == nil) then
        return { exitState="CONTINUE" }
      end

      local success, apiResult = deleteUserAccount(connection, loginResult.url, billingEntityValues.groupID, customerValues.acronisID);
      logout(connection, loginResult.url);

      if(success == nil) then
        local syslog = new("syslog");
        syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
        syslog.syslog("LOG_ERR", "Delete user acccount failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
        syslog.closelog();
        return { returnCode="CONTINUE" }
      end

      if(success) then
        local syslog = new("syslog");
        syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
        syslog.syslog("LOG_INFO", "Acronis user account deleted");
        syslog.closelog();
        return { exitState="SUCCESS" }
      else
        local syslog = new("syslog");
        syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
        syslog.syslog("LOG_INFO", "Acronis user account was not deleted");
        syslog.closelog();
        return { exitState="CONTINUE" }
      end
    end
  end

  return { exitState="CONTINUE" }
end

function pre_create_server_trigger(p)
  if (p == nil) then
    return {
      ref="pre_create_server_trigger",
      name="Clear backup encryption password",
      description="Pre Server create trigger that retrieve the encyption password set on the server and hide it from the API while making it available to FDL",
      triggerType="PRE_CREATE",
      triggerOptions={ "SERVER" },
      api="TRIGGER",
      version=1
    }
  end

  preServerCreate(p.input);

  return { exitState="CONTINUE" }
end

function post_create_server_trigger(p)
  if (p == nil) then
    return {
      ref="post_create_server_trigger",
      name="Create Acronis Account",
      description="Post Server create trigger that will create a Acronis account",
      triggerType="POST_CREATE",
      triggerOptions={ "SERVER" },
      api="TRIGGER",
      version=1
    }
  end

  postServerCreate(p.input);

  return { exitState="CONTINUE" }
end

function pre_server_metadata_update_trigger(p)
  if (p == nil) then
    return {
      ref="pre_server_metadata_update_trigger",
      name="Acronis Server Metadata Trigger",
      description="PRE_SERVER_METADATA_UPDATE trigger that will add the acronis",
      priority=-8000,
      triggerType="PRE_SERVER_METADATA_UPDATE",
      triggerOptions={ "ANY" },
      api="TRIGGER",
      version=1,
    }
  end

  local server = p.input[1];
  local document = p.input[2];

  local customerValues=getCustomerValues(server:getCustomerUUID());
  local billingEntityValues=getBillingEntityValues(server:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
    syslog.closelog();
    return { exitState="CONTINUE" }
  end

  if(customerValues.success) then
    local xmlHelper=new("FDLXMLHelper");
    local serverSystemNode=xmlHelper:findNode(document, "CONFIG/meta/server/system");

    local acronisNode = xmlHelper:addNode(document, serverSystemNode, "fco-acronis");

    local scriptDownloadLink = billingEntityValues.cpURL .. "/rest/open/current/resources/blob/" ..getLinuxScriptBlobUUID() .. "/download";
    xmlHelper:addTextNode(document, acronisNode, "linux-download", scriptDownloadLink);

    local windowsDownloadLink = billingEntityValues.cpURL .. "/rest/open/current/resources/blob/" .. getWindowExecutableBlobUUID() .. "/download";
    xmlHelper:addTextNode(document, acronisNode, "windows-download", windowsDownloadLink);
    xmlHelper:addTextNode(document, acronisNode, "url", billingEntityValues.serviceURL);
    xmlHelper:addTextNode(document, acronisNode, "username", customerValues.acronisUsername);
    xmlHelper:addTextNode(document, acronisNode, "password", customerValues.acronisPassword);

    local cloudInit = "";
    --[[
    -- This could enable it for Debian, but breaks Ubuntu
    cloudInit = cloudInit .. "packages:\n";
    cloudInit = cloudInit .. " - curl\n\n";
    ]]
    cloudInit = cloudInit .. "bootcmd:\n";
    cloudInit = cloudInit .. " - curl -k -X GET " .. scriptDownloadLink .. " >> /tmp/linux-backup-setup-script.pl\n";
    cloudInit = cloudInit .. " - sudo test -e /usr/lib/Acronis/BackupAndRecovery/AmsRegisterHelper && sudo perl /tmp/linux-backup-setup-script.pl all || echo \"Backup first boot, will run setup script after boot complete.\" \n";
    cloudInit = cloudInit .. "runcmd:\n";
    cloudInit = cloudInit .. " - perl /tmp/linux-backup-setup-script.pl all\n";

    local runtimeNode = xmlHelper:findNode(document, "CONFIG/meta/runtime");
    local systemNode = xmlHelper:findNode(runtimeNode, "system");
    local userdataNode = nil;

    if(systemNode == nil) then
      systemNode = xmlHelper:addNode(document, runtimeNode, "system");
    else
      userdataNode = xmlHelper:findNode(systemNode, "userdata");
    end

    local cData = "";
    local boundary = "runtimemetadataboundary";

    if(userdataNode == nil) then
      cData = "Content-Type: multipart/mixed; boundary=\""..boundary.."\"\n";
      cData = cData.."MIME-Version: 1.0\n"
    else
      cData = userdataNode:getTextContent()
      xmlHelper:removeNode(systemNode, userdataNode)
    end

    cData = cData:gsub( "%-%-"..boundary.."%-%-", " \n")

    cData = cData.."\n--"..boundary.."\n"
    cData = cData.."Content-Type: text/cloud-config; charset=\"us-ascii\"\n"
    cData = cData.."MIME-Version: 1.0\n"
    cData = cData.."Content-Transfer-Encoding: 7bit\n"
    cData = cData.."Content-Disposition: attachment; filename=\"fco-backup.fake\"\n"
    cData = cData.."\n"

    cData = cData..cloudInit
    cData = cData.."--"..boundary.."--\n"

    xmlHelper:addCDataNode(document, systemNode, "userdata", cData)

    return { exitState="SUCCESS" }
  end

  return { exitState="CONTINUE" }
end

function post_server_state_change_trigger(p)
  if(p == nil) then
    return {
      ref="post_server_state_change_trigger",
      name="Acronis Server State Change Trigger",
      description="A Server State Change Trigger that focuses on when a server is put to DELETING state.",
      triggerType="POST_SERVER_STATE_CHANGE",
      triggerOptions={"DELETING"},
      api="TRIGGER",
      version=1,
    }
  end

  postServerDelete(p.input);

  return { exitState="CONTINUE" }
end

function pre_modify_server_trigger(p)

  if (p == nil) then
    return {
      ref="pre_modify_server_trigger",
      name="Modify Acronis Server",
      description="Pre Modify trigger for Servers that will clean-up acronis data if the PO was modified",
      triggerType="PRE_MODIFY",
      triggerOptions={ "SERVER" },
      api="TRIGGER",
      version=1
    }
  end

  local adminAPI = new("AdminAPI", "5.0");

  local updatedServer = p.input;
  if(updatedServer == nil) then
    return { exitState="CONTINUE" }
  end

  local currentServer = adminAPI:getResource(updatedServer:getResourceUUID(), true);
  if(currentServer == nil) then
    return { exitState="CONTINUE" }
  end

  if(currentServer:getProductOfferUUID() == updatedServer:getProductOfferUUID()) then
    if(doesProductOfferUseAcronis(adminAPI, updatedServer:getProductOfferUUID())) then

      local oldServerValues = getServerValues(currentServer);

      local oldConfig = currentServer:getProviderValues("ACRONIS_BACKUP");
      local oldRetention = oldConfig:get("retention");
      local oldFrequency = oldConfig:get("frequency");
      local oldPassword = oldServerValues.password;
      if(oldPassword == nil) then
        oldPassword = "";
      end

      local newConfig = updatedServer:getProviderValues("ACRONIS_BACKUP");
      local newRetention = newConfig:get("retention");
      local newFrequency = newConfig:get("frequency");
      local newPassword = newConfig:get("password");
      if(newPassword == nil) then
        newPassword = "";
      end

      if(#oldPassword > 0 and #newPassword == #oldPassword and oldPassword ~= newPassword)then
        -- Check if newPassword is the same as oldPassword or stars the same length as oldPassword
        local newPasswordAsStars = "";
        for i = 1, #oldPassword, 1 do
          newPasswordAsStars = newPasswordAsStars .. "*";
        end

        if(newPassword == oldPassword or newPassword == newPasswordAsStars) then
          newPassword = oldPassword;
          newConfig:put("password", newPassword);
        end
      end

      if(oldRetention ~= newRetention or oldFrequency ~= newFrequency or oldPassword ~= newPassword) then

        -- Delete old BackupPlan
        postServerDelete(currentServer);
        -- Update password in provider data if required
        preServerCreate(updatedServer);
      end
    end

    return { exitState="CONTINUE" }
  end

  if(doesProductOfferUseAcronis(adminAPI, currentServer:getProductOfferUUID())) then
    -- Changing from backup we need to delete any existing backup plans
    postServerDelete(currentServer);
  end

  if(doesProductOfferUseAcronis(adminAPI, updatedServer:getProductOfferUUID())) then
    -- Changing to backup we will need to add encryption password to datastore and create a backup account
    preServerCreate(updatedServer);
    postServerCreate(updatedServer);
  else
    -- If new PO is not backup we clear the backup information from providers
    updatedServer:getProviderValues():remove("ACRONIS_BACKUP");
  end

  return { exitState="CONTINUE" }
end

function scheduled_trigger(p)
  if(p == nil) then
    return{
      api="TRIGGER",
      version=1,
      ref="acronis_scheduled_trigger",
      name="Acronis Clean-up trigger",
      description="A scheduled trigger that will clean up the backups and machines on acronis for deleted servers",
      triggerType="SCHEDULED",
      triggerOptions={"ANY"},
      schedule={start={hour=22,minute=0,second=0},frequency={hours=24}}
    }
  end
  
  local simplehttp=new("simplehttp");

  local triggeredTime = p.input[1];
  local repeatFrequency = p.input[2];
  local currentTime = p.input[3];

  local adminAPI = new("AdminAPI", "5.0");
  local utils = new("Utils");
  local dateHelper = new("FDLDateHelper");

  local searchFilter = new("SearchFilter");
  searchFilter:addCondition(utils:createFilterCondition("resourceState", "IS_EQUAL_TO", "ACTIVE"));

  local queryLimit = new("QueryLimit");
  queryLimit:setLoadChildren(false);

  local beIterator = adminAPI:runListQuery(searchFilter, queryLimit, "BILLING_ENTITY");

  local connection = nil;

  while(beIterator:hasNext()) do
    local billingEntity = beIterator:next();

    local billingEntityValues = getBillingEntityValues(billingEntity);
    if(billingEntityValues.success) then

      connection=simplehttp.newConnection({enable_cookie=true, ssl_verify=true });
      local loginResult=loginToAcronis(connection, billingEntityValues.serviceURL, billingEntityValues.username, billingEntityValues.password);
      if(loginResult ~= nil and loginResult.url ~= nil) then
        local groupUsers=getGroupUsers(connection, loginResult.url, billingEntityValues.groupID, false);
        logout(connection, loginResult.url);

        if(groupUsers ~= nil) then
          for i = 1, #groupUsers, 1 do
            local user = groupUsers[i];

            if(billingEntityValues.uuid == user.billingEntityUUID) then

              local customerValues = getCustomerValues(user.customerUUID);

              connection=simplehttp.newConnection({enable_cookie=true, ssl_verify=true });
              local loginResult = loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword, false);
              if(loginResult ~= nil and loginResult.url ~= nil) then

                local backupAccess = accessBackup(connection, loginResult.url, "self", false);

                if(backupAccess ~= nil) then

                  -- Check if customer has valid acronis servers
                  local machines = getAllMachines(connection, backupAccess.url, backupAccess.hostName, false);
                  if(machines ~= nil) then

                    for j = 1, #machines, 1 do
                      local machine = machines[j];

                      local cleanUp = true;
                      
                      local hasBackups = false;

                      if(machine.lastBackup ~= nil) then
                        hasBackups = true;
                      
                        -- lastBackup format is not consistent with our expected formats, Z is show as +00:00 instead of +0000, We remove last : so the date is in expected format.
                        local backupString = machine.lastBackup;
                        backupString = string.gsub(backupString:reverse(), ":", "", 1):reverse();

                        local lastBackup = dateHelper:getTimestamp(backupString, "yyyy-MM-dd'T'HH:mm:ssZ");

                        local hoursDifference = ((((currentTime - lastBackup) / 1000) / 60) / 60);
                        if(hoursDifference < 24) then
                          cleanUp = false;
                        end
                      end
                      
                      if (cleanUp) then

                        -- Check if server has been deleted or is no longer using an acronis PO
                        searchFilter = new("SearchFilter");
                        searchFilter:addCondition(utils:createFilterCondition("productOffer.product.components.referenceField", "IS_EQUAL_TO", "ACRONIS_BACKUP_SERVER_SETTINGS"));
                        searchFilter:addCondition(utils:createFilterCondition("nics.ipAddresses.ipAddress", "IS_EQUAL_TO", machine.ipAddress));
                        searchFilter:addCondition(utils:createFilterCondition("customerUUID", "IS_EQUAL_TO", user.customerUUID));

                        queryLimit = new("QueryLimit");
                        queryLimit:setLoadChildren(false);
                        queryLimit:setMaxRecords(1);

                        local serverIterator = adminAPI:runListQuery(searchFilter, queryLimit, "SERVER");
                        if(serverIterator:hasNext()) then
                          cleanUp=false;
                        end
                        
                        local debug = false;

                        if(cleanUp)then
                          local deleteMachine = false;

                          if(hasBackups) then
                            deleteMachine = deleteBackups(connection, backupAccess.url, customerValues.acronisUsername, customerValues.acronisPassword, backupAccess.hostName, machine.subscriptionId, machine.id, debug);
                            
                            if(deleteMachine) then
                              local syslog = new("syslog");
                              syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
                              syslog.syslog("LOG_INFO", "Backups for machine " ..machine.ipAddress.." have been removed");
                              syslog.closelog();
                            else
                              local syslog = new("syslog");
                              syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
                              syslog.syslog("LOG_ERR", "Backups for machine " ..machine.ipAddress.." failed to be removed");
                              syslog.closelog();
                            end
                            
                          else
                            deleteMachine = true;
                          end

                          if(deleteMachine) then
                            
                            local result = deleteAcronisMachine(connection, backupAccess.url, backupAccess.hostName, machine.id, debug);

                            if(result) then
                              local syslog = new("syslog");
                              syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
                              syslog.syslog("LOG_INFO", "Machine " ..machine.ipAddress.." has been removed");
                              syslog.closelog();
                            else
                              local syslog = new("syslog");
                              syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
                              syslog.syslog("LOG_ERR", "Machine " ..machine.ipAddress.." failed to be removed");
                              syslog.closelog();
                            end
                            
                          end
                          
                        end -- no valid acronis/FCO server, do clean up
                      end -- check clean up needed
                    end -- machines for loop
                  end -- has machines
                end -- has backups access

                logout(connection, loginResult.url, false);
              end -- has customer login
            end -- user belongs to BE
          end -- groupUsers for loop
        end -- found users
      end -- has BE login
    end -- billingEntityValues.success
  end -- beIterator while loop

  return { exitState="SUCCESS" }
end

--[[ End of Trigger Functions ]]
--[[ Action Functions ]]

function action_function_link_account(p)

  local loginResult=nil;
  local apiResult=nil;

  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  loginResult, apiResult=loginToAcronis(connection, p.parameters.serviceURL, p.parameters.username, p.parameters.password, false);

  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SETUP_ACCOUNT_FAILED", " ") }
    else
      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SETUP_ACCOUNT_FAILED", apiResult.response) }
    end
  end

  logout(connection, loginResult.url);

  local dataStoreMap=new("Map");

  dataStoreMap:put("acronisGroupID", p.parameters.backupGroup);
  dataStoreMap:put("acronisUsername", p.parameters.username);
  dataStoreMap:put("acronisPassword", p.parameters.password);
  dataStoreMap:put("acronisServiceURL", p.parameters.serviceURL);
  dataStoreMap:put("acronisEmail", loginResult.user.email);

  dataStore:resetPrivateDataMap(p.resource:getResourceUUID(), dataStoreMap)

  -- Remove password as we do not want to store this in config values
  dataStoreMap:remove("acronisPassword");

  local adminAPI=new("AdminAPI", "5.0");
  local providerValues = new("Map");
  providerValues:put("serviceURL", p.parameters.serviceURL);
  providerValues:put("username", p.parameters.username);
  providerValues:put("backupGroup", p.parameters.backupGroup);
  adminAPI:updateConfigurationProviderValues(p.resource:getResourceUUID(), "ACRONIS_BACKUP", providerValues);

  local utils = new("Utils");

  return { returnCode="SUCCESSFUL", returnType="FUNCTION", returnContent=utils:createRefreshFunctionActionContent(true, translate.string("#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_LINK_ACCOUNT_MESSAGE"), "SUCCESS"); }
end

function action_function_unlink_account(p)

  dataStore:resetPrivateDataMap(p.resource:getResourceUUID(), nil)

  local adminAPI=new("AdminAPI", "5.0");
  adminAPI:updateConfigurationProviderValues(p.resource:getResourceUUID(), "ACRONIS_BACKUP", nil);

  local utils = new("Utils");

  return { returnCode="SUCCESSFUL", returnType="FUNCTION", returnContent=utils:createRefreshFunctionActionContent(true, translate.string("#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_UNLINK_ACCOUNT_MESSAGE"), "SUCCESS"); }

end

function action_function_sigin(p)

  local billingEntityValues=getBillingEntityValues(p.resource:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
  end

  local customerValues=nil;

  if(p.resource:getResourceType():name() == "CUSTOMER") then
    customerValues=getCustomerValues(p.resource);
  else
    customerValues=getCustomerValues(p.resource:getCustomerUUID());
  end

  if(customerValues.success == false or customerValues.exists == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis customer credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
  end

  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local loginResult=nil;
  local apiResult=nil;

  loginResult, apiResult=loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword, false);
  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      if(apiResult.response == nil or #apiResult.response == 0) then
        apiResult.response = translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED");
      end

      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local backupConnectionDetails = nil;
  apiResult=nil;

  backupConnectionDetails, apiResult=getBackupConnectionDetails(connection, loginResult.url, "self");
  logout(connection, loginResult.url);

  if(backupConnectionDetails == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      if(apiResult.response == nil or #apiResult.response == 0) then
        apiResult.response = translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED");
      end

      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local utils=new("Utils");

  return { returnCode="SUCCESSFUL", returnType="URL_POPUP", returnContent=utils:createURLActionContent("GET", backupConnectionDetails.sso, nil) }
end

function action_function_display_details(p)

  local billingEntityValues=getBillingEntityValues(p.resource:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_ERROR") }
  end

  local customerValues=nil;
  local serverValues=nil;

  if(p.resource:getResourceType():name() == "CUSTOMER") then
    customerValues=getCustomerValues(p.resource);
  else
    customerValues=getCustomerValues(p.resource:getCustomerUUID());
    serverValues=getServerValues(p.resource);
  end

  if(customerValues.success == false or customerValues.exists == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis customer credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_ERROR") }
  end

  local values = {
    {
      key="serviceURL",
      name=translate.string("#__ACRONIS_BACKUP_PCT_BE_SETTINGS_SERVICE_URL_NAME"),
      description=translate.string("#__ACRONIS_BACKUP_PCT_BE_SETTINGS_SERVICE_URL_DESCRIPTION"),
      readOnly=true,
      value=billingEntityValues.serviceURL
    },
    {
      key="acronisID",
      name=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ID_NAME"),
      description=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ID_DESCRIPTION"),
      readOnly=true,
      value=customerValues.acronisID
    },
    {
      key="username",
      name=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_USERNAME_NAME"),
      description=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_USERNAME_DESCRIPTION"),
      readOnly=true,
      value=customerValues.acronisUsername
    },
    {
      key="password",
      name=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_PASSWORD_NAME"),
      description=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_PASSWORD_DESCRIPTION"),
      readOnly=true,
      validator={
        validatorType="PASSWORD"
      },
      value=customerValues.acronisPassword
    }
  };


  if(serverValues ~= nil) then
    local registered = false;

    local simplehttp=new("simplehttp");
    local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

    local loginResult=nil;

    loginResult = loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword);
    if(loginResult ~= nil) then

      local backupAccess=nil;

      backupAccess = accessBackup(connection, loginResult.url, "self", false);
      if(backupAccess == nil) then
        logout(connection, loginResult.url);
      else

        local machine=getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress);
        logout(connection, loginResult.url);

        registered = machine ~= nil;
      end
    end

    local registeredString = translate.string("#__ACRONIS_BACKUP_REGISTRATION_INCOMPLETE");
    if(registered) then
      registeredString = translate.string("#__ACRONIS_BACKUP_REGISTRATION_COMPLETE");
    end

    table.insert(values, {
      key="registration",
      name=translate.string("#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_REGISTRATION_STATE_NAME"),
      description=translate.string("#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_REGISTRATION_STATE_DESCRIPTION"),
      readOnly=true,
      value=registeredString
    });

    table.insert(values, {
      key="encryption",
      name=translate.string("#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_PASSWORD_NAME"),
      description=translate.string("#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_PASSWORD_DESCRIPTION"),
      validator={
        validatorType="PASSWORD"
      },
      readOnly=true,
      defaultText=translate.string("#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_PASSWORD_PLACEHOLDER"),
      defaultValue="",
      value=serverValues.password
    });
  end

  table.insert(values, {
    key="linuxScript",
    name=translate.advanced("#__ACRONIS_BACKUP_X_SETUP_SCRIPT_NAME", "#__ACRONIS_BACKUP_OS_TYPE_LINUX"),
    description=translate.advanced("#__ACRONIS_BACKUP_X_SETUP_SCRIPT_DESCRIPTION", "#__ACRONIS_BACKUP_OS_TYPE_LINUX"),
    readOnly=true,
    value=getBlobDownloadlink(billingEntityValues.cpURL, getLinuxScriptBlobUUID(), "linux-backup-setup-script.pl")
  });

  table.insert(values, {
    key="windowsScript",
    name=translate.advanced("#__ACRONIS_BACKUP_X_SETUP_SCRIPT_NAME", "#__ACRONIS_BACKUP_OS_TYPE_WINDOWS"),
    description=translate.advanced("#__ACRONIS_BACKUP_X_SETUP_SCRIPT_DESCRIPTION", "#__ACRONIS_BACKUP_OS_TYPE_WINDOWS"),
    readOnly=true,
    value=getBlobDownloadlink(billingEntityValues.cpURL, getWindowExecutableBlobUUID(), "WindowsBackupSetup.exe")
  });

  local utils = new("Utils");
  local returnContent = utils:createDisplayDialogueActionContent(values, translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_NAME"), translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_MESSAGE"), "FONT_ICON_CIRCLE_INFO");

  return { returnCode="SUCCESSFUL", returnType="DIALOGUE", returnContent=returnContent }
end

function action_function_signin_webrestore(p)

  local billingEntityValues=getBillingEntityValues(p.resource:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
  end

  local customerValues=nil;

  if(p.resource:getResourceType():name() == "CUSTOMER") then
    customerValues=getCustomerValues(p.resource);
  else
    customerValues=getCustomerValues(p.resource:getCustomerUUID());
  end

  if(customerValues.success == false or customerValues.exists == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis customer credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
  end

  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local loginResult=nil;
  local apiResult=nil;

  loginResult, apiResult=loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword, false);
  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      if(apiResult.response == nil or #apiResult.response == 0) then
        apiResult.response = translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED");
      end

      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local backupConnectionDetails = nil;
  apiResult=nil;

  backupConnectionDetails, apiResult=accessBackup(connection, loginResult.url, "self", false);
  logout(connection, loginResult.url);

  if(backupConnectionDetails == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      if(apiResult.response == nil or #apiResult.response == 0) then
        apiResult.response = translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED");
      end

      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local webstoreConnectionDetails = nil;
  apiResult=nil;

  webstoreConnectionDetails, apiResult=getWebRestoreConnectionDetails(connection, backupConnectionDetails.url, customerValues.acronisUsername, customerValues.acronisPassword, false);
  logout(connection, loginResult.url);

  if(webstoreConnectionDetails == nil or webstoreConnectionDetails.sso == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      if(apiResult.response == nil or #apiResult.response == 0) then
        apiResult.response = translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED");
      end

      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local utils=new("Utils");

  return { returnCode="SUCCESSFUL", returnType="URL_POPUP", returnContent=utils:createURLActionContent("POST", webstoreConnectionDetails.sso, nil) }

end

function action_download_setup_scripts(p)

  local osType = p.parameters.osType;

  local blobUUID = nil;
  local filename = nil;

  if(osType == "#__ACRONIS_BACKUP_OS_TYPE_LINUX") then
    blobUUID = getLinuxScriptBlobUUID();
    filename = "linux-backup-setup-script.pl";
  elseif(osType == "#__ACRONIS_BACKUP_OS_TYPE_WINDOWS") then
    blobUUID = getWindowExecutableBlobUUID();
    filename = "WindowsBackupSetup.exe";
  end


  local adminAPI = new("AdminAPI", "5.0");
  local billingEntity = adminAPI:getResource(p.resource:getBillingEntityUUID(), false);
  if(billingEntity == nil) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Server's billing entity could not be found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
  end

  local url = billingEntity:getControlPanelURL() .. "/rest/open/current/resources/blob/" ..blobUUID .. "/download";

  local params = {};
  params.headers = {};
  params.headers["Content-Description"] = "File Transfer";
  params.headers["Content-Disposition"] = "inline; filename='".. filename .."'";

  local utils = new("Utils");

  return { returnCode="SUCCESSFUL", returnType="URL_POPUP", returnContent=utils:createURLActionContent("GET", url, params) }
end

function action_delete_all_backups(p)

  local billingEntityValues=getBillingEntityValues(p.resource:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_ERROR") }
  end

  local customerValues=getCustomerValues(p.resource:getCustomerUUID());
  local serverValues=getServerValues(p.resource);

  if(customerValues.success == false or customerValues.exists == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis customer credentials not found");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_DISPLAY_DETAILS_ERROR") }
  end
  
  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local loginResult=nil;
  local apiResult=nil;

  loginResult, apiResult=loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword, false);
  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorCode=401, errorString="Failed to get backup access for user" }
    else
      if(apiResult.response == nil or #apiResult.response == 0) then
        apiResult.response = "Failed to get backup access for user";
      end

      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end
  
  local backupAccess = accessBackup(connection, loginResult.url, "self", false);
  if(backupAccess == nil) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Failed to get backup access for user");
    syslog.closelog();
    logout(connection, loginResult.url);
    return { returnCode="FAILED", errorCode=401, errorString="Failed to get backup access for user" }
  end
  
  local machine=getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress);
  if(machine == nil) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Failed to get machine on backup service");
    syslog.closelog();
    logout(connection, loginResult.url);
    return { returnCode="FAILED", errorCode=502, errorString="Failed to get machine on backup service" }
  end
  
  local debug = true;

  local deleteMachine = deleteBackups(connection, backupAccess.url, customerValues.acronisUsername, customerValues.acronisPassword, backupAccess.hostName, machine.subscriptionId, machine.id, debug);
                            
  if(deleteMachine) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_INFO", "Backups for machine " ..serverValues.ipAddress.." have been removed");
    syslog.closelog();
  else
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Backups for machine " ..serverValues.ipAddress.." failed to be removed");
    syslog.closelog();
    return { returnCode="FAILED", errorCode=502, errorString="Failed to delete all backups for server" }
  end
  
  local utils = new("Utils");
  return { returnCode="SUCCESSFUL", returnType="FUNCTION", returnContent=utils:createRefreshFunctionActionContent(true, "Delete all backups for server successful", "SUCCESS"); }

end

--[[ End of Action Functions ]]
--[[ Helper functions ]]

function getServerValues(server)

  local providerValues=server:getProviderValues("ACRONIS_BACKUP");

  local enabledString=providerValues:get("enabled");
  local enabledBoolean=enabledString ~= nil and string.upper(enabledString) == "TRUE";

  local retentionString=providerValues:get("retention");
  if(retentionString == "#__ACRONIS_BACKUP_RETENTION_OPTION_2") then
    retentionString=30;
  else
    retentionString=-1;
  end

  local frequencyString=providerValues:get("frequency");
  if(frequencyString == nil) then
    frequencyString=0;
  end
  local frequencyNumber=tonumber(frequencyString);

  local passwordString="";
  local serverData = dataStore:getPrivateDataMap(server:getResourceUUID());
  if(serverData ~= nil) then
    passwordString=serverData:get("encryptionPassword");
  end

  local ipAddressString="";
  local serverNics=server:getNics();
  if(serverNics ~= nil and serverNics:size() > 0) then
    local ipAddresses=serverNics:get(0):getIpAddresses();
    if(ipAddresses ~= nil and ipAddresses:size() > 0) then
      ipAddressString=ipAddresses:get(0):getIpAddress();
    end
  end

  return{
    enabled=enabledBoolean,
    uuid=server:getResourceUUID(),
    retention=retentionString,
    frequency=frequencyNumber,
    password=passwordString,
    ipAddress=ipAddressString,
  }
end

function getBillingEntityValues(billingEntity)

  if(billingEntity == nil) then
    return{
      success=false
    }
  end

  local beUUID=billingEntity;

  local groupIDString=nil;
  local usernameString=nil;
  local passwordString=nil;
  local serviceURLString=nil;
  local success=false;
  local cpURLString=nil;
  local acronisEmailString=nil;

  if(type(billingEntity) ~= "string") then
    beUUID=billingEntity:getResourceUUID();
  else
    local adminAPI = new("AdminAPI", "5.0");
    billingEntity = adminAPI:getResource(beUUID, false);
  end

  if(billingEntity ~= nil) then
    cpURLString = billingEntity:getControlPanelURL();
  end

  local billingData = dataStore:getPrivateDataMap(beUUID);

  if(billingData ~= nil) then
    groupIDString=billingData:get("acronisGroupID")
    usernameString=billingData:get("acronisUsername")
    passwordString=billingData:get("acronisPassword")
    serviceURLString=billingData:get("acronisServiceURL");
    acronisEmailString=billingData:get("acronisEmail");

    success=usernameString ~= nil and passwordString ~= nil and groupIDString ~= nil and serviceURLString ~= nil;
  end

  return{
    groupID=groupIDString,
    uuid=beUUID,
    username=usernameString,
    password=passwordString,
    serviceURL=serviceURLString,
    cpURL=cpURLString,
    success=success,
    email=acronisEmailString,
  }
end

function getCustomerValues(customerUUID)

  local customer=nil;

  if(type(customerUUID) ~= "string") then
    customer=customerUUID;
    customerUUID=customerUUID:getResourceUUID()
  else
    local adminAPI=new("AdminAPI", "5.0");
    customer=adminAPI:getResource(customerUUID, true);
  end

  if(customer == nil) then
    return { success=false }
  end

  local address1=customer:getAddress():getAddress1();
  if(address1 == nil) then
    address1="";
  end
  local address2=customer:getAddress():getAddress2();
  if(address2 == nil) then
    address2="";
  end
  local address3=customer:getAddress():getAddress3();
  if(address3 == nil) then
    address3="";
  end
  local address4=customer:getAddress():getAddress4();
  if(address4 == nil) then
    address4="";
  end
  local address5=customer:getAddress():getAddress5();
  if(address5 == nil) then
    address5="";
  end
  local address6=customer:getAddress():getAddress6();
  if(address6 == nil) then
    address6="";
  end

  local firstnameString=customer:getResourceName();
  local lastnameString=customer:getBillingEntityName();
  local emailString="";
  local phoneString="";

  if(customer:getUsers() ~= nil and customer:getUsers():size() > 0) then
    local user=customer:getUsers():get(0);

    emailString=user:getEmail();

    phoneString=user:getMobileNumber();
    if(phoneString == nil) then
      phoneString=user:getDayTimeNumber();
      if(phoneString == nil) then
        phoneString=user:getEveningNumber();
        if(phoneString == nil) then
          phoneString="";
        end
      end
    end
  end

  local beUUID = customer:getBillingEntityUUID();

  local acronisUsername = beUUID.."."..customerUUID;
  local acronisEmail = beUUID.."."..customerUUID.."@acronis.flexiant.com";
  local acronisPassword = getRandomString(16);
  local acronisIDString="";
  local exists = false;

  local customerData = dataStore:getPrivateDataMap(customerUUID);
  if(customerData ~= nil) then
    if(customerData:containsKey("acronisPassword")) then
      acronisPassword = customerData:get("acronisPassword");
    end
    if(customerData:containsKey("acronisID")) then
      acronisIDString = customerData:get("acronisID");
      exists = acronisIDString ~= nil and #acronisIDString > 0;
    end
  end

  customerData = new("Map");
  customerData:put("acronisUsername", acronisUsername);
  customerData:put("acronisPassword", acronisPassword);
  customerData:put("acronisID", acronisIDString);

  dataStore:resetPrivateDataMap(customerUUID, customerData);

  return {
    success=true,
    uuid=customer:getResourceUUID(),
    customerName=customer:getResourceName(),
    beuuid=beUUID,
    address1=address1,
    address2=address2,
    address3=address3,
    address4=address4,
    address5=address5,
    address6=address6,
    acronisUsername=acronisUsername,
    acronisPassword=acronisPassword,
    acronisEmail=acronisEmail,
    acronisID=acronisIDString,
    firstname=firstnameString,
    lastname=lastnameString,
    phone=phoneString,
    email=emailString,
    status=customer:getStatus():name(),
    exists=exists
  }
end

function makeAPICall(connection, url, method, params, headers, debug)

  if(debug == nil) then
    debug = false;
  end

  local success=false;
  local statusCode="";
  local response="";

  connection:setURL(url);
  if(headers ~= nil) then
    connection:clearRequestHeaders();
    connection:setRequestHeaders(headers);
  end


  local responseHeaders=nil;

  if(debug) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_INFO", "Make API Call Request");
    syslog.syslog("LOG_INFO", method);
    syslog.syslog("LOG_INFO", url);
    syslog.syslog("LOG_INFO", params);
    syslog.closelog();
  end

  local apiFunction=function(value) response=response .. tostring(value); return true; end

  if(method == "GET") then
    if(connection:get(apiFunction)) then
      success=true;
      statusCode=connection:getHTTPStatusCode();
      responseHeaders=connection:getResponseHeaders();
    else
      success=false;
      statusCode, response=connection:getLastError();
    end
  elseif(method == "DELETE") then
    if(connection:delete(apiFunction)) then
      success=true;
      statusCode=connection:getHTTPStatusCode();
      responseHeaders=connection:getResponseHeaders();
    else
      success=false;
      statusCode, response=connection:getLastError();
    end
  elseif(method == "PUT") then
    if(connection:put(params, apiFunction)) then
      success=true;
      statusCode=connection:getHTTPStatusCode();
      responseHeaders=connection:getResponseHeaders();
    else
      success=false;
      statusCode, response=connection:getLastError();
    end
  elseif(method == "POST") then
    if(connection:post(params, apiFunction)) then
      success=true;
      statusCode=connection:getHTTPStatusCode();
      responseHeaders=connection:getResponseHeaders();
    else
      success=false;
      statusCode, response=connection:getLastError();
    end
  end

  if(statusCode ~= nil and (tonumber(statusCode) >= 300 or tonumber(statusCode) < 200)) then
    success=false;
    local cleanResponse=cleanErrorResponse(response, debug);

    if(cleanResponse == response and tonumber(statusCode) == 100) then
      -- Override for create backup plan that returns 100 regardless (apparently)
      success=true;
    end

    if(tonumber(statusCode) == 302) then
      success=true;
      cleanResponse = responseHeaders.Location;
    end

    response = cleanResponse;
  end

  if(debug) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_INFO", "Make API Call Result");
    syslog.syslog("LOG_INFO", tostring(success));
    syslog.syslog("LOG_INFO", tostring(statusCode));
    syslog.syslog("LOG_INFO",  tostring(response));
    syslog.closelog();
  end

  return{
    success=success,
    statusCode=statusCode,
    response=response,
    responseHeaders=responseHeaders
  }
end

function logout(connection, acronisURL, debug)

  makeAPICall(connection, acronisURL.."/api/1/logout/", "POST", "", nil, debug);

end

function loginToAcronis(connection, acronisURL, username, password, debug)

  if(debug == nil) then
    debug = false;
  end

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json";
  headers['Accept']="application/json";

  local urlEncodedUsername = username;
  urlEncodedUsername = string.gsub(username, "%+", "%%2B");

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/accounts/?login="..urlEncodedUsername, "GET", "", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Initial login failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  local acronisURLParams=json:decode(apiResult.response);

  if(acronisURLParams.server_url == nil) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERROR", "401 : Unauthorised");
    syslog.closelog();
    return nil, nil;
  end

  local loginCredentials=json:encode({ username=username, password=password });

  apiResult=makeAPICall(connection, acronisURLParams.server_url.."/api/1/login/", "POST", loginCredentials, headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Login failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  local acronisLoginParams=json:decode(apiResult.response);
  if(acronisLoginParams == nil or acronisLoginParams.id == nil) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERROR", "401 : Unauthorised");
    syslog.closelog();
    return nil, nil;
  end

  local data={
    url=acronisURLParams.server_url,
    group=tostring(acronisLoginParams.group.id),
    user={
      id=acronisLoginParams.id,
      access={
        read=acronisLoginParams.access_type == 1,
        branding=acronisLoginParams.access_type == 2,
        readWrite=acronisLoginParams.access_type == 4,
        full=acronisLoginParams.access_type == 7
      },
      firstname=acronisLoginParams.firstname,
      lastname=acronisLoginParams.lastname,
      email=acronisLoginParams.email,
      language=acronisLoginParams.language,
    }
  };

  return data, nil;
end

function createUserAccount(connection, acronisURL, customerData, password, groupID)

  local json=new("JSON");

  local userData=json:encode({
    address1=customerData.address1,
    address2=customerData.address2,
    city=customerData.address3,
    state=customerData.address4,
    zipcode=customerData.address5,
    country=customerData.address6,
    login=customerData.acronisUsername,
    email=customerData.acronisEmail,
    firstname=customerData.firstname,
    lastname=customerData.lastname,
    phone=customerData.phone,
    notifications_backup=0,
    notifications_management=0,
    privileges={
      quota_kind=1--[[,
      server_count=1,
      storage_size=1000,
      vm_count=1,
      workstation_count=1]]
    }
  });

  local headers={ };
  headers['Content-Type']="application/json";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/users/", "POST", userData, headers, false);
  if(apiResult.success == false) then
    if(apiResult.statusCode == 409) then
      -- Account already exists, return false.
      return false;
    end

    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Create backup user failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end

  local userAccount=json:decode(apiResult.response);
  if(userAccount.id == nil) then
    return false;
  else

    local customerProviderMap = dataStore:getPrivateDataMap(customerData.uuid);
    customerProviderMap:put("acronisID", tostring(userAccount.id));
    dataStore:resetPrivateDataMap(customerData.uuid, customerProviderMap);

    -- Update customer provider values as we have created customer account
    local adminAPI = new("AdminAPI");
    local providerValues = new("Map");
    providerValues:put("acronisID", tostring(userAccount.id));
    adminAPI:updateConfigurationProviderValues(customerData.uuid, "ACRONIS_BACKUP", providerValues);

    apiResult=makeAPICall(connection, acronisURL.."/api/1/actions/mail/activate/?email="..customerData.acronisEmail.."&login="..customerData.acronisUsername, "GET", "", headers, false);
    if(apiResult.success == false) then
      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      syslog.syslog("LOG_ERR", "Request activate account failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
      syslog.closelog();
      return nil, apiResult;
    end

    local userParams=json:decode(apiResult.response);
    apiResult=makeAPICall(connection, acronisURL.."/api/1/actions/activate/?token=" .. userParams.token, "POST", json:encode({password=customerData.acronisPassword}), headers, false);
    if(apiResult.success == false) then
      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      syslog.syslog("LOG_ERR", "Activate account failed : " ..  apiResult.statusCode .. " : " .. apiResult.response);
      syslog.closelog();
      return nil, apiResult;
    end

    return true;
  end

  return false;
end

function deleteUserAccount(connection, acronisURL, groupID, accountID)

  if(accountID == nil) then
    return false
  end

  local json=new("JSON")
  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult = makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/users/"..accountID, "GET", nil, headers, false);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get backup account failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  local user = json:decode(apiResult.response);
  user.status = 0;

  local accountVersion = user.version;

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/users/"..accountID.."?version="..accountVersion, "PUT", json:encode({status=0}), headers, false);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Disable backup account failed : " ..  apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end

  local result = json:decode(apiResult.response);
  accountVersion = result.version;

  apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/users/"..accountID.."?version="..accountVersion, "DELETE", "", headers, false);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Delete backup account failed : " ..  apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end

  return true;
end

function getBackupConnectionDetails(connection, acronisURL, groupID, debug)

  if(debug == nil) then
    debug = false;
  end

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/backupconsole", "GET", "", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get backup connection details failed : " ..  apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end

  local result=json:decode(apiResult.response);

  local backupURL=result.host;
  local backupToken=result.token;
  if(result.url ~= nil and (backupURL == nil or backupToken == nil)) then
    backupURL, backupToken=result.url:match("([^,]+)#access_token=([^,]+)");
  end

  return{
    sso = result.url,
    url = backupURL,
    token = backupToken
  }, nil;

end

function accessBackup(connection, acronisURL, groupID, debug)

  if(debug == nil) then
    debug = false;
  end

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  if(groupID == nil) then
    groupID="self";
  end

  local backupConnectionDetails = nil;
  local apiResult = nil;
  backupConnectionDetails, apiResult = getBackupConnectionDetails(connection, acronisURL, groupID, debug);
  if(backupConnectionDetails == nil or backupConnectionDetails.url == nil) then
    return nil, apiResult;
  end
  
  local apiResult = makeAPICall(connection, backupConnectionDetails.url.."/api/remote_connection", "POST", json:encode({access_token=backupConnectionDetails.token}), headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get backup connection failed : " ..  apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  local backupSession=json:decode(apiResult.response);

  return{
    hostName=backupSession.host_name,
    url=backupConnectionDetails.url,
    token=backupConnectionDetails.token,
    sso=backupConnectionDetails.sso
  }, nil
end

function getMachine(connection, backupAccessURL, hostName, ipAddress, debug)

  if(debug == nil) then
    debug = false;
  end

  if(backupAccessURL == nil or hostName == nil or ipAddress == nil) then
    return nil;
  end

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/subscriptions", "POST", "{}", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get subscription details failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  local response=json:decode(apiResult.response);

  apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/" .. hostName .. "/resources?subscriptionId=" .. response.id .. "&recursive=5", "GET", "", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get machine details failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  response=json:decode(apiResult.response);

  local data=response["data"]
  if(data == nil) then
    return nil;
  end

  for i=1, #data, 1 do
    local item=data[i];

    if(item.type == "machine" and item.ip ~= nil and item.ip[1] == ipAddress) then
      return{
        id=item.id,
        instanceID=item.instance_id,
        lastBackup=item.lastBackup,
        ipAddress=ipAddress
      }
    end
  end

  return nil
end

function deleteAcronisMachine(connection, backupAccessURL, hostName, machineID, debug)

  if(debug == nil) then
    debug = false;
  end

  if(backupAccessURL == nil or hostName == nil or machineID == nil) then
    return false;
  end

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/machines/"..machineID, "DELETE", "", headers, debug);
  if(apiResult.success == false) then
  
    if(tostring(apiResult.statusCode) == "404") then
      apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/machines/"..machineID, "DELETE", "", headers, debug);
    end
    
    if(apiResult.success == false) then
      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      syslog.syslog("LOG_ERR", "Delete machine failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
      syslog.closelog();
      return false, apiResult;
    end
  end

  return true;
end

function deleteBackups(connection, backupAccessURL, username, password, hostName, subscriptionId, machineID, debug, retryOn504)

  if(retryOn504 == nil) then
    retryOn504 = true;
  end

  if(backupAccessURL == nil or machineID == nil) then
    return false;
  end

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local success = true;
  local errorResult = nil;

  local params = {};
  params.resourceId = machineID;
  params.locationId = "Cloud";
  params.subscriptionId = subscriptionId;

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/archive_operations/delete_backups", "POST", new("JSON"):encode(params), headers, debug);
  if(apiResult.success == false) then
    
    if(apiResult.statusCode == 504) then
      -- This sometimes occurs when it is successful, we will still say it failed but wont print error, 
      if(retryOn504) then
        -- will try again and see if we get a 200 the next time if retryOn504 == true
        return deleteBackups(connection, backupAccessURL, username, password, hostName, subscriptionId, machineID, debug, false);
      end
    else
      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      syslog.syslog("LOG_ERR", "Delete backups failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
      syslog.closelog();
    end

    success = false;
    errorResult = apiResult;
  end

  return success, errorResult;

end

function createBackupPlan(connection, backupAccessURL, hostName, planName, machineID, backupRetention, backupFrequency, backupPassword, debug)

  -- TODO remove this next line
  debug = true;

  if(debug == nil) then
    debug = false;
  end

  planName = string.gsub(planName, " ", "_");

  local json=new("JSON")

  local nilPlaceholder = "null_placeholder";

  local timeIntervalNumber=backupFrequency * 60 * 60;
  if(backupFrequency > 12) then
    -- Can't have a backup frequency larger than 12
    timeIntervalNumber = 0;
  end

  local cleanUpTable={};
  if(backupRetention > 0) then
    cleanUpTable["value"]=backupRetention;
    cleanUpTable["type"]="days";
  end

  local archiveProtectionTable=nil;
  if(backupPassword ~= nil and #backupPassword > 0) then
    archiveProtectionTable={
      algorithm=3,
      password=backupPassword,
      usePassword=true
    }
  end

  local actionString = "createAndRun";
  if(debug) then
    actionString = "create";
  end

  local apiParams={
    action= actionString,
    data= {
      backupType= "gct::disks",
      id= nilPlaceholder,
      name= planName,
      options= {
        backupOptions= {
          archiveProtection=archiveProtectionTable,
          diskSpeed= {
            mode= "percent",
            value= 100
          },
          exclusions= {
            excludeSystem= false,
            excludeHidden= false,
            exclusionMasks= {}
          },
          networkSpeed= {
            mode= "percent",
            value= 100
          }
        }
      },
      origin= "centralized",
      route= {
        stages= {
          {
            cleanUpIfNoSpace= false,
            destinationKind= "online",
            maintenanceWindow=nilPlaceholder,
            rules= {
              {
                afterBackup=true,
                backupCountUpperLimit=0,
                backupSetIndex=nilPlaceholder,
                backupUpperLimitSize=0,
                beforeBackup=false,
                consolidateBackup=false,
                deleteOlderThan=cleanUpTable,
                deleteYongerThan= {
                  value= 0,
                  type= "days"
                },
                onSchedule=false,
                retentionSchedule= {
                  alarms= {},
                  conditions= {},
                  maxDelayPeriod= -1,
                  maxRetries=0,
                  preventFromSleeping=true,
                  retryPeriod=0,
                  unique= false,
                  waitActionType=2
                },
                stagingOperationType= 0
              }
            },
            useProtectionPlanCredentials=false
          }
        }
      },
      scheme= {
        parameters= {
          backupSchedule= {
            kind= {
              dataType= "binary",
              type= "incremental"
            },
            schedule= {
              alarms= {
                {
                  beginDate= {
                    day= 0,
                    month= 0,
                    year= 0
                  },
                  calendar= {
                    weekInterval= 0,
                    days= 0,
                    type= "weekly"
                  },
                  distribution= {
                    enabled= false,
                    interval= 0,
                    method= 0
                  },
                  endDate= {
                    day= 0,
                    month= 0,
                    year= 0
                  },
                  machineWake= false,
                  onceADayFlag= false,
                  repeatAtDay= {
                    endTime= {
                      hour= 23,
                      minute= 59,
                      second= 59
                    },
                    timeInterval= timeIntervalNumber
                  },
                  skipOccurrences= 0,
                  startTime= {
                    hour= 0,
                    minute= 0,
                    second= 0
                  },
                  startTimeDelay= 0,
                  type= "time",
                  utcBasedSettings= false
                }
              },
              conditions= {},
              maxDelayPeriod= -1,
              maxRetries= 0,
              preventFromSleeping= true,
              retryPeriod= 0,
              unique= false,
              waitActionType= "run"
            }
          },
          backupTypeRule= "alwaysFull"
        },
        type= "simple"
      },
      target= {
        inclusions= {
          {
            key=machineID
          }
        }
      }
    }
  };

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  -- json:encode discards and keys with nil values, using the place holder we can make sure that it is included
  local apiParamString = json:encode(apiParams);
  apiParamString = string.gsub(apiParamString, "\""..nilPlaceholder.."\"", "null");

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/bplans", "POST", apiParamString, headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Create backup plan failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end

  return planName;
end

function deleteBackupPlan(connection, backupAccessURL, hostName, backupPlanID, debug)

  if(debug == nil) then
    debug = false;
  end

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/bplans/"..backupPlanID, "DELETE", "", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Delete backup plan failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return false, apiResult;
  end

  return true;
end

function getBackupPlanID(connection, backupAccessURL, hostName, machineID, debug)

  if(debug == nil) then
    debug = false;
  end

  local json=new("JSON");
  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/bplans", "GET", "", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get backup plan failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  local backupPlans=json:decode(apiResult.response);

  local data=backupPlans["data"];
  if(data == nil) then
    return nil;
  end

  for key, value in pairs(data) do
    local target=value["target"];
    if(target ~= nil) then
      local inclusions=target["inclusions"];
      if(inclusions ~= nil and #inclusions > 0) then
        for i=1, #inclusions, 1 do
          if(inclusions[i].key == machineID) then
            return value.id;
          end
        end
      end
    end
  end

  return nil;
end

function getAcronisStorageUsage(acronisURL, username, password, machineInstanceID, debug)
  local json=new("JSON")

  local def={ enable_cookie=true, ssl_verify=true }
  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection(def)

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local connParams={
    username=username,
    password=password,
    remember=true
  };

  local loginResult=loginToAcronis(connection, acronisURL, username, password, debug)
  if(loginResult == nil or loginResult.url == nil) then
    return 0;
  end

  local backupAccess=accessBackup(connection, loginResult.url, "self", debug);
  if(backupAccess == nil) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Failed to get backup access to get storage usage for " .. username);
    syslog.closelog();
    logout(connection, loginResult.url);
    return 0;
  end

  local apiResult=makeAPICall(connection, backupAccess.url.."/api/ams/statistics/space_usage", "GET", "", headers, debug);
  if(apiResult.success == false) then
  
    if(tostring(apiResult.statusCode) == "404") then
      apiResult=makeAPICall(connection, backupAccess.url.."/api/ams/"..backupAccess.hostName.."/statistics/space_usage", "GET", "", headers, debug);
      
      if(apiResult.success == false) then
        apiResult=makeAPICall(connection, backupAccess.url.."/api/ams/api/ams/"..backupAccess.hostName.."/statistics/space_usage", "GET", "", headers, debug);
      end
    end
    
    if(apiResult.success == false) then
      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      syslog.syslog("LOG_ERR", "Create space usage failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
      syslog.closelog();
      return 0;
    end
  end

  local response=json:decode(apiResult.response);
  if(response == nil or type(response) ~= "table" or response.data == nil) then
    return 0;
  end

  local data = response.data;

  for i = 1, #data, 1 do
    local response = data[i];
    if(response.instanceId == machineInstanceID) then
      -- 'value / 1073741824' is used to covert bytes into a GB value
      return (tonumber(response.value) / 1073741824);
    end
  end

  return 0;
end

function getWebRestoreConnectionDetails(connection, backupAccessURL, username, password, debug)

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/links/webrestore", "GET", "", headers, debug);
  if(apiResult.success == false) then
  
    if(tostring(apiResult.statusCode) == "404") then
      apiResult=makeAPICall(connection, backupAccessURL.."/api/links/webrestore", "GET", "", headers, debug);
    end
    
    if(apiResult.success == false) then
      return nil, apiResult;
    end
  end
  
  local baseURL = apiResult.response;
  
  -- Need to make sure this is the base URL and not the path to the login or index page
  local utils = new("Utils");
  if(utils:stringEndsWith(baseURL, "/enterprise/login/login.htm")) then
    baseURL = string.sub(baseURL, 1, string.len(baseURL) - string.len("/enterprise/login/login.htm"));
  end
  if(utils:stringEndsWith(baseURL, "/enterprise/index.htm")) then
     baseURL = string.sub(baseURL, 1, string.len(baseURL) - string.len("/enterprise/index.htm"));
  end

  local webRestoreURL = baseURL .. "/enterprise/login/handleLoginForm.htm?email="..username.."&password="..password.."&timeZoneOffset=-180";

  return {
    url = baseURL,
    sso = webRestoreURL
  };
end

function getGroupUsers(connection, acronisURL, groupID, debug)

  if(debug == nil) then
    debug = false;
  end

  local json=new("JSON");
  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/users", "GET", "", headers, debug);
  if(apiResult.success == false) then
    return nil, apiResult;
  end

  local response=json:decode(apiResult.response);
  if(response.items == nil) then
    return nil;
  end

  local users = {};

  for i = 1, #response.items, 1 do

    local item = response.items[i];

    local customerUUID = nil;
    local beUUID = nil;

    beUUID, customerUUID = string.match(item.login, "([^.]+).([^.]+)");

    local user = {};
    user.id = item.id;
    user.customerUUID = customerUUID;
    user.billingEntityUUID = beUUID;
    user.customerName = item.firstname;
    user.billingEntityName = item.lastname;

    if(customerUUID ~= nil and beUUID ~= nil) then
      table.insert(users, user);
    end
  end

  return users;
end

function getAllMachines(connection, backupAccessURL, hostName, debug)

  if(debug == nil) then
    debug = false;
  end

  if(backupAccessURL == nil or hostName == nil) then
    return nil;
  end

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/subscriptions", "POST", "{}", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get subscription details failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  local response=json:decode(apiResult.response);

  local subscriptionId = response.id;

  apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/resources?subscriptionId=" .. subscriptionId .. "&recursive=5", "GET", "", headers, debug);
  if(apiResult.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Get all machine details failed : " .. apiResult.statusCode .. " : " .. apiResult.response);
    syslog.closelog();
    return nil, apiResult;
  end
  response=json:decode(apiResult.response);

  local data=response["data"]
  if(data == nil) then
    return nil;
  end

  local machines = {};

  for i=1, #data, 1 do
    local item=data[i];
    if(item.type == "machine" and item.ip ~= nil) then

      local machine = {};
      machine.ipAddress = item.ip[1];
      machine.instanceID = item.instance_id;
      machine.lastBackup = item.lastBackup;
      machine.id = item.id;
      machine.subscriptionId = subscriptionId;

      table.insert(machines, machine);
    end
  end

  return machines
end

function cleanErrorResponse(input, debug)

  local output=input:gsub("<a.->(.-)</a>","%1");

  output=output:gsub("<html.->(.-)</html>","%1");
  output=output:gsub("<body.->(.-)</body>","%1");
  output=output:gsub("<h1.->(.-)</h1>","%1");
  output=output:gsub("<title.->(.-)</title>","%1");
  output=output:gsub("<head.->(.-)</head>","%1");
  output=output:gsub("<hr.->(.-)</hr>","%1");
  output=output:gsub("<center.->(.-)</center>","%1");
  output=output:gsub("<p.->(.-)</p>","%1");

  local jsonOutput = nil;

  if(pcall(function() jsonOutput = new("JSON"):decode(output); end)) then
    if(jsonOutput ~= nil and type(jsonOutput) == "table") then
    
      local newOutput = nil;
      
      local message = jsonOutput.message;
      local reason = jsonOutput.reason;
      
      if(message ~= nil) then
        newOutput = message;
      elseif(reason ~= nil) then
        newOutput = reason;
      end
      
      if(newOutput ~= nil) then
        if(debug) then
          local syslog = new("syslog");
          syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
          syslog.syslog("LOG_INFO", "Filtering JSON error response");
          syslog.syslog("LOG_INFO", tostring(output));
          syslog.closelog();
        end
        output = newOutput;
      end
      
    end
  end

  return output;
end

function getRandomString(length)

  -- No capital i or o as could be mistaken for 1 and 0 with some fonts
  local randomString = "";
  local pool = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z","-"}

  for i=1, length do
    randomString = randomString..pool[math.random(1, #pool)]
  end

  return randomString;
end

function getLinuxScriptBlobUUID()
  local hasher = new ("FDLHashHelper");
  return hasher:getNamedUUID("_skyline/blobs/fco-acronis-setup-script.pl");
end

function getWindowExecutableBlobUUID()
  local hasher = new ("FDLHashHelper");
  return hasher:getNamedUUID("_skyline/blobs/FCOAcronisWinBackupSetup.exe");
end

function preServerCreate(server)
  local providerValues=server:getProviderValues("ACRONIS_BACKUP");

  if(providerValues ~= nil) then
    local passwordString = providerValues:get("password");
    if(passwordString ~= nil) then

      local serverData = new("Map");
      serverData:put("encryptionPassword", passwordString);
      dataStore:resetPrivateDataMap(server:getResourceUUID(), serverData);

      local newPasswordString = "";
      for i = 1, #passwordString, 1 do
        newPasswordString = newPasswordString .. "*";
      end

      providerValues:put("password", newPasswordString);
    end
  end
end

function postServerCreate(server)
  local billingEntityValues=getBillingEntityValues(server:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
    syslog.closelog();
    return { exitState="CONTINUE" }
  end

  local serverValues=getServerValues(server);
  if(serverValues.enabled) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Backup is enabled for server "..server:getResourceName());
    syslog.closelog();
  else
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Backup not enabled for server "..server:getResourceName());
    syslog.closelog();
  end

  local customerValues=getCustomerValues(server:getCustomerUUID());
  if(customerValues.success) then

    local simplehttp=new("simplehttp");
    local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

    local loginResult=loginToAcronis(connection, billingEntityValues.serviceURL, billingEntityValues.username, billingEntityValues.password)
    if(loginResult == nil or loginResult.url == nil) then
      return { exitState="CONTINUE" }
    end

    local createUserAccount=createUserAccount(connection, loginResult.url, customerValues, billingEntityValues.password, billingEntityValues.groupID);
    logout(connection, loginResult.url);

    if(createUserAccount == nil) then
      return { exitState="CONTINUE" }
    end

    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    if(createUserAccount) then
      syslog.syslog("LOG_INFO", "New user account created on Acronis");
    else
      syslog.syslog("LOG_INFO", "User account exists on Acronis");
    end
    syslog.closelog();

    return { exitState="SUCCESS" }
  else
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Failed to find server customer "..server:getCustomerUUID());
    syslog.closelog();
    return { exitState="CONTINUE" }
  end
end

function postServerDelete(server)

  local serverValues=getServerValues(server);
  local billingEntityValues=getBillingEntityValues(server:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    local syslog = new("syslog");
    syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
    syslog.syslog("LOG_ERR", "Acronis admin credentials not found");
    syslog.closelog();
    return { exitState="CONTINUE" }
  end

  -- Server is deleted, doesn't need the private data map
  dataStore:resetPrivateDataMap(serverValues.uuid, nil);

  local simplehttp=new("simplehttp");
  local connection=simplehttp.newConnection({enable_cookie=true, ssl_verify=true });

  local loginResult=loginToAcronis(connection, billingEntityValues.serviceURL, billingEntityValues.username, billingEntityValues.password, false);
  if(loginResult == nil or loginResult.url == nil) then
    return { exitState="CONTINUE" }
  end

  local backupAccess=accessBackup(connection, loginResult.url, billingEntityValues.groupID, false);
  if(backupAccess == nil) then
    logout(connection, loginResult.url);
    return { exitState="CONTINUE" }
  end

  local machine=getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress, false);
  if(machine == nil) then
    logout(connection, loginResult.url);
    return { exitState="CONTINUE" }
  end

  local backupPlanID = getBackupPlanID(connection, backupAccess.url, backupAccess.hostName, machine.id, false);

  if(backupPlanID ~= nil) then
    local deleteResult = deleteBackupPlan(connection, backupAccess.url, backupAccess.hostName, backupPlanID, false);
    if(deleteResult) then
      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      syslog.syslog("LOG_INFO", "Backup Plan " ..backupPlanID.." has been deleted");
      syslog.closelog();
    else
      local syslog = new("syslog");
      syslog.openlog("ACRONIS_BACKUP", syslog.LOG_ODELAY + syslog.LOG_PID);
      syslog.syslog("LOG_INFO", "Backup Plan " ..backupPlanID.." was not deleted");
      syslog.closelog();
    end
  end

  logout(connection, loginResult.url);
end

function doesProductOfferUseAcronis(adminAPI, productOfferUUID)

  if(adminAPI == nil or productOfferUUID == nil or #productOfferUUID == 0) then
    return false;
  end

  local utils = new("Utils");

  local searchFilter = new("SearchFilter");
  searchFilter:addCondition(utils:createFilterCondition("product.components.referenceField", "IS_EQUAL_TO", "ACRONIS_BACKUP_SERVER_SETTINGS"));
  searchFilter:addCondition(utils:createFilterCondition("resourceUUID", "IS_EQUAL_TO", productOfferUUID));

  local queryLimit = new("QueryLimit");
  queryLimit:setLoadChildren(false);
  queryLimit:setMaxRecords(1);

  local iterator = adminAPI:runListQuery(searchFilter, queryLimit, "PRODUCTOFFER");
  if(iterator:hasNext()) then
    return true;
  end

  return false;
end

function getBlobDownloadlink(cpURL, blobUUID, filename)
  -- Link for service details, not for download, download returns the headers for skyline to add correctly
  return cpURL .. "/rest/open/current/resources/blob/" .. blobUUID .. "/download?headers=%7B%22Content-Disposition%22%3A%22inline%3B+filename%3D'" .. filename .. "'%22%2C+%22Content-Description%22%3A%22File+Transfer%22%7D";
end

--[[ End of Helper Functions ]]
