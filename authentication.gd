class_name Authentication extends Node
#REFERENCE: https://www.youtube.com/watch?v=g1tgPEKCKg0

const METHOD_DICT = {
			HTTPClient.METHOD_GET:"GET",
			HTTPClient.METHOD_HEAD:"HEAD",
			HTTPClient.METHOD_POST:"POST",
			HTTPClient.METHOD_PUT:"PUT",
			HTTPClient.METHOD_DELETE:"DELETE",
			HTTPClient.METHOD_OPTIONS:"OPTIONS",
			HTTPClient.METHOD_TRACE:"TRACE",
			HTTPClient.METHOD_CONNECT:"CONNECT",
			HTTPClient.METHOD_PATCH:"PATCH",
			HTTPClient.METHOD_MAX:"MAX"
		}

#supabase
var SUPABASE_URL = str("https://",SUPABASE_PROJECT_ID,".supabase.co")
const SUPABASE_PROJECT_ID = "ejsiqjmcbkeiqbpvwlfa"
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVqc2lxam1jYmtlaXFicHZ3bGZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwNDAwODAsImV4cCI6MjA4MjYxNjA4MH0.ckwUzUOr8v_vyD37C0pzbCKXCLhATylURUbvHZfbUa0"

var saveLoadManager: SaveLoadManager

#local server
var tcpServer:TCPServer
var localPort = 54321
var redirectUrl = str("http://localhost:",localPort)

#pkce
var codeVerifier:String
var codeChallenge:String

var httpRequest: HTTPRequest

signal authSuccess(session)
signal authError(error)
signal httpReply(message)
signal httpReplyError(message)
signal tokenRefreshed

var sessionCache:Dictionary

var user: Dictionary
var isSignedIn: bool = false

func setSignedIn():
	isSignedIn = true
	var userResponse = await getOwnUser()
	user = JSON.parse_string(userResponse.get_string_from_utf8())
	signalBus.signInStatusUpdated.emit()
func setSignedOut():
	isSignedIn = false
	user = {}
	signalBus.signInStatusUpdated.emit()
	
func _ready() -> void:
	if system.isWebVersion:
		handleWebRedirect()
	httpRequest = HTTPRequest.new()
	add_child(httpRequest)
	authSuccess.connect(onAuthSuccess)
	authError.connect(onAuthError)
	httpReply.connect(onHttpReply)
	httpReplyError.connect(onHttpReplyError)
	signalBus.uploadCurrentLevel.connect(uploadLevel)
	httpRequest.request_completed.connect(onHttpRequestCompleted)
	
	signalBus.signedIn.connect(setSignedIn)
	signalBus.signedOut.connect(setSignedOut)
	
	call_deferred("sendSignInSignal")
		
	sessionCache = await loadSession()
	await signalBus.signInStatusUpdated
	print(user)

##send a signal if signed in
func sendSignInSignal():
	if isSessionValid():
		isSignedIn = true
		var userBody = await getCurrentUser()
		if userBody!="null":
			signalBus.signedIn.emit()
		else:
			isSignedIn = true


##looks for the user in the session cache
func getCurrentUser(getFullResponse = false):
	var response = await rpcRequest({},"getCurrentUser")
	if getFullResponse:
		return response
	else:
		var body = response[3].get_string_from_utf8()
		return body

##makes sure the account exists and has an entry in the database
func ensureAccountExists():
	#print("user: ", user)
	#print("checking for user "+user.id)
	#var response = await rpcRequest({},"getCurrentUser")
	#var response = await rpcRequest({},"getCurrentUser")
	#var body = response[3].get_string_from_utf8()
	var response = await getCurrentUser(true)
	var body = response[3].get_string_from_utf8()
	
	#if there is no instance of this user
	if body == "[]" or body=="null" and response[1]==200:
		await signUp()
	else:
		print("user found: ", body)
		signalBus.signedIn.emit()

func getOwnUser():
	var response = await rpcRequest({},"getCurrentUser")
	return response[3]

func signUp(username:String=""):
	if username=="":
		signalBus.startTextEditPopup.emit("Welcome new player! \nWhat would you like your display name to be?")
		var returns = await signalBus.endTextEditPopup
		username = returns[0]
		var isCancelled = returns[1]
		if isCancelled:
			await signOut()
			#signalBus.startTextPopup.emit("User not created")
			return
	if !username:
		await signOut()
		signalBus.startTextPopup.emit("Invalid username.\n You cannot have an empty username.")
		return
	var response = await rpcRequest({"username": username},"createUser")
	if response[1] >199 and response[1] < 300:
		signalBus.startTextPopup.emit("User created \nsuccessfully!")
		signalBus.signedIn.emit()
	else:
		signalBus.startTextPopup.emit("Failed to create user :( ")

##Sends a request for a supabase rpc function. response is an array where:[br]
##Response[0]: result[br]
##Response[1]: responseCode[br] 
##Response[2]: headers[br]
##Response[3]: body[br]
func rpcRequest(params:Dictionary,functionName:String):
	if system.isWebVersion:
		return await rpcRequestWeb(params, functionName)
		
	var url = SUPABASE_URL + "/rest/v1/rpc/"+functionName
	var headers = [
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + sessionCache.access_token,
		"Content-Type: application/json"
	] if isSignedIn else [
		"apikey: " + SUPABASE_ANON_KEY,
		"Content-Type: application/json"
	]
	#print(headers)
	var body = JSON.stringify(params)
	httpRequest.request(url, headers, HTTPClient.METHOD_POST, body)
	var response = await httpRequest.request_completed
	return response

##Http request that behaves
func genericHttpRequest(url:String,headers:PackedStringArray,method:HTTPClient.Method,requestData:String=""):
	if system.isWebVersion:
		return await webRequest(url,headers,method,requestData)
	else:
		httpRequest.request(url, headers, method, requestData)
		return await httpRequest.request_completed

##like an Http request but adapted to work on browsers
func webRequest(url:String,headers:PackedStringArray,method:HTTPClient.Method,requestData:String=""):
	var headersString = {}
	for i in headers:
		var midpoint = i.find(": ")
		if midpoint!=-1:
			headersString[i.substr(0,midpoint)] = i.substr(midpoint + 2)
	headersString = JSON.stringify(headersString)
	var body = ""
	if method!=0 and requestData:
		JavaScriptBridge.eval("window._godot_fetch_body = " + requestData + ";")
		body = "  body: JSON.stringify(window._godot_fetch_body),"
	JavaScriptBridge.eval(
		"window._godot_rpc_result = undefined;"
		+ "window._godot_rpc_error = undefined;"
		+ "fetch('" + url + "', {"
		+ "  method: '"+METHOD_DICT[method]+"',"
		+ "  headers: " + headersString + ","
		+ body
		+ "})"
		+ ".then(r => r.text())"
		+ ".then(t => { window._godot_rpc_result = t; })"
		+ ".catch(e => { window._godot_rpc_error = e.toString(); })"
	)
	var timeout = 0.0
	while JavaScriptBridge.eval("window._godot_rpc_result === undefined && window._godot_rpc_error === undefined"):
		await get_tree().create_timer(0.05).timeout
		timeout += 0.05
		if timeout > 10.0:
			printerr("webFetch timed out: ", url)
			return [FAILED, 0, [], PackedByteArray()]
	
	if JavaScriptBridge.eval("window._godot_rpc_error !== undefined"):
		printerr("webFetch JS error: ", JavaScriptBridge.eval("window._godot_rpc_error"))
		return [FAILED, 0, [], PackedByteArray()]
	
	var result = str(JavaScriptBridge.eval("window._godot_rpc_result"))
	JavaScriptBridge.eval("delete window._godot_rpc_result; delete window._godot_fetch_body;")
	return [OK, 200, [], result.to_utf8_buffer()]


func rpcRequestWeb(params: Dictionary, functionName: String):
	var url = SUPABASE_URL + "/rest/v1/rpc/" + functionName
	var token = sessionCache.get("access_token", "")
	var body = JSON.stringify(params)
	JavaScriptBridge.eval("window._godot_fetch_body = " + body + ";")
	var _headers = "{'apikey': '" + SUPABASE_ANON_KEY + "', 'Content-Type': 'application/json'"
	if isSignedIn:
		_headers += ", 'Authorization': 'Bearer " + token + "'"
	_headers += "}"
	JavaScriptBridge.eval(
		"window._godot_rpc_result = undefined;"
		+ "window._godot_rpc_error = undefined;"
		+ "fetch('" + url + "', {"
		+ "  method: 'POST',"
		+ "  headers: " + _headers + ","
		+ "  body: JSON.stringify(window._godot_fetch_body)"
		+ "})"
		+ ".then(r => r.text())"
		+ ".then(t => { window._godot_rpc_result = t; })"
		+ ".catch(e => { window._godot_rpc_error = e.toString(); })"
	)
	var timeout = 0.0
	while JavaScriptBridge.eval("window._godot_rpc_result === undefined && window._godot_rpc_error === undefined"):
		await get_tree().create_timer(0.05).timeout
		timeout += 0.05
		if timeout > 10.0:
			printerr("rpcRequestWeb timed out: ", functionName)
			return [FAILED, 0, [], PackedByteArray()]
	if JavaScriptBridge.eval("window._godot_rpc_error !== undefined"):
		printerr("rpcRequestWeb JS error: ", JavaScriptBridge.eval("window._godot_rpc_error"))
		return [FAILED, 0, [], PackedByteArray()]
	var result = JavaScriptBridge.eval("window._godot_rpc_result")
	JavaScriptBridge.eval("delete window._godot_rpc_result; delete window._godot_rpc_error;")
	var resultBytes = (result as String).to_utf8_buffer() if result else PackedByteArray()
	#print("result is the of ", resultBytes.get_string_from_utf8())
	return [OK, 200, [], resultBytes]

func uploadLevel(levelName=""):
	await ensureValidSession()
	if isSessionValid():
		if !levelName:
			signalBus.startTextEditPopup.emit("Enter name for your level")
			var returns = await signalBus.endTextEditPopup
			levelName = returns[0]
			var isCancelled = returns[1]
			if isCancelled:
				#signalBus.startTextPopup.emit("Level not created")
				return
		if !levelName:
			signalBus.startTextPopup.emit("Invalid level name.\n You cannot have an empty level name.")
			return

		#upload the level database entry
		var response1 = await rpcRequest({
			"artist":user.id,
			"name":levelName
		}, "uploadLevel")
		if response1[1] > 199 and response1[1] < 300:
			#if the database entry successfully uploads, retrieve the level ID then upload the level file
			var levelID = response1[3].get_string_from_utf8()
			var levelSaveStruct = saveLoadManager.parseLevelToJson()
			var data = JSON.stringify(levelSaveStruct)
			var url = SUPABASE_URL + "/storage/v1/object/Levels/"+levelID+".json"
			var headers = [
				"Content-Type: application/octet-stream",
				"apikey: "+SUPABASE_ANON_KEY,
				"Authorization: Bearer "+sessionCache.access_token
			]
			httpRequest.request(url,headers,HTTPClient.METHOD_POST,data)
			var response2 = await httpRequest.request_completed
			if response2[1] > 199 and response2[1] < 300:
				signalBus.startTextPopup.emit("Successfully uploaded level")
				#httpReply.emit(str("Successfully uploaded level ",JSON.parse_string(body.get_string_from_utf8())["Key"].get_file() ) )
			else:
				httpReplyError.emit("Failed to upload level")
				signalBus.startTextPopup.emit("Failed to upload level")
	else:
		#authError.emit("flip dude, youre not signed in bro")
		signalBus.startTextPopup.emit("Bummer, I don't think you're signed in")
func downloadLevel(levelID:="0"):
	var url = SUPABASE_URL + "/storage/v1/object/Levels/"+levelID+".json"
	var headers = [
		"Content-Type: application/octet-stream",
		"apikey: "+SUPABASE_ANON_KEY,
	]
	#genericHttpRequest(url,headers,HTTPClient.METHOD_GET,data)
	var response = await genericHttpRequest(url,headers,HTTPClient.METHOD_GET)
	#httpRequest.request(url,headers,HTTPClient.METHOD_GET,data)
	#var response = await httpRequest.request_completed
	var responseCode = response[1]
	var body = response[3]
	if responseCode == 200:
		httpReply.emit(str("Successfully downloaded level "))
		signalBus.loadLevel.emit(JSON.parse_string(body.get_string_from_utf8()))
	else:
		httpReplyError.emit("Failed to download level")
		signalBus.startTextPopup.emit(str("Failed to load level.\nCould not find level with the ID ",levelID))

func handleWebRedirect():
	var urlPart = JavaScriptBridge.eval("window.location.hash", true)
	if urlPart == "" or not urlPart.begins_with("#"):
		return

	var query = urlPart.substr(1)
	var params = {} 
	var pairs = query.split("&")
	for pair in pairs:
		var keyValue = pair.split("=")
		if keyValue.size() == 2:
			params[keyValue[0].uri_decode()] = keyValue[1].uri_decode()
	if params.has("error"):
		authError.emit(params.error_description)
		return
	var session = {
		"access_token": params.get("access_token", ""),
		"refresh_token": params.get("refresh_token", ""),
		"expires_in": params.get("expires_in", 0),
		"user": params.get("user", {})
	}
	var url = SUPABASE_URL+"/auth/v1/user"
	#var headers = [
		#"Content-Type: application/json",
		#"apikey: "+SUPABASE_ANON_KEY,
		#"Authorization: Bearer "+session.access_token
	#]
	#set_meta("temp_session", session)
	#httpRequest.request(url,headers,HTTPClient.METHOD_GET,"")
	#await httpRequest.request_completed
	var headers = PackedStringArray([
		"Content-Type: application/json",
		"apikey: "+SUPABASE_ANON_KEY,
		"Authorization: Bearer "+session.access_token
	])
	var response = await genericHttpRequest(url, headers, HTTPClient.METHOD_GET)
	if response[1]>199 and response[1]<300:
		var body = response[3].get_string_from_utf8()
		if body!="null":
			session["user"] = JSON.parse_string(body)
			authSuccess.emit(session)
	else:
		authError.emit("failed to fetch user")
	JavaScriptBridge.eval("history.replaceState(null, '', window.location.pathname)")

func onHttpRequestCompleted(_result, responseCode, _headers, body):
	var session
	var json
	var response = body.get_string_from_utf8()
	#when signing in through browser
	if has_meta("temp_session"):
		print("temp_session responseCode: ", responseCode, " body: ", response)
		session = get_meta("temp_session")
		remove_meta("temp_session")
		if responseCode == 200:
			json = JSON.new()
			session["user"]=json.data
			if json.parse(response) == OK:
				authSuccess.emit(session)
		else:
			authError.emit("Failed to get user info")
		clearTcpServer()
		return
	clearTcpServer()
	
	if responseCode < 200 or responseCode > 299:
		httpReplyError.emit(response)
		return
		
	json = JSON.new()
	json.parse(response)
	#var parsedResult = json.parse(response)
	#if parsedResult != OK:
		#httpReplyError.emit("Failed to parse http response")
		#return
	var data = json.data
	#when signing in through downloaded version of the game
	if data and typeof(data)==TYPE_DICTIONARY and data.has("access_token"):
		session = {
			"access_token": data.get("access_token", ""),
			"refresh_token": data.get("refresh_token", ""),
			"expires_in": data.get("expires_in", 0),
			"user": data.get("user", {})
		}
		authSuccess.emit(session)
	else:
		#if data and data.has("user"):
		#print(response)
		httpReply.emit(response)


func signInWithGoogle():
	var params = {}
	redirectUrl = ""
	if system.isWebVersion:
		redirectUrl = JavaScriptBridge.eval("window.location.origin + window.location.pathname")
		JavaScriptBridge.eval("alert('redirectUrl: ' + '" + redirectUrl + "')")
		params = {
			"provider": "google",
			"redirect_to": redirectUrl,
		}
	else:
		#generate a random string
		codeVerifier = ""
		var randsChars = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm123456790"
		for i in 64:
			codeVerifier+= randsChars[randi() % randsChars.length()]
		
		#generate pkce params
		var bytes = codeVerifier.to_utf8_buffer()
		var hashingContext = HashingContext.new()
		hashingContext.start(HashingContext.HASH_SHA256)
		hashingContext.update(bytes)
		var hashed = hashingContext.finish()
		codeChallenge = Marshalls.raw_to_base64(hashed).replace("+","-").replace("/","_").rstrip("=")
	
		#start tcp server
		tcpServer = TCPServer.new()
		var error = tcpServer.listen(localPort)#,"127.0.0.1")
		if error!=OK:
			print("Could not start TCP server on port ",localPort,", ",error)
			var fallbackPorts = [3000, 54322, 54323, 9999, 8080]
			for port in fallbackPorts:
				error = tcpServer.listen(port,"127.0.0.1")
				if error==OK:
					localPort = port
					#redirectUrl = str("http://localhost:",localPort)
					print("successfully started tcp server on fallback port ",localPort)
					break
			if error !=OK:
				printerr("Failed to start TCP server on all fallback ports")
				return false
		redirectUrl = str("http://localhost:",localPort)
		set_process(true)
		#build the auth url
		params = {
			"provider": "google",
			"redirect_to": redirectUrl,
			"code_challenge": codeChallenge,
			"code_challenge_method": "S256",
			"flow_type": "pkce"
		}
	var queryString = ""
	for param in params:
		if queryString != "":
			queryString+='&'
		queryString += str(param,"=",params[param].uri_encode())
	var authUrl = SUPABASE_URL + "/auth/v1/authorize?" + queryString
	
	if system.isWebVersion:
		JavaScriptBridge.eval("window.open('" + authUrl + "', '_blank')")
	else:
		OS.shell_open(authUrl)

func _process(_delta: float) -> void:
	
	if not tcpServer or not tcpServer.is_listening():
		return
	if tcpServer.is_connection_available():
		var connection := tcpServer.take_connection()
		if connection:
			#handle the callback
			var buffer = PackedByteArray()
			var timeout = 0.0
			while connection.get_status() == StreamPeerTCP.STATUS_CONNECTED and timeout < 2.0:
				var available = connection.get_available_bytes()
				if available > 0:
					buffer.append_array( connection.get_data(available)[1] )
					var request = buffer.get_string_from_utf8()
					
					if request.contains("\r\n\r\n"):
						
						#process the callback request
						var requestLines = request.split('\n')
						var requestLine = requestLines[0] if requestLines.size() > 0 else ""
						if requestLine.begins_with("GET"):
							var urlPart = requestLine.split(" ")[1]
							var queryStart = urlPart.find("?")
							var query = urlPart.substr(queryStart+1)
							#parse query params
							var params = {} 
							var pairs = query.split("&")
							for pair in pairs:
								var keyValue = pair.split("=")
								if keyValue.size() == 2:
									params[keyValue[0].uri_decode()] = keyValue[1].uri_decode()
							
							if params.has("error"):
								sendCallbackResponse(connection,false,params.get("error_description","Authentication failed"))
								authError.emit(params.get("error_description","Authentication failed"))
								
								clearTcpServer()
								return
								
							#get auth code
							var code =  params.get("code","")
							if code != "":
								sendCallbackResponse(connection)
								#exchange code for session
								var url = SUPABASE_URL + "/auth/v1/token?grant_type=pkce"
								var headers = [
									"Content-Type: application/json",
									"apikey: "+SUPABASE_ANON_KEY
								]
								var body = JSON.stringify({
									"auth_code":code,
									"code_verifier":codeVerifier
								})
								
								#var session = {
									#"access_token": params.get("access_token", ""),
									#"refresh_token": params.get("refresh_token", ""),
									#"expires_in": params.get("expires_in", 0),
									#"user": params.get("user", {})
								#}
								#set_meta("temp_session", session)
								
								httpRequest.request(url,headers,HTTPClient.METHOD_POST,body)
								await httpRequest.request_completed
							else:
								sendCallbackResponse(connection,false,"No auth code received")
						break
				else:
					await get_tree().create_timer(0.01).timeout
					timeout+=0.1

func clearTcpServer():
	if tcpServer:
		tcpServer.stop()
		tcpServer = null
	set_process(false)
	return

func sendCallbackResponse(connection, isSuccess=true, message=""):
	var body:String
	if isSuccess:
		body = """
		<html>
		<body>
		Authentication successful
		</body>
		</html>
		"""
	else:
		body = str("""
		<html>
		<body>
		Authentication Failed <br>""",message,"""
		</body>
		</html>
		""")
	var response = str("HTTP/1.1 200 OK\r\n"
	+ "Content-Type: text/html; charset=utf-8\r\n"
	+ "Content-Length: %d\r\n" % body.to_utf8_buffer().size()
	+ "Connection: close\r\n"
	+ "\r\n"
	+ body
	)
	connection.put_data(response.to_utf8_buffer())
	connection.disconnect_from_host()

func storeSession(session):
	session["stored_at"] = Time.get_unix_time_from_system()
	#apparently this isnt the most secure option but it is good enough for now.
	var file = FileAccess.open("user://auth_session.dat",FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(session))
		file.close()
	return session
func loadSession():
	var file = FileAccess.open("user://auth_session.dat",FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(content) == OK:
			var session = json.data
			
			if session.has("stored_at") and session.has("expires_in") :
				var age = Time.get_unix_time_from_system() - session.stored_at
				if age > int(session.expires_in) - 300:
					session["is_expired"] = true
			return session
	return {}
func isSessionValid():
	var session = loadSession()
	if not session.has("access_token") or session.access_token == "":
		return false
	if session.get("is_expired", false):
		return false
	return true
func ensureValidSession():
	if !isSessionValid():
		if !sessionCache.has("refresh_token"):
			return false
		refreshToken(sessionCache["refresh_token"])
		await tokenRefreshed
	else:
		return true
func refreshToken(refreshString):
	var url = SUPABASE_URL+"/auth/v1/token?grant_type=refresh_token"
	var headers = [
		"Content-Type: application/json",
		"apikey: "+SUPABASE_ANON_KEY
	]
	var body = {
		"refresh_token": refreshString
	}
	httpRequest.request(url,headers,HTTPClient.METHOD_POST,JSON.stringify(body))
	await httpRequest.request_completed

func signOut():
	var session = loadSession()
	if session.has("access_token"):
		var url = SUPABASE_URL+"/auth/v1/logout"
		var headers = [
			"Content-Type: application/json",
			"apikey: "+SUPABASE_ANON_KEY,
			"Authorization: Bearer "+session.access_token
		]
		clearSession()
		#httpRequest.request(url,headers,HTTPClient.METHOD_POST,"")
		await genericHttpRequest(url,headers,HTTPClient.METHOD_POST)
		#await httpRequest.request_completed

##clear session file
func clearSession():
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("auth_session.dat")
	sessionCache={}
	signalBus.signedOut.emit()

func onHttpReply(_message):
	#print("http just called, they said ",_message)
	pass
func onHttpReplyError(message):
	printerr("error: ",message)
	
func onAuthSuccess(session):
	if typeof(session) == TYPE_DICTIONARY:
		storeSession(session)
		sessionCache = session
		tokenRefreshed.emit()
		isSignedIn = true
		await ensureAccountExists()
	#signalBus.startTextPopup.emit(str("Welcome ",session["user"]["user_metadata"]["name"]))
	#print("Welcome ",session["user"]["user_metadata"]["name"])

func onAuthError(error):
	print("auth error: ",error)
	
