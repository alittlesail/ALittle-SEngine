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

function ALittle.SipCall:Ctor()
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
	___rawset(self, "_client_ssrc", 0)
	___rawset(self, "_server_ssrc", 0)
end

function ALittle.SipCall:DispatchStepChanged()
	local event = {}
	event.call_info = self
	A_SipSystem:DispatchEvent(___all_struct[-1220217441], event)
end

function ALittle.SipCall:HandleSipInfo(method, status, response_list, content_list)
	self._sip_receive_time = ALittle.Time_GetCurTime()
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

function ALittle.SipCall:StopCall(reason)
	self._stop_reason = reason
	if self._sip_step == 0 or self._sip_step == 1 or self._sip_step == 2 then
		self:CallOutCancel()
	elseif self._sip_step == 4 or self._sip_step == 5 or self._sip_step == 6 then
		self:CallInForbidden()
	elseif self._sip_step == 9 then
		self:TalkBye()
	end
end

function ALittle.SipCall:TalkBye()
	self:TalkByeImpl()
	A_SipSystem:AddResend(self)
end

function ALittle.SipCall:TalkByeImpl()
	local auth = self:GenProxyAuth("BYE", false)
	self._callout_cseq = self._callout_cseq + (1)
	local sip_head = self:GenCmd("BYE", not self._out_or_in)
	sip_head = sip_head .. self:GenFromToCallID(not self._out_or_in)
	sip_head = sip_head .. "CSeq: " .. self._callout_cseq .. " BYE\r\n"
	sip_head = sip_head .. self:GenVia(not self._out_or_in)
	sip_head = sip_head .. auth
	sip_head = sip_head .. "Reason: Q.850;cause=16;text=\"Normal call clearing\"\r\n"
	sip_head = sip_head .. "User-Agent: ALittle\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	A_SipSystem:Send(sip_head)
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
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		A_SipSystem:Send(sip_head)
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
		sip_head = sip_head .. "User-Agent: ALittle\r\n"
		sip_head = sip_head .. "Allow: INVITE,ACK,OPTIONS,REGISTER,INFO,BYE,UPDATE\r\n"
		sip_head = sip_head .. "Contact: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ">\r\n"
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		A_SipSystem:Send(sip_head .. sip_body)
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
		sip_head = sip_head .. "User-Agent: ALittle\r\n"
		sip_head = sip_head .. "Allow: INVITE,ACK,OPTIONS,REGISTER,INFO,BYE,UPDATE\r\n"
		sip_head = sip_head .. "Contact: <sip:" .. self._from_number .. "@" .. self._from_sip_ip .. ":" .. self._from_sip_port .. ">\r\n"
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		A_SipSystem:Send(sip_head .. sip_body)
		return
	end
	if method == "ACK" then
		local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
		if rtp_ip ~= nil and rtp_ip ~= "" then
			A_RtpSystem:SetRemoteRtp(self._call_id, rtp_ip, rtp_port)
		end
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
			sip_head = sip_head .. "User-Agent: ALittle\r\n"
			sip_head = sip_head .. "Max-Forwards: 70\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			local reason = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REASON")
			if reason ~= nil and reason ~= "" then
				self._stop_reason = reason
			end
			return
		end
	end
end

function ALittle.SipCall:HandleSipInfoAtTalkBying(method, status, response_list, content_list)
	local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
	if method == "SIP/2.0" and status == "200" then
		if cseq_method == "BYE" then
			self._sip_step = 11
			self:DispatchStepChanged()
			return
		end
		if cseq_method == "INVITE" and self._sip_step ~= 9 then
			self:HandleResponseOKForInvite(content_list)
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
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		A_SipSystem:Send(sip_head)
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
	local sxx = ALittle.String_Sub(status, 1, 1)
	if method == "SIP/2.0" and (sxx == "4" or sxx == "5" or sxx == "6") then
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
	sip_head = sip_head .. "User-Agent: ALittle\r\n"
	sip_head = sip_head .. "Supported: timer\r\n"
	sip_head = sip_head .. "Require: timer\r\n"
	sip_head = sip_head .. "Session-Expires: " .. self._session_expires .. ";refresher=uac\r\n"
	sip_head = sip_head .. "Min-SE: " .. self._session_expires .. "\r\n"
	sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	A_SipSystem:Send(sip_head .. sip_body)
end

function ALittle.SipCall:HandleSipInfoCreateCallInInvite(method, status, response_list, content_list, self_sip_ip, self_sip_port)
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
	if rtp_ip ~= nil and rtp_ip ~= "" then
		A_RtpSystem:SetRemoteRtp(self._call_id, rtp_ip, rtp_port)
	end
	self._call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
	self._callin_allow = ALittle.SipCall.GetKeyValueFromUDP(content_list, "ALLOW")
	do
		local sip_head = "SIP/2.0 100 Trying\r\n"
		sip_head = sip_head .. self:GenFromToCallID(false)
		sip_head = sip_head .. "CSeq: " .. self._callin_invite_cseq .. " INVITE\r\n"
		sip_head = sip_head .. self:GenVia(false)
		sip_head = sip_head .. "Contact: <sip:" .. self._to_number .. "@" .. self._to_sip_ip .. ":" .. self._to_sip_port .. ">\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		A_SipSystem:Send(sip_head)
	end
	self._sip_step = 5
	self._client_ssrc = ALittle.Math_RandomInt(1, 100000)
	self._server_ssrc = ALittle.Math_RandomInt(1, 100000)
	local use_rtp = A_RtpSystem:UseRtp(self._call_id, self._client_ssrc, self._server_ssrc, rtp_ip, rtp_port)
	if use_rtp == nil then
		return false
	end
	self._use_rtp = use_rtp
	do
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
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		A_SipSystem:Send(sip_head .. sip_body)
	end
	self._sip_step = 6
	A_SipSystem:AddResend(self)
	self:DispatchStepChanged()
	return true
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
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		A_SipSystem:Send(sip_head .. sip_body)
		self._sip_step = 11
		self:DispatchStepChanged()
		return
	end
end

function ALittle.SipCall:CallInForbidden()
	if self._sip_step == 6 or self._sip_step == 4 or self._sip_step == 5 then
		self:CallInForbiddenImpl()
	end
end

function ALittle.SipCall:CallInForbiddenImpl()
	if self._to_tag == nil or self._to_tag == "" then
		self._to_tag = ALittle.String_Md5(ALittle.String_GenerateID("to_tag"))
	end
	local sip_head = "SIP/2.0 403 Forbidden\r\n"
	sip_head = sip_head .. self:GenFromToCallID(false)
	sip_head = sip_head .. "CSeq: " .. self._callin_invite_cseq .. " INVITE\r\n"
	sip_head = sip_head .. self:GenVia(false)
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	A_SipSystem:Send(sip_head)
	self._sip_step = 8
	self._sip_send_time = ALittle.Time_GetCurTime()
	self._forbidden_count = self._forbidden_count + (1)
	self:DispatchStepChanged()
end

function ALittle.SipCall:CallInOK()
	if self._sip_step == 6 or self._sip_step == 4 or self._sip_step == 5 then
		self:CallInOKImpl()
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
	sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	A_SipSystem:Send(sip_head .. sip_body)
	self._sip_step = 7
	self._sip_send_time = ALittle.Time_GetCurTime()
	self._ok_count = self._ok_count + (1)
	self:DispatchStepChanged()
end

function ALittle.SipCall:HandleSipInfoAtCallInOK(method, status, response_list, content_list)
	if method == "ACK" then
		self._sip_step = 9
		self._via_branch = "z9hG4bK-" .. ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
		self:DispatchStepChanged()
		return
	end
end

function ALittle.SipCall:HandleSipInfoAtCallInForbidden(method, status, response_list, content_list)
	if method == "ACK" then
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
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
		sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
		A_SipSystem:Send(sip_head .. sip_body)
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
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		A_SipSystem:Send(sip_head)
		self._sip_step = 11
		self:DispatchStepChanged()
	end
end

function ALittle.SipCall:CallOutInvite(start_time)
	self:CallOutInviteImpl(start_time)
	A_SipSystem:AddResend(self)
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
	sip_head = sip_head .. "User-Agent: ALittle\r\n"
	sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	A_SipSystem:Send(sip_head .. sip_body)
	self._sip_step = 0
	self._sip_send_time = ALittle.Time_GetCurTime()
	self._invite_count = self._invite_count + (1)
	self:DispatchStepChanged()
end

function ALittle.SipCall:CallOutCancel()
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
	sip_head = sip_head .. "User-Agent: ALittle\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	A_SipSystem:Send(sip_head)
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
	sip_head = sip_head .. "User-Agent: ALittle\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	A_SipSystem:Send(sip_head)
end

function ALittle.SipCall:HandleSipInfoAtCallOutInvite(method, status, response_list, content_list)
	if method == "SIP/2.0" and (status == "100" or status == "181" or status == "182") then
		local to_number = ""
		if self._to_tag == nil or self._to_tag == "" then
			to_number, self._to_tag = ALittle.SipCall.GetToFromUDP(content_list)
		end
		self._sip_step = 1
		self:DispatchStepChanged()
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
		if rtp_ip ~= nil and rtp_ip ~= "" then
			A_RtpSystem:SetRemoteRtp(self._call_id, rtp_ip, rtp_port)
		end
		local reason = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REASON")
		if reason ~= nil and reason ~= "" then
			self._stop_reason = reason
		end
		self._receive_183_180 = true
		self._sip_step = 2
		self:DispatchStepChanged()
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
			sip_head = sip_head .. "User-Agent: ALittle\r\n"
			sip_head = sip_head .. "Max-Forwards: 70\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			A_SipSystem:Send(sip_head)
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
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			A_SipSystem:Send(sip_head)
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
		sip_head = sip_head .. "User-Agent: ALittle\r\n"
		sip_head = sip_head .. "Max-Forwards: 70\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		A_SipSystem:Send(sip_head)
		local reason = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REASON")
		if reason == nil or reason == "" then
			reason = status .. "-FAILED"
		end
		if self._stop_reason == nil or self._stop_reason == "" then
			self._stop_reason = reason
		end
		local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
		if status == "500" and cseq_method == "PRACK" then
			return
		end
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
		if rtp_ip ~= nil and rtp_ip ~= "" then
			A_RtpSystem:SetRemoteRtp(self._call_id, rtp_ip, rtp_port)
		end
		local reason = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REASON")
		if reason ~= nil and reason ~= "" then
			self._stop_reason = reason
		end
		self:CheckRequire100rel(content_list)
		return
	end
	local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
	if method == "SIP/2.0" and status == "200" then
		if cseq_method == "INVITE" and self._sip_step ~= 9 then
			self:HandleResponseOKForInvite(content_list)
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
		sip_head = sip_head .. "User-Agent: ALittle\r\n"
		sip_head = sip_head .. "Max-Forwards: 70\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		A_SipSystem:Send(sip_head)
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
			sip_head = sip_head .. "User-Agent: ALittle\r\n"
			sip_head = sip_head .. "Max-Forwards: 70\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			A_SipSystem:Send(sip_head)
			local reason = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REASON")
			if reason == nil or reason == "" then
				reason = status .. "-CANCELING-FAILED"
			end
			if reason ~= nil and reason ~= "" then
				self._stop_reason = reason
			end
			self._sip_step = 11
			self:DispatchStepChanged()
			return
		end
	end
	if method == "SIP/2.0" and status == "200" then
		if cseq_method == "INVITE" and self._sip_step ~= 9 then
			self:HandleResponseOKForInvite(content_list)
			self._sip_step = 9
			self:DispatchStepChanged()
			self:StopCall("正在Cancel的时候收到200接听事件，现在立刻发送bye来挂断电话")
			return
		end
	end
end

function ALittle.SipCall:HandleResponseOKForInvite(content_list)
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
	if rtp_ip ~= nil and rtp_ip ~= "" then
		A_RtpSystem:SetRemoteRtp(self._call_id, rtp_ip, rtp_port)
	end
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
				A_SipSystem:AddSession(self)
			end
		end
	end
	sip_head = sip_head .. "User-Agent: ALittle\r\n"
	sip_head = sip_head .. "Max-Forwards: 70\r\n"
	sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
	A_SipSystem:Send(sip_head)
	local reason = ALittle.SipCall.GetKeyValueFromUDP(content_list, "REASON")
	if reason ~= nil and reason ~= "" then
		self._stop_reason = reason
	end
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
	local sip_body = ""
	local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
	if rtp_ip ~= nil and rtp_ip ~= "" then
		A_RtpSystem:SetRemoteRtp(self._call_id, rtp_ip, rtp_port)
		sip_body = self:GenSDP()
		sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	end
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	A_SipSystem:Send(sip_head .. sip_body)
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
	local sip_body = ""
	local audio_name, audio_number, dtmf_rtpmap, dtmf_fmtp, dtmf_number, rtp_ip, rtp_port = self:GetAudioInfoSDP(content_list)
	if rtp_ip ~= nil and rtp_ip ~= "" then
		A_RtpSystem:SetRemoteRtp(self._call_id, rtp_ip, rtp_port)
	end
	sip_body = self:GenSDP()
	sip_head = sip_head .. "Content-Type: application/sdp\r\n"
	sip_head = sip_head .. "Content-Length: " .. ALittle.String_Len(sip_body) .. "\r\n\r\n"
	A_SipSystem:Send(sip_head .. sip_body)
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
		auth = ALittle.SipCall.GenAuth(self._callout_auth_nonce, self._callout_auth_realm, self._account, self._password, method, uri)
		auth = "Proxy-Authorization: " .. auth .. "\r\n"
	end
	return auth
end

function ALittle.SipCall.GenAuth(nonce, realm, account, password, method, uri)
	local response_1 = ALittle.String_Md5(account .. ":" .. realm .. ":" .. password)
	local response_2 = ALittle.String_Md5(method .. ":" .. uri)
	local response = ALittle.String_Md5(response_1 .. ":" .. nonce .. ":" .. response_2)
	return "Digest username=\"" .. account .. "\",realm=\"" .. realm .. "\",nonce=\"" .. nonce .. "\",uri=\"" .. uri .. "\",response=\"" .. response .. "\",algorithm=MD5"
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
	local sdp = "v=0\r\n"
	sdp = sdp .. "o=- 4 2 IN IP4 " .. self._use_rtp.self_rtp_ip .. "\r\n"
	sdp = sdp .. "s=ALittle\r\n"
	sdp = sdp .. "c=IN IP4 " .. self._use_rtp.self_rtp_ip .. "\r\n"
	sdp = sdp .. "t=0 0\r\n"
	sdp = sdp .. "m=audio " .. self._use_rtp.self_rtp_port .. " RTP/AVP " .. self._audio_number .. " " .. self._dtmf_number .. "\r\n"
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
		return nil, nil
	end
	local nonce = ""
	do
		local pos_1 = ALittle.String_Find(value, "nonce=\"")
		if pos_1 == nil then
			return nil, nil
		end
		pos_1 = pos_1 + (ALittle.String_Len("nonce=\""))
		local pos_2 = ALittle.String_Find(value, "\"", pos_1)
		if pos_2 == nil then
			return nil, nil
		end
		nonce = ALittle.String_Sub(value, pos_1, pos_2 - 1)
	end
	local realm = ""
	do
		local pos_1 = ALittle.String_Find(value, "realm=\"")
		if pos_1 == nil then
			return nil, nil
		end
		pos_1 = pos_1 + (ALittle.String_Len("realm=\""))
		local pos_2 = ALittle.String_Find(value, "\"", pos_1)
		if pos_2 == nil then
			return nil, nil
		end
		realm = ALittle.String_Sub(value, pos_1, pos_2 - 1)
	end
	return nonce, realm
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
		return nil, nil
	end
	return ALittle.SipCall.GetFromOrToFromUDP(value)
end

function ALittle.SipCall.GetToFromUDP(content_list)
	local value = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
	if value == nil then
		return nil, nil
	end
	return ALittle.SipCall.GetFromOrToFromUDP(value)
end

function ALittle.SipCall.GetFromOrToFromUDP(value)
	local pos_begin = ALittle.String_Find(value, "sip:")
	if pos_begin == nil then
		pos_begin = ALittle.String_Find(value, "tel:")
		if pos_begin == nil then
			return nil, nil
		end
	end
	local pos_end = ALittle.String_Find(value, "@")
	if pos_end == nil then
		pos_end = ALittle.String_Find(value, ";")
		if pos_end == nil then
			pos_end = ALittle.String_Find(value, ">")
		end
		if pos_end == nil then
			return nil, nil
		end
	end
	if pos_begin >= pos_end then
		return nil, nil
	end
	local from_number = ALittle.String_Sub(value, pos_begin + 4, pos_end - 1)
	local from_tag = ""
	local split_list = ALittle.String_Split(value, "tag=")
	if split_list[2] ~= nil then
		from_tag = split_list[2]
	end
	return from_number, from_tag
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