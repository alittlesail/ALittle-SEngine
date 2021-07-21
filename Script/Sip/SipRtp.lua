-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs

ALittle.RegStruct(-1961403292, "ALittle.SipUseRtp", {
name = "ALittle.SipUseRtp", ns_name = "ALittle", rl_name = "SipUseRtp", hash_code = -1961403292,
name_list = {"from_rtp_ip","from_rtp_port","to_rtp_ip","to_rtp_port","from_ssrc","to_ssrc","call_id","sip_system"},
type_list = {"string","int","string","int","int","int","string","ALittle.SipSystem"},
option_map = {}
})
ALittle.RegStruct(-1599226887, "ALittle.RtpInfo", {
name = "ALittle.RtpInfo", ns_name = "ALittle", rl_name = "RtpInfo", hash_code = -1599226887,
name_list = {"call_id_map_port","cur_port","idle_list","total_count","use_count"},
type_list = {"Map<ALittle.SipSystem,Map<string,int>>","int","List<int>","int","int"},
option_map = {}
})

ALittle.SipRtp = Lua.Class(nil, "ALittle.SipRtp")

function ALittle.SipRtp:Ctor()
	___rawset(self, "_proxy_ip", "127.0.0.1")
	___rawset(self, "_proxy_yun_ip", "")
	___rawset(self, "_self_ip", "127.0.0.1")
	___rawset(self, "_self_yun_ip", "")
	___rawset(self, "_group_port_count", 2)
end

function ALittle.SipRtp:Setup(proxy_ip, proxy_yun_ip, self_ip, self_yun_ip, start_port, port_count)
	self._rtp_info = {}
	self._rtp_info.cur_port = start_port
	self._rtp_info.total_count = port_count
	self._rtp_info.use_count = 0
	self._rtp_info.call_id_map_port = {}
	self._rtp_info.idle_list = {}
	self._proxy_ip = proxy_ip
	self._proxy_yun_ip = proxy_yun_ip
	self._self_ip = self_ip
	self._self_yun_ip = self_yun_ip
end

function ALittle.SipRtp:Shutdown()
	__CPPAPI_ServerSchedule:ReleaseAllRtp()
end

function ALittle.SipRtp:UseRtp(sip_system, call_id, from_ip, from_ssrc, to_ssrc)
	self._rtp_info.use_count = self._rtp_info.use_count + (self._group_port_count)
	local first_port = 0
	if self._rtp_info.idle_list[1] ~= nil then
		first_port = self._rtp_info.idle_list[1]
		ALittle.List_Remove(self._rtp_info.idle_list, 1)
	else
		first_port = self._rtp_info.cur_port
		self._rtp_info.cur_port = self._rtp_info.cur_port + (self._group_port_count)
	end
	local call_id_map_port = self._rtp_info.call_id_map_port[sip_system]
	if call_id_map_port == nil then
		call_id_map_port = {}
		self._rtp_info.call_id_map_port[sip_system] = call_id_map_port
	end
	call_id_map_port[call_id] = first_port
	local from_rtp_ip
	local from_rtp_yun_ip
	local to_rtp_ip
	local to_rtp_yun_ip
	if self._self_ip == from_ip then
		from_rtp_ip = self._self_ip
		from_rtp_yun_ip = self._self_yun_ip
		to_rtp_ip = self._proxy_ip
		to_rtp_yun_ip = self._proxy_yun_ip
	else
		from_rtp_ip = self._proxy_ip
		from_rtp_yun_ip = self._proxy_yun_ip
		to_rtp_ip = self._self_ip
		to_rtp_yun_ip = self._self_yun_ip
	end
	local from_rtp_port = first_port
	local to_rtp_port = first_port + 1
	if from_rtp_yun_ip == "" or from_rtp_yun_ip == nil then
		from_rtp_yun_ip = from_rtp_ip
	end
	if to_rtp_yun_ip == "" or to_rtp_yun_ip == nil then
		to_rtp_yun_ip = to_rtp_ip
	end
	__CPPAPI_ServerSchedule:UseRtp(first_port, call_id, from_rtp_yun_ip, from_rtp_port, from_ssrc, to_rtp_yun_ip, to_rtp_port, to_ssrc)
	local result = {}
	result.call_id = call_id
	result.sip_system = sip_system
	result.from_rtp_ip = from_rtp_yun_ip
	result.from_rtp_port = from_rtp_port
	result.from_ssrc = from_ssrc
	result.to_rtp_ip = to_rtp_yun_ip
	result.to_rtp_port = to_rtp_port
	result.to_ssrc = to_ssrc
	return result
end

function ALittle.SipRtp:ReleaseRtp(sip_system, call_id)
	local first_port = self:GetRtpInfoByCallId(sip_system, call_id)
	if first_port == nil then
		return
	end
	local call_id_map_port = self._rtp_info.call_id_map_port[sip_system]
	if call_id_map_port == nil then
		return
	end
	call_id_map_port[call_id] = nil
	self._rtp_info.use_count = self._rtp_info.use_count - (self._group_port_count)
	ALittle.List_Push(self._rtp_info.idle_list, first_port)
	__CPPAPI_ServerSchedule:ReleaseRtp(first_port)
end

function ALittle.SipRtp:SetFromRtp(sip_system, call_id, rtp_ip, rtp_port)
	local first_port = self:GetRtpInfoByCallId(sip_system, call_id)
	if first_port == nil then
		return
	end
	__CPPAPI_ServerSchedule:SetFromRtp(first_port, rtp_ip, rtp_port)
end

function ALittle.SipRtp:SetToRtp(sip_system, call_id, rtp_ip, rtp_port)
	local first_port = self:GetRtpInfoByCallId(sip_system, call_id)
	if first_port == nil then
		return
	end
	__CPPAPI_ServerSchedule:SetToRtp(first_port, rtp_ip, rtp_port)
end

function ALittle.SipRtp:GetRtpInfoByCallId(sip_system, call_id)
	local call_id_map_port = self._rtp_info.call_id_map_port[sip_system]
	if call_id_map_port ~= nil then
		local first_port = call_id_map_port[call_id]
		if first_port ~= nil then
			return first_port
		end
	end
	return nil
end

end