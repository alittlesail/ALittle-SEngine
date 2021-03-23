-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___pairs = pairs
local ___ipairs = ipairs
local ___all_struct = ALittle.GetAllStruct()

ALittle.RegStruct(1715346212, "ALittle.Event", {
name = "ALittle.Event", ns_name = "ALittle", rl_name = "Event", hash_code = 1715346212,
name_list = {"target"},
type_list = {"ALittle.EventDispatcher"},
option_map = {}
})
ALittle.RegStruct(1390762725, "ALittle.SipLogEvent", {
name = "ALittle.SipLogEvent", ns_name = "ALittle", rl_name = "SipLogEvent", hash_code = 1390762725,
name_list = {"target","type","call_id","info"},
type_list = {"ALittle.EventDispatcher","string","string","string"},
option_map = {}
})
ALittle.RegStruct(689640541, "ALittle.SipRegisterSucceedEvent", {
name = "ALittle.SipRegisterSucceedEvent", ns_name = "ALittle", rl_name = "SipRegisterSucceedEvent", hash_code = 689640541,
name_list = {"target","nickname"},
type_list = {"ALittle.EventDispatcher","string"},
option_map = {}
})

assert(ALittle.EventDispatcher, " extends class:ALittle.EventDispatcher is nil")
ALittle.SipSystem = Lua.Class(ALittle.EventDispatcher, "ALittle.SipSystem")

function ALittle.SipSystem:Ctor()
end

function ALittle.SipSystem:HandleSipLog(type, call_id, info)
	local event = {}
	event.type = type
	event.call_id = call_id
	event.info = info
	self:DispatchEvent(___all_struct[1390762725], event)
end

function ALittle.SipSystem:HandleRegisterSucceed(nickname)
	local event = {}
	event.nickname = nickname
	self:DispatchEvent(___all_struct[689640541], event)
end

_G.A_SipSystem = ALittle.SipSystem()
end