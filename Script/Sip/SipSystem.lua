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
ALittle.RegStruct(-1220217441, "ALittle.SipCallStepEvent", {
name = "ALittle.SipCallStepEvent", ns_name = "ALittle", rl_name = "SipCallStepEvent", hash_code = -1220217441,
name_list = {"target","call_info"},
type_list = {"ALittle.EventDispatcher","ALittle.SipCall"},
option_map = {}
})

assert(ALittle.EventDispatcher, " extends class:ALittle.EventDispatcher is nil")
ALittle.SipSystem = Lua.Class(ALittle.EventDispatcher, "ALittle.SipSystem")

function ALittle.SipSystem:Ctor()
	___rawset(self, "_self_ip", "127.0.0.1")
	___rawset(self, "_self_port", 5060)
	___rawset(self, "_remote_ip", "127.0.0.1")
	___rawset(self, "_remote_port", 5060)
	___rawset(self, "_remote_domain", "")
	___rawset(self, "_support_100_rel", false)
	___rawset(self, "_call_map", {})
end

function ALittle.SipSystem:Setup(self_ip, self_port, remote_ip, remote_port, remote_domain)
	self._self_ip = self_ip
	self._self_port = self_port
	self._remote_ip = remote_ip
	self._remote_port = remote_port
	self._remote_domain = remote_domain
	__CPPAPI_ServerSchedule:CreateUdpServer(self._self_ip, self._self_port)
	A_UdpSystem:AddEventListener(___all_struct[-1948184705], self, self.HandleSipInfo)
	self._resend_weak_map = ALittle.CreateKeyWeakMap()
	self._session_weak_map = ALittle.CreateKeyWeakMap()
	self._loop_resend = ALittle.LoopFunction(Lua.Bind(self.HandleUpdateResend, self), -1, 1000, 1000)
	self._loop_resend:Start()
	self._loop_session = ALittle.LoopFunction(Lua.Bind(self.HandleUpdateSession, self), -1, 6000, 1000)
	self._loop_session:Start()
end

function ALittle.SipSystem:Shutdown()
	A_UdpSystem:RemoveEventListener(___all_struct[-1948184705], self, self.HandleSipInfo)
	if self._loop_resend ~= nil then
		self._loop_resend:Stop()
		self._loop_resend = nil
	end
	if self._loop_session ~= nil then
		self._loop_session:Stop()
		self._loop_session = nil
	end
end

function ALittle.SipSystem:AddResend(call)
	self._resend_weak_map[call] = true
end

function ALittle.SipSystem:AddSession(call)
	self._session_weak_map[call] = true
end

function ALittle.SipSystem:Send(message)
	__CPPAPI_ServerSchedule:SendUdpMessage(self._self_ip, self._self_port, self._remote_ip, self._remote_port, message)
	ALittle.Log("SEND==>")
	ALittle.Log(message)
end

function ALittle.SipSystem:ReleaseCall(call_info)
	ALittle.Log("Release call_id:" .. call_info._call_id)
	A_RtpSystem:ReleaseRtp(call_info._call_id)
	self._call_map[call_info._call_id] = nil
	self._session_weak_map[call_info] = nil
	self._resend_weak_map[call_info] = nil
end

function ALittle.SipSystem:HandleUpdateResend()
	local cur_time = ALittle.Time_GetCurTime()
	local remove_map
	for call_info, _ in ___pairs(self._resend_weak_map) do
		if call_info._sip_step == 9 then
			if remove_map == nil then
				remove_map = {}
			end
			remove_map[call_info] = false
		elseif call_info._sip_step == 0 then
			if call_info._invite_count < 5 then
				if cur_time - call_info._sip_send_time > 2 then
					call_info:CallOutInviteImpl(cur_time)
				end
			else
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		elseif call_info._sip_step == 1 then
			if cur_time - call_info._sip_receive_time > 60 * 10 then
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		elseif call_info._sip_step == 2 then
			if cur_time - call_info._sip_receive_time > 60 * 10 then
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		elseif call_info._sip_step == 3 then
			if call_info._cancel_count < 15 then
				if cur_time - call_info._sip_send_time >= 1 then
					call_info:CallOutCancel()
				end
			else
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		elseif call_info._sip_step == 8 then
			if call_info._forbidden_count < 5 then
				if cur_time - call_info._sip_send_time > 10 then
					call_info:CallInForbiddenImpl()
				end
			else
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		elseif call_info._sip_step == 6 then
			if cur_time - call_info._sip_send_time > 60 * 10 then
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		elseif call_info._sip_step == 7 then
			if call_info._ok_count < 50 then
				if cur_time - call_info._sip_send_time > 30 then
					call_info:CallInOKImpl()
				end
			else
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		elseif call_info._sip_step == 10 then
			if call_info._bye_count < 50 then
				if cur_time - call_info._sip_send_time > 30 then
					call_info:TalkByeImpl()
				end
			else
				if remove_map == nil then
					remove_map = {}
				end
				remove_map[call_info] = true
			end
		end
	end
	if remove_map ~= nil then
		for call_info, need_release in ___pairs(remove_map) do
			self._resend_weak_map[call_info] = nil
			if need_release then
				self:ReleaseCall(call_info)
			end
		end
	end
end

function ALittle.SipSystem:HandleUpdateSession()
	local cur_time = ALittle.Time_GetCurTime()
	for call_info, _ in ___pairs(self._session_weak_map) do
		if call_info._sip_step ~= 11 then
			call_info:SendSession(cur_time)
		end
	end
end

function ALittle.SipSystem:HandleSipInfo(event)
	ALittle.Log("RECEIVE <===", event.remote_ip .. ":" .. event.remote_port)
	ALittle.Log(event.message)
	local content_list = ALittle.String_Split(event.message, "\r\n")
	local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
	if call_id == nil or call_id == "" then
		return
	end
	if content_list[1] == nil then
		return
	end
	local response_list = ALittle.String_Split(content_list[1], " ")
	if response_list[1] == nil then
		return
	end
	local method = response_list[1]
	local status = ""
	if method == "SIP/2.0" then
		if response_list[2] == nil then
			return
		end
		status = response_list[2]
	end
	local cseq_number, cseq_method = ALittle.SipCall.GetCseqFromUDP(content_list)
	if cseq_method == "REGISTER" then
		if status == "401" then
			local nonce, realm = ALittle.SipCall.GetNonceRealmFromUDP(content_list, "WWW-AUTHENTICATE")
			local from_number, from_tag = ALittle.SipCall.GetFromFromUDP(content_list)
			local uri = self._remote_domain
			if uri == nil or uri == "" then
				uri = self._remote_ip .. ":" .. self._remote_port
			end
			local auth = ALittle.SipCall.GenAuth(nonce, realm, from_number, A_SipRegister:GetPassword(from_number), "REGISTER", uri)
			local via_branch = ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
			self:Send(self:GenRegister(from_number, call_id, via_branch, from_tag, cseq_number + 1, auth))
		elseif status == "200" then
			local from_number, from_tag = ALittle.SipCall.GetFromFromUDP(content_list)
			A_SipRegister:HandleRegisterSucceed(from_number)
		end
		return
	end
	if method == "INVITE" then
		local call_info = self._call_map[call_id]
		if call_info == nil then
			call_info = ALittle.SipCall()
			call_info._call_id = call_id
			self._call_map[call_id] = call_info
			if not call_info:HandleSipInfoCreateCallInInvite(method, "", response_list, content_list, self._self_ip, self._self_port) then
				call_info:StopCall("HandleSipInfoCreateCallInInvite失败")
			else
			end
		else
			call_info:HandleCallSipReInvite(method, "", response_list, content_list)
		end
	else
		local call_info = self._call_map[call_id]
		if call_info == nil then
			ALittle.Warn("can't find call id:" .. call_id)
			self:HandleUnknowCall(method, status, response_list, content_list)
			return
		end
		call_info:HandleSipInfo(method, status, response_list, content_list)
		if call_info._sip_step == 11 then
			self:ReleaseCall(call_info)
		end
	end
end

function ALittle.SipSystem:HandleUnknowCall(method, status, response_list, content_list)
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
		self:Send(sip_head)
	end
end

function ALittle.SipSystem:RegisterAccount(account, password)
	local call_id = ALittle.String_Md5(ALittle.String_GenerateID("call_id"))
	local via_branch = ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
	local from_tag = ALittle.String_Md5(ALittle.String_GenerateID("from_tag"))
	self:Send(self:GenRegister(account, call_id, via_branch, from_tag, 1, ""))
end
ALittle.SipSystem.RegisterAccount = Lua.CoWrap(ALittle.SipSystem.RegisterAccount)

function ALittle.SipSystem:GenRegister(account, call_id, via_branch, from_tag, cseq, auth)
	local remote_sip_domain = self._remote_domain
	if remote_sip_domain == "" then
		remote_sip_domain = self._remote_ip .. ":" .. self._remote_port
	end
	local self_sip_domain = self._self_ip .. ":" .. self._self_port
	local sip = "REGISTER sip:" .. remote_sip_domain .. " SIP/2.0\r\n"
	sip = sip .. "Via: SIP/2.0/UDP " .. self_sip_domain .. ";rport;branch=z9hG4bK-" .. via_branch .. "\r\n"
	sip = sip .. "Max-Forwards: 70\r\n"
	sip = sip .. "Contact: <sip:" .. account .. "@" .. self_sip_domain .. ">\r\n"
	sip = sip .. "From: <sip:" .. account .. "@" .. remote_sip_domain .. ">;tag=" .. from_tag .. "\r\n"
	sip = sip .. "To: <sip:" .. account .. "@" .. remote_sip_domain .. ">\r\n"
	sip = sip .. "Call-ID: " .. call_id .. "\r\n"
	sip = sip .. "CSeq: " .. cseq .. " REGISTER\r\n"
	sip = sip .. "Expires: " .. A_SipRegister:GetExpires() .. "\r\n"
	if auth ~= nil and auth ~= "" then
		sip = sip .. "Authorization: " .. auth .. "\r\n"
	end
	sip = sip .. "Allow: INVITE,ACK,CANCEL,OPTIONS,BYE,REFER,NOTIFY,INFO,MESSAGE,SUBSCRIBE,INFO\r\n"
	sip = sip .. "User-Agent: ALittle\r\n"
	sip = sip .. "Content-Length: 0\r\n"
	sip = sip .. "\r\n"
	return sip
end

function ALittle.SipSystem:CallOut(call_id, account, password, from_number, to_number, audio_number, audio_name)
	local start_time = ALittle.Time_GetCurTime()
	local client_ssrc = ALittle.Math_RandomInt(1, 100000)
	local server_ssrc = ALittle.Math_RandomInt(1, 100000)
	local use_rtp = A_RtpSystem:UseRtp(call_id, client_ssrc, server_ssrc, "", 0)
	if use_rtp == nil then
		return "RTP资源不足", nil
	end
	local call_info = ALittle.SipCall()
	self._call_map[call_id] = call_info
	call_info._account = account
	call_info._password = password
	call_info._support_100rel = self._support_100_rel
	call_info._to_sip_domain = self._remote_domain
	call_info._client_ssrc = client_ssrc
	call_info._server_ssrc = server_ssrc
	call_info._use_rtp = use_rtp
	call_info._via_branch = "z9hG4bK-" .. ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
	call_info._call_id = call_id
	call_info._out_or_in = true
	call_info._from_sip_ip = self._self_ip
	call_info._from_sip_port = self._self_port
	call_info._from_tag = ALittle.String_Md5(ALittle.String_GenerateID("from_tag"))
	call_info._from_number = from_number
	call_info._to_sip_ip = self._remote_ip
	call_info._to_sip_port = self._remote_port
	call_info._to_tag = ""
	call_info._to_number = to_number
	call_info._audio_number = audio_number
	call_info._audio_name = audio_name
	call_info._dtmf_number = "101"
	call_info._dtmf_rtpmap = "a=rtpmap:101 telephone-event/8000"
	call_info._dtmf_fmtp = "a=fmtp:101 0-15"
	call_info:CallOutInvite(start_time)
	return nil, call_info
end

function ALittle.SipSystem:StopCall(call_id, reason)
	local call_info = self._call_map[call_id]
	if call_info == nil then
		return
	end
	call_info:StopCall(reason)
end

function ALittle.SipSystem:AcceptCallIn(call_id)
	local call_info = self._call_map[call_id]
	if call_info == nil then
		return
	end
	call_info:CallInOK()
end

_G.A_SipSystem = ALittle.SipSystem()
end