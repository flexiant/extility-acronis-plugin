--[[
FCO Acronis Plugin

{"FDLINFO":{"VERSION":"1.0.0"}}
]]

function register()
  return { "acronis_backup_provider", "acronis_delete_trigger", "acronis_server_billing" }
end

--[[ Configuration Provider ]]
function acronis_backup_provider()
  return{
    ref="acronis_backup_provider",
    name="#__ACRONIS_BACKUP_NAME",
    description="#__ACRONIS_BACKUP_DESCRIPTION",
    providerType="ACRONIS_BACKUP",
    providerGroup="FCO_EXTENSION",
    api = "CONFIG_PROVIDER",
    version = 1,
    measurementFunctions={"server_measurement_function"},
    triggerFunctions={"pre_server_metadata_update_trigger", "post_create_server_trigger", "post_server_state_change_trigger"},
    resourceConfigs={
      {
        associatedResourceType="BILLING_ENTITY",
        useWithBilling=false,
        productComponentTypes={{
          resourceName="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_NAME",
          referenceField="BE_SETTINGS",
          configurableList={
            {
              key = "backupKey",
              name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_KEY_NAME",
              description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_KEY_DESCRIPTION",
              readOnly = true
            },
            {
              key = "username",
              name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_NAME",
              description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_DESCRIPTION",
              readOnly = true
            }
          },
          actionFunctions={
            {
              key = "setup_account",
              name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_SETUP_ACCOUNT_NAME",
              description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_SETUP_ACCOUNT_DESCRIPTION",
              returnType = "STRING",
              executionFunction = "action_function_setup_account",
              parameters = {
                {
                  key = "backupKey",
                  name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_KEY_NAME",
                  description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_BACKUP_KEY_DESCRIPTION",
                  required = true
                },
                {
                  key = "username",
                  name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_NAME",
                  description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_USERNAME_DESCRIPTION",
                  required = true
                },
                {
                  key = "password",
                  name = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_PASSWORD_NAME",
                  description = "#__ACRONIS_BACKUP_PCT_BE_SETTINGS_PASSWORD_DESCRIPTION",
                  validator = {
                    validatorType = "PASSWORD"
                  },
                  required = true
                },
              }
            }
          }
        }
        }
      },
      {
        associatedResourceType="SERVER",
        userWithBilling=true,
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
                name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_LOGIN_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_LOGIN_ACCOUNT_DESCRIPTION",
                returnType="URL",
                executionFunction="action_function_sigin",
              },
              {
                key="register",
                name="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_REGISTER_ACCOUNT_NAME",
                description="#__ACRONIS_BACKUP_PCT_BE_SETTINGS_ACTION_REGISTER_ACCOUNT_DESCRIPTION",
                returnType="STRING",
                executionFunction="action_function_register",
              }
            }
          }
        }
      }
    }
  }
end

--[[ Separate POST_JOB_STATE_CHANGE trigger to delete an Acronis account when FCO customer is deleted ]]
function acronis_delete_trigger(p)
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

  -- TODO : as this trigger is not a config trigger it will not have access to the datastore

  if(p.input:getJobType():name() == "DELETE_RESOURCE" and p.input:getItemType():name() == "CUSTOMER") then
    local adminAPI = new("AdminAPI", "current");
    local customer = adminAPI:getResource(p.input:getItemUUID(), true);
    local billingEntity = adminAPI:getResource(customer:getBillingEntityUUID(), true);

    local billingEntityValues = getBillingEntityValues(billingEntity);

    if(billingEntityValues.success) then
    -- TODO : cant complete as dev tech had it as you do not have access to username and password from the BE values in this trigger
    end
  end

  return { exitState = "SUCCESS" }
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
          key = "charge_measurement_type",
          name = "#__BILLING_KEY_CHARGE_MEASUREMENT_TYPE_NAME",
          description = "#__BILLING_KEY_CHARGE_MEASUREMENT_TYPE_DESCRIPTION",
          validator = {validatorType = "ENUM", validateString = "GB,TB"},
          measureType = "NUMERIC",
          required=true
        },
        {
          key = "repeat_units",
          name = "#__BILLING_KEY_REPEAT_UNITS_NAME",
          description = "#__BILLING_KEY_REPEAT_UNITS_DESCRIPTION",
          measureType = "UNIT",
          validator = {validatorType = "NUMERIC_DOUBLE"},
          required=true
        }
      },
      api = "BILLING",
      version = 1
    }
  end

  local units = 0;

  local measureType = nil;
  local measureSize = nil;
  
  local measureHash = p.measureComp:getMAXMeasureBetween(p.lastBillingTime, p.currentBillingTime, "providers.ACRONIS_BACKUP.acronisUsage");
  if(measureHash ~= nil and measureHash:size()) then
    local usageValue = measureHash:get("providers.ACRONIS_BACKUP.acronisUsage");
    if(usageValue ~= nil) then
      measureType = usageValue:getMeasurementType():name();
      measureSize = usageValue:getMeasurement();
    end
  end
  
  measureSize = p.measureComp:getMeasureAt(p.lastBillingTime, "disk_read,disk_write");
  
  if(measureSize == nil or measureType == nil) then
    return nil;
  end
  
  local chargeUnits = nil;
  local chargeMeasureType = nil;
  
  local chargeMeasureTypeValue = p.billingComp:getBillingValue("charge_measurement_type");
  if(chargeMeasureTypeValue ~= nil) then
    chargeMeasureType = chargeMeasureTypeValue:getValue();
  end
  local chargeUnitsValue = p.billingComp:getBillingValue("repeat_units");
  if(chargeUnitsValue ~= nil) then
    chargeUnits = tonumber(chargeUnitsValue:getValue());
  end

  if(chargeUnits == nil or chargeMeasureType == nil) then
    return nil;
  end

  units = chargeUnits * tonumber(measureSize) * (convert_mtype(chargeMeasureType,measureType)) * -1 * p.billingFactor

  return { { units=units, description=translate.string("#__ACRONIS_BACKUP_BILLING_DESC_BACKUP_CHARGE", measureSize, translate.measureType(measureType)) } }
end

--[[ Measurement Functions ]]

function server_measurement_function(p)
  if (p == nil) then
    return {
      ref = "server_measurement_function",
      name = "Acronis Measurement Function",
      description = "Measurement function to get disk usage from Acronis backup system",
      measuredValues = {
        {
          key = "acronisUsage",
          name = "Acronis usage measurement",
          description = "The disk usage measurement from Acronis, in GB",
          measureType="GB"
        }
      },
      associatedType = "SERVER",
      api = "MEASURE",
      version = 1
    }
  end

  local acronisUsage = 0;
  local server = p.resource;
  local serverValues = getServerValues(server);

  local billingEntityValues = getBillingEntityValues(server:getBillingEntityUUID());

  local json = new("JSON");

  local def = { enable_cookie=true, ssl_verify=true }
  local simplehttp = new("simplehttp");
  local connection = simplehttp:newConnection(def)

  local loginData = loginToAcronis(connection, "https://baas.acronis.com", billingEntityValues.username, billingEntityValues.password)
  if(loginData == nil or loginData.url == nil) then
    return { { key = "acronisUsage", value=acronisUsage } }
  end

  local customerUUID = server:getCustomerUUID();
  local billingEntityUUID = server:getBillingEntityUUID();

  local customerValues = getCustomerValues(customerUUID, billingEntityUUID);
  if(customerValues.success == false) then
    return { { key = "acronisUsage", value=acronisUsage } }
  end

  local backupAccess = accessBackup(connection, loginData.url, billingEntityValues.backupKey);
  if(backupAccess == nil) then
    return { { key = "acronisUsage", value=acronisUsage } }
  end

  local machine = getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress)
  if(machine == nil) then
    return { { key = "acronisUsage", value=acronisUsage } }
  end

  local backupPlanID = getBackupPlanID(connection, backupAccess.url, backupAccess.hostName, machine.id);

  if(serverValues.enabled) then
    -- Backup is enabled
    if(backupPlanID == nil) then
      -- Does not have backup plan

      local backupPlanID = createBackupPlan(connection, backupAccess.url, backupAccess.hostName, "Backup-"..server:getCustomerName(), machine.id, serverValues.retention, serverValues.frequency, serverValues.password);
      if(backupPlanID) then
        print("ACRONIS_BACKUP NOTICE", "Backup place created " ..backupPlanID);
      else
        print("ACRONIS_BACKUP ERROR", "Failed to create backup plan");
      end

      if(machine.lastBackup ~= nil) then
        acronisUsage = getAcronisStorageUsage(connection, loginData.url);
        if(acronisUsage > 0) then
          print("ACRONIS_BACKUP NOTICE", "Acronis storage usage is: "..acronisUsage.." B for server "..serverValues.ipAddress.."");
        end
      end
    else
      -- Has existing backup plan
      acronisUsage = getAcronisStorageUsage(connection, loginData.url);
      if(acronisUsage > 0) then
        print("ACRONIS_BACKUP NOTICE", "Acronis storage usage is: "..acronisUsage.." B for server "..serverValues.ipAddress.."");
      end
    end
  elseif(backupPlanID ~= nil) then
    -- Backup is not enabled but we have a backup plan id, we need to delete it. We don't care about the result
    deleteBackupPlan(connection, backupAccess.url, backupAccess.hostName, backupPlanID)
  end

  return { { key = "acronisUsage", value=acronisUsage } }
end

--[[ End of Measurement Functions ]]
--[[ Trigger Functions ]]

function post_create_server_trigger(p)
  if (p == nil) then
    return {
      ref = "post_create_server_trigger",
      name = "Create Acronis Account",
      description = "Post Server create trigger that will create a Acronis account",
      triggerType = "POST_CREATE",
      triggerOptions = { "SERVER" },
      api = "TRIGGER",
      version = 1
    }
  end

  local server = p.input;

  local billingEntityValues = getBillingEntityValues(server:getBillingEntityUUID());
  if(billingPrivateData.success == false) then
    print("ACRONIS_BACKUP ERROR", "Acronis admin credentials not found")
    return { exitState = "CONTINUE" }
  end

  local serverValues = getServerValues(server);
  if(serverValues.enabled) then

    local customerData = getCustomerValues(p:getCustomerUUID(), p.beUUID);
    if(customerData.success) then

      local simplehttp = new("simplehttp");
      local connection = simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

      local loginData = loginToAcronis(connection, "https://baas.acronis.com", billingEntityValues.username, billingEntityValues.password)
      if(loginData == nil or loginData.url == nil) then
        return { exitState = "CONTINUE" }
      end

      local createUserAccount = createUserAccount(connection, loginData.url, customerData, billingEntityValues.password, billingEntityValues.backupKey);
      if(createUserAccount == nil) then
        return { exitState = "CONTINUE" }
      end

      if(createUserAccount) then
        print("ACRONIS_BACKUP NOTICE", "New user account created on Acronis");
      else
        print("ACRONIS_BACKUP NOTICE", "User account exists on Acronis");
      end

      return { exitState = "SUCCESS" }
    else
      print("ACRONIS_BACKUP ERROR", "Failed to find server customer "..server:getCustomerUUID())
      return { exitState = "CONTINUE" }
    end
  else
    print("ACRONIS_BACKUP ERROR", "Backup not enabled for server "..server:getResourceName())
    return { exitState = "CONTINUE" }
  end

  return { exitState = "CONTINUE" }
end

function pre_server_metadata_update_trigger(p)
  if (p == nil) then
    return {
      ref = "pre_server_metadata_update_trigger",
      name = "",
      description = "",
      priority = -9000,
      triggerType = "PRE_SERVER_METADATA_UPDATE",
      triggerOptions = { "ANY" },
      api = "TRIGGER",
      version = 1,
    }
  end

  local server = p.input[1];

  local customerValues = getCustomerValues(server:getCustomerUUID(), server:getBillingEntityUUID());

  if(customerValues.success) then
    local xmlHelper = new("FDLXMLHelper");
    local runtimeNode = xmlHelper:findNode(p.input[2], "CONFIG/meta/server/system");

    xmlHelper:addTextNode(p.input[2], runtimeNode, "acronis_url", "https://eu-baas.acronis.com");
    xmlHelper:addTextNode(p.input[2], runtimeNode, "acronis_username", customerValues.acronisUsername);
    xmlHelper:addTextNode(p.input[2], runtimeNode, "acronis_password", customerValues.acronisPassword);
  end

  return { exitState = "SUCCESS" }
end

function post_server_state_change_trigger(p)
  if(p == nil) then
    return {
      ref = "post_server_state_change_trigger",
      name = "",
      description = "",
      triggerType = "POST_SERVER_STATE_CHANGE",
      triggerOptions = {"DELETING"},
      api = "TRIGGER",
      version = 1,
    }
  end

  local serverValues = getServerValues(p.input);
  local beValues getBillingEntityValues(p.input:getBillingEntityUUID());

  local simplehttp = new("simplehttp");
  local json = new("JSON")

  local connection = simplehttp.newConnection({enable_cookie=true, ssl_verify=true });

  local loginData = loginToAcronis(connection, "https://baas.acronis.com", beValues.username, beValues.password);
  if(loginData == nil or loginData.url == nil) then
    return { exitState = "CONTINUE" }
  end

  local backupAccess = accessBackup(connection, loginData.url, beValues.backupKey);
  if(backupAccess == nil) then
    return { exitState = "CONTINUE" }
  end

  local machine = getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress);
  if(machine == nil) then
    return { exitState = "CONTINUE" }
  end

  local backupPlanID = getBackupPlanID(connection, backupAccess.url, backupAccess.hostName, machine.id);
  if(backupPlanID == nil) then
    return { exitState = "CONTINUE" }
  end

  deleteBackupPlan(connection, backupAccess.url, backupAccess.hostName, backupPlanID);
  print("ACRONIS_BACKUP NOTICE", "Backup Plan " ..backupPlanID.." has been deleted");

  return { exitState = "SUCCESS" }
end

--[[ End of Trigger Functions ]]
--[[ Action Functions ]]

function action_function_setup_account(p)

  local dataStoreMap = new("Map");

  dataStoreMap:put("acronisBackupKey", p.parameters.backupKey);
  dataStoreMap:put("acronisUsername", p.parameters.username);
  dataStoreMap:put("acronisPassword", p.parameters.password);

  dataStore:resetPrivateDataMap(p.resource:getResourceUUID(), dataStoreMap)

  -- Remove password as we do not want to store this in config values
  dataStoreMap:remove("acronisPassword");
  
  local adminAPI = new("AdminAPI", "current");
  adminAPI:updateConfigurationProviderValues(p.resource:getResourceUUID(), "ACRONIS_BACKUP", dataStoreMap)

  -- TODO : check if this information is valid?
  local loginResult = nil;
  local apiResult = nil;

  loginResult, apiResult = loginToAcronis(connection, "https://baas.acronis.com", p.parameters.username, p.parameters.password);
  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode = "FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SETUP_ACCOUNT_FAILED", "") }
    else
      return { returnCode = "FAILED", errorCode=apiResult.statusCode, errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SETUP_ACCOUNT_FAILED", apiResult.response) }
    end
  end

  return { returnCode = "SUCCESSFUL", returnType = "STRING", returnContent=translate.string("#__ACRONIS_BACKUP_MESSAGE_SETUP_ACCOUNT_SUCCESS") }
end

function action_function_sigin(p)

  local billingEntityValues = getBillingEntityValues(p.resource:getBillingEntityUUID());

  local simplehttp = new("simplehttp");
  local connection = simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local logoutResult = false;
  local apiResult = nil;

  logoutResult, apiResult = logoutOfAcronis(connection, "https://baas.acronis.com");
  if(logoutResult == false) then
    if(apiResult == nil) then
      return { returnCode = "FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      return { returnCode = "FAILED", errorCode=apiResult..statusCode, errorString=apiResult.response }
    end
  end

  local loginResult = nil;
  apiResult = nil;

  loginResult, apiResult = loginToAcronis(connection, "https://baas.acronis.com", billingEntityValues.username, billingEntityValues.password);
  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode = "FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      return { returnCode = "FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local backupAccess = nil;
  apiResult = nil;

  backupAccess, apiResult = accessBackup(connection, "https://baas.acronis.com/api/1", nil);
  if(backupAccess == nil) then
    if(apiResult == nil) then
      return { returnCode = "FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_SSO_FAILED") }
    else
      return { returnCode = "FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local utils = new("Utils");

  return { returnCode = "SUCCESSFUL", returnType = "URL", returnContent=utils:createURLActionContent("GET", backupAccess.url, nil) }
end

function action_function_register(p)

  local serverValues = getServerValues(p.resource);
  local billingEntityValues = getBillingEntityValues(p.resource:getBillingEntityUUID());

  local simplehttp = new("simplehttp");
  local connection = simplehttp:newConnection({ enable_cookie=true, ssl_verify=true })

  local loginResult = nil;
  local apiResult = nil;

  loginResult, apiResult = loginToAcronis(connection, "https://baas.acronis.com", billingEntityValues.username, billingEntityValues.password)
  if(loginResult == nil) then
    if(apiResult == nil) then
      return { returnCode = "FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_FAILED") }
    else
      return { returnCode = "FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local backupAccess = nil;
  apiResult = nil;

  backupAccess, apiResult = accessBackup(connection, loginResult.url, billingEntityValues.backupKey);
  if(backupAccess == nil) then
    if(apiResult == nil) then
      return { returnCode = "FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_FAILED") }
    else
      return { returnCode = "FAILED", errorCode=apiResult.statusCode, errorString=apiResult.response }
    end
  end

  local machine = getMachine(connection, backupAccess.url, backupAccess.hostName, serverValues.ipAddress);
  if(machine == nil) then
    return { returnCode = "FAILED", errorString=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_FAILED") }
  end

  return { returnCode = "SUCCESSFUL", returnType = "STRING", returnContent=translate.string("#__ACRONIS_BACKUP_MESSAGE_REGISTER_SUCCESS") }
end

--[[ End of Action Functions ]]
--[[ Helper functions ]]

function makeAPICall(connection, url, method, params, headers)

  local success = false;
  local statusCode = "";
  local response = "";

  connection:setURL(url);
  if(headers ~= nil) then
    connection:clearRequestHeaders();
    connection:setRequestHeaders(headers);
  end

  local apiFunction = function(value) response = response .. tostring(value); return true; end

  if(method == "GET") then
    if(connection:get(apiFunction)) then
      success = true;
      statusCode = connection:getHTTPStatusCode();
    else
      success = false;
      statusCode, response = conn:getLastError();
    end
  elseif(method == "DELETE") then
    if(connection:delete(apiFunction)) then
      success = true;
      statusCode = connection:getHTTPStatusCode();
    else
      success = false;
      statusCode, response = conn:getLastError();
    end
  elseif(method == "PUT") then
    if(connection:put(params, apiFunction)) then
      success = true;
      statusCode = connection:getHTTPStatusCode();
    else
      success = false;
      statusCode, response = conn:getLastError();
    end
  elseif(method == "POST") then
    if(connection:get(params, apiFunction)) then
      success = true;
      statusCode = connection:getHTTPStatusCode();
    else
      success = false;
      statusCode, response = conn:getLastError();
    end
  end

  return{
    success = success,
    statusCode = statusCode,
    response = response,
  }
end

function getServerValues(server)

  local providerValues = server:getProviderValues("ACRONIS_BACKUP");

  local enabledString = providerValues:get("enabled");
  local enabledBoolean = enabledString ~= nil and string.upper(enabledString) == "TRUE";

  local retentionString = providerValues:get("retention");
  if(retentionString == "#__ACRONIS_BACKUP_RETENTION_OPTION_2") then
    retentionString = 30;
  else
    retentionString = -1;
  end

  local frequencyString = providerValues:get("frequency");
  if(frequencyString == nil) then
    frequencyString = 0;
  end
  local frequencyNumber = tonumber(frequencyString);

  local passwordString = providerValues:get("password");

  local ipAddressString = "";
  local serverNics = server:getNics();
  if(serverNics ~= nil and serverNics:size() > 0) then
    local ipAddresses = serverNics:get(0):getIpAddresses();
    if(ipAddresses ~= nil and ipAddresses:size() > 0) then
      ipAddressString = ipAddresses:get(0):getIpAddress();
    end
  end

  return{
    enabled=enabledBoolean,
    retention=retentionString,
    frequency=frequencyNumber,
    password=passwordString,
    ipAddress=ipAddressString
  }

  -- TODO : password should be in private data
end

function getBillingEntityValues(billingEntity)

  local beUUID = billingEntity;

  local backupKeyString=nil;
  local usernameString=nil;
  local passwordString=nil;
  local credentials=false;

  if(type(billingEntity) ~= "string") then
    beUUID = billingEntity:getResourceUUID()

    local providerValues = billingEntity:getProviderValues("ACRONIS_BACKUP");
    backupKeyString = providerValues:get("backupKey");
  end

  local dataStore = dataStore:getPrivateDataMap(beUUID);

  if(dataStore ~= nil) then
    if(backupKeyString == nil) then
      backupKeyString = dataStore:get("acronisBackupKey")
    end

    usernameString = dataStore:get("acronisUsername")
    passwordString = dataStore:get("acronisPassword")

    credentials = usernameString ~= nil and passwordString ~= nil and backupKeyString ~= nil;
  else
    credentials = backupKeyString ~= nil;
  end

  return{
    backupKey=backupKeyString,
    username=usernameString,
    password=passwordString,
    success=credentials
  }
end

function getCustomerValues(customerUUID, billingEntityUUID)

  local adminAPI = new("AdminAPI", "current");

  local customer = nil;

  if(type(customerUUID) ~= "string") then
    customer = customerUUID;
    customerUUID = customerUUID:getResourceUUID()
  else
    customer = adminAPI:getResource(customerUUID, false);
  end


  if(customer == nil) then
    return { success=false }
  end

  local user = customer:getUsers():get(0);

  return {
    success=true,
    address1=customer:getAddress():getAddress1(),
    address2=customer:getAddress():getAddress2(),
    address3=customer:getAddress():getAddress3(),
    address4=customer:getAddress():getAddress4(),
    address5=customer:getAddress():getAddress5(),
    address6=customer:getAddress():getAddress6(),
    acronisUsername=billingEntityUUID.."."..customerUUID.."@acronis.flexiant.com",
    acronisPassword=billingEntityUUID.."."..customerUUID,
    firstname=user:getFirstName(),
    lastname=user:getLastName(),
    phone=user:getMobileNumber(),
    email=user:getEmail(),
    status=customer:getStatus():name()
  }
end

function logoutOfAcronis(connection, acronisURL)

  local headers = {};
  headers['Content-Type'] = "application/json";
  headers['Accept'] = "application/json";

  local apiResult = makeAPICall(connection, acronisURL.."/api/1/logout/", "GET", "", headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return false, { apiResult.statusCode, apiResult.response };
  end

  return true, nil;
end

function loginToAcronis(connection, acronisURL, username, password)

  local json = new("JSON");

  local headers = {};
  headers['Content-Type'] = "application/json";
  headers['Accept'] = "application/json";

  local apiResult = makeAPICall(connection, acronisURL.."/api/1/accounts/?login"..username, "GET", "", headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, { apiResult.statusCode, apiResult.response };
  end
  local acronisURLParams = json:decode(apiResult.response);

  if(acronisURLParams.server_url == nil) then
    print("ACRONIS_BACKUP ERROR", "401 Unauthorised");
    return nil, nil;
  end

  local server_url = acronisURLParams.server_url.."/api/1/";

  local loginCredentials = json:encode({ username=username, password=password });

  apiResult = makeAPICall(connection, server_url.."/login/", "POST", loginCredentials, headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, { apiResult.statusCode, apiResult.response };
  end
  local acronisLoginParams = json:decode(apiResult.response);
  if(acronisLoginParams == nil or acronisLoginParams.id == nil) then
    print("ACRONIS_BACKUP ERROR", "401 Unauthorised");
    return nil, nil;
  end

  local data={
    url=server_url,
    user={
      id=acronisLoginParams.id,
      access={
        read = acronisLoginParams.access_type == 1,
        branding = acronisLoginParams.access_type == 2,
        readWrite = acronisLoginParams.access_type == 4,
        full = acronisLoginParams.access_type == 7
      },
      firstname=acronisLoginParams.firstname,
      lastname=acronisLoginParams.lastname,
      email=acronisLoginParams.email,
      language=acronisLoginParams.language,
    }
  };

  return data, nil;
end

function createUserAccount(connection, acronisURL, customerData, password, backupKey)

  local json = new("JSON");

  local userData = json:encode({
    address1=customerData.address1,
    address2=customerData.address2,
    city=customerData.address3,
    state=customerData.address4,
    zipcode=customerData.address5,
    country=customerData.address6,
    email=customerData.acronisUsername,
    firstname=customerData.firstname,
    lastname=customerData.lastname,
    phone=customerData.phone,
    notifications_backup=0,
    notifications_management=0,
    privileges={
      quota_kind=1,
      server_count=1,
      stroage_size=1000
    }
  });
  local headers = { };
  headers['Content-Type'] = "application/json";
  headers['Accept'] = "application/json";

  local apiResult = makeAPICall(connection, acronisURL.."/groups/"..backupKey.."/users/", "POST", userData, headers);
  if(apiResult.success == false) then
    if(apiResult.statusCode == 409) then
      -- Account already exists, we catch this error and return false.
      return false;
    end
  
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil;
  end

  local userAccount = json:decode(apiResult.response);
  if(userAccount.id == nil) then
    return false;
  else
    apiResult = makeAPICall(connection, acronisURL.."/actions/mail/activate/?email="..customerData.acronisUsername, "GET", "", headers);
    if(apiResult.success == false) then
      print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
      return nil;
    end

    local userParams = json:decode(apiResult.response);
    apiResult = makeAPICall(connection, acronisURL.."/actions/activate/?token=" .. userParams.token, "POST", "", headers);
    if(apiResult.success == false) then
      print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
      return nil;
    end

    return true;
  end

  return false;
end

function accessBackup(connection, acronisURL, backupKey)

  local json = new("JSON");

  local headers = {};
  headers['Content-Type'] = "application/json; charset=UTF-8";
  headers['Accept'] = "application/json";

  if(backupKey == nil) then
    backupKey = "self";
  end

  local apiResult = makeAPICall(connection, acronisURL.."/groups/"..backupKey.."/backupconsole", "GET", "", headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end

  local result = json:decode(apiResult.response);
  local backupURL = "";
  local backupToken = "";
  if(result.url ~= nil) then
    backupURL, backupToken = result.url:match("([^,]+)#access_token=([^,]+)");
  end

-- TODO : cant find this call in the api docs
  apiResult = makeAPICall(connection, backupURL.."/api/remote_connection", "POST", json:encode({access_token=backupToken}), headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil, apiResult;
  end
  local backupSession = json:decode(apiResult.response);

  return{
    hostName = backupSession.host_name,
    url = backupURL
  }, nil
end

function getMachine(connection, acronisURL, hostName, ipAddress)

  if(acronisURL == nil or hostName == nil or ipAddress == nil) then
    return nil;
  end

  local json = new("JSON");

  local headers = {};
  headers['Content-Type'] = "application/json; charset=UTF-8";

  local apiResult = makeAPICall(connection, acronisURL.."/api/subscriptions", "POST", "", headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil;
  end
  local response = json:decode(apiResult.response);

  apiResult = makeAPICall(connection, acronisURL.."/api/ams/" .. hostName .. "/resources?subscriptionId=" .. response.id .. "&recursive=5", "GET", "", headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil;
  end
 response = json:decode(apiResult.response);

  local data = response["data"]
  if(data == nil) then
    return nil;
  end
  
  for i = 1, #data, 1 do
    local item = data[i];
    if(item.type == "machine" and item.ip ~= nil and item.ip[1] == ipAddress) then
      return item;
    end
  end

  return nil
end

function getBackupPlanID(connection, acronisURL, hostName, machineID)

  local json = new("JSON")

  local headers = {};
  headers['Content-Type'] = "application/json";

  local apiResult = makeAPICall(connection, acronisURL.."/api/ams/"..hostName.."/bplans", "GET", "", headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil;
  end
  local backupPlans = json:decode(apiResult.response);

  local data = backupPlans["data"];
  if(data == nil) then
    return nil;
  end

  for key, value in pairs(data) do

    local target = value["target"];
    if(target ~= nil) then
      local inclusions = target["inclusions"];
      if(inclusions ~= nil and #inclusions > 0) then
        for i = 1, #inclusions, 1 do
          if(inclusions[i].key == machineID) then
            return value.id;
          end
        end
      end
    end
  end
end

function createBackupPlan(connection, acronisURL, hostName, planName, machineID, backupRetention, backupFrequency, backupPassword)

  local json = new("JSON")

  local timeIntervalNumber = backupFrequency * 60 * 60;

  local passwordString = backupPassword;
  local usePasswordValue = true;
  if(passwordString == nil) then
    passwordString = "";
    usePasswordValue = false;
  end

  local cleanUpTable = {};
  if(backupRetention > 0) then
    cleanUpTable["value"] = backupRetention;
    cleanUpTable["type"] = "days";
  end

  local apiParams = {
    action= "create",
    data= {
      name= planName,
      scheme= {
        parameters= {
          backupSchedule= {
            kind= {
              dataType= "binary",
              type= "incremental"
            },
            schedule= {
              unique= false,
              retryPeriod= 0,
              alarms= {
                {
                  beginDate= {
                    day= 0,
                    month= 0,
                    year= 0
                  },
                  endDate= {
                    day= 0,
                    month= 0,
                    year= 0
                  },
                  repeatAtDay= {
                    endTime= {
                      hour= 23,
                      minute= 59,
                      second= 59
                    },
                    timeInterval= timeIntervalNumber
                  },
                  startTime= {
                    hour= 0,
                    minute= 0,
                    second= 0
                  },
                  distribution= {
                    enabled= false,
                    interval= 0,
                    method= 0
                  },
                  calendar= {
                    weekInterval= 0,
                    days= 0,
                    type= "weekly"
                  },
                  machineWake= false,
                  onceADayFlag= false,
                  skipOccurrences= 0,
                  startTimeDelay= 0,
                  type= "time",
                  utcBasedSettings= false
                }
              },
              preventFromSleeping= true,
              conditions= {},
              waitActionType= "run",
              maxDelayPeriod= -1,
              maxRetries= 0
            }
          },
          backupTypeRule= "alwaysFull"
        },
        type= "simple"
      },
      options= {
        backupOptions= {
          archiveProtection={
            algorithm=3,
            password=passwordString,
            usePassword=usePasswordValue
          },
          exclusions= {
            excludeSystem= false,
            excludeHidden= false,
            exclusionMasks= {}
          },
          diskSpeed= {
            mode= "percent",
            value= 100
          },
          networkSpeed= {
            mode= "percent",
            value= 100
          }
        }
      },
      route= {
        stages= {
          {
            destinationKind= "online",
            useProtectionPlanCredentials= false,
            archiveName= "Archive ["..machineID.."]",
            maintenanceWindow= null,
            cleanUpIfNoSpace= false,
            rules= {
              {
                deleteOlderThan= cleanUpTable,
                backupCountUpperLimit= 0,
                backupSetIndex= null,
                beforeBackup= false,
                onSchedule= false,
                deleteYongerThan= {
                  value= 0,
                  type= "days"
                },
                retentionSchedule= {
                  conditions= {},
                  unique= false,
                  preventFromSleeping= true,
                  waitActionType= 2,
                  alarms= {},
                  maxDelayPeriod= -1,
                  retryPeriod= 0,
                  maxRetries= 0
                },
                afterBackup= true,
                consolidateBackup= true,
                stagingOperationType= 0,
                backupUpperLimitSize= 0
              }
            }
          }
        }
      },
      origin= "centralized",
      id= null,
      target= {
        inclusions= {
          {
            key=machineID
          }
        }
      },
      backupType= "gct::disks"
    }
  };

  local headers = {};
  headers['Content-Type'] = "application/json; charset=UTF-8";
  headers['Accept'] = "application/json";

  -- TODO : can't confirm input as docs are incomplete
  local apiResult = makeAPICall(connection, acronisURL.."/api/ams/"..hostName.."/bplans", "POST", json:encode(apiParams), headers);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil;
  end
  return apiResult.response;
end

function deleteBackupPlan(connection, acronisURL, hostName, backupPlanID)

  local json = new("JSON")

  local apiResult = makeAPICall(connection, acronisURL.."/api/ams/"..hostName.."/bplans/"..backupPlanID, "DELETE", "", nil);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return nil;
  end

  return json:decode(apiResult.response);
end

function getAcronisStorageUsage(connection, acronisURL)
  local json = new("JSON")

  local apiResult = makeAPICall(connection, acronisURL.."/users/self", "GET", "", nil);
  if(apiResult.success == false) then
    print("ACRONIS_BACKUP ERROR", apiResult.statusCode, apiResult.response);
    return 0;
  end
  local userProfile = json:decode(apiResult.response);
  if(userProfile == nil or userProfile.usage == nil or userProfile.usage.storage_size == nil) then
    return 0;
  end

--1073741824 is used to covert storage_size value into a GB value
  return (tonumber(userProfile.usage.storage_size) / 1073741824);
end

--[[ End of Helper Functions ]]
