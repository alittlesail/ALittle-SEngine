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
name_list = {"call_id","self_rtp_ip","self_rtp_port","client_rtp_ip_list","client_rtp_port","inner_rtp_ip","inner_rtp_port","remote_rtp_ip","remote_rtp_port","client_ssrc","server_ssrc"},
type_list = {"string","string","int","List<string>","int","string","int","string","int","int","int"},
option_map = {}
})
ALittle.RegStruct(-1961403292, "ALittle.SipUseRtp", {
name = "ALittle.SipUseRtp", ns_name = "ALittle", rl_name = "SipUseRtp", hash_code = -1961403292,
name_list = {"client_rtp_ip_list","client_rtp_port","self_rtp_ip","self_rtp_port","inner_rtp_ip","inner_rtp_port","session"},
type_list = {"List<string>","int","string","int","string","int","ALittle.MsgSessionTemplate<ALittle.MsgSessionNative,carp.CarpMessageWriteFactory>"},
option_map = {}
})
ALittle.RegStruct(-1949158135, "ALittle.SIP2RTP_NSetRemoteRtp", {
name = "ALittle.SIP2RTP_NSetRemoteRtp", ns_name = "ALittle", rl_name = "SIP2RTP_NSetRemoteRtp", hash_code = -1949158135,
name_list = {"call_id","remote_rtp_ip","remote_rtp_port"},
type_list = {"string","string","int"},
option_map = {}
})
ALittle.RegStruct(1861512184, "ALittle.SIP2RTP_NRelease", {
name = "ALittle.SIP2RTP_NRelease", ns_name = "ALittle", rl_name = "SIP2RTP_NRelease", hash_code = 1861512184,
name_list = {"call_id"},
type_list = {"string"},
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
name_list = {"client_ip_list","self_ip","inner_ip","call_id_map_port","cur_port","idle_list","total_count","use_count","min_port","max_port","session"},
type_list = {"List<string>","string","string","Map<string,int>","int","List<int>","int","int","int","int","ALittle.MsgSessionTemplate<ALittle.MsgSessionNative,carp.CarpMessageWriteFactory>"},
option_map = {}
})
ALittle.RegStruct(-114578914, "ALittle.SIP2RTP_NSetInnerRtp", {
name = "ALittle.SIP2RTP_NSetInnerRtp", ns_name = "ALittle", rl_name = "SIP2RTP_NSetInnerRtp", hash_code = -114578914,
name_list = {"call_id","inner_rtp_ip","inner_rtp_port"},
type_list = {"string","string","int"},
option_map = {}
})
ALittle.RegStruct(-27537649, "ALittle.SIP2RTP_NTransferToClient", {
name = "ALittle.SIP2RTP_NTransferToClient", ns_name = "ALittle", rl_name = "SIP2RTP_NTransferToClient", hash_code = -27537649,
name_list = {"call_id","client_ssrc"},
type_list = {"string","int"},
option_map = {}
})

ALittle.RtpSystem = Lua.Class(nil, "ALittle.RtpSystem")

function ALittle.RtpSystem:Ctor()
	___rawset(self, "_module_map_info", {})
end

function ALittle.RtpSystem:Setup(client_ip_list, self_ip, inner_ip, start_port, step_count)
	self._client_ip_list = client_ip_list
	self._self_ip = self_ip
	self._inner_ip = inner_ip
	self._start_port = start_port
	self._step_count = step_count
	A_SessionSystem:AddEventListener(___all_struct[-36908822], self, self.HandleAnyDisconnect)
	A_SessionSystem:AddEventListener(___all_struct[888437463], self, self.HandleAnyConnect)
end

function ALittle.RtpSystem:Release()
	A_SessionSystem:RemoveEventListener(___all_struct[-36908822], self, self.HandleAnyDisconnect)
	A_SessionSystem:RemoveEventListener(___all_struct[888437463], self, self.HandleAnyConnect)
end

function ALittle.RtpSystem:UseRtp(call_id, client_ssrc, server_ssrc, remote_rtp_ip, remote_rtp_port)
	local min = 2.0
	local target_info = nil
	local target_route_num = nil
	for route_num, info in ___pairs(self._module_map_info) do
		if info.total_count > 0 and info.total_count - info.use_count >= 4 then
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
	target_info.use_count = target_info.use_count + (3)
	local first_port = 0
	if target_info.idle_list[1] ~= nil then
		first_port = target_info.idle_list[1]
		ALittle.List_Remove(target_info.idle_list, 1)
	else
		first_port = target_info.cur_port
		target_info.cur_port = target_info.cur_port + (3)
	end
	target_info.call_id_map_port[call_id] = first_port
	local result = {}
	result.session = target_info.session
	result.client_rtp_ip_list = target_info.client_ip_list
	result.self_rtp_ip = target_info.self_ip
	result.inner_rtp_ip = target_info.inner_ip
	result.self_rtp_port = first_port
	result.client_rtp_port = first_port + 1
	result.inner_rtp_port = first_port + 2
	local msg = {}
	msg.call_id = call_id
	msg.self_rtp_ip = target_info.self_ip
	msg.self_rtp_port = result.self_rtp_port
	msg.client_rtp_ip_list = result.client_rtp_ip_list
	msg.client_rtp_port = result.client_rtp_port
	msg.inner_rtp_ip = result.inner_rtp_ip
	msg.inner_rtp_port = result.inner_rtp_port
	msg.remote_rtp_ip = remote_rtp_ip
	msg.remote_rtp_port = remote_rtp_port
	msg.client_ssrc = client_ssrc
	msg.server_ssrc = server_ssrc
	target_info.session:SendMsg(___all_struct[1995174805], msg)
	return result
end

function ALittle.RtpSystem:ReleaseRtp(call_id)
	local info, first_port = self:GetRtpInfoByCallId(call_id)
	if info == nil then
		return
	end
	info.call_id_map_port[call_id] = nil
	info.use_count = info.use_count - (3)
	ALittle.List_Push(info.idle_list, first_port)
	local msg = {}
	msg.call_id = call_id
	info.session:SendMsg(___all_struct[1861512184], msg)
end

function ALittle.RtpSystem:SetRemoteRtp(call_id, remote_rtp_ip, remote_rtp_port)
	local info, first_port = self:GetRtpInfoByCallId(call_id)
	if info == nil then
		return
	end
	local msg = {}
	msg.call_id = call_id
	msg.remote_rtp_ip = remote_rtp_ip
	msg.remote_rtp_port = remote_rtp_port
	info.session:SendMsg(___all_struct[-1949158135], msg)
end

function ALittle.RtpSystem:TransferToClient(call_id, client_ssrc)
	local info, first_port = self:GetRtpInfoByCallId(call_id)
	if info == nil then
		return
	end
	local msg = {}
	msg.call_id = call_id
	msg.client_ssrc = client_ssrc
	info.session:SendMsg(___all_struct[-27537649], msg)
end

function ALittle.RtpSystem:GetRtpInfoByCallId(call_id)
	for route_num, info in ___pairs(self._module_map_info) do
		local first_port = info.call_id_map_port[call_id]
		if first_port ~= nil then
			return info, first_port
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
	for call_id, port in ___pairs(info.call_id_map_port) do
		A_SipSystem:StopCall(call_id, "rtp server disconnect")
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
	info.client_ip_list = self._client_ip_list
	info.self_ip = self._self_ip
	info.inner_ip = self._inner_ip
	info.min_port = self._start_port + (event.route_num - 1) * self._step_count
	info.max_port = info.min_port + self._step_count - 1
	info.cur_port = info.min_port
	info.total_count = info.max_port - info.min_port + 1
	info.use_count = 0
	info.call_id_map_port = {}
	info.idle_list = {}
	ALittle.Log("new rtp:" .. info.min_port .. "," .. info.max_port)
end

_G.A_RtpSystem = ALittle.RtpSystem()
end