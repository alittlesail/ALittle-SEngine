-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs
local ___all_struct = ALittle.GetAllStruct()

ALittle.RegStruct(-1948184705, "ALittle.UdpMessageEvent", {
name = "ALittle.UdpMessageEvent", ns_name = "ALittle", rl_name = "UdpMessageEvent", hash_code = -1948184705,
name_list = {"target","self_ip","self_port","remote_ip","remote_port","message"},
type_list = {"ALittle.EventDispatcher","string","int","string","int","string"},
option_map = {}
})
ALittle.RegStruct(1715346212, "ALittle.Event", {
name = "ALittle.Event", ns_name = "ALittle", rl_name = "Event", hash_code = 1715346212,
name_list = {"target"},
type_list = {"ALittle.EventDispatcher"},
option_map = {}
})

assert(ALittle.EventDispatcher, " extends class:ALittle.EventDispatcher is nil")
ALittle.UdpSystem = Lua.Class(ALittle.EventDispatcher, "ALittle.UdpSystem")

function ALittle.UdpSystem:Ctor()
	___rawset(self, "_event", {})
end

function ALittle.UdpSystem:HandleUdpMessage(self_ip, self_port, remote_ip, remote_port, message)
	local event = self._event
	event.self_ip = self_ip
	event.self_port = self_port
	event.remote_ip = remote_ip
	event.remote_port = remote_port
	event.message = message
	self:DispatchEvent(___all_struct[-1948184705], event)
end

_G.A_UdpSystem = ALittle.UdpSystem()
end