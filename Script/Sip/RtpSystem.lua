-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs
local ___all_struct = ALittle.GetAllStruct()

ALittle.RegStruct(1995174805, "ALittle.SIP2RTP_NUse", {
name = "ALittle.SIP2RTP_NUse", ns_name = "ALittle", rl_name = "SIP2RTP_NUse", hash_code = 1995174805,
name_list = {"first_port","call_id","from_rtp_ip","from_rtp_port","from_ssrc","to_rtp_ip","to_rtp_port","to_ssrc"},
type_list = {"int","string","string","int","int","string","int","int"},
option_map = {}
})
ALittle.RegStruct(-1961403292, "ALittle.SipUseRtp", {
name = "ALittle.SipUseRtp", ns_name = "ALittle", rl_name = "SipUseRtp", hash_code = -1961403292,
name_list = {"from_rtp_ip","from_rtp_port","to_rtp_ip","to_rtp_port","from_ssrc","to_ssrc","call_id","sip_system","session"},
type_list = {"string","int","string","int","int","int","string","ALittle.SipSystem","ALittle.MsgSessionTemplate<ALittle.MsgSessionNative,carp.CarpMessageWriteFactory>"},
option_map = {}
})
ALittle.RegStruct(1861512184, "ALittle.SIP2RTP_NRelease", {
name = "ALittle.SIP2RTP_NRelease", ns_name = "ALittle", rl_name = "SIP2RTP_NRelease", hash_code = 1861512184,
name_list = {"first_port"},
type_list = {"int"},
option_map = {}
})
ALittle.RegStruct(1715346212, "ALittle.Event", {
name = "ALittle.Event", ns_name = "ALittle", rl_name = "Event", hash_code = 1715346212,
name_list = {"target"},
type_list = {"ALittle.EventDispatcher"},
option_map = {}
})
ALittle.RegStruct(-1599226887, "ALittle.RtpInfo", {
name = "ALittle.RtpInfo", ns_name = "ALittle", rl_name = "RtpInfo", hash_code = -1599226887,
name_list = {"proxy_ip","self_ip","call_id_map_port","cur_port","idle_list","total_count","use_count","min_port","max_port","session"},
type_list = {"string","string","Map<ALittle.SipSystem,Map<string,int>>","int","List<int>","int","int","int","int","ALittle.MsgSessionTemplate<ALittle.MsgSessionNative,carp.CarpMessageWriteFactory>"},
option_map = {}
})
ALittle.RegStruct(-936152749, "ALittle.SIP2RTP_NSetToRtp", {
name = "ALittle.SIP2RTP_NSetToRtp", ns_name = "ALittle", rl_name = "SIP2RTP_NSetToRtp", hash_code = -936152749,
name_list = {"first_port","rtp_ip","rtp_port"},
type_list = {"int","string","int"},
option_map = {}
})
ALittle.RegStruct(-295216066, "ALittle.SIP2RTP_NSetFromRtp", {
name = "ALittle.SIP2RTP_NSetFromRtp", ns_name = "ALittle", rl_name = "SIP2RTP_NSetFromRtp", hash_code = -295216066,
name_list = {"first_port","rtp_ip","rtp_port"},
type_list = {"int","string","int"},
option_map = {}
})

ALittle.RtpSystem = Lua.Class(nil, "ALittle.RtpSystem")

function ALittle.RtpSystem:Ctor()
	___rawset(self, "_module_map_info", {})
	___rawset(self, "_group_port_count", 2)
end

function ALittle.RtpSystem:Setup(proxy_ip, self_ip, start_port, step_count)
	self._proxy_ip = proxy_ip
	self._self_ip = self_ip
	self._start_port = start_port
	self._step_count = step_count
	A_SessionSystem:AddEventListener(___all_struct[-36908822], self, self.HandleAnyDisconnect)
	A_SessionSystem:AddEventListener(___all_struct[888437463], self, self.HandleAnyConnect)
end

function ALittle.RtpSystem:Shutdown()
	A_SessionSystem:RemoveEventListener(___all_struct[-36908822], self, self.HandleAnyDisconnect)
	A_SessionSystem:RemoveEventListener(___all_struct[888437463], self, self.HandleAnyConnect)
end

function ALittle.RtpSystem:UseRtp(sip_system, call_id, from_ip, from_ssrc, to_ssrc)
	local min = 2.0
	local target_info = nil
	local target_route_num = nil
	for route_num, info in ___pairs(self._module_map_info) do
		if info.total_count > 0 and info.total_count - info.use_count >= self._group_port_count then
			local rate = info.use_count / info.total_count
			if rate < min then
				target_info = info
				target_route_num = route_num
				min = rate
			end
		end
	end
	if target_info == nil then
		return nil
	end
	target_info.use_count = target_info.use_count + (self._group_port_count)
	local first_port = 0
	if target_info.idle_list[1] ~= nil then
		first_port = target_info.idle_list[1]
		ALittle.List_Remove(target_info.idle_list, 1)
	else
		first_port = target_info.cur_port
		target_info.cur_port = target_info.cur_port + (self._group_port_count)
	end
	local call_id_map_port = target_info.call_id_map_port[sip_system]
	if call_id_map_port == nil then
		call_id_map_port = {}
		target_info.call_id_map_port[sip_system] = call_id_map_port
	end
	call_id_map_port[call_id] = first_port
	local msg = {}
	msg.call_id = call_id
	msg.first_port = first_port
	if self._self_ip == from_ip then
		msg.from_rtp_ip = self._self_ip
		msg.to_rtp_ip = self._proxy_ip
	else
		msg.from_rtp_ip = self._proxy_ip
		msg.to_rtp_ip = self._self_ip
	end
	msg.from_rtp_port = first_port
	msg.to_rtp_port = first_port + 1
	msg.from_ssrc = from_ssrc
	msg.to_ssrc = to_ssrc
	target_info.session:SendMsg(___all_struct[1995174805], msg)
	local result = {}
	result.call_id = call_id
	result.sip_system = sip_system
	result.session = target_info.session
	result.from_rtp_ip = msg.from_rtp_ip
	result.from_rtp_port = msg.from_rtp_port
	result.from_ssrc = from_ssrc
	result.to_rtp_ip = msg.to_rtp_ip
	result.to_rtp_port = msg.to_rtp_port
	result.to_ssrc = to_ssrc
	return result
end

function ALittle.RtpSystem:ReleaseRtp(sip_system, call_id)
	local info, first_port = self:GetRtpInfoByCallId(sip_system, call_id)
	if info == nil then
		return
	end
	local call_id_map_port = info.call_id_map_port[sip_system]
	if call_id_map_port == nil then
		return
	end
	call_id_map_port[call_id] = nil
	info.use_count = info.use_count - (self._group_port_count)
	ALittle.List_Push(info.idle_list, first_port)
	local msg = {}
	msg.first_port = first_port
	info.session:SendMsg(___all_struct[1861512184], msg)
end

function ALittle.RtpSystem:SetFromRtp(sip_system, call_id, rtp_ip, rtp_port)
	local info, first_port = self:GetRtpInfoByCallId(sip_system, call_id)
	if info == nil then
		return
	end
	local msg = {}
	msg.first_port = first_port
	msg.rtp_ip = rtp_ip
	msg.rtp_port = rtp_port
	info.session:SendMsg(___all_struct[-295216066], msg)
end

function ALittle.RtpSystem:SetToRtp(sip_system, call_id, rtp_ip, rtp_port)
	local info, first_port = self:GetRtpInfoByCallId(sip_system, call_id)
	if info == nil then
		return
	end
	local msg = {}
	msg.first_port = first_port
	msg.rtp_ip = rtp_ip
	msg.rtp_port = rtp_port
	info.session:SendMsg(___all_struct[-936152749], msg)
end

function ALittle.RtpSystem:GetRtpInfoByCallId(sip_system, call_id)
	for route_num, info in ___pairs(self._module_map_info) do
		local call_id_map_port = info.call_id_map_port[sip_system]
		if call_id_map_port ~= nil then
			local first_port = call_id_map_port[call_id]
			if first_port ~= nil then
				return info, first_port
			end
		end
	end
	return nil, nil
end

function ALittle.RtpSystem:HandleAnyDisconnect(event)
	if event.route_type ~= 12 then
		return
	end
	local info = self._module_map_info[event.route_num]
	if info == nil then
		ALittle.Error("route_id(" .. event.route_num .. " is not exist!!!!!")
		return
	end
	for sip_system, call_id_map_port in ___pairs(info.call_id_map_port) do
		for call_id, port in ___pairs(call_id_map_port) do
			sip_system:StopCall(call_id, "rtp server disconnect")
		end
	end
	self._module_map_info[event.route_num] = nil
end

function ALittle.RtpSystem:HandleAnyConnect(event)
	if event.route_type ~= 12 then
		return
	end
	local info = self._module_map_info[event.route_num]
	if info ~= nil then
		ALittle.Error("route_id(" .. event.route_num .. " is already exist!!!!!")
		return
	end
	info = {}
	self._module_map_info[event.route_num] = info
	info.session = event.session
	info.proxy_ip = self._proxy_ip
	info.self_ip = self._self_ip
	info.min_port = self._start_port + (event.route_num - 1) * self._step_count
	info.max_port = info.min_port + self._step_count - 1
	info.cur_port = info.min_port
	info.total_count = info.max_port - info.min_port + 1
	info.use_count = 0
	info.call_id_map_port = {}
	info.idle_list = {}
	ALittle.Log("SipServer receive new rtp:" .. info.min_port .. "," .. info.max_port)
end

_G.A_RtpSystem = ALittle.RtpSystem()
end