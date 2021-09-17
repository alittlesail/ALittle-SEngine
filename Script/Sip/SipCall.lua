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
ALittle.RegStruct(533527039, "ALittle.SipProxyRtp", {
name = "ALittle.SipProxyRtp", ns_name = "ALittle", rl_name = "SipProxyRtp", hash_code = 533527039,
name_list = {"from_rtp_ip","from_rtp_port","to_rtp_ip","to_rtp_port"},
type_list = {"string","int","string","int"},
option_map = {}
})

ALittle.SipStep = {
	OUT_INVITE = 0,
	OUT_TRYING = 1,
	OUT_RINGING = 2,
	OUT_CANCELING = 3,
	IN_INVITE = 4,
	IN_TRYING = 5,
	IN_RINGING = 6,
	IN_OK = 7,
	IN_FORBIDDEN = 8,
	TALK = 9,
	TALK_BYING = 10,
	TALK_END = 11,
}

ALittle.SipCall = Lua.Class(nil, "ALittle.SipCall")

function ALittle.SipCall:Ctor(sip_system)
	___rawset(self, "_support_100rel", false)
	___rawset(self, "_out_or_in", false)
	___rawset(self, "_callout_cseq", 0)
	___rawset(self, "_callout_invite_cseq", 0)
	___rawset(self, "_session_expires", 0)
	___rawset(self, "_session_expires_last_time", 0)
	___rawset(self, "_in_prack", false)
	___rawset(self, "_receive_183_180", false)
	___rawset(self, "_sip_send_time", 0)
	___rawset(self, "_sip_receive_time", 0)
	___rawset(self, "_invite_count", 0)
	___rawset(self, "_cancel_count", 0)
	___rawset(self, "_forbidden_count", 0)
	___rawset(self, "_ok_count", 0)
	___rawset(self, "_bye_count", 0)
	___rawset(self, "_start_time", 0)
	___rawset(self, "_anwser_time", 0)
	___rawset(self, "_sip_system", sip_system)
end

function ALittle.SipCall:DispatchStepChanged()
	local event = {}
	event.call_info = self
	self._sip_system:DispatchEvent(___all_struct[-1220217441], event)
end

function ALittle.SipCall:GetStatusString()
	if self._sip_step == 0 then
		return "out invite"
	end
	if self._sip_step == 1 then
		return "out trying"
	end
	if self._sip_step == 2 then
		return "out ringing"
	end
	if self._sip_step == 3 then
		return "out canceling"
	end
	if self._sip_step == 4 then
		return "in invite"
	end
	if self._sip_step == 5 then
		return "in trying"
	end
	if self._sip_step == 6 then
		return "in ringing"
	end
	if self._sip_step == 7 then
		return "in ok"
	end
	if self._sip_step == 8 then
		return "in forbidden"
	end
	if self._sip_step == 9 then
		return "talk"
	end
	if self._sip_step == 10 then
		return "talk bying"
	end
	if self._sip_step == 11 then
		return "talk end"
	end
	return "unknow"
end

function ALittle.SipCall:HandleSipInfo(method, status, response_list, content_list)
	self._sip_receive_time = ALittle.Time_GetCurTime()
	local sxx = ALittle.String_Sub(status, 1, 1)
	if method == "SIP/2.0" and (sxx == "4" or sxx == "5" or sxx == "6") and status ~= "401" and status ~= "407" then
		self:UpdateFailedReason(status, content_list)
	end
	if method == "UPDATE" then
		self:HandleCallSipUpdate(method, status, response_list, content_list)
	elseif self._sip_step == 0 then
		self:HandleSipInfoAtCallOutInvite(method, status, response_list, content_list)
	elseif self._sip_step == 1 then
		self:HandleSipInfoAtCallOutTrying(method, status, response_list, content_list)
	elseif self._sip_step == 2 then
		self:HandleSipInfoAtCallOutRinging(method, status, response_list, content_list)
	elseif self._sip_step == 3 then
		self:HandleSipInfoAtCallOutCanceling(method, status, response_list, content_list)
	elseif self._sip_step == 4 or self._sip_step == 5 or self._sip_step == 6 then
		self:HandleSipInfoAtCallInInvite(method, status, response_list, content_list)
	elseif self._sip_step == 7 then
		self:HandleSipInfoAtCallInOK(method, status, response_list, content_list)
	elseif self._sip_step == 8 then
		self:HandleSipInfoAtCallInForbidden(method, status, response_list, content_list)
	elseif self._sip_step == 9 then
		self:HandleSipInfoAtTalk(method, status, response_list, content_list)
	elseif self._sip_step == 10 then
		self:HandleSipInfoAtTalkBying(method, status, response_list, content_list)
	end
end

function ALittle.SipCall:StopCall(response, reason)
	self._stop_reason = reason
	if self._sip_step == 0 or self._sip_step == 1 or self._sip_step == 2 then
		self:CallOutCancel(reason)
	elseif self._sip_step == 4 or self._sip_step == 5 or self._sip_step == 6 then
		self:CallInForbidden(response, reason)
	elseif self._sip_step == 9 then
		self:TalkBye(reason)
	end
end

function ALittle.SipCall:TalkBye(reason)
	self:TalkByeImpl(reason)
	self._sip_system:AddResend(self)
end

function ALittle.SipCall:TalkByeImpl(reason)
	if reason == nil then
		reason = ""
	end
	local auth = self:GenProxyAuth("BYE", false)
	self._callout_cseq = self._callout_cseq + (1)
	local sip_head = self:GenCmd("BYE", not self._out_or_in)
	sip_head = sip_head .. self:GenFromToCallID(not self._out_or_in)
	sip_head = sip_head .. "CSeq: " .. self._callout_cseq .. " BYE\r\n"
	sip_head = sip_head .. self:GenVia(not self._out_or_in)
	sip_head = sip_head .. auth
	sip_head = sip_head .. "Reason: Q.850;cause=16;text=\"Normal call clearing\" " .. reason .. "\r\n"
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
	self._sip_step = 10
	self._sip_send_time = ALittle.Time_GetCurTime()
	self._bye_count = self._bye_count + (1)
	self:DispatchStepChanged()
end

function ALittle.SipCall:HandleSipInfoAtTalk(method, status, response_list, content_list)
	if method == "BYE" then
		local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
		local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
		local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
		local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
		local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
		local sip_head = "SIP/2.0 200 OK\r\n"
		sip_head = sip_head .. "Via: " .. via .. "\r\n"
		sip_head = sip_head .. "From: " .. from .. "\r\n"
		sip_head = sip_head .. "To: " .. to .. "\r\n"
		sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
	if method == "INVITE" then
		local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
		local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
		local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
		local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
		local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
		local sip_body = self:GenSDP()
		local sip_head = "SIP/2.0 200 OK\r\n"
		sip_head = sip_head .. "Via: " .. via .. "\r\n"
		sip_head = sip_head .. "From: " .. from .. "\r\n"
		sip_head = sip_head .. "To: " .. to .. "\r\n"
		sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Allow: INVITE,ACK,OPTIONS,REGISTER,INFO,BYE,UPDATE\r\n"
		sip_head = sip_head .. "Contact: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ">\r\n"
		if sip_body ~= nil and sip_body ~= "" then
			sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		end
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
		return
	end
	if method == "OPTIONS" then
		local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
		local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
		local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
		local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
		local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
		local sip_body = self:GenSDP()
		local sip_head = "SIP/2.0 200 OK\r\n"
		sip_head = sip_head .. "Via: " .. via .. "\r\n"
		sip_head = sip_head .. "From: " .. from .. "\r\n"
		sip_head = sip_head .. "To: " .. to .. "\r\n"
		sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Allow: INVITE,ACK,OPTIONS,REGISTER,INFO,BYE,UPDATE\r\n"
		sip_head = sip_head .. "Contact: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ">\r\n"
		if sip_body ~= nil and sip_body ~= "" then
			sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		end
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
		return
	end
	if method == "ACK" then
		local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
		self:UpdateRtpIpAndPort(rtp_ip, rtp_port)
		return
	end
	if method == "SIP/2.0" and status == "200" then
		local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
		if cseq_method == "INVITE" then
			local auth = self:GenProxyAuth("INVITE", true)
			local sip_head = self:GenCmd("ACK", false)
			sip_head = sip_head .. self:GenFromToCallID(false)
			sip_head = sip_head .. "CSeq: " .. self._callout_cseq .. " ACK\r\n"
			sip_head = sip_head .. self:GenVia(false)
			sip_head = sip_head .. auth
			sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
			sip_head = sip_head .. "Max-Forwards: 70\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
			return
		end
	end
end

function ALittle.SipCall:HandleSipInfoAtTalkBying(method, status, response_list, content_list)
	local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
	if method == "SIP/2.0" and status == "200" then
		if cseq_method == "BYE" then
			self:StopRecord()
			self._sip_step = 11
			self:DispatchStepChanged()
			return
		end
		if cseq_method == "INVITE" and self._sip_step ~= 9 then
			self:HandleResponseOKForInvite(status, content_list)
			return
		end
		return
	end
	if method == "BYE" then
		local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
		local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
		local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
		local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
		local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
		local sip_head = "SIP/2.0 200 OK\r\n"
		sip_head = sip_head .. "Via: " .. via .. "\r\n"
		sip_head = sip_head .. "From: " .. from .. "\r\n"
		sip_head = sip_head .. "To: " .. to .. "\r\n"
		sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
	local sxx = ALittle.String_Sub(status, 1, 1)
	if method == "SIP/2.0" and (sxx == "4" or sxx == "5" or sxx == "6") then
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
end

function ALittle.SipCall:SendSession(cur_time)
	if cur_time - self._session_expires_last_time < self._session_expires / 2 then
		return
	end
	self._session_expires_last_time = cur_time
	self._callout_cseq = self._callout_cseq + (1)
	local sip_body = self:GenSDP()
	local sip_head = self:GenCmd("UPDATE", not self._out_or_in)
	sip_head = sip_head .. self:GenFromToCallID(not self._out_or_in)
	sip_head = sip_head .. "CSeq: " .. self._callout_cseq .. " UPDATE\r\n"
	sip_head = sip_head .. self:GenVia(not self._out_or_in)
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Supported: timer\r\n"
	sip_head = sip_head .. "Require: timer\r\n"
	sip_head = sip_head .. "Session-Expires: " .. self._session_expires .. ";refresher=uac\r\n"
	sip_head = sip_head .. "Min-SE: " .. self._session_expires .. "\r\n"
	if sip_body ~= nil and sip_body ~= "" then
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	end
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
end

function ALittle.SipCall:UpdateFailedReason(status, content_list)
	self._failed_response = content_list[1]
	local reason = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REASON")
	if reason == nil then
		reason = ""
	elseif reason ~= "" then
		reason = reason .. " "
	end
	reason = reason .. "call sip step:" .. self:GetStatusString()
	if self._failed_reason == nil or self._failed_reason == "" then
		self._failed_reason = reason
	end
end

function ALittle.SipCall:HandleSipInfoCreateCallInInvite(method, status, response_list, content_list, self_sip_ip, self_sip_port, remote_sip_ip, remote_sip_port, rtp_transfer)
	self._sip_ip = remote_sip_ip
	self._sip_port = remote_sip_port
	self._sip_receive_time = ALittle.Time_GetCurTime()
	self._sip_send_time = self._sip_receive_time
	if self._start_time == nil or self._start_time == 0 then
		self._start_time = ALittle.Time_GetCurTime()
	end
	self._sip_step = 4
	self._out_or_in = false
	self._callin_invite_cseq = ALittle.SipCall.GetCseqFromUDP(content_list)
	if self._callin_invite_cseq == nil or self._callin_invite_cseq == 0 then
		self._callin_invite_cseq = 1
	end
	self._callout_cseq = 10
	self._from_sip_ip, self._from_sip_port, self._via_branch = self:GetViaFromUDP(content_list)
	self._from_number, self._from_tag = ALittle.SipCall.GetFromFromUDP(content_list)
	self._to_sip_ip = self_sip_ip
	self._to_sip_port = self_sip_port
	self._to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
	local rtp_ip = ""
	local rtp_port = 0
	self._audio_name, self._audio_number, self._dtmf_rtpmap, self._dtmf_fmtp, self._dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
	self._call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
	self._callin_allow = ALittle.SipCall.GetKeyValueFromUDP(content_list, "ALLOW")
	do
		local sip_head = "SIP/2.0 100 Trying\r\n"
		sip_head = sip_head .. self:GenFromToCallID(false)
		sip_head = sip_head .. "CSeq: " .. self._callin_invite_cseq .. " INVITE\r\n"
		sip_head = sip_head .. self:GenVia(false)
		sip_head = sip_head .. "Contact: <sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. ">\r\n"
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
	end
	self._sip_step = 5
	self:DispatchStepChanged()
	if not self._sip_system:CheckAccount(self._from_number, remote_sip_ip, remote_sip_port) then
		return "account is not exist"
	end
	if rtp_transfer then
		if self._sip_system._sip_rtp == nil then
			return "rtp is null"
		end
		self._use_rtp = self._sip_system._sip_rtp:UseRtp(self._sip_system, self._call_id, self_sip_ip)
		if self._use_rtp == nil then
			return "rtp resource is not enough"
		end
	else
		self._proxy_rtp = {}
	end
	self:UpdateRtpIpAndPort(rtp_ip, rtp_port)
	self._sip_system:AddResend(self)
	return nil
end

function ALittle.SipCall:CallInRinging()
	if self._sip_step == 5 then
		if self._to_tag == nil or self._to_tag == "" then
			self._to_tag = ALittle.String_Md5(ALittle.String_GenerateID("to_tag"))
		end
		local sip_body = self:GenSDP()
		local sip_head = "SIP/2.0 183 Session Progress\r\n"
		sip_head = sip_head .. self:GenFromToCallID(false)
		sip_head = sip_head .. "CSeq: " .. self._callin_invite_cseq .. " INVITE\r\n"
		sip_head = sip_head .. self:GenVia(false)
		sip_head = sip_head .. "Allow: " .. self._callin_allow .. "\r\n"
		sip_head = sip_head .. "Max-Forwards: 70\r\n"
		sip_head = sip_head .. "Contact: <sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. ">\r\n"
		if sip_body ~= nil and sip_body ~= "" then
			sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		end
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
		self._sip_step = 6
		self:DispatchStepChanged()
		self._sip_system:AddResend(self)
	end
end

function ALittle.SipCall:HandleSipInfoAtCallInInvite(method, status, response_list, content_list)
	if method == "CANCEL" then
		local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
		local sip_body = self:GenSDP()
		local sip_head = "SIP/2.0 200 OK\r\n"
		sip_head = sip_head .. self:GenFromToCallID(false)
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. self:GenVia(false)
		sip_head = sip_head .. "Max-Forwards: 70\r\n"
		if sip_body ~= nil and sip_body ~= "" then
			sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		end
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
end

function ALittle.SipCall:CallInForbidden(response, reason)
	if self._sip_step == 6 or self._sip_step == 4 or self._sip_step == 5 then
		self:CallInForbiddenImpl(response, reason)
		self._sip_system:AddResend(self)
	end
end

function ALittle.SipCall:CallInForbiddenImpl(response, reason)
	if self._to_tag == nil or self._to_tag == "" then
		self._to_tag = ALittle.String_Md5(ALittle.String_GenerateID("to_tag"))
	end
	if response == nil or response == "" then
		response = "SIP/2.0 403 Forbidden"
	end
	local sip_head = response .. "\r\n"
	sip_head = sip_head .. self:GenFromToCallID(false)
	sip_head = sip_head .. "CSeq: " .. self._callin_invite_cseq .. " INVITE\r\n"
	sip_head = sip_head .. self:GenVia(false)
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	if reason ~= nil then
		sip_head = sip_head .. "Reason: " .. reason .. "\r\n"
	end
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
	self._sip_step = 8
	self._sip_send_time = ALittle.Time_GetCurTime()
	self._forbidden_count = self._forbidden_count + (1)
	self:DispatchStepChanged()
end

function ALittle.SipCall:CallInOK()
	if self._sip_step == 6 or self._sip_step == 4 or self._sip_step == 5 then
		self:CallInOKImpl()
		self._sip_system:AddResend(self)
	end
end

function ALittle.SipCall:CallInOKImpl()
	if self._anwser_time == nil or self._anwser_time == 0 then
		self._anwser_time = ALittle.Time_GetCurTime()
	end
	local sip_body = self:GenSDP()
	local sip_head = "SIP/2.0 200 OK\r\n"
	sip_head = sip_head .. self:GenFromToCallID(false)
	sip_head = sip_head .. "CSeq: " .. self._callin_invite_cseq .. " INVITE\r\n"
	sip_head = sip_head .. self:GenVia(false)
	sip_head = sip_head .. "Allow: " .. self._callin_allow .. "\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Contact: <sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. ">\r\n"
	if sip_body ~= nil and sip_body ~= "" then
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	end
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
	self._sip_step = 7
	self._sip_send_time = ALittle.Time_GetCurTime()
	self._ok_count = self._ok_count + (1)
	self:DispatchStepChanged()
end

function ALittle.SipCall:HandleSipInfoAtCallInOK(method, status, response_list, content_list)
	if method == "ACK" then
		self:StartRecordTalking()
		self._sip_step = 9
		self._via_branch = "z9hG4bK-" .. ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
		self:DispatchStepChanged()
		return
	end
end

function ALittle.SipCall:HandleSipInfoAtCallInForbidden(method, status, response_list, content_list)
	if method == "ACK" then
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
	if method == "CANCEL" then
		local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
		local sip_body = self:GenSDP()
		local sip_head = "SIP/2.0 200 OK\r\n"
		sip_head = sip_head .. self:GenFromToCallID(false)
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. self:GenVia(false)
		sip_head = sip_head .. "Max-Forwards: 70\r\n"
		if sip_body ~= nil and sip_body ~= "" then
			sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		end
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
	if method == "BYE" then
		local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
		local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
		local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
		local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
		local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
		local sip_head = "SIP/2.0 200 OK\r\n"
		sip_head = sip_head .. "Via: " .. via .. "\r\n"
		sip_head = sip_head .. "From: " .. from .. "\r\n"
		sip_head = sip_head .. "To: " .. to .. "\r\n"
		sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
	end
end

function ALittle.SipCall:CallOutInvite(start_time)
	self:CallOutInviteImpl(start_time)
	self._sip_system:AddResend(self)
end

function ALittle.SipCall:CallOutInviteImpl(start_time)
	if self._start_time == nil or self._start_time == 0 then
		self._start_time = start_time
	end
	local sip_body = self:GenSDP()
	self._callout_cseq = 1
	local auth = self:GenProxyAuth("INVITE", true)
	if auth ~= nil and auth ~= "" then
		self._callout_cseq = 2
	end
	self._callout_invite_cseq = self._callout_cseq
	local support = ""
	if self._support_100rel then
		support = "Supported: 100rel,timer\r\n"
	end
	local sip_head = self:GenCmd("INVITE", false)
	sip_head = sip_head .. self:GenFromToCallID(false)
	sip_head = sip_head .. "CSeq: " .. self._callout_cseq .. " INVITE\r\n"
	sip_head = sip_head .. self:GenVia(false)
	sip_head = sip_head .. "Allow: INVITE,ACK,OPTIONS,REGISTER,INFO,BYE,UPDATE\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. support
	sip_head = sip_head .. "Contact: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ">\r\n"
	sip_head = sip_head .. auth
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	if sip_body ~= nil and sip_body ~= "" then
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	end
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
	self._sip_step = 0
	self._sip_send_time = ALittle.Time_GetCurTime()
	self._invite_count = self._invite_count + (1)
	self:DispatchStepChanged()
end

function ALittle.SipCall:CallOutCancel(reason)
	self:CallOutCancelImpl(reason)
	self._sip_system:AddResend(self)
end

function ALittle.SipCall:CallOutCancelImpl(reason)
	self._sip_step = 3
	self._sip_send_time = ALittle.Time_GetCurTime()
	self:DispatchStepChanged()
	if self._in_prack then
		return
	end
	self._cancel_count = self._cancel_count + (1)
	local auth = self:GenProxyAuth("CANCEL", true)
	local sip_head = self:GenCmd("CANCEL", false)
	sip_head = sip_head .. self:GenFromToCallID(false)
	sip_head = sip_head .. "CSeq: " .. self._callout_invite_cseq .. " CANCEL\r\n"
	sip_head = sip_head .. self:GenVia(false)
	sip_head = sip_head .. auth
	if reason ~= nil then
		sip_head = sip_head .. "Reason: " .. reason .. "\r\n"
	end
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
end

function ALittle.SipCall:CheckRequire100rel(content_list)
	local require = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REQUIRE")
	if require == nil or not self._support_100rel or ALittle.String_Find(require, "100rel") == nil then
		return
	end
	self._callout_cseq = self._callout_cseq + (1)
	self._in_prack = true
	local rseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "RSEQ")
	local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
	local sip_head = self:GenCmd("PRACK", false)
	sip_head = sip_head .. self:GenFromToCallID(false)
	sip_head = sip_head .. "CSeq: " .. self._callout_cseq .. " PRACK\r\n"
	sip_head = sip_head .. self:GenVia(false)
	sip_head = sip_head .. self:GenContact()
	sip_head = sip_head .. "RAck: " .. rseq .. " " .. cseq .. "\r\n"
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
end

function ALittle.SipCall:HandleSipInfoAtCallOutInvite(method, status, response_list, content_list)
	if method == "SIP/2.0" and (status == "100" or status == "181" or status == "182") then
		local to_number = ""
		if self._to_tag == nil or self._to_tag == "" then
			to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
		end
		self._sip_step = 1
		self:DispatchStepChanged()
		self._sip_system:AddResend(self)
		return
	end
	local sxx = ALittle.String_Sub(status, 1, 1)
	if method == "SIP/2.0" and (status == "183" or status == "180" or sxx == "4" or sxx == "5" or sxx == "6") then
		self:HandleSipInfoAtCallOutTrying(method, status, response_list, content_list)
		return
	end
end

function ALittle.SipCall:HandleSipInfoAtCallOutTrying(method, status, response_list, content_list)
	if method == "SIP/2.0" and (status == "183" or status == "180") then
		local to_number = ""
		if self._to_tag == nil or self._to_tag == "" then
			to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
		end
		local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
		self:UpdateRtpIpAndPort(rtp_ip, rtp_port)
		self._receive_183_180 = true
		self:StartRecordRinging()
		self._sip_step = 2
		self:DispatchStepChanged()
		self._sip_system:AddResend(self)
		self:CheckRequire100rel(content_list)
		return
	end
	if method == "SIP/2.0" and status == "200" then
		self:HandleSipInfoAtCallOutRinging(method, status, response_list, content_list)
		return
	end
	if method == "SIP/2.0" and status == "407" then
		local cseq = ALittle.SipCall.GetCseqFromUDP(content_list)
		if cseq == nil then
			cseq = self._callout_cseq
		end
		if self._callout_auth_nonce == nil or self._callout_auth_nonce == "" then
			local to_number = ""
			if self._to_tag == nil or self._to_tag == "" then
				to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
			end
			local sip_head = self:GenCmd("ACK", false)
			sip_head = sip_head .. self:GenFromToCallID(false)
			sip_head = sip_head .. "CSeq: " .. cseq .. " ACK\r\n"
			sip_head = sip_head .. self:GenVia(false)
			sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
			sip_head = sip_head .. "Max-Forwards: 70\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
			self._callout_auth_nonce, self._callout_auth_realm = ALittle.SipCall.GetNonceRealmFromUDP(content_list, "PROXY-AUTHENTICATE")
			self._to_tag = ""
			self._via_branch = "z9hG4bK-" .. ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
			self:CallOutInviteImpl(ALittle.Time_GetCurTime())
		else
			local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
			local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
			local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
			local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
			local sip_head = self:GenCmd("ACK", false)
			sip_head = sip_head .. "Via: " .. via .. "\r\n"
			sip_head = sip_head .. "From: " .. from .. "\r\n"
			sip_head = sip_head .. "To: " .. to .. "\r\n"
			sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
			sip_head = sip_head .. "CSeq: " .. cseq .. " ACK\r\n"
			sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
		end
		return
	end
	local sxx = ALittle.String_Sub(status, 1, 1)
	if method == "SIP/2.0" and (sxx == "4" or sxx == "5" or sxx == "6") then
		self:HandleSipInfoAtCallOutRinging(method, status, response_list, content_list)
		return
	end
end

function ALittle.SipCall:HandleSipInfoAtCallOutRinging(method, status, response_list, content_list)
	if method == "SIP/2.0" and status == "407" then
		return
	end
	local sxx = ALittle.String_Sub(status, 1, 1)
	if method == "SIP/2.0" and (sxx == "4" or sxx == "5" or sxx == "6") then
		local to_number = ""
		if self._to_tag == nil or self._to_tag == "" then
			to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
		end
		local sip_head = self:GenCmd("ACK", false)
		sip_head = sip_head .. self:GenFromToCallID(false)
		sip_head = sip_head .. "CSeq: " .. self._callout_invite_cseq .. " ACK\r\n"
		sip_head = sip_head .. self:GenVia(false)
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Max-Forwards: 70\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
		local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
		if status == "500" and cseq_method == "PRACK" then
			return
		end
		self:StopRecord()
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
	if method == "SIP/2.0" and (status == "183" or status == "180") then
		local to_number = ""
		if self._to_tag == nil or self._to_tag == "" then
			to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
		end
		local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
		self:UpdateRtpIpAndPort(rtp_ip, rtp_port)
		self:CheckRequire100rel(content_list)
		return
	end
	local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
	if method == "SIP/2.0" and status == "200" then
		if cseq_method == "INVITE" and self._sip_step ~= 9 then
			self:HandleResponseOKForInvite(status, content_list)
			self:StartRecordTalking()
			self._sip_step = 9
			self:DispatchStepChanged()
			return
		end
		if cseq_method == "PRACK" then
			self._in_prack = false
			return
		end
	end
	if method == "SIP/2.0" and status == "407" then
		local sip_head = self:GenCmd("ACK", false)
		sip_head = sip_head .. self:GenFromToCallID(false)
		sip_head = sip_head .. "CSeq: 1 ACK\r\n"
		sip_head = sip_head .. self:GenVia(false)
		sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
		sip_head = sip_head .. "Max-Forwards: 70\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
		return
	end
end

function ALittle.SipCall:HandleSipInfoAtCallOutCanceling(method, status, response_list, content_list)
	if method == "SIP/2.0" and status == "407" then
		return
	end
	local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
	local sxx = ALittle.String_Sub(status, 1, 1)
	if method == "SIP/2.0" and (sxx == "4" or sxx == "5" or sxx == "6") then
		if status == "500" and cseq_method == "CANCEL" then
		else
			local to_number = ""
			if self._to_tag == nil or self._to_tag == "" then
				to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
			end
			local sip_head = self:GenCmd("ACK", false)
			sip_head = sip_head .. self:GenFromToCallID(false)
			sip_head = sip_head .. "CSeq: " .. self._callout_cseq .. " ACK\r\n"
			sip_head = sip_head .. self:GenVia(false)
			sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
			sip_head = sip_head .. "Max-Forwards: 70\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
			self:StopRecord()
			self._sip_step = 11
			self:DispatchStepChanged()
			return
		end
	end
	if method == "SIP/2.0" and status == "200" then
		if cseq_method == "INVITE" and self._sip_step ~= 9 then
			self:HandleResponseOKForInvite(status, content_list)
			self:StartRecordTalking()
			self._sip_step = 9
			self:DispatchStepChanged()
			self:StopCall(nil, "正在Cancel的时候收到200接听事件，现在立刻发送bye来挂断电话")
			return
		end
		if cseq_method == "CANCEL" and self._sip_step ~= 9 then
			self:StopRecord()
			self._sip_step = 11
			self:DispatchStepChanged()
			return
		end
	end
end

function ALittle.SipCall:HandleResponseOKForInvite(status, content_list)
	if self._sip_step == 9 then
		return
	end
	local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
	if cseq_method ~= "INVITE" then
		return
	end
	local to_number = ""
	if self._to_tag == nil or self._to_tag == "" then
		to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
	end
	local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
	self:UpdateRtpIpAndPort(rtp_ip, rtp_port)
	if self._anwser_time == nil or self._anwser_time == 0 then
		self._anwser_time = ALittle.Time_GetCurTime()
	end
	local auth = self:GenProxyAuth("INVITE", true)
	local session_expires = ALittle.SipCall.GetKeyValueFromUDP(content_list, "SESSION-EXPIRES")
	local min_se = ALittle.SipCall.GetKeyValueFromUDP(content_list, "MIN-SE")
	local sip_head = self:GenCmd("ACK", false)
	sip_head = sip_head .. self:GenFromToCallID(false)
	sip_head = sip_head .. "CSeq: " .. cseq_number .. " ACK\r\n"
	sip_head = sip_head .. self:GenVia(false)
	sip_head = sip_head .. auth
	if session_expires ~= nil and session_expires ~= "" then
		sip_head = sip_head .. "Supported: timer\r\n"
		sip_head = sip_head .. "Require: timer\r\n"
		sip_head = sip_head .. "Session-Expires: " .. session_expires .. "\r\n"
		if min_se ~= nil and min_se ~= "" then
			sip_head = sip_head .. "Min-SE: " .. min_se .. "\r\n"
		end
		local session_expires_list = ALittle.String_Split(session_expires, ";")
		if session_expires_list[1] ~= nil then
			self._session_expires = ALittle.Math_ToIntOrZero(session_expires_list[1])
			if self._session_expires > 1 and session_expires_list[2] == "refresher=uac" then
				self._session_expires_last_time = 0
				self._sip_system:AddSession(self)
			end
		end
	end
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head, self._sip_ip, self._sip_port)
end

function ALittle.SipCall:HandleCallSipUpdate(method, status, response_list, content_list)
	local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
	local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
	local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
	local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
	local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
	local session_expires = ALittle.SipCall.GetKeyValueFromUDP(content_list, "SESSION-EXPIRES")
	local min_se = ALittle.SipCall.GetKeyValueFromUDP(content_list, "MIN-SE")
	local sip_head = "SIP/2.0 200 OK\r\n"
	sip_head = sip_head .. "Via: " .. via .. "\r\n"
	sip_head = sip_head .. "From: " .. from .. "\r\n"
	sip_head = sip_head .. "To: " .. to .. "\r\n"
	sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
	sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
	if session_expires ~= nil and session_expires ~= "" then
		sip_head = sip_head .. "Supported: timer\r\n"
		sip_head = sip_head .. "Require: timer\r\n"
		sip_head = sip_head .. "Session-Expires: " .. session_expires .. "\r\n"
		if min_se ~= nil and min_se ~= "" then
			sip_head = sip_head .. "Min-SE: " .. min_se .. "\r\n"
		end
	end
	local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
	self:UpdateRtpIpAndPort(rtp_ip, rtp_port)
	local sip_body = self:GenSDP()
	if sip_body ~= nil and sip_body ~= "" then
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	end
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
end

function ALittle.SipCall:HandleCallSipReInvite(method, status, response_list, content_list)
	local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
	local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
	local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
	local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
	local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
	local session_expires = ALittle.SipCall.GetKeyValueFromUDP(content_list, "SESSION-EXPIRES")
	local min_se = ALittle.SipCall.GetKeyValueFromUDP(content_list, "MIN-SE")
	local sip_head = "SIP/2.0 200 OK\r\n"
	sip_head = sip_head .. "Via: " .. via .. "\r\n"
	sip_head = sip_head .. "From: " .. from .. "\r\n"
	sip_head = sip_head .. "To: " .. to .. "\r\n"
	sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
	sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
	if session_expires ~= nil and session_expires ~= "" then
		sip_head = sip_head .. "Supported: timer\r\n"
		sip_head = sip_head .. "Require: timer\r\n"
		sip_head = sip_head .. "Session-Expires: " .. session_expires .. "\r\n"
		if min_se ~= nil and min_se ~= "" then
			sip_head = sip_head .. "Min-SE: " .. min_se .. "\r\n"
		end
	end
	sip_head = sip_head .. self:GenContact()
	local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
	self:UpdateRtpIpAndPort(rtp_ip, rtp_port)
	local sip_body = self:GenSDP()
	if sip_body ~= nil and sip_body ~= "" then
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	end
	sip_head = sip_head .. "Server: " .. self._sip_system._service_name .. "\r\n"
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	self._sip_system:Send(self._call_id, sip_head .. sip_body, self._sip_ip, self._sip_port)
end

function ALittle.SipCall:UpdateRtpIpAndPort(rtp_ip, rtp_port)
	if rtp_ip == nil or rtp_ip == "" then
		return
	end
	if rtp_port == nil or rtp_port == 0 then
		return
	end
	self._rtp_ip = rtp_ip
	self._rtp_port = rtp_port
	if self._use_rtp ~= nil then
		if self._out_or_in then
			self._sip_system._sip_rtp:SetToRtp(self._use_rtp.sip_system, self._use_rtp.call_id, rtp_ip, rtp_port)
		else
			self._sip_system._sip_rtp:SetFromRtp(self._use_rtp.sip_system, self._use_rtp.call_id, rtp_ip, rtp_port)
		end
	elseif self._proxy_rtp ~= nil then
		if self._out_or_in then
			self._proxy_rtp.from_rtp_ip = rtp_ip
			self._proxy_rtp.from_rtp_port = rtp_port
		else
			self._proxy_rtp.to_rtp_ip = rtp_ip
			self._proxy_rtp.to_rtp_port = rtp_port
		end
	end
end

function ALittle.SipCall:StartRecordRinging()
	if self._use_rtp == nil then
		return
	end
	if not self._sip_system._record_ringing then
		return
	end
	local file_name = self._from_number .. "_" .. self._to_number .. "_" .. self._use_rtp.call_id .. "_ringing.rtp"
	self._sip_system._sip_rtp:StartRecordRtp(self._use_rtp.sip_system, self._use_rtp.call_id, self._sip_system._record_ringing_path .. file_name)
end

function ALittle.SipCall:StartRecordTalking()
	if self._use_rtp == nil then
		return
	end
	if not self._sip_system._record_talking then
		return
	end
	local file_name = self._from_number .. "_" .. self._to_number .. "_" .. self._use_rtp.call_id .. "_talking.rtp"
	self._sip_system._sip_rtp:StartRecordRtp(self._use_rtp.sip_system, self._use_rtp.call_id, self._sip_system._record_talking_path .. file_name)
end

function ALittle.SipCall:StopRecord()
	if self._use_rtp == nil then
		return
	end
	self._sip_system._sip_rtp:StopRecordRtp(self._use_rtp.sip_system, self._use_rtp.call_id)
end

function ALittle.SipCall:GenProxyAuth(method, use_to_number)
	local auth = ""
	if self._callout_auth_nonce ~= nil and self._callout_auth_nonce ~= "" then
		local to_number = ""
		if use_to_number then
			to_number = self._to_number .. "@"
		end
		local uri = "sip:" .. to_number .. self._to_sip_ip .. ":" .. self._to_sip_port
		if self._to_sip_domain ~= nil and self._to_sip_domain ~= "" then
			uri = "sip:" .. to_number .. self._to_sip_domain
		end
		auth = ALittle.SipCall.GenAuth(self._callout_auth_nonce, self._callout_auth_realm, self._auth_account, self._auth_password, method, uri)
		auth = "Proxy-Authorization: " .. auth .. "\r\n"
	end
	return auth
end

function ALittle.SipCall.GenAuthResponse(nonce, realm, auth_account, auth_password, method, uri)
	local response_1 = ALittle.String_Md5(auth_account .. ":" .. realm .. ":" .. auth_password)
	local response_2 = ALittle.String_Md5(method .. ":" .. uri)
	local response = ALittle.String_Md5(response_1 .. ":" .. nonce .. ":" .. response_2)
	return response
end

function ALittle.SipCall.GenAuth(nonce, realm, auth_account, auth_password, method, uri)
	local response = ALittle.SipCall.GenAuthResponse(nonce, realm, auth_account, auth_password, method, uri)
	return "Digest username=\"" .. auth_account .. "\",realm=\"" .. realm .. "\",nonce=\"" .. nonce .. "\",uri=\"" .. uri .. "\",response=\"" .. response .. "\",algorithm=MD5"
end

function ALittle.SipCall:GenCmd(method, swap)
	if swap then
		if self._to_sip_domain ~= nil and self._to_sip_domain ~= "" then
			return method .. " sip:" .. self._from_number .. "@" .. self._to_sip_domain .. " SIP/2.0\r\n"
		else
			return method .. " sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. " SIP/2.0\r\n"
		end
	else
		if self._to_sip_domain ~= nil and self._to_sip_domain ~= "" then
			return method .. " sip:" .. self._to_number .. "@" .. self._to_sip_domain .. " SIP/2.0\r\n"
		else
			return method .. " sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. " SIP/2.0\r\n"
		end
	end
end

function ALittle.SipCall:GenFromToCallID(swap)
	local sip = ""
	if swap then
		if self._to_sip_domain ~= nil and self._to_sip_domain ~= "" then
			sip = sip .. "From: <sip:" .. self._to_number .. "@" .. self._to_sip_domain .. ";transport=UDP>"
		else
			sip = sip .. "From: <sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. ";transport=UDP>"
		end
		if self._to_tag ~= nil and self._to_tag ~= "" then
			sip = sip .. ";tag=" .. self._to_tag
		end
		sip = sip .. "\r\n"
		if self._to_sip_domain ~= nil and self._to_sip_domain ~= "" then
			sip = sip .. "To: <sip:" .. self._from_number .. "@" .. self._to_sip_domain .. ";transport=UDP>"
		else
			sip = sip .. "To: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ";transport=UDP>"
		end
		if self._from_tag ~= nil and self._from_tag ~= "" then
			sip = sip .. ";tag=" .. self._from_tag
		end
		sip = sip .. "\r\n"
	else
		if self._to_sip_domain ~= nil and self._to_sip_domain ~= "" then
			sip = sip .. "From: <sip:" .. self._from_number .. "@" .. self._to_sip_domain .. ";transport=UDP>"
		else
			sip = sip .. "From: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ";transport=UDP>"
		end
		if self._from_tag ~= nil and self._from_tag ~= "" then
			sip = sip .. ";tag=" .. self._from_tag
		end
		sip = sip .. "\r\n"
		if self._to_sip_domain ~= nil and self._to_sip_domain ~= "" then
			sip = sip .. "To: <sip:" .. self._to_number .. "@" .. self._to_sip_domain .. ";transport=UDP>"
		else
			sip = sip .. "To: <sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. ";transport=UDP>"
		end
		if self._to_tag ~= nil and self._to_tag ~= "" then
			sip = sip .. ";tag=" .. self._to_tag
		end
		sip = sip .. "\r\n"
	end
	sip = sip .. "Call-ID: " .. self._call_id .. "\r\n"
	return sip
end

function ALittle.SipCall:GenVia(swap)
	if swap then
		return "Via: SIP/2.0/UDP " .. self._to_sip_ip .. ":" .. self._to_sip_port .. ";rport;branch=" .. self._via_branch .. "\r\n"
	else
		return "Via: SIP/2.0/UDP " .. self._from_sip_ip .. ":" .. self._from_sip_port .. ";rport;branch=" .. self._via_branch .. "\r\n"
	end
end

function ALittle.SipCall:GenSDP()
	local rtp_ip
	local rtp_port
	if self._use_rtp ~= nil then
		rtp_ip = self._use_rtp.from_rtp_ip
		rtp_port = self._use_rtp.from_rtp_port
		if self._out_or_in then
			rtp_ip = self._use_rtp.to_rtp_ip
			rtp_port = self._use_rtp.to_rtp_port
		end
	elseif self._proxy_rtp ~= nil then
		rtp_ip = self._proxy_rtp.from_rtp_ip
		rtp_port = self._proxy_rtp.from_rtp_port
		if self._out_or_in then
			rtp_ip = self._proxy_rtp.to_rtp_ip
			rtp_port = self._proxy_rtp.to_rtp_port
		end
	end
	if rtp_ip == nil then
		return ""
	end
	if self._sdp_session == nil then
		self._sdp_session = ALittle.Time_GetCurTime() .. ""
	end
	local sdp = "v=0\r\n"
	sdp = sdp .. "o=- " .. self._sdp_session .. " " .. self._sdp_session .. " IN IP4 " .. rtp_ip .. "\r\n"
	sdp = sdp .. "s=" .. self._sip_system._service_name .. "\r\n"
	sdp = sdp .. "c=IN IP4 " .. rtp_ip .. "\r\n"
	sdp = sdp .. "t=0 0\r\n"
	sdp = sdp .. "m=audio " .. rtp_port .. " RTP/AVP " .. self._audio_number .. " " .. self._dtmf_number .. "\r\n"
	sdp = sdp .. "a=rtpmap:" .. self._audio_number .. " " .. self._audio_name .. "/8000\r\n"
	sdp = sdp .. "a=fmtp:" .. self._audio_number .. " annexb=no\r\n"
	sdp = sdp .. self._dtmf_rtpmap .. "\r\n"
	sdp = sdp .. self._dtmf_fmtp .. "\r\n"
	sdp = sdp .. "a=sendrecv\r\n"
	return sdp
end

function ALittle.SipCall:GenContact()
	if self._out_or_in then
		return "Contact: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ">\r\n"
	else
		return "Contact: <sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. ">\r\n"
	end
end

function ALittle.SipCall.GetKeyValueFromUDP(content_list, upper_key)
	for index, content in ___ipairs(content_list) do
		local key_value = ALittle.String_Split(content, ":")
		if ALittle.List_Len(key_value) >= 2 then
			if ALittle.String_Upper(ALittle.String_Trim(key_value[1])) == upper_key then
				ALittle.List_Remove(key_value, 1)
				return ALittle.String_Trim(ALittle.String_Join(key_value, ":"))
			end
		end
	end
	return nil
end

function ALittle.SipCall.GetNonceRealmFromUDP(content_list, upper_key)
	local value = ALittle.SipCall.GetKeyValueFromUDP(content_list, upper_key)
	if value == nil then
		return nil, nil, nil, nil
	end
	local nonce = ""
	do
		local pos_1 = ALittle.String_Find(value, "nonce=\"")
		if pos_1 == nil then
			return nil, nil, nil, nil
		end
		pos_1 = pos_1 + (ALittle.String_Len("nonce=\""))
		local pos_2 = ALittle.String_Find(value, "\"", pos_1)
		if pos_2 == nil then
			return nil, nil, nil, nil
		end
		nonce = ALittle.String_Sub(value, pos_1, pos_2 - 1)
	end
	local realm = ""
	do
		local pos_1 = ALittle.String_Find(value, "realm=\"")
		if pos_1 == nil then
			return nil, nil, nil, nil
		end
		pos_1 = pos_1 + (ALittle.String_Len("realm=\""))
		local pos_2 = ALittle.String_Find(value, "\"", pos_1)
		if pos_2 == nil then
			return nil, nil, nil, nil
		end
		realm = ALittle.String_Sub(value, pos_1, pos_2 - 1)
	end
	local uri = ""
	do
		local pos_1 = ALittle.String_Find(value, "uri=\"")
		if pos_1 ~= nil then
			pos_1 = pos_1 + (ALittle.String_Len("uri=\""))
			local pos_2 = ALittle.String_Find(value, "\"", pos_1)
			if pos_2 ~= nil then
				uri = ALittle.String_Sub(value, pos_1, pos_2 - 1)
			end
		end
	end
	local response = ""
	do
		local pos_1 = ALittle.String_Find(value, "response=\"")
		if pos_1 ~= nil then
			pos_1 = pos_1 + (ALittle.String_Len("response=\""))
			local pos_2 = ALittle.String_Find(value, "\"", pos_1)
			if pos_2 ~= nil then
				response = ALittle.String_Sub(value, pos_1, pos_2 - 1)
			end
		end
	end
	return nonce, realm, uri, response
end

function ALittle.SipCall.GetCseqFromUDP(content_list)
	local value = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
	if value == nil then
		return nil, nil
	end
	local split_list = ALittle.String_Split(value, " ", 1, true)
	return ALittle.Math_ToIntOrZero(split_list[1]), split_list[2]
end

function ALittle.SipCall:GetViaFromUDP(content_list)
	local value = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
	if value == nil then
		return nil, nil, nil
	end
	local pos = ALittle.String_Find(value, " ")
	if pos == nil then
		return nil, nil, nil
	end
	value = ALittle.String_Sub(value, pos + 1)
	local split_list = ALittle.String_Split(value, ";")
	if split_list[1] == nil then
		return nil, nil, nil
	end
	local split_list_sip = ALittle.String_Split(split_list[1], ":")
	if split_list_sip[1] == nil then
		return nil, nil, nil
	end
	local to_sip_ip = split_list_sip[1]
	local to_sip_port = "5060"
	if split_list_sip[2] ~= nil then
		to_sip_port = split_list_sip[2]
	end
	local branch = ""
	for index, content in ___ipairs(split_list) do
		pos = ALittle.String_Find(content, "branch=")
		if pos ~= nil then
			branch = ALittle.String_Sub(content, pos + 7)
			break
		end
	end
	return to_sip_ip, ALittle.Math_ToIntOrZero(to_sip_port), branch
end

function ALittle.SipCall.GetFromFromUDP(content_list)
	local value = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
	if value == nil then
		return nil, nil, nil
	end
	return ALittle.SipCall.GetFromOrToFromUDP(value)
end

function ALittle.SipCall.GetToFromUDP(content_list)
	local value = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
	if value == nil then
		return nil, nil, nil
	end
	return ALittle.SipCall.GetFromOrToFromUDP(value)
end

function ALittle.SipCall.GetFromOrToFromUDP(value)
	local pos_begin = ALittle.String_Find(value, "sip:")
	if pos_begin == nil then
		pos_begin = ALittle.String_Find(value, "tel:")
		if pos_begin == nil then
			return nil, nil, nil
		end
	end
	local pos_end_at = ALittle.String_Find(value, "@")
	local pos_end_semicolon = ALittle.String_Find(value, ";")
	local pos_end_brackets = ALittle.String_Find(value, ">")
	if pos_end_semicolon ~= nil and pos_end_semicolon ~= nil and pos_end_semicolon > pos_end_brackets then
		pos_end_semicolon = nil
	end
	local number_end = pos_end_at
	if number_end == nil then
		number_end = pos_end_semicolon
	end
	if number_end == nil then
		number_end = pos_end_brackets
	end
	if number_end == nil then
		return nil, nil, nil
	end
	if pos_begin >= number_end then
		return nil, nil, nil
	end
	local number = ALittle.String_Sub(value, pos_begin + 4, number_end - 1)
	local sip_end = pos_end_semicolon
	if sip_end == nil then
		sip_end = pos_end_brackets
	end
	if sip_end == nil then
		return nil, nil, nil
	end
	if pos_begin >= sip_end then
		return nil, nil, nil
	end
	local sip = ALittle.String_Sub(value, pos_begin + 4, sip_end - 1)
	local tag = ""
	local split_list = ALittle.String_Split(value, "tag=")
	if split_list[2] ~= nil then
		tag = split_list[2]
	end
	return number, tag, sip
end

function ALittle.SipCall:GetAudioInfoSDP(content_list)
	local rtp_ip = ""
	for index, content in ___ipairs(content_list) do
		local pos = ALittle.String_Find(content, "c=IN IP4 ")
		if pos ~= nil then
			rtp_ip = ALittle.String_Sub(content, pos + 9)
			break
		end
	end
	local rtp_port = 0
	for index, content in ___ipairs(content_list) do
		local pos = ALittle.String_Find(content, "m=audio ")
		if pos ~= nil then
			local split_list = ALittle.String_Split(content, " ")
			if split_list[2] ~= nil then
				rtp_port = ALittle.Math_ToIntOrZero(split_list[2])
			end
			break
		end
	end
	local audio_name = ""
	local audio_number = ""
	for index, content in ___ipairs(content_list) do
		if ALittle.String_Sub(content, 1, 1) == "a" then
			local pos = ALittle.String_Find(content, "G")
			if pos == nil then
				pos = ALittle.String_Find(content, "P")
			end
			if pos ~= nil then
				local pos_2 = ALittle.String_Find(content, "/")
				if pos_2 ~= nil then
					audio_name = ALittle.String_Sub(content, pos, pos_2 - 1)
				end
				local pos_3 = ALittle.String_Find(content, ":")
				if pos_3 ~= nil then
					audio_number = ALittle.String_Sub(content, pos_3 + 1, pos - 2)
				end
				break
			end
		end
	end
	local dtmf_rtpmap = ""
	local dtmf_number = ""
	for index, content in ___ipairs(content_list) do
		if ALittle.String_Sub(content, 1, 1) == "a" then
			local pos = ALittle.String_Find(content, "telephone-event")
			if pos ~= nil then
				dtmf_rtpmap = content
				local pos_1 = ALittle.String_Find(content, ":")
				local pos_2 = ALittle.String_Find(content, " ")
				if pos_1 ~= nil and pos_2 ~= nil then
					dtmf_number = ALittle.String_Sub(content, pos_1 + 1, pos_2 - 1)
				end
				break
			end
		end
	end
	local fmtp_number = "fmtp:" .. dtmf_number
	local dtmf_fmtp = ""
	for index, content in ___ipairs(content_list) do
		if ALittle.String_Sub(content, 1, 1) == "a" then
			local pos = ALittle.String_Find(content, fmtp_number)
			if pos ~= nil then
				dtmf_fmtp = content
				break
			end
		end
	end
	if audio_name == "" then
		audio_name = "PCMA"
		audio_number = "8"
	end
	return audio_name, ALittle.Math_ToIntOrZero(audio_number), dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port
end

end