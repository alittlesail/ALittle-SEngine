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
ALittle.RegStruct(997595746, "ALittle.SipCallInEvent", {
name = "ALittle.SipCallInEvent", ns_name = "ALittle", rl_name = "SipCallInEvent", hash_code = 997595746,
name_list = {"target","call_info"},
type_list = {"ALittle.EventDispatcher","ALittle.SipCall"},
option_map = {}
})
ALittle.RegStruct(766817303, "ALittle.SipAccount", {
name = "ALittle.SipAccount", ns_name = "ALittle", rl_name = "SipAccount", hash_code = 766817303,
name_list = {"account","password","sip_ip","sip_port","register_time"},
type_list = {"string","string","string","int","int"},
option_map = {}
})
ALittle.RegStruct(588051539, "ALittle.SipCallReleaseEvent", {
name = "ALittle.SipCallReleaseEvent", ns_name = "ALittle", rl_name = "SipCallReleaseEvent", hash_code = 588051539,
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
	___rawset(self, "_account_map", {})
	___rawset(self, "_support_100_rel", false)
	___rawset(self, "_call_map", {})
end

function ALittle.SipSystem:Setup(sip_register, self_ip, self_port, remote_ip, remote_port, remote_domain, support_100_rel)
	self._sip_register = sip_register
	self._self_ip = self_ip
	self._self_port = self_port
	self._remote_ip = remote_ip
	self._remote_port = remote_port
	self._remote_domain = remote_domain
	self._support_100_rel = support_100_rel
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

function ALittle.SipSystem:ReloadAccount(account_map_password)
	local new_map = {}
	for account, password in ___pairs(account_map_password) do
		local sip_account = {}
		new_map[account] = sip_account
		sip_account.account = account
		sip_account.password = password
		local old_account = self._account_map[account]
		if old_account ~= nil then
			sip_account.register_time = old_account.register_time
			sip_account.sip_ip = old_account.sip_ip
			sip_account.sip_port = old_account.sip_port
		end
	end
	self._account_map = new_map
end

function ALittle.SipSystem:CheckAccount(from_number, remote_ip, remote_port)
	if self._remote_ip == remote_ip and self._remote_port == remote_port then
		return true
	end
	local sip_account = self._account_map[from_number]
	if sip_account == nil then
		return false
	end
	if ALittle.Time_GetCurTime() > sip_account.register_time + 3600 then
		return false
	end
	return remote_ip ~= sip_account.sip_ip and remote_port ~= sip_account.sip_port
end

function ALittle.SipSystem:AddResend(call)
	self._resend_weak_map[call] = true
end

function ALittle.SipSystem:AddSession(call)
	self._session_weak_map[call] = true
end

function ALittle.SipSystem:Send(message, sip_ip, sip_port)
	if sip_ip == nil or sip_ip == "" or sip_port == 0 or sip_port == nil then
		sip_ip = self._remote_ip
		sip_port = self._remote_port
	end
	__CPPAPI_ServerSchedule:SendUdpMessage(self._self_ip, self._self_port, sip_ip, sip_port, message)
	ALittle.Log("SEND==>")
	ALittle.Log(message)
end

function ALittle.SipSystem:ReleaseCall(call_info)
	ALittle.Log("Release call_id:" .. call_info._call_id)
	A_RtpSystem:ReleaseRtp(self, call_info._call_id)
	self._call_map[call_info._call_id] = nil
	self._session_weak_map[call_info] = nil
	self._resend_weak_map[call_info] = nil
	local event = {}
	event.call_info = call_info
	self:DispatchEvent(___all_struct[588051539], event)
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
		elseif call_info._sip_step == 5 or call_info._sip_step == 6 then
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
	if event.self_ip ~= self._self_ip or event.self_port ~= self._self_port then
		return
	end
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
	if method == "REGISTER" then
		self:HandleRegister(method, status, response_list, content_list, event.remote_ip, event.remote_port)
		return
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
			local auth = ALittle.SipCall.GenAuth(nonce, realm, from_number, self._sip_register:GetPassword(from_number), "REGISTER", uri)
			local via_branch = ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
			self:Send(self:GenRegister(from_number, call_id, via_branch, from_tag, cseq_number + 1, auth), event.remote_ip, event.remote_port)
		elseif status == "200" then
			local from_number, from_tag = ALittle.SipCall.GetFromFromUDP(content_list)
			self._sip_register:HandleRegisterSucceed(from_number)
		end
		return
	end
	if method == "INVITE" then
		local call_info = self._call_map[call_id]
		if call_info == nil then
			call_info = ALittle.SipCall(self)
			call_info._call_id = call_id
			self._call_map[call_id] = call_info
			local error = call_info:HandleSipInfoCreateCallInInvite(method, "", response_list, content_list, self._self_ip, self._self_port, event.remote_ip, event.remote_port)
			if error ~= nil then
				call_info:StopCall(error)
			else
				local call_in_event = {}
				call_in_event.call_info = call_info
				self:DispatchEvent(___all_struct[997595746], call_in_event)
			end
		else
			call_info:HandleCallSipReInvite(method, "", response_list, content_list)
		end
	else
		local call_info = self._call_map[call_id]
		if call_info == nil then
			ALittle.Warn("can't find call id:" .. call_id)
			self:HandleUnknowCall(method, status, response_list, content_list, event.remote_ip, event.remote_port)
			return
		end
		call_info:HandleSipInfo(method, status, response_list, content_list)
		if call_info._sip_step == 11 then
			self:ReleaseCall(call_info)
		end
	end
end

function ALittle.SipSystem:HandleRegister(method, status, response_list, content_list, remote_ip, remote_port)
	local via = ALittle.SipCall.GetKeyValueFromUDP(content_list, "VIA")
	local from = ALittle.SipCall.GetKeyValueFromUDP(content_list, "FROM")
	local to = ALittle.SipCall.GetKeyValueFromUDP(content_list, "TO")
	local cseq = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CSEQ")
	local call_id = ALittle.SipCall.GetKeyValueFromUDP(content_list, "CALL-ID")
	local max_forwards = ALittle.SipCall.GetKeyValueFromUDP(content_list, "MAX-FORWARDS")
	local expires = ALittle.SipCall.GetKeyValueFromUDP(content_list, "EXPIRES")
	local allow = ALittle.SipCall.GetKeyValueFromUDP(content_list, "ALLOW")
	if ALittle.String_Find(to, "tag=") == nil then
		to = to .. ";tag=" .. ALittle.String_Md5(ALittle.String_GenerateID("to_tag"))
	end
	local authorization = ALittle.SipCall.GetKeyValueFromUDP(content_list, "AUTHORIZATION")
	if authorization == nil then
		local sip_head = "SIP/2.0 401 Unauthorized\r\n"
		sip_head = sip_head .. "Via: " .. via .. "\r\n"
		sip_head = sip_head .. "From: " .. from .. "\r\n"
		sip_head = sip_head .. "To: " .. to .. "\r\n"
		sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
		sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
		sip_head = sip_head .. "Max-Forwards: " .. max_forwards .. "\r\n"
		sip_head = sip_head .. "Allow: " .. allow .. "\r\n"
		sip_head = sip_head .. "WWW-Authenticate: Digest realm=\"ALittle\", nonce=\"" .. ALittle.String_Md5(ALittle.String_GenerateID("nonce")) .. "\", stale=FALSE, algorithm=MD5\r\n"
		sip_head = sip_head .. "Server: ALittle\r\n"
		sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
		self:Send(sip_head, remote_ip, remote_port)
		return
	end
	local nonce, realm, uri, response = ALittle.SipCall.GetNonceRealmFromUDP(content_list, "AUTHORIZATION")
	local from_number, from_tag = ALittle.SipCall.GetFromFromUDP(content_list)
	local sip_account = self._account_map[from_number]
	if sip_account ~= nil then
		local gen_response = ALittle.SipCall.GenAuthResponse(nonce, realm, sip_account.account, sip_account.password, "REGISTER", uri)
		if gen_response == response then
			sip_account.register_time = ALittle.Time_GetCurTime()
			sip_account.sip_ip = remote_ip
			sip_account.sip_port = remote_port
			local sip_head = "SIP/2.0 200 OK\r\n"
			sip_head = sip_head .. "Via: " .. via .. "\r\n"
			sip_head = sip_head .. "From: " .. from .. "\r\n"
			sip_head = sip_head .. "To: " .. to .. "\r\n"
			sip_head = sip_head .. "Call-ID: " .. call_id .. "\r\n"
			sip_head = sip_head .. "CSeq: " .. cseq .. "\r\n"
			sip_head = sip_head .. "Max-Forwards: " .. max_forwards .. "\r\n"
			sip_head = sip_head .. "Expires: " .. expires .. "\r\n"
			sip_head = sip_head .. "Allow: " .. allow .. "\r\n"
			sip_head = sip_head .. "Server: ALittle\r\n"
			sip_head = sip_head .. "Content-Length: 0\r\n\r\n"
			self:Send(sip_head, remote_ip, remote_port)
			return
		end
	end
end

function ALittle.SipSystem:HandleUnknowCall(method, status, response_list, content_list, remote_ip, remote_port)
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
		self:Send(sip_head, remote_ip, remote_port)
	end
end

function ALittle.SipSystem:RegisterAccount(account, password)
	local call_id = ALittle.String_Md5(ALittle.String_GenerateID("call_id"))
	local via_branch = ALittle.String_Md5(ALittle.String_GenerateID("via_branch"))
	local from_tag = ALittle.String_Md5(ALittle.String_GenerateID("from_tag"))
	self:Send(self:GenRegister(account, call_id, via_branch, from_tag, 1, ""), self._remote_ip, self._remote_port)
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
	sip = sip .. "Expires: " .. self._sip_register:GetExpires() .. "\r\n"
	if auth ~= nil and auth ~= "" then
		sip = sip .. "Authorization: " .. auth .. "\r\n"
	end
	sip = sip .. "Allow: INVITE,ACK,CANCEL,OPTIONS,BYE,REFER,NOTIFY,INFO,MESSAGE,SUBSCRIBE,INFO\r\n"
	sip = sip .. "User-Agent: ALittle\r\n"
	sip = sip .. "Content-Length: 0\r\n"
	sip = sip .. "\r\n"
	return sip
end

function ALittle.SipSystem:CallOut(call_id, account, password, from_number, to_number, audio_number, audio_name, use_rtp)
	if self._call_map[call_id] ~= nil then
		return "call_id已存在", nil
	end
	local start_time = ALittle.Time_GetCurTime()
	local call_info = ALittle.SipCall(self)
	self._call_map[call_id] = call_info
	call_info._use_rtp = use_rtp
	call_info._account = account
	call_info._password = password
	call_info._support_100rel = self._support_100_rel
	call_info._to_sip_domain = self._remote_domain
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

end