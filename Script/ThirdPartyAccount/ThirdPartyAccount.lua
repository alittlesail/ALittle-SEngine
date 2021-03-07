-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs
local ___all_struct = ALittle.GetAllStruct()

ALittle.RegStruct(-1645771103, "ALittle.S2CThirdPartyForceLogout", {
name = "ALittle.S2CThirdPartyForceLogout", ns_name = "ALittle", rl_name = "S2CThirdPartyForceLogout", hash_code = -1645771103,
name_list = {"reason"},
type_list = {"string"},
option_map = {}
})
ALittle.RegStruct(1058901483, "ALittle.S2CThirdPartyServerInfo", {
name = "ALittle.S2CThirdPartyServerInfo", ns_name = "ALittle", rl_name = "S2CThirdPartyServerInfo", hash_code = 1058901483,
name_list = {"http_ip","http_port"},
type_list = {"string","int"},
option_map = {}
})
ALittle.RegStruct(891920104, "ALittle.S2CThirdPartySession", {
name = "ALittle.S2CThirdPartySession", ns_name = "ALittle", rl_name = "S2CThirdPartySession", hash_code = 891920104,
name_list = {"session_id"},
type_list = {"string"},
option_map = {}
})
ALittle.RegStruct(-548580726, "ALittle.S2CThirdPartyAccountInfo", {
name = "ALittle.S2CThirdPartyAccountInfo", ns_name = "ALittle", rl_name = "S2CThirdPartyAccountInfo", hash_code = -548580726,
name_list = {"account_id","account_name"},
type_list = {"string","string"},
option_map = {}
})
ALittle.RegStruct(-18909987, "ALittle.ThirdPartySessionInfo", {
name = "ALittle.ThirdPartySessionInfo", ns_name = "ALittle", rl_name = "ThirdPartySessionInfo", hash_code = -18909987,
name_list = {"new_client","old_client","time"},
type_list = {"string","string","int"},
option_map = {}
})

ALittle.ThirdPartyAccount = Lua.Class(nil, "ALittle.ThirdPartyAccount")

function ALittle.ThirdPartyAccount:Ctor(client, account_id, account_name)
	___rawset(self, "_session_info", {})
	self._session_info.old_client = "s" .. tostring(math.random(100000, 999999))
	self._session_info.new_client = self._session_info.old_client
	self._session_info.time = os.time(nil)
	___rawset(self, "_client", client)
	___rawset(self, "_account_id", account_id)
	___rawset(self, "_account_name", account_name)
end

function ALittle.ThirdPartyAccount:IsLogin()
	return self._is_login
end

function ALittle.ThirdPartyAccount:IsDataReady()
	return self._is_login
end

function ALittle.ThirdPartyAccount:GetID()
	return self._account_id
end

function ALittle.ThirdPartyAccount:GetAccountName()
	return self._account_name
end

function ALittle.ThirdPartyAccount:GetClient()
	return self._client
end

function ALittle.ThirdPartyAccount:SendMsg(T, msg)
	if self._client == nil then
		return
	end
	self._client:SendMsg(T, msg)
end

function ALittle.ThirdPartyAccount:ForceLogout(reason)
	local param = {}
	param.reason = reason
	self._client:SendMsg(___all_struct[-1645771103], param)
end

function ALittle.ThirdPartyAccount:LogoutActionSystem()
	self._is_login = false
end

function ALittle.ThirdPartyAccount:LoginActionSystem()
	self._is_login = true
	self:GenSessionCodeAndSync()
	do
		local param = {}
		param.account_id = self._account_id
		param.account_name = self._account_name
		self._client:SendMsg(___all_struct[-548580726], param)
	end
	do
		local param = {}
		param.http_ip = __CPPAPI_ServerSchedule:GetHttpServerYunIp()
		if param.http_ip == nil or param.http_ip == "" then
			param.http_ip = __CPPAPI_ServerSchedule:GetHttpServerIp()
		end
		param.http_port = __CPPAPI_ServerSchedule:GetHttpServerPort()
		self._client:SendMsg(___all_struct[1058901483], param)
	end
end

function ALittle.ThirdPartyAccount:GenSessionCodeAndSync()
	self._session_info.old_client = self._session_info.new_client
	self._session_info.new_client = "s" .. tostring(math.random(100000, 999999))
	self._session_info.time = os.time(nil)
	local param = {}
	param.session_id = self._session_info.new_client
	self._client:SendMsg(___all_struct[891920104], param)
end

function ALittle.ThirdPartyAccount:CheckSessionCodeAndSync(session_code)
	if session_code == nil or session_code == "" then
		return false
	end
	session_code = tostring(session_code)
	local result = self._session_info.old_client == session_code or self._session_info.new_client == session_code
	if os.time(nil) - self._session_info.time > 300 then
		self:GenSessionCodeAndSync()
	end
	return result
end

end