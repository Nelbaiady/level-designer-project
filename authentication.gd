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

signal authSuccess(session)
signal authError(error)
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
	authSuccess.connect(onAuthSuccess)
	authError.connect(onAuthError)

	httpReplyError.connect(onHttpReplyError)
	
	signalBus.uploadCurrentLevel.connect(uploadLevel)
	signalBus.signedIn.connect(setSignedIn)
	signalBus.signedOut.connect(setSignedOut)
		
	sessionCache = await loadSession()
	call_deferred("sendSignInSignal")
	
	await signalBus.signInStatusUpdated
	print(user)

##send a signal if signed in
func sendSignInSignal():
	if await ensureValidSession():
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
	var response = await getCurrentUser(true)
	var body = response[3].get_string_from_utf8()
	#if the account does not have a database entry
	if (body == "[]" or body=="null") and response[1]==200:
		return await signUpPartTwo()
	else:
		print("user found: ", body)
		signalBus.signedIn.emit()
		return response[1]

func getOwnUser():
	var response = await rpcRequest({},"getCurrentUser")
	return response[3]

func signUp(email:String, password:String):
	var response = await genericHttpRequest(
		SUPABASE_URL+"/auth/v1/signup",
		["Content-Type: application/json","apikey: " + SUPABASE_ANON_KEY], 
		HTTPClient.METHOD_POST, 
		JSON.stringify({
			"email":email,
			"password":password
			}))
	var body = JSON.parse_string(response[3].get_string_from_utf8())
	if response[1]==200:
		if body.has("user_metadata"):
			if body["user_metadata"]=={}:
				authError.emit("This email already has an account. \nTry signing in or using a different email.")
				return -2
			elif body["user_metadata"]["email_verified"]==false:
				if response[1] >199 and response[1] < 300:
					signalBus.startTextPopup.emit(str("A verification email has been sent to ",email,". \nLook for an email sent by Cheese Chair\n and click the link to complete the sign up process. \n You will need to enter your credentials again to sign in \nafter verifying your account."))
				else:
					authError.emit("Failed to create user for some unknown wacky reason :(")
	else:
		authError.emit(body["msg"])
	return response[1]
	
func signUpPartTwo(username:String=""):
	if username=="":
		signalBus.startTextEditPopup.emit("Welcome new player! \nWhat would you like your display name to be?")
		var returns = await signalBus.endTextPopup
		username = returns[0]
		var isCancelled = !returns[1]
		if isCancelled:
			await signOut()
			return -1
	if !username:
		await signOut()
		authError.emit("Invalid username.\n You cannot have an empty username.")
		return -1
	var response = await rpcRequest({"username": username},"createUser")
	if response[1] >199 and response[1] < 300:
		signalBus.startTextPopup.emit("User creation complete. \n I hope you create wonderful things.\n Have Fun!")
		signalBus.signedIn.emit()
		return 200
	else:
		authError.emit("Failed to create user :( ")
		return response[1]

func signIn(email:String,password:String):
	var response = await genericHttpRequest(
		SUPABASE_URL+"/auth/v1/token?grant_type=password",
		["Content-Type: application/json","apikey: " + SUPABASE_ANON_KEY], 
		HTTPClient.METHOD_POST, 
		JSON.stringify({
			"email":email,
			"password":password
			}))
	var body = JSON.parse_string(response[3].get_string_from_utf8())
	if response[1]==400:
		if body["error_code"]=="email_not_confirmed":
			response = [0,0]
			var playerInput=false
			#while there are no errors
			while response[1]!=200 and playerInput==false:
				signalBus.startBinaryChoicePopup.emit("Email not verified. \nWould you like to resend verification email?")
				playerInput = (await signalBus.endTextPopup)[1]
				if playerInput==false:
					response = await genericHttpRequest(
						SUPABASE_URL+"/auth/v1/resend",
						["Content-Type: application/json","apikey: " + SUPABASE_ANON_KEY], 
						HTTPClient.METHOD_POST, 
						JSON.stringify({
							"type":"signup",
							"email":email
							}))
					body = JSON.parse_string(response[3].get_string_from_utf8())
					if response[1]!=200:
						authError.emit(body["msg"])
						await signalBus.endTextPopup
					else:
						signalBus.startTextPopup.emit(str("Verification email sent. \nCheck your email at ",email," and click the link, then try to sign in again."))
		elif body["error_code"]=="invalid_credentials":
			authError.emit(str("Incorrect email or password"))
		else:
			authError.emit(body["msg"])
	elif response[1]==200:
		var session = {
			"accessToken": body.get("access_token", ""),
			"refreshToken": body.get("refresh_token", ""),
			"expiresIn": body.get("expires_in", 0),
			"user": body.get("user", {})
		}
		authSuccess.emit(session)
		return await ensureAccountExists()

##Sends a request for a supabase rpc function. response is an array where:[br]
##Response[0]: result[br]
##Response[1]: responseCode[br] 
##Response[2]: headers[br]
##Response[3]: body[br]
func rpcRequest(params:Dictionary,functionName:String):
	var url = SUPABASE_URL + "/rest/v1/rpc/"+functionName
	var headers = [
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + sessionCache["accessToken"],
		"Content-Type: application/json"
	] if isSignedIn else [
		"apikey: " + SUPABASE_ANON_KEY,
		"Content-Type: application/json"
	]
	var body = JSON.stringify(params)
	var response = await genericHttpRequest(url, headers, HTTPClient.METHOD_POST, body)
	return response

func newHttpRequest(url:String,headers:PackedStringArray,method:HTTPClient.Method,requestData:String=""):
	var request = HTTPRequest.new()
	add_child(request)
	request.request(url,headers,method,requestData)
	var response = await request.request_completed
	request.queue_free()
	return response

##Web request that behaves the same on web and desktop versions. Not actually an http request if using web.
func genericHttpRequest(url:String,headers:PackedStringArray,method:HTTPClient.Method,requestData:String=""):
	if system.isWebVersion:
		return await webRequest(url,headers,method,requestData)
	else:
		return await newHttpRequest(url, headers, method, requestData)

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
		JavaScriptBridge.eval("window.godotBody = " + requestData + ";")
		body = "  body: JSON.stringify(window.godotBody),"
	JavaScriptBridge.eval(
		"window.godotResult = undefined;"
		+ "window.godotError = undefined;"
		+ "fetch('" + url + "', {"
		+ "method: '" + METHOD_DICT[method] + "',"
		+ "headers: " + headersString + ","
		+ body
		+ "})"
		+ ".then(async r => {"
		+ "const text = await r.text();"
		+ "window.godotResult = JSON.stringify({"
		+ "status: r.status,"
		+ "body: text});})"
		+ ".catch(e => { window.godotError = e.toString(); })"
	)
	var timeout = 0.0
	while JavaScriptBridge.eval("window.godotResult === undefined && window.godotError === undefined"):
		await get_tree().create_timer(0.05).timeout
		timeout += 0.05
		if timeout > 10.0:
			printerr("webFetch timed out: ", url)
			JavaScriptBridge.eval("delete window.godotBody; delete window.godotError; delete window.godotResult;")
			return [FAILED, 0, [], PackedByteArray()]
	
	
	if JavaScriptBridge.eval("window.godotError !== undefined"):
		printerr("webFetch JS error: ", JavaScriptBridge.eval("window.godotError"))
		JavaScriptBridge.eval("delete window.godotBody; delete window.godotError; delete window.godotResult;")
		return [FAILED, 0, [], PackedByteArray()]
	
	var result = JSON.parse_string(str(JavaScriptBridge.eval("window.godotResult")))
	
	JavaScriptBridge.eval("delete window.godotBody; delete window.godotError; delete window.godotResult;")
	return [OK, result["status"], [], result["body"].to_utf8_buffer()]


func uploadLevel(levelName=""):
	await ensureValidSession()
	if isSessionValid():
		if !levelName:
			signalBus.startTextEditPopup.emit("Enter name for your level")
			var returns = await signalBus.endTextPopup
			levelName = returns[0]
			var isCancelled = !returns[1]
			if isCancelled:
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
			var levelID = response1[3].get_string_from_utf8()
			var levelSaveStruct = saveLoadManager.parseLevelToJson()
			var data = JSON.stringify(levelSaveStruct)
			var url = SUPABASE_URL + "/storage/v1/object/Levels/"+levelID+".json"
			var headers = [
				"Content-Type: application/octet-stream",
				"apikey: "+SUPABASE_ANON_KEY,
				"Authorization: Bearer "+sessionCache["accessToken"]
			]
			var response2 = await genericHttpRequest(url,headers,HTTPClient.METHOD_POST,data)
			if response2[1] > 199 and response2[1] < 300:
				signalBus.startTextPopup.emit("Successfully uploaded level")
			else:
				httpReplyError.emit("Failed to upload level")
				signalBus.startTextPopup.emit("Failed to upload level")
	else:
		signalBus.startTextPopup.emit("Bummer, I don't think you're signed in")
func downloadLevel(levelID:="0"):
	var url = SUPABASE_URL + "/storage/v1/object/Levels/"+levelID+".json"
	var headers = [
		"Content-Type: application/octet-stream",
		"apikey: "+SUPABASE_ANON_KEY,
	]
	var response = await genericHttpRequest(url,headers,HTTPClient.METHOD_GET)
	var responseCode = response[1]
	var body = response[3]
	if responseCode == 200:
		signalBus.loadLevel.emit(JSON.parse_string(body.get_string_from_utf8()))
	else:
		httpReplyError.emit("Failed to download level")
		signalBus.startTextPopup.emit(str("Failed to load level.\nCould not find level with the ID ",levelID))

func storeSession(session):
	session["storedAt"] = Time.get_unix_time_from_system()
	#apparently this isnt the most secure option but it is good enough for now.
	var file = FileAccess.open("user://authSession.dat",FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(session))
		file.close()
	return session
func loadSession():
	var file = FileAccess.open("user://authSession.dat",FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(content) == OK:
			var session = json.data
			
			if session.has("storedAt") and session.has("expiresIn") :
				var age = Time.get_unix_time_from_system() - session["storedAt"]
				if age > int(session["expiresIn"]) - 300:
					session["isExpired"] = true
			return session
	return {}
func isSessionValid():
	var session = loadSession()
	if not session.has("accessToken") or session["accessToken"] == "":
		return false
	if session.get("isExpired", false):
		return false
	return true
func ensureValidSession():
	if !isSessionValid():
		if !sessionCache.has("refreshToken"):
			return false
		refreshToken(sessionCache["refreshToken"])
		await tokenRefreshed
		return true
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
	await genericHttpRequest(url,headers,HTTPClient.METHOD_POST,JSON.stringify(body))

func signOut():
	var session = loadSession()
	if session.has("accessToken"):
		var url = SUPABASE_URL+"/auth/v1/logout"
		var headers = [
			"Content-Type: application/json",
			"apikey: "+SUPABASE_ANON_KEY,
			"Authorization: Bearer "+session["accessToken"]
		]
		clearSession()
		await genericHttpRequest(url,headers,HTTPClient.METHOD_POST)

##clear session file
func clearSession():
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("authSession.dat")
	sessionCache={}
	signalBus.signedOut.emit()

func onHttpReplyError(message):
	printerr("error: ",message)
	
func onAuthSuccess(session):
	if typeof(session) == TYPE_DICTIONARY:
		storeSession(session)
		sessionCache = session
		tokenRefreshed.emit()
		isSignedIn = true
		##BRING THIS BACK AFTER REWORK
		await ensureAccountExists()

func onAuthError(error):
	printerr(error)
