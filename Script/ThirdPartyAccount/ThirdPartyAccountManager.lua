-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs
local ___all_struct = ALittle.GetAllStruct()

ALittle.RegStruct(1715346212, "ALittle.Event", {
name = "ALittle.Event", ns_name = "ALittle", rl_name = "Event", hash_code = 1715346212,
name_list = {"target"},
type_list = {"ALittle.EventDispatcher"},
option_map = {}
})
ALittle.RegStruct(1458883016, "ALittle.QThirdPartyLogin", {
name = "ALittle.QThirdPartyLogin", ns_name = "ALittle", rl_name = "QThirdPartyLogin", hash_code = 1458883016,
name_list = {"account_name","account_pwd"},
type_list = {"string","string"},
option_map = {}
})
ALittle.RegStruct(780546240, "ALittle.QThirdPartyLogout", {
name = "ALittle.QThirdPartyLogout", ns_name = "ALittle", rl_name = "QThirdPartyLogout", hash_code = 780546240,
name_list = {},
type_list = {},
option_map = {}
})
ALittle.RegStruct(-574496421, "ALittle.AThirdPartyLogin", {
name = "ALittle.AThirdPartyLogin", ns_name = "ALittle", rl_name = "AThirdPartyLogin", hash_code = -574496421,
name_list = {},
type_list = {},
option_map = {}
})
ALittle.RegStruct(-523029315, "ALittle.ThirdPartyAccountLogoutEvent", {
name = "ALittle.ThirdPartyAccountLogoutEvent", ns_name = "ALittle", rl_name = "ThirdPartyAccountLogoutEvent", hash_code = -523029315,
name_list = {"target","account"},
type_list = {"ALittle.EventDispatcher","ALittle.ThirdPartyAccount"},
option_map = {}
})
ALittle.RegStruct(-503665164, "ALittle.AThirdPartyLogout", {
name = "ALittle.AThirdPartyLogout", ns_name = "ALittle", rl_name = "AThirdPartyLogout", hash_code = -503665164,
name_list = {},
type_list = {},
option_map = {}
})
ALittle.RegStruct(-109045606, "ALittle.ThirdPartyAccountLoginEvent", {
name = "ALittle.ThirdPartyAccountLoginEvent", ns_name = "ALittle", rl_name = "ThirdPartyAccountLoginEvent", hash_code = -109045606,
name_list = {"target","account"},
type_list = {"ALittle.EventDispatcher","ALittle.ThirdPartyAccount"},
option_map = {}
})

assert(ALittle.EventDispatcher, " extends class:ALittle.EventDispatcher is nil")
ALittle.ThirdPartyAccountManager = Lua.Class(ALittle.EventDispatcher, "ALittle.ThirdPartyAccountManager")

function ALittle.ThirdPartyAccountManager:Ctor()
	___rawset(self, "_id_map_account", {})
	___rawset(self, "_client_map_account", {})
	___rawset(self, "_account_count", 0)
end

function ALittle.ThirdPartyAccountManager:Setup(login_check)
	self._login_check = login_check
	self._update_route = ALittle.GatewayUpdateRoute(__CPPAPI_ServerSchedule:GetClientServerYunIp(), __CPPAPI_ServerSchedule:GetClientServerIp(), __CPPAPI_ServerSchedule:GetClientServerPort(), __CPPAPI_ServerSchedule:GetHttpServerYunIp(), __CPPAPI_ServerSchedule:GetHttpServerIp(), __CPPAPI_ServerSchedule:GetHttpServerPort(), self._account_count)
	A_ClientSystem:AddEventListener(___all_struct[-245025090], self, self.HandleClientDisconnect)
	A_ClientSystem:AddEventListener(___all_struct[-1221484301], self, self.HandleClientConnect)
end

function ALittle.ThirdPartyAccountManager:GetAccountById(account_id)
	return self._id_map_account[account_id]
end

function ALittle.ThirdPartyAccountManager:SendMsgToAll(T, msg)
	for id, account in ___pairs(self._id_map_account) do
		account:SendMsg(T, msg)
	end
end

function ALittle.ThirdPartyAccountManager:GetAccountByClient(client)
	return self._client_map_account[client]
end

function ALittle.ThirdPartyAccountManager:AddAccount(account)
	self._client_map_account[account:GetClient()] = account
	self._id_map_account[account:GetID()] = account
	self._account_count = self._account_count + 1
end

function ALittle.ThirdPartyAccountManager:RemoveAccount(account_id)
	local account = self._id_map_account[account_id]
	if account == nil then
		return
	end
	self._id_map_account[account_id] = nil
	self._client_map_account[account:GetClient()] = nil
	self._account_count = self._account_count - 1
	self._update_route:UpdateRouteWeight(self._account_count)
end

function ALittle.ThirdPartyAccountManager:ForceLogout(account_id, reason)
	local account = self._id_map_account[account_id]
	if account == nil then
		return false
	end
	local logout_event = {}
	logout_event.account = account
	self:DispatchEvent(___all_struct[-523029315], logout_event)
	account:ForceLogout(reason)
	account:LogoutActionSystem()
	self:RemoveAccount(account_id)
	return true
end

function ALittle.ThirdPartyAccountManager:CheckLoginById(account_id, session_id)
	local account = self:GetAccountById(account_id)
	Lua.Assert(account ~= nil, "请先登录")
	Lua.Assert(account:CheckSessionCodeAndSync(session_id), "请先登录")
	return account
end

function ALittle.ThirdPartyAccountManager:CheckLoginByClient(client)
	local account = self:GetAccountByClient(client)
	Lua.Assert(account ~= nil, "请先登录")
	return account
end

function ALittle.ThirdPartyAccountManager:Shutdown()
end

function ALittle.ThirdPartyAccountManager:HandleClientDisconnect(event)
	event.msg_receiver._thirdparty_is_logining = false
	local account = self:GetAccountById(event.msg_receiver._thirdparty_account_id)
	if account == nil then
		return
	end
	local logout_event = {}
	logout_event.account = account
	self:DispatchEvent(___all_struct[-245025090], event)
	event.msg_receiver._thirdparty_account_id = ""
	account:LogoutActionSystem()
	self:RemoveAccount(account:GetID())
end

function ALittle.ThirdPartyAccountManager:HandleClientConnect(event)
end

_G.A_ThirdPartyAccountManager = ALittle.ThirdPartyAccountManager()
function ALittle.HandleQThirdPartyLogin(client, msg)
	local ___COROUTINE = coroutine.running()
	local receiver = client
	Lua.Assert(receiver._thirdparty_account_id == "" or receiver._thirdparty_account_id == nil, "当前连接已经登录")
	local error = nil
	local account_id = nil
	Lua.Assert(A_ThirdPartyAccountManager._login_check ~= nil, "没有设置登录验证回调")
	error, account_id = A_ThirdPartyAccountManager._login_check(msg.account_name, msg.account_pwd)
	if error ~= nil then
		Lua.Throw("登录验证失败:" .. error)
	end
	local other_account = A_ThirdPartyAccountManager:GetAccountById(account_id)
	if other_account ~= nil then
		local other_client = other_account:GetClient()
		other_account:ForceLogout("您的账号再另一个地方登录了")
		other_account:LogoutActionSystem()
		A_ThirdPartyAccountManager:RemoveAccount(account_id)
		if other_client ~= nil then
			other_client._thirdparty_account_id = ""
		end
	end
	local thirdparty_account = ALittle.ThirdPartyAccount(receiver, account_id, msg.account_name)
	A_ThirdPartyAccountManager:AddAccount(thirdparty_account)
	receiver._thirdparty_account_id = account_id
	thirdparty_account:LoginActionSystem()
	local login_event = {}
	login_event.account = thirdparty_account
	A_ThirdPartyAccountManager:DispatchEvent(___all_struct[-109045606], login_event)
	A_ThirdPartyAccountManager._update_route:UpdateRouteWeight(A_ThirdPartyAccountManager._account_count)
	return {}
end

ALittle.RegMsgRpcCallback(1458883016, ALittle.HandleQThirdPartyLogin, -574496421)
function ALittle.HandleQThirdPartyLogout(client, msg)
	local ___COROUTINE = coroutine.running()
	local receiver = client
	Lua.Assert(receiver._thirdparty_account_id ~= nil and receiver._thirdparty_account_id ~= "", "当前连接还未登录")
	local thirdparty_account = A_ThirdPartyAccountManager:GetAccountByClient(receiver)
	Lua.Assert(thirdparty_account ~= nil, "账号还未登录")
	local logout_event = {}
	logout_event.account = thirdparty_account
	A_ThirdPartyAccountManager:DispatchEvent(___all_struct[-523029315], logout_event)
	receiver._thirdparty_account_id = ""
	thirdparty_account:LogoutActionSystem()
	A_ThirdPartyAccountManager:RemoveAccount(thirdparty_account:GetID())
	return {}
end

ALittle.RegMsgRpcCallback(780546240, ALittle.HandleQThirdPartyLogout, -503665164)
end