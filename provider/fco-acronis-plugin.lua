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
    triggerFunctions={"post_job_state_change_trigger", "pre_server_metadata_update_trigger", "post_create_server_trigger", "post_server_state_change_trigger", "pre_create_server_trigger"},
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
                name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_SETUP_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_SETUP_ACCOUNT_DESCRIPTION",
                returnType="FUNCTION",
                executionFunction="action_function_setup_account",
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
                order=0
              },
              {
                key="login_webrestore",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_function_signin_webrestore",
                order=1
              },
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
                order=0
              },
              {
                key="login_webrestore",
                name="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_NAME",
                description="#__ACRONIS_BACKUP_PCT_CUSTOMER_SETTINGS_ACTION_LOGIN_RESTORE_DESCRIPTION",
                returnType="URL_POPUP",
                executionFunction="action_function_signin_webrestore",
                order=1
              },
              {
                key="register",
                name="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_ACTION_REGISTER_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_SERVER_SETTINGS_ACTION_REGISTER_ACCOUNT_DESCRIPTION",
                returnType="STRING",
                executionFunction="action_function_register",
                order=2
              }
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
    return nil;
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
    return nil;
  end

  units=chargeUnits * tonumber(measureSize) * (convert_mtype(chargeMeasureType,measureType)) * -1 * p.billingFactor;

  return { { units=units, description=translate.string("#__ACRONIS_BACKUP_BILLING_DESC_BACKUP_CHARGE", measureSize, translate.measureType(measureType)) } }
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
    logout(connection, loginResult.url);
    return { { key="acronisUsage", value=acronisUsage } }
  end

  local machine=getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress)
  if(machine == nil) then
    logout(connection, loginResult.url);
    return { { key="acronisUsage", value=acronisUsage } }
  end

  if(serverValues.enabled) then
    -- Backup is enabled

    local customerValues=getCustomerValues(server:getCustomerUUID());

    if(serverValues.backupPlanID == nil) then
      -- Does not have backup plan

      local backupPlanID = createBackupPlan(connection, backupAccess.url, backupAccess.hostName, "Backup-"..server:getCustomerName().."-"..serverValues.ipAddress, machine.id, serverValues.retention, serverValues.frequency, serverValues.password);
      if(backupPlanID ~= nil and #backupPlanID > 0) then
        serverValues.backupPlanID = backupPlanID;
        print("ACRONIS_BACKUP NOTICE", "Backup plan created " .. backupPlanID);
        
        -- Reset map with password and backup plan id
        local serverData = new("Map");
        serverData:put("encryptionPassword", serverValues.password);
        serverData:put("backupPlanID", backupPlanID);
        dataStore:resetPrivateDataMap(server:getResourceUUID(), serverData);
      else
        print("ACRONIS_BACKUP ERROR", "Failed to create backup plan");
      end

      if(machine.lastBackup ~= nil) then
        acronisUsage=getAcronisStorageUsage(connection, backupAccess.url, customerValues.acronisUsername, backupAccess.hostName, machine.instanceID);
        if(acronisUsage > 0) then
          print("ACRONIS_BACKUP NOTICE", "Acronis storage usage is: "..acronisUsage.." GB for server "..serverValues.ipAddress.."");
        end
      end
    else
      -- Has existing backup plan
      acronisUsage=getAcronisStorageUsage(connection, backupAccess.url, customerValues.acronisUsername, backupAccess.hostName, machine.instanceID);
      if(acronisUsage > 0) then
        print("ACRONIS_BACKUP NOTICE", "Acronis storage usage is: "..acronisUsage.." GB for server "..serverValues.ipAddress.."");
      end
    end
  elseif(serverValues.backupPlanID ~= nil) then
    -- Backup is not enabled but we have a backup plan id, we need to delete it. We don't care about the result
    deleteBackupPlan(connection, backupAccess.url, backupAccess.hostName, serverValues.backupPlanID)
    
    -- Reset map with just password, removing backup plan id
    local serverData = new("Map");
    serverData:put("encryptionPassword", serverValues.password);
    dataStore:resetPrivateDataMap(server:getResourceUUID(), serverData);
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
      name="Delete Acronis Account",
      description="Delete the Acronis account after when the customer is delete",
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
        print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
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

      if(createUserAccount) then
        print("ACRONIS_BACKUP NOTICE", "New user account created on Acronis");
      else
        print("ACRONIS_BACKUP NOTICE", "User account exists on Acronis");
      end

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
        print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
        return { returnCode="CONTINUE" }
      end

      if(success) then
        print("ACRONIS_BACKUP NOTICE", "Acronis user account deleted");
        return { exitState="SUCCESS" }
      else
        print("ACRONIS_BACKUP NOTICE", "Acronis user account was not deleted");
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

  local server=p.input;

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

  local server=p.input;

  local billingEntityValues=getBillingEntityValues(server:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
    return { exitState="CONTINUE" }
  end

  local serverValues=getServerValues(server);
  if(serverValues.enabled) then

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

      if(createUserAccount) then
        print("ACRONIS_BACKUP NOTICE", "New user account created on Acronis");
      else
        print("ACRONIS_BACKUP NOTICE", "User account exists on Acronis");
      end

      return { exitState="SUCCESS" }
    else
      print("ACRONIS_BACKUP ERROR", "Failed to find server customer "..server:getCustomerUUID())
      return { exitState="CONTINUE" }
    end
  else
    print("ACRONIS_BACKUP ERROR", "Backup not enabled for server "..server:getResourceName())
    return { exitState="CONTINUE" }
  end

  return { exitState="CONTINUE" }
end

function pre_server_metadata_update_trigger(p)
  if (p == nil) then
    return {
      ref="pre_server_metadata_update_trigger",
      name="Acronis Server Metadata Trigger",
      description="PRE_SERVER_METADATA_UPDATE trigger that will add the acronis",
      priority=-9000,
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
    print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
    return { exitState="CONTINUE" }
  end

  if(customerValues.success) then
    local xmlHelper=new("FDLXMLHelper");
    local runtimeNode=xmlHelper:findNode(document, "CONFIG/meta/server/system");

    local acronisNode = xmlHelper:addNode(document, runtimeNode, "fco-acronis");

    xmlHelper:addTextNode(document, acronisNode, "url", billingEntityValues.serviceURL);
    xmlHelper:addTextNode(document, acronisNode, "username", customerValues.acronisUsername);
    xmlHelper:addTextNode(document, acronisNode, "password", customerValues.acronisPassword);

    return { exitState="SUCCESS" }
  end

  return { exitState="CONTINUE" }
end

function post_server_state_change_trigger(p)
  if(p == nil) then
    return {
      ref="post_server_state_change_trigger",
      name="",
      description="",
      triggerType="POST_SERVER_STATE_CHANGE",
      triggerOptions={"DELETING"},
      api="TRIGGER",
      version=1,
    }
  end

  local serverValues=getServerValues(p.input);
  local billingEntityValues=getBillingEntityValues(p.input:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
    return { exitState="CONTINUE" }
  end

  -- Server is deleted, doesn't need the private data map
  dataStore:resetPrivateDataMap(serverValues.uuid, nil);

  local simplehttp=new("simplehttp");
  local json=new("JSON")

  local connection=simplehttp.newConnection({enable_cookie=true, ssl_verify=true });

  local loginResult=loginToAcronis(connection, billingEntityValues.serviceURL, billingEntityValues.username, billingEntityValues.password);
  if(loginResult == nil or loginResult.url == nil) then
    return { exitState="CONTINUE" }
  end

  local backupAccess=accessBackup(connection, loginResult.url, billingEntityValues.groupID);
  if(backupAccess == nil) then
    logout(connection, loginResult.url);
    return { exitState="CONTINUE" }
  end

  local machine=getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress);
  if(machine == nil) then
    logout(connection, loginResult.url);
    return { exitState="CONTINUE" }
  end

  if(serverValues.backupPlanID ~= nil) then
    deleteBackupPlan(connection, backupAccess.url, backupAccess.hostName, serverValues.backupPlanID);
    print("ACRONIS_BACKUP NOTICE", "Backup Plan " ..serverValues.backupPlanID.." has been deleted");
  end

  --[[
  -- We do not want to delete the machine from Acronis, backups should persist after server deletion.
  deleteMachine(connection, backupAccess.url, backupAccess.hostName, machine.id);
  print("ACRONIS_BACKUP NOTICE", "Machine " ..serverValues.ipAddress.." has been removed");
  ]]
  logout(connection, loginResult.url);

  return { exitState="SUCCESS" }
end

--[[ End of Trigger Functions ]]
--[[ Action Functions ]]

function action_function_setup_account(p)

  local loginResult=nil;
  local apiResult=nil;

  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  loginResult, apiResult=loginToAcronis(connection, p.parameters.serviceURL, p.parameters.username, p.parameters.password);

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

  dataStore:resetPrivateDataMap(p.resource:getResourceUUID(), dataStoreMap)

  -- Remove password as we do not want to store this in config values
  dataStoreMap:remove("acronisPassword");

  local adminAPI=new("AdminAPI", "current");
  local providerValues = new("Map");
  providerValues:put("serviceURL", p.parameters.serviceURL);
  providerValues:put("username", p.parameters.username);
  providerValues:put("backupGroup", p.parameters.backupGroup);
  adminAPI:updateConfigurationProviderValues(p.resource:getResourceUUID(), "ACRONIS_BACKUP", providerValues);

  local utils = new("Utils");

  return { returnCode="SUCCESSFUL", returnType="FUNCTION", returnContent=utils:createRefreshFunctionActionContent(true); }
end

function action_function_sigin(p)

  local billingEntityValues=getBillingEntityValues(p.resource:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
  end

  local customerValues=nil;

  if(p.resource:getResourceType():name() == "CUSTOMER") then
    customerValues=getCustomerValues(p.resource);
  else
    customerValues=getCustomerValues(p.resource:getCustomerUUID());
  end

  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local loginResult=nil;
  local apiResult=nil;

  loginResult, apiResult=loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword);
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

function action_function_register(p)

  local serverValues=getServerValues(p.resource);
  local billingEntityValues=getBillingEntityValues(p.resource:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_FAILED") }
  end

  local customerValues=getCustomerValues(p.resource:getCustomerUUID());

  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local loginResult=nil;
  local apiResult=nil;

  loginResult, apiResult=loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword);
  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode="FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_FAILED") }
    else
      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local backupAccess=nil;
  apiResult=nil;

  backupAccess, apiResult=accessBackup(connection, loginResult.url, "self");
  if(backupAccess == nil) then
    logout(connection, loginResult.url);

    if(apiResult == nil) then
      return { returnCode="FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_FAILED") }
    else
      return { returnCode="FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local machine=getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress);
  logout(connection, loginResult.url);

  if(machine == nil) then
    return { returnCode="SUCCESSFUL", returnType="STRING", returnContent=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_FAILED") }
  end

  return { returnCode="SUCCESSFUL", returnType="STRING", returnContent=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_SUCCESS") }
end

function action_function_signin_webrestore(p)

  local billingEntityValues=getBillingEntityValues(p.resource:getBillingEntityUUID());
  if(billingEntityValues.success == false) then
    print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
    return { returnCode="FAILED", errorCode=401, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
  end

  local customerValues=nil;

  if(p.resource:getResourceType():name() == "CUSTOMER") then
    customerValues=getCustomerValues(p.resource);
  else
    customerValues=getCustomerValues(p.resource:getCustomerUUID());
  end

  local simplehttp=new("simplehttp");
  local connection=simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local loginResult=nil;
  local apiResult=nil;

  loginResult, apiResult=loginToAcronis(connection, billingEntityValues.serviceURL, customerValues.acronisUsername, customerValues.acronisPassword);
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

  backupConnectionDetails, apiResult=accessBackup(connection, loginResult.url, "self");
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

  webstoreConnectionDetails, apiResult=getWebRestoreConnectionDetails(connection, backupConnectionDetails.url, customerValues.acronisUsername, customerValues.acronisPassword);
  logout(connection, loginResult.url);

  if(webstoreConnectionDetails == nil) then
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

  return { returnCode="SUCCESSFUL", returnType="URL_POPUP", returnContent=utils:createURLActionContent("GET", webstoreConnectionDetails.sso, nil) }

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
  local backupPlanIDString="";
  local serverData = dataStore:getPrivateDataMap(server:getResourceUUID());
  if(serverData ~= nil) then
    passwordString=serverData:get("encryptionPassword");
    backupPlanIDString=serverData:get("backupPlanID");
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
    backupPlanID=backupPlanIDString
  }
end

function getBillingEntityValues(billingEntity)

  local beUUID=billingEntity;

  local groupIDString=nil;
  local usernameString=nil;
  local passwordString=nil;
  local serviceURLString=nil;
  local success=false;

  if(type(billingEntity) ~= "string") then
    beUUID=billingEntity:getResourceUUID();
  end

  local billingData = dataStore:getPrivateDataMap(beUUID);

  if(billingData ~= nil) then
    groupIDString=billingData:get("acronisGroupID")
    usernameString=billingData:get("acronisUsername")
    passwordString=billingData:get("acronisPassword")
    serviceURLString=billingData:get("acronisServiceURL");

    success=usernameString ~= nil and passwordString ~= nil and groupIDString ~= nil and serviceURLString ~= nil;
  end

  return{
    groupID=groupIDString,
    uuid=beUUID,
    username=usernameString,
    password=passwordString,
    serviceURL=serviceURLString,
    success=success
  }
end

function getCustomerValues(customerUUID)

  local customer=nil;

  if(type(customerUUID) ~= "string") then
    customer=customerUUID;
    customerUUID=customerUUID:getResourceUUID()
  else
    local adminAPI=new("AdminAPI", "current");
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

  local customerData = dataStore:getPrivateDataMap(customerUUID);
  if(customerData ~= nil) then
    if(customerData:containsKey("acronisPassword")) then
      acronisPassword = customerData:get("acronisPassword");
    end
    if(customerData:containsKey("acronisID")) then
      acronisIDString = customerData:get("acronisID");
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
    print("makeAPICall input", method, url, params);
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
    if(debug) then
      print("makeAPICall pre-error cleanup", response, ".");
    end
    local cleanResponse=cleanErrorResponse(response);

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
    print("makeAPICall result", success, statusCode, response);
  end

  return{
    success=success,
    statusCode=statusCode,
    response=response,
    responseHeaders=responseHeaders
  }
end

function logout(connection, acronisURL)

  makeAPICall(connection, acronisURL.."/api/1/logout", "GET", "", nil);

end

function loginToAcronis(connection, acronisURL, username, password)

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/accounts/?login="..username, "GET", "", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  local acronisURLParams=json:decode(apiResult.response);

  if(acronisURLParams.server_url == nil) then
    print("ACRONIS_BACKUP ERROR", "401 Unauthorised");
    return nil, nil;
  end

  local loginCredentials=json:encode({ username=username, password=password });

  apiResult=makeAPICall(connection, acronisURLParams.server_url.."/api/1/login/", "POST", loginCredentials, headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  local acronisLoginParams=json:decode(apiResult.response);
  if(acronisLoginParams == nil or acronisLoginParams.id == nil) then
    print("ACRONIS_BACKUP ERROR", "401 Unauthorised");
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

    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
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
      print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
      return nil, apiResult;
    end

    local userParams=json:decode(apiResult.response);
    apiResult=makeAPICall(connection, acronisURL.."/api/1/actions/activate/?token=" .. userParams.token, "POST", json:encode({password=customerData.acronisPassword}), headers, false);
    if(apiResult.success == false) then
      print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
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
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  local user = json:decode(apiResult.response);
  user.status = 0;

  local accountVersion = user.version;

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/users/"..accountID.."?version="..accountVersion, "PUT", json:encode({status=0}), headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end

  local result = json:decode(apiResult.response);
  accountVersion = result.version;

  apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/users/"..accountID.."?version="..accountVersion, "DELETE", "", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end

  return true;
end

function getBackupConnectionDetails(connection, acronisURL, groupID)

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, acronisURL.."/api/1/groups/"..groupID.."/backupconsole", "GET", "", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end

  local result=json:decode(apiResult.response);

  local backupURL="";
  local backupToken="";
  if(result.url ~= nil) then
    backupURL, backupToken=result.url:match("([^,]+)#access_token=([^,]+)");
  end

  return{
    sso = result.url,
    url = backupURL,
    token = backupToken
  }, nil;

end

function accessBackup(connection, acronisURL, groupID)

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  if(groupID == nil) then
    groupID="self";
  end

  local backupConnectionDetails = nil;
  local apiResult = nil;
  backupConnectionDetails, apiResult = getBackupConnectionDetails(connection, acronisURL, groupID);
  if(backupConnectionDetails == nil) then
    return nil, apiResult;
  end

  local apiResult = makeAPICall(connection, backupConnectionDetails.url.."/api/remote_connection", "POST", json:encode({access_token=backupConnectionDetails.token}), headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
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

function getMachine(connection, backupAccessURL, hostName, ipAddress)

  if(backupAccessURL == nil or hostName == nil or ipAddress == nil) then
    return nil;
  end

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/subscriptions", "POST", "{}", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  local response=json:decode(apiResult.response);

  apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/" .. hostName .. "/resources?subscriptionId=" .. response.id .. "&recursive=5", "GET", "", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
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
        lastBackup=item.lastBackup
      }
    end
  end

  return nil
end

function deleteMachine(connection, backupAccessURL, hostName, ipAddress)

  if(backupAccessURL == nil or hostName == nil or ipAddress == nil) then
    return nil;
  end

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/machines/"..ipAddress, "DELETE", "", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end

  return true;
end

function createBackupPlan(connection, backupAccessURL, hostName, planName, machineID, backupRetention, backupFrequency, backupPassword)

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

  local apiParams={
    action= "createAndRun",
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
            archiveName= "Archive-"..planName.."",
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

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/bplans", "POST", apiParamString, headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  
  return json:decode(apiResult.response);
end

function deleteBackupPlan(connection, backupAccessURL, hostName, backupPlanID)

  local json=new("JSON");
  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/bplans/"..backupPlanID, "DELETE", "", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end

  return json:decode(apiResult.response);
end

function getAcronisStorageUsage(connection, backupAccessURL, username, hostName, machineInstanceID)
  local json=new("JSON")

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/ams/"..hostName.."/statistics/space_usage?account="..username, "GET", "", headers, true);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return 0;
  end
  local response=json:decode(apiResult.response);
  if(response == nil or type(response) ~= "table" or response.data == nil) then
    return 0;
  end

  local data = response.data;

  for i = 1, #data, 1 do
    local response = data[i];
    if(response.instance == machineInstanceID) then
      --1073741824 is used to covert bytes into a GB value
      return (tonumber(response.value) / 1073741824);
    end
  end

  return 0;
end

function getWebRestoreConnectionDetails(connection, backupAccessURL, username, password)

  local json=new("JSON");

  local headers={};
  headers['Content-Type']="application/json; charset=UTF-8";
  headers['Accept']="application/json";

  local apiResult=makeAPICall(connection, backupAccessURL.."/api/links/webrestore", "GET", "", headers, false);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end

  local webRestoreURL = apiResult.response;

  apiResult=makeAPICall(connection, webRestoreURL.."/mobile/v1/login?login="..username.."&password="..password.."", "POST", "{}", headers, true);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  
  apiResult=makeAPICall(connection, webRestoreURL.."/mobile/v1/autologin", "GET", nil, headers, true);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  
  local result = json:decode(apiResult.response);

  return {
    sso = result.text,
    url = webRestoreURL
  };
end

function cleanErrorResponse(input)

  local output=input:gsub("<a.->(.-)</a>","%1");

  output=output:gsub("<html.->(.-)</html>","%1");
  output=output:gsub("<body.->(.-)</body>","%1");
  output=output:gsub("<h1.->(.-)</h1>","%1");
  output=output:gsub("<title.->(.-)</title>","%1");
  output=output:gsub("<head.->(.-)</head>","%1");
  output=output:gsub("<hr.->(.-)</hr>","%1");
  output=output:gsub("<center.->(.-)</center>","%1");

  local jsonOutput = nil;

  if(pcall(function() jsonOutput = new("JSON"):decode(output); end)) then
    if(jsonOutput ~= nil and type(jsonOutput) == "table") then
      local message = jsonOutput.message;
      if(message ~= nil) then
        output = message;
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

--[[ End of Helper Functions ]]
