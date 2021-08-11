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
ALittle.RegStruct(707557875, "ALittle.NatPortInfo", {
name = "ALittle.NatPortInfo", ns_name = "ALittle", rl_name = "NatPortInfo", hash_code = 707557875,
name_list = {"port_map","client_map","cur_port","idle_map","total_count","use_count"},
type_list = {"Map<int,ALittle.IMsgCommon>","Map<ALittle.IMsgCommon,Map<int,bool>>","int","Map<int,bool>","int","int"},
option_map = {}
})

ALittle.NatSystem = Lua.Class(nil, "ALittle.NatSystem")

function ALittle.NatSystem:Ctor()
	___rawset(self, "_nat_ip", "127.0.0.1")
	___rawset(self, "_start_port", 0)
	___rawset(self, "_port_count", 0)
end

function ALittle.NatSystem:Setup(nat_ip, start_port, port_count)
	self._start_port = start_port
	self._port_count = port_count
	self._port_info = {}
	self._port_info.cur_port = start_port
	self._port_info.total_count = port_count
	self._port_info.use_count = 0
	self._port_info.port_map = {}
	self._port_info.client_map = {}
	self._port_info.idle_map = {}
	A_SessionSystem:AddEventListener(___all_struct[888437463], self, self.HandleAnyConnect)
	A_SessionSystem:AddEventListener(___all_struct[-36908822], self, self.HandleAnyDisconnect)
	self._clear_idle_timer = A_LoopSystem:AddTimer(60 * 1000, Lua.Bind(self.HandleClearIdle, self), -1, 60 * 1000)
end

function ALittle.NatSystem:HandleClearIdle()
	__CPPAPI_ServerSchedule:ClearIdleRtp(60)
end

function ALittle.NatSystem:Shutdown()
	if self._clear_idle_timer ~= nil then
		A_LoopSystem:RemoveTimer(self._clear_idle_timer)
		self._clear_idle_timer = nil
	end
	__CPPAPI_ServerSchedule:ReleaseAllNat()
end

function ALittle.NatSystem:HandleAnyConnect(event)
	ALittle.Log("connect node:", ALittle.GetRouteName(event.route_type, event.route_num))
	self._port_info.client_map[event.session] = {}
end

function ALittle.NatSystem:HandleAnyDisconnect(event)
	ALittle.Log("disconnected and clear all nat:", ALittle.GetRouteName(event.route_type, event.route_num))
	local map = self._port_info.client_map[event.session]
	if map == nil then
		return
	end
	self._port_info.client_map[event.session] = nil
	for port, info in ___pairs(map) do
		self:ReleasePort(event.session, port)
	end
end

function ALittle.NatSystem:UsePort(client, port)
	if self._port_info.use_count + 1 > self._port_info.total_count then
		return nil, nil
	end
	self._port_info.use_count = self._port_info.use_count + (1)
	if port == nil or port == 0 then
		for value, _ in ___pairs(self._port_info.idle_map) do
			port = value
			break
		end
		if port ~= nil then
			self._port_info.idle_map[port] = nil
		else
			while true do
				port = self._port_info.cur_port
				self._port_info.cur_port = self._port_info.cur_port + (1)
				if self._port_info.port_map[port] == nil then
					break
				end
			end
		end
	else
		if port < self._start_port then
			return nil, nil
		end
		if port >= self._start_port + self._port_count then
			return nil, nil
		end
		if self._port_info.port_map[port] ~= nil then
			port = nil
		else
			self._port_info.idle_map[port] = nil
		end
	end
	if port == 0 or port == nil then
		return nil, nil
	end
	self._port_info.port_map[port] = client
	self._port_info.client_map[client][port] = true
	local password = ALittle.String_Md5(ALittle.String_GenerateID("carp_net_auth:"))
	__CPPAPI_ServerSchedule:UseNat(self._nat_ip, port)
	__CPPAPI_ServerSchedule:SetNatAuth(port, password)
	return port, password
end

function ALittle.NatSystem:HasClientAndPort(client, port)
	return self._port_info.port_map[port] == client
end

function ALittle.NatSystem:SetTarget(client, port, target_ip, target_port)
	if self._port_info.port_map[port] ~= client then
		return "port:" .. port .. " is not be used by client"
	end
	__CPPAPI_ServerSchedule:SetNatTarget(port, target_ip, target_port)
	return nil
end

function ALittle.NatSystem:ReleasePort(client, port)
	if self._port_info.port_map[port] ~= client then
		return
	end
	local map = self._port_info.client_map[client]
	if map ~= nil then
		map[port] = nil
	end
	self._port_info.use_count = self._port_info.use_count - (1)
	self._port_info.idle_map[port] = true
	self._port_info.port_map[port] = nil
	__CPPAPI_ServerSchedule:ReleaseNat(port)
end

end