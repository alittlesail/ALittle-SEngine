-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs
local ___all_struct = ALittle.GetAllStruct()

ALittle.RegStruct(1821069430, "ALittle.ProtocolAnyStruct", {
name = "ALittle.ProtocolAnyStruct", ns_name = "ALittle", rl_name = "ProtocolAnyStruct", hash_code = 1821069430,
name_list = {"hash_code","value"},
type_list = {"int","any"},
option_map = {}
})
ALittle.RegStruct(1721209641, "ALittle.GS2CL_ACmd", {
name = "ALittle.GS2CL_ACmd", ns_name = "ALittle", rl_name = "GS2CL_ACmd", hash_code = 1721209641,
name_list = {"result"},
type_list = {"string"},
option_map = {}
})
ALittle.RegStruct(1463647694, "DataServer.GS2DATA_NBackupStruct", {
name = "DataServer.GS2DATA_NBackupStruct", ns_name = "DataServer", rl_name = "GS2DATA_NBackupStruct", hash_code = 1463647694,
name_list = {"account_id","data"},
type_list = {"int","ALittle.ProtocolAnyStruct"},
option_map = {}
})
ALittle.RegStruct(-1121683527, "DataServer.GS2DATA_QLoadStruct", {
name = "DataServer.GS2DATA_QLoadStruct", ns_name = "DataServer", rl_name = "GS2DATA_QLoadStruct", hash_code = -1121683527,
name_list = {"account_id","hash_code"},
type_list = {"int","int"},
option_map = {}
})
ALittle.RegStruct(468063233, "ALittle.CL2GS_QCmd", {
name = "ALittle.CL2GS_QCmd", ns_name = "ALittle", rl_name = "CL2GS_QCmd", hash_code = 468063233,
name_list = {"cmd"},
type_list = {"string"},
option_map = {}
})
ALittle.RegStruct(-197564509, "ALittle.GS2C_NAccountInfo", {
name = "ALittle.GS2C_NAccountInfo", ns_name = "ALittle", rl_name = "GS2C_NAccountInfo", hash_code = -197564509,
name_list = {"session_code","account_id","gs_route_id"},
type_list = {"string","int","int"},
option_map = {}
})

ALittle.GameAccountStatus = {
	CREATE = 1,
	LOADING = 2,
	CACHE = 3,
	ONLINE = 4,
}

ALittle.GameModule = Lua.Class(nil, "ALittle.GameModule")

function ALittle.GameModule:Ctor(account)
	___rawset(self, "_account", account)
	self._account:RegisterModule(self)
end

function ALittle.GameModule:GetDataReflect()
	return nil
end

function ALittle.GameModule:Release()
end

function ALittle.GameModule:HasData()
	return false
end

function ALittle.GameModule:LoadData(session)
end
ALittle.GameModule.LoadData = Lua.CoWrap(ALittle.GameModule.LoadData)

function ALittle.GameModule:BackupData(session)
end

function ALittle.GameModule:OnDataReady()
end

function ALittle.GameModule:OnSendData()
end

function ALittle.GameModule:OnLogin()
end

function ALittle.GameModule:OnLogout()
end

assert(ALittle.GameModule, " extends class:ALittle.GameModule is nil")
ALittle.GameModuleTemplate = Lua.Class(ALittle.GameModule, "ALittle.GameModuleTemplate")

function ALittle.GameModuleTemplate:GetDataReflect()
	return self.__class.__element[1]
end

function ALittle.GameModuleTemplate:OnLogin()
	self._account:SendMsg(self.__class.__element[1], self._data)
end

function ALittle.GameModuleTemplate:HasData()
	return true
end

function ALittle.GameModuleTemplate:LoadData(session)
	if session == nil then
		self._account:LoadOneCompleted(tostring(self) .. " session == null")
		return
	end
	local rflt = self:GetDataReflect()
	if rflt == nil then
		self._account:LoadOneCompleted(tostring(self) .. ":GetDataReflect() == null")
		return
	end
	local param = {}
	param.account_id = self._account:GetId()
	param.hash_code = rflt.hash_code
	local error, result = ALittle.IMsgCommon.InvokeRPC(-1121683527, session, param)
	if error ~= nil then
		self._account:LoadOneCompleted(tostring(self) .. " DataServer.HandleQLoadStruct() failed:" .. error)
		return
	end
	self._data = result.value
	self._account:LoadOneCompleted(nil)
end
ALittle.GameModuleTemplate.LoadData = Lua.CoWrap(ALittle.GameModuleTemplate.LoadData)

function ALittle.GameModuleTemplate:BackupData(session)
	if session == nil then
		return
	end
	local rflt = self:GetDataReflect()
	if rflt == nil then
		ALittle.Error(tostring(self) .. ":GetDataReflect() == null")
		return
	end
	local param = {}
	param.account_id = self._account:GetId()
	param.data = {}
	param.data.hash_code = rflt.hash_code
	param.data.value = self._data
	session:SendMsg(___all_struct[1463647694], param)
end

ALittle.GameAccount = Lua.Class(nil, "ALittle.GameAccount")

function ALittle.GameAccount:Ctor(id)
	___rawset(self, "_id", id)
	___rawset(self, "_loading_count", 0)
	___rawset(self, "_loading_failed", nil)
	___rawset(self, "_status", 1)
	___rawset(self, "_module_map", {})
	___rawset(self, "_module_list", {})
	___rawset(self, "_BACKUP_INTERVAL", 60 * 1000)
	___rawset(self, "_CACHE_INTERVAL", 30 * 60 * 1000)
	___rawset(self, "_session", tostring(math.random(10000, 99999)))
end

function ALittle.GameAccount:Release()
	local len = ALittle.List_Len(self._module_list)
	while len > 0 do
		self._module_list[len]:Release()
		len = len - 1
	end
	self:StopBackupTimer()
	self:StopCacheTimer()
end

function ALittle.GameAccount:GetId()
	return self._id
end

function ALittle.GameAccount:SetClient(client)
	self._client = client
end

function ALittle.GameAccount:GetClient()
	return self._client
end

function ALittle.GameAccount:GetStatus()
	return self._status
end

function ALittle.GameAccount:SetStatus(status)
	self._status = status
end

function ALittle.GameAccount:GetSession()
	return self._session
end

function ALittle.GameAccount:RegisterModule(module)
	local rflt = (module).__class
	if self._module_map[rflt.__name] ~= nil then
		return
	end
	self._module_map[rflt.__name] = module
	ALittle.List_Push(self._module_list, module)
end

function ALittle.GameAccount:GetModule(T)
	local rflt = T
	return self._module_map[rflt.__name]
end

function ALittle.GameAccount:GetAllDataReflect()
	local map = {}
	local table_map = {}
	for _, module in ___ipairs(self._module_list) do
		local rflt = module:GetDataReflect()
		if rflt ~= nil then
			local primary = rflt.option_map["primary"]
			if primary ~= "account_id" then
				return rflt.ns_name .. "." .. rflt.rl_name .. " don't contain primary named 'account_id'", nil, nil
			end
			local field_index = ALittle.List_IndexOf(rflt.name_list, "account_id")
			if field_index == nil then
				return rflt.ns_name .. "." .. rflt.rl_name .. " don't contain field named 'account_id'", nil, nil
			end
			local field_type = rflt.type_list[field_index]
			if field_type ~= "int" then
				return rflt.ns_name .. "." .. rflt.rl_name .. " field type of 'account_id' must be 'int'", nil, nil
			end
			table_map[rflt.hash_code] = true
			local error = ALittle.CollectStructReflect(rflt, map)
			if error ~= nil then
				return error, nil, nil
			end
		end
	end
	local rflt_list = {}
	local count = 0
	for hash_code, info in ___pairs(map) do
		count = count + 1
		rflt_list[count] = info
	end
	return nil, rflt_list, table_map
end

function ALittle.GameAccount:StartLoading(session)
	self._loading_count = 0
	for _, module in ___ipairs(self._module_list) do
		if module:HasData() then
			self._loading_count = self._loading_count + 1
		end
	end
	if not A_GameAccountManager:IsSendModuleReflect(session) then
		local error, rflt_list, table_map = self:GetAllDataReflect()
		if error ~= nil then
			self._loading_failed = error
			self:LoadAllCompleted()
			return
		end
		A_GameAccountManager:SendModuleReflect(session, rflt_list, table_map)
	end
	if self._loading_count == 0 then
		self:LoadAllCompleted()
		return
	end
	for _, module in ___ipairs(self._module_list) do
		module:LoadData(session)
	end
end

function ALittle.GameAccount:LoadOneCompleted(error)
	self._loading_count = self._loading_count - 1
	if error ~= nil then
		self._loading_failed = error
	end
	if self._loading_count > 0 then
		return
	end
	self:LoadAllCompleted()
end

function ALittle.GameAccount:LoadAllCompleted()
	local account = A_GameAccountManager:GetAccountById(self._id)
	if account ~= self then
		return
	end
	if self._loading_failed ~= nil then
		ALittle.Log("Loading Failed:" .. self._loading_failed .. ", account_id:" .. self._id)
		ALittle.g_GameLeaseManager:ReleaseLease(self._id)
		A_GameAccountManager:DeleteAccount(self)
		if self._client ~= nil then
			local msg = {}
			msg.reason = self._loading_failed
			self._client:SendMsg(___all_struct[-660832923], msg)
		end
		return
	end
	self:OnDataReady()
	if self._client ~= nil then
		self:SetStatus(4)
		self:LoginAction()
	else
		self:SetStatus(3)
		self:StartCacheTimer()
	end
	self:StartBackupTimer()
end

function ALittle.GameAccount:StartBackupTimer()
	ALittle.Log("StartBackupTimer, account_id:" .. self._id)
	if self._backup_timer ~= nil then
		A_LoopSystem:RemoveTimer(self._backup_timer)
	end
	self._backup_timer = A_LoopSystem:AddTimer(self._BACKUP_INTERVAL, Lua.Bind(self.Backup, self), 0, self._BACKUP_INTERVAL)
end

function ALittle.GameAccount:StopBackupTimer()
	if self._backup_timer == nil then
		return
	end
	ALittle.Log("StopBackupTimer, account_id:" .. self._id)
	A_LoopSystem:RemoveTimer(self._backup_timer)
	self._backup_timer = nil
end

function ALittle.GameAccount:StartCacheTimer()
	ALittle.Log("StartCacheTimer, account_id:" .. self._id)
	if self._cache_timer ~= nil then
		A_LoopSystem:RemoveTimer(self._cache_timer)
	end
	self._cache_timer = A_LoopSystem:AddTimer(self._CACHE_INTERVAL, Lua.Bind(self.CacheTimeout, self))
end

function ALittle.GameAccount:StopCacheTimer()
	if self._cache_timer == nil then
		return
	end
	ALittle.Log("StopCacheTimer, account_id:" .. self._id)
	A_LoopSystem:RemoveTimer(self._cache_timer)
	self._cache_timer = nil
end

function ALittle.GameAccount:CacheTimeout()
	ALittle.Log("CacheTimeout, account_id:" .. self._id)
	self._cache_timer = nil
	self:Backup()
	ALittle.g_GameLeaseManager:ReleaseLease(self._id)
	A_GameAccountManager:DeleteAccount(self)
end

function ALittle.GameAccount:Backup()
	ALittle.Log("Backup, account_id:" .. self._id)
	local lease_info = ALittle.g_GameLeaseManager:GetLease(self._id)
	if lease_info == nil or lease_info.session == nil then
		return
	end
	for _, module in ___ipairs(self._module_list) do
		module:BackupData(lease_info.session)
	end
end

function ALittle.GameAccount:LogoutAction()
	for _, module in ___ipairs(self._module_list) do
		module:OnLogout()
	end
	self:Backup()
end

function ALittle.GameAccount:OnDataReady()
	for _, module in ___ipairs(self._module_list) do
		module:OnDataReady()
	end
end

function ALittle.GameAccount:LoginAction()
	local param = {}
	param.account_id = self._id
	param.gs_route_id = __CPPAPI_ServerSchedule:GetRouteId()
	param.session_code = self._session
	self:SendMsg(___all_struct[-197564509], param)
	for _, module in ___ipairs(self._module_list) do
		module:OnLogin()
	end
	for _, module in ___ipairs(self._module_list) do
		module:OnSendData()
	end
	self:SendMsg(___all_struct[-1836835016], {})
end

function ALittle.GameAccount:SendMsg(T, msg)
	if self._client == nil then
		return
	end
	self._client:SendMsg(T, msg)
end

local __enable_cmd = false
function ALittle.EnableCmd(enable)
	__enable_cmd = enable
end

ALittle.RegCmdCallback("EnableCmd", ALittle.EnableCmd, {"bool"}, {"enable"}, "")
function ALittle.HandleCmd(client, msg)
	local ___COROUTINE = coroutine.running()
	Lua.Assert(__enable_cmd, "未开启指令模式")
	local account = A_GameAccountManager:GetAccountByClient(client)
	Lua.Assert(account, "账号未登录")
	local cmd = ""
	local cmd_split_index = ALittle.String_Find(msg.cmd, " ")
	if cmd_split_index == nil then
		cmd = msg.cmd .. " " .. account:GetId()
	else
		cmd = ALittle.String_Sub(msg.cmd, 1, cmd_split_index) .. account:GetId() .. " " .. ALittle.String_Sub(msg.cmd, cmd_split_index + 1)
	end
	local error, result = Lua.TCall(ALittle.ExecuteCommand, cmd)
	Lua.Assert(error == nil, error)
	local rsp = {}
	rsp.result = result
	return rsp
end

ALittle.RegMsgRpcCallback(468063233, ALittle.HandleCmd, 1721209641)
end