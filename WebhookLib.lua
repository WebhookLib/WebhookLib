--[[
██╗    ██╗███████╗██████╗ ██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗██╗     ██╗██████╗ 
██║    ██║██╔════╝██╔══██╗██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██║     ██║██╔══██╗
██║ █╗ ██║█████╗  ██████╔╝███████║██║   ██║██║   ██║█████╔╝ ██║     ██║██████╔╝
██║███╗██║██╔══╝  ██╔══██╗██╔══██║██║   ██║██║   ██║██╔═██╗ ██║     ██║██╔══██╗
╚███╔███╔╝███████╗██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████╗██║██████╔╝
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ 

PURPOSE:
  WebhookLib is a production-quality Discord webhook library for Roblox Server environments.
  It provides a complete suite of features for sending Discord webhook messages including:
  - Plain text and rich embed messages with automatic sanitization
  - Player join/leave notifications with Roblox avatar thumbnails
  - Optional automatic rate limiting and request queueing with exponential backoff
  - DataStore-backed join count tracking with in-memory caching
  - Robust error handling with configurable retry logic
  - Optional profanity filtering with custom word lists
  - Comprehensive debugging and logging capabilities
  - Thread-safe operations that won't block the main game thread
  - Send messages to Discord threads
  - Edit and delete webhook messages
  - Message ID tracking and logging

REQUIRED ROBLOX GAME SETTINGS:
  1. Go to Game Settings > Security tab
  2. Enable "Allow HTTP Requests" - This is REQUIRED for webhook functionality
  3. Ensure DataStore API access is enabled (usually enabled by default)
  4. For production games, consider enabling Studio API access for testing

HOW TO OBTAIN A DISCORD WEBHOOK URL (USING THE PROXY):
1. In your Discord server, go to Server Settings > Integrations > Webhooks
2. Click New Webhook or Create Webhook
3. Set the webhook name, avatar, and target channel
4. Copy the webhook URL (format: https://discord.com/api/webhooks/ID/TOKEN)
5. Open https://webhook.lewisakura.moe/
6. Paste your normal Discord webhook URL and convert it
7. You will get a new URL in the format:
   https://webhook.lewisakura.moe/api/webhooks/ID/TOKEN
8. Use this new URL in your Roblox script instead of the normal Discord link
9. Keep this URL secure -- anyone with access can send messages to your Discord

MINIMAL SETUP STEPS:
  1. Place this ModuleScript in ReplicatedStorage and name it "WebhookLib"
  2. In a ServerScript, require the module: local WebhookLib = require(game.ReplicatedStorage.WebhookLib)
  3. Create an instance: local webhook = WebhookLib.new("YOUR_WEBHOOK_URL_HERE")
  4. Send a test message: webhook:SendMessage("Hello from Roblox!")
  5. Optional: Connect player events for automatic join/leave notifications

CONFIGURATION OPTIONS:
  - queue_enabled: Enable request queueing (default: false, only enabled if explicitly set)
  - queue_rate_limit: Requests per second limit (default: none, only enabled if set)
  - filter_profanity: Enable profanity filtering (default: false)
  - debug: Enable debug logging (default: false)
  - track_message_ids: Store message IDs for editing/deleting (default: false)
  - All other options are available but not required

PRODUCTION CONSIDERATIONS:
  - Always use pcall() when calling webhook methods in production
  - Only enable queue_enabled for high-traffic games if needed
  - Set appropriate cache_ttl_avatar values based on your needs
  - Use debug = false in production for better performance
  - Implement proper error handling for mission-critical notifications
--]]
--[[
PUT IT IN ReplicatedStorage
by bluezly!
https://webhooklib.github.io/
Enhanced with Thread Support, Message Editing, and Deletion
--]]

-- Services
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Constants
local API_THUMBNAILS_URL = "https://thumbnails.roblox.com/v1/users/avatar-headshot"
local DEFAULT_AVATAR_URL = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
local MAX_EMBED_DESCRIPTION_LENGTH = 4096
local MAX_EMBED_FIELD_VALUE_LENGTH = 1024
local MAX_EMBED_TITLE_LENGTH = 256
local MAX_EMBEDS_PER_MESSAGE = 10
local MAX_CONTENT_LENGTH = 2000
local DATASTORE_RETRY_ATTEMPTS = 3
local HTTP_RETRY_ATTEMPTS = 3
local QUEUE_CHECK_INTERVAL = 0.1
local AVATAR_FETCH_TIMEOUT = 5

-- Default configuration options (minimal defaults, features only enabled when explicitly requested)
local DEFAULT_OPTIONS = {
	username = "Roblox Game",
	avatar_url = DEFAULT_AVATAR_URL,
	default_color = 0x00ff00, -- Green
	max_retries = 3,
	retry_backoff_base = 1, -- seconds
	queue_enabled = false, -- Disabled by default
	queue_rate_limit = nil, -- No rate limiting by default
	cache_ttl_avatar = 300, -- 5 minutes in seconds
	debug = false,
	datastore_name = "WebhookLib_JoinCounts",
	filter_profanity = false,
	banned_words = {}, -- Custom banned words to add to defaults
	track_message_ids = false, -- Store message IDs for editing/deleting
	max_stored_messages = 100 -- Maximum number of message IDs to store
}

-- Default banned words list (keep it minimal and appropriate)
local DEFAULT_BANNED_WORDS = {
	"noob", "trash", "garbage", "stupid", "idiot", "loser", "fail"
}

-- WebhookLib Module
local WebhookLib = {}
WebhookLib.__index = WebhookLib

-- Utility Functions
local function deepCopy(original)
	if type(original) ~= "table" then return original end
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = deepCopy(value)
	end
	return copy
end

local function mergeOptions(defaults, overrides)
	local result = deepCopy(defaults)
	if overrides and type(overrides) == "table" then
		for key, value in pairs(overrides) do
			result[key] = value
		end
	end
	return result
end

local function truncateText(text, maxLength)
	if not text then return "" end
	text = tostring(text)
	if #text <= maxLength then return text end
	return text:sub(1, maxLength - 3) .. "..."
end

local function getCurrentTimestamp()
	return tick()
end

local function exponentialBackoff(attempt, baseDelay)
	return math.min(baseDelay * (2 ^ (attempt - 1)), 60) -- Cap at 60 seconds
end

local function safeJSONDecode(str)
	local success, result = pcall(HttpService.JSONDecode, HttpService, str)
	return success and result or nil
end

local function safeJSONEncode(data)
	local success, result = pcall(HttpService.JSONEncode, HttpService, data)
	return success and result or nil
end

local function extractWebhookInfo(url)
	-- Extract webhook ID and token from URL
	local pattern = "/webhooks/(%d+)/([%w%-_]+)"
	local id, token = url:match(pattern)
	return id, token
end

local function buildWebhookUrl(baseUrl, threadId)
	if threadId then
		local separator = baseUrl:find("?") and "&" or "?"
		return baseUrl .. separator .. "thread_id=" .. threadId
	end
	return baseUrl
end

local function buildMessageUrl(baseUrl, messageId)
	-- Convert webhook URL to message-specific URL
	local id, token = extractWebhookInfo(baseUrl)
	if id and token then
		local baseApiUrl = baseUrl:match("(.+)/webhooks/")
		return baseApiUrl .. "/webhooks/" .. id .. "/" .. token .. "/messages/" .. messageId
	end
	return nil
end

-- Constructor
function WebhookLib.new(url, options)
	if not url or type(url) ~= "string" or url == "" then
		error("WebhookLib.new() requires a valid webhook URL string", 2)
	end

	local self = setmetatable({}, WebhookLib)

	-- Configuration with smart defaults
	self._url = url
	self._config = mergeOptions(DEFAULT_OPTIONS, options)

	-- Smart queue configuration
	if options then
		-- Enable queue if explicitly requested OR if rate limit is set
		if options.queue_enabled == true or options.queue_rate_limit then
			self._config.queue_enabled = true
		end

		-- If queue_rate_limit is provided, ensure queue is enabled
		if options.queue_rate_limit and type(options.queue_rate_limit) == "number" and options.queue_rate_limit > 0 then
			self._config.queue_enabled = true
			self._config.queue_rate_limit = options.queue_rate_limit
		end
	end

	-- State management
	self._avatarCache = {}
	self._joinCountCache = {}
	self._requestQueue = {}
	self._queueRunning = false
	self._lastRequestTime = 0
	self._shutdown = false
	self._messageIds = {} -- Store message IDs for editing/deleting
	self._messageCount = 0

	-- DataStore initialization
	self._dataStore = nil
	pcall(function()
		self._dataStore = DataStoreService:GetDataStore(self._config.datastore_name)
	end)

	-- Banned words setup (only if profanity filtering is enabled)
	self._bannedWords = {}
	if self._config.filter_profanity then
		for _, word in ipairs(DEFAULT_BANNED_WORDS) do
			self._bannedWords[word:lower()] = true
		end
		if self._config.banned_words then
			for _, word in ipairs(self._config.banned_words) do
				self._bannedWords[tostring(word):lower()] = true
			end
		end
	end

	-- Initialize logging
	self:_log("WebhookLib initialized successfully")
	self:_log("Queue system:", self._config.queue_enabled and "ENABLED" or "DISABLED")
	if self._config.queue_enabled and self._config.queue_rate_limit then
		self:_log("Rate limit:", self._config.queue_rate_limit, "requests/second")
	elseif self._config.queue_enabled then
		self:_log("Rate limit: DISABLED (no rate limiting)")
	end
	self:_log("DataStore:", self._dataStore and "AVAILABLE" or "UNAVAILABLE")
	self:_log("Profanity filter:", self._config.filter_profanity and "ENABLED" or "DISABLED")
	self:_log("Message ID tracking:", self._config.track_message_ids and "ENABLED" or "DISABLED")

	-- Start background queue processor only if queue is enabled
	if self._config.queue_enabled then
		self:_startQueueProcessor()
	end

	return self
end

-- Private Methods

function WebhookLib:_log(...)
	if self._config.debug then
		local args = {...}
		for i, arg in ipairs(args) do
			args[i] = tostring(arg)
		end
		print("[WebhookLib]", table.concat(args, " "))
	end
end

function WebhookLib:_storeMessageId(messageId, metadata)
	if not self._config.track_message_ids or not messageId then return end

	self._messageCount = self._messageCount + 1
	local key = "msg_" .. self._messageCount

	-- Store with metadata
	self._messageIds[key] = {
		id = messageId,
		timestamp = getCurrentTimestamp(),
		metadata = metadata or {}
	}

	-- Clean old messages if we exceed the limit
	if self._messageCount > self._config.max_stored_messages then
		local oldestKey = "msg_" .. (self._messageCount - self._config.max_stored_messages)
		self._messageIds[oldestKey] = nil
	end

	self:_log("Stored message ID:", messageId, "as", key)
end

function WebhookLib:_findMessageById(messageId)
	for key, data in pairs(self._messageIds) do
		if data.id == messageId then
			return key, data
		end
	end
	return nil, nil
end

function WebhookLib:_startQueueProcessor()
	if self._queueRunning or not self._config.queue_enabled then return end
	self._queueRunning = true

	task.spawn(function()
		self:_log("Queue processor started")

		while not self._shutdown and self._config.queue_enabled do
			if #self._requestQueue > 0 then
				local request = table.remove(self._requestQueue, 1)

				-- Rate limiting check (only if rate limit is configured)
				if self._config.queue_rate_limit and self._config.queue_rate_limit > 0 then
					local timeSinceLastRequest = getCurrentTimestamp() - self._lastRequestTime
					local minInterval = 1 / self._config.queue_rate_limit

					if timeSinceLastRequest < minInterval then
						local waitTime = minInterval - timeSinceLastRequest
						self:_log("Rate limiting: waiting", string.format("%.2f", waitTime), "seconds")
						task.wait(waitTime)
					end
				end

				self:_executeRequest(request)
				self._lastRequestTime = getCurrentTimestamp()
			else
				task.wait(QUEUE_CHECK_INTERVAL)
			end
		end

		self._queueRunning = false
		self:_log("Queue processor stopped")
	end)
end

function WebhookLib:_executeRequest(request)
	if self._shutdown then return end

	local success, response = pcall(function()
		return HttpService:RequestAsync(request.httpRequest)
	end)

	if not success then
		self:_log("HTTP request failed with error:", response)
		self:_handleRequestFailure(request, response)
		return
	end

	self:_log("HTTP response status:", response.StatusCode)

	if response.StatusCode >= 200 and response.StatusCode < 300 then
		-- Success
		self:_log("Request completed successfully")

		-- Extract message ID from response if available
		if response.Body and request.trackMessageId then
			local responseData = safeJSONDecode(response.Body)
			if responseData and responseData.id then
				self:_log("Message ID received:", responseData.id)
				self:_storeMessageId(responseData.id, request.messageMetadata)
			end
		end

		if request.onSuccess then
			task.spawn(request.onSuccess, response)
		end
	elseif response.StatusCode == 429 then
		-- Rate limited by Discord
		self:_handleDiscordRateLimit(request, response)
	elseif response.StatusCode >= 500 then
		-- Server error - retry
		self:_handleRequestFailure(request, "HTTP " .. response.StatusCode .. " (Server Error)")
	else
		-- Client error - don't retry
		self:_log("Request failed with client error:", response.StatusCode)
		if response.Body then
			local errorData = safeJSONDecode(response.Body)
			if errorData and errorData.message then
				self:_log("Discord error message:", errorData.message)
			end
		end
		if request.onFailure then
			task.spawn(request.onFailure, response)
		end
	end
end

function WebhookLib:_handleDiscordRateLimit(request, response)
	local retryAfter = 1 -- Default fallback

	-- Parse retry-after from response headers
	if response.Headers and response.Headers["retry-after"] then
		retryAfter = tonumber(response.Headers["retry-after"]) or retryAfter
	elseif response.Headers and response.Headers["Retry-After"] then
		retryAfter = tonumber(response.Headers["Retry-After"]) or retryAfter
	elseif response.Body then
		local data = safeJSONDecode(response.Body)
		if data and data.retry_after then
			retryAfter = data.retry_after
		end
	end

	-- Cap retry delay for safety
	retryAfter = math.min(retryAfter, 300) -- Max 5 minutes

	self:_log("Discord rate limit detected, retrying after", retryAfter, "seconds")

	-- Schedule retry
	task.spawn(function()
		task.wait(retryAfter)
		if not self._shutdown then
			table.insert(self._requestQueue, 1, request) -- Priority insertion
		end
	end)
end

function WebhookLib:_handleRequestFailure(request, errorMsg)
	request.attempts = (request.attempts or 0) + 1

	if request.attempts < self._config.max_retries then
		local delay = exponentialBackoff(request.attempts, self._config.retry_backoff_base)
		self:_log("Scheduling retry in", string.format("%.2f", delay), "seconds (attempt", request.attempts + 1 .. "/" .. self._config.max_retries .. ")")

		task.spawn(function()
			task.wait(delay)
			if not self._shutdown then
				if self._config.queue_enabled then
					table.insert(self._requestQueue, request)
				else
					self:_executeRequest(request)
				end
			end
		end)
	else
		self:_log("Request failed permanently after", self._config.max_retries, "attempts:", errorMsg)
		if request.onFailure then
			task.spawn(request.onFailure, errorMsg)
		end
	end
end

function WebhookLib:_queueRequest(httpRequest, onSuccess, onFailure, trackMessageId, messageMetadata)
	if not HttpService.HttpEnabled then
		self:_log("ERROR: HTTP requests are disabled in game settings")
		if onFailure then
			task.spawn(onFailure, "HTTP requests disabled")
		end
		return
	end

	local request = {
		httpRequest = httpRequest,
		onSuccess = onSuccess,
		onFailure = onFailure,
		attempts = 0,
		timestamp = getCurrentTimestamp(),
		trackMessageId = trackMessageId or false,
		messageMetadata = messageMetadata or {}
	}

	if self._config.queue_enabled then
		table.insert(self._requestQueue, request)
		self:_log("Request queued (queue size:", #self._requestQueue .. ")")

		if not self._queueRunning then
			self:_startQueueProcessor()
		end
	else
		-- Execute immediately without queueing
		task.spawn(function()
			self:_executeRequest(request)
		end)
	end
end

function WebhookLib:_filterText(text)
	if not self._config.filter_profanity or not text then
		return text
	end

	text = tostring(text)
	local words = text:split(" ")

	for i, word in ipairs(words) do
		local cleanWord = word:lower():gsub("[%p%c]", "") -- Remove punctuation
		if self._bannedWords[cleanWord] then
			words[i] = string.rep("*", #word)
		end
	end

	return table.concat(words, " ")
end

function WebhookLib:_sanitizeEmbed(embed)
	if not embed or type(embed) ~= "table" then return embed end

	local sanitized = deepCopy(embed)

	-- Sanitize and truncate text fields
	if sanitized.title then
		sanitized.title = truncateText(self:_filterText(sanitized.title), MAX_EMBED_TITLE_LENGTH)
	end

	if sanitized.description then
		sanitized.description = truncateText(self:_filterText(sanitized.description), MAX_EMBED_DESCRIPTION_LENGTH)
	end

	if sanitized.fields and type(sanitized.fields) == "table" then
		for i, field in ipairs(sanitized.fields) do
			if type(field) == "table" then
				if field.name then
					sanitized.fields[i].name = truncateText(self:_filterText(field.name), 256)
				end
				if field.value then
					sanitized.fields[i].value = truncateText(self:_filterText(field.value), MAX_EMBED_FIELD_VALUE_LENGTH)
				end
			end
		end
	end

	if sanitized.footer and type(sanitized.footer) == "table" and sanitized.footer.text then
		sanitized.footer.text = truncateText(self:_filterText(sanitized.footer.text), 2048)
	end

	if sanitized.author and type(sanitized.author) == "table" and sanitized.author.name then
		sanitized.author.name = truncateText(self:_filterText(sanitized.author.name), 256)
	end

	return sanitized
end

function WebhookLib:_fetchPlayerAvatar(userId)
	local success, result = pcall(function()
		local url = API_THUMBNAILS_URL .. "?userIds=" .. userId .. "&size=420x420&format=Png&isCircular=false"

		local httpRequest = {
			Url = url,
			Method = "GET",
			Headers = {}
		}

		local response = HttpService:RequestAsync(httpRequest)

		if response.StatusCode == 200 and response.Body then
			local data = safeJSONDecode(response.Body)
			if data and data.data and data.data[1] and data.data[1].imageUrl then
				return data.data[1].imageUrl
			end
		end

		return nil
	end)

	if success and result then
		self:_log("Successfully fetched avatar for user", userId)
		return result
	else
		self:_log("Failed to fetch avatar for user", userId .. ":", result or "Unknown error")
		return self._config.avatar_url
	end
end

function WebhookLib:_getPlayerAvatar(userId)
	local cacheKey = tostring(userId)
	local cached = self._avatarCache[cacheKey]

	-- Check cache validity
	if cached and (getCurrentTimestamp() - cached.timestamp) < self._config.cache_ttl_avatar then
		return cached.url
	end

	-- Fetch avatar asynchronously
	task.spawn(function()
		local avatarUrl = self:_fetchPlayerAvatar(userId)

		-- Cache the result
		self._avatarCache[cacheKey] = {
			url = avatarUrl,
			timestamp = getCurrentTimestamp()
		}
	end)

	-- Return cached URL if available, otherwise default
	return cached and cached.url or self._config.avatar_url
end

function WebhookLib:_getJoinCount(userId)
	local cacheKey = tostring(userId)

	-- Check memory cache first
	if self._joinCountCache[cacheKey] then
		return self._joinCountCache[cacheKey]
	end

	-- Try DataStore with retries
	local count = 0
	if self._dataStore then
		for attempt = 1, DATASTORE_RETRY_ATTEMPTS do
			local success, result = pcall(function()
				return self._dataStore:GetAsync("joins_" .. userId)
			end)

			if success then
				count = tonumber(result) or 0
				self:_log("Retrieved join count for user", userId .. ":", count)
				break
			else
				self:_log("DataStore get attempt", attempt, "failed for user", userId .. ":", result)
				if attempt < DATASTORE_RETRY_ATTEMPTS then
					task.wait(exponentialBackoff(attempt, 0.1))
				end
			end
		end
	else
		self:_log("DataStore not available, using memory cache only")
	end

	-- Cache the result
	self._joinCountCache[cacheKey] = count
	return count
end

function WebhookLib:_incrementJoinCount(userId)
	local currentCount = self:_getJoinCount(userId)
	local newCount = currentCount + 1
	local cacheKey = tostring(userId)

	-- Update memory cache immediately
	self._joinCountCache[cacheKey] = newCount

	-- Update DataStore asynchronously
	if self._dataStore then
		task.spawn(function()
			for attempt = 1, DATASTORE_RETRY_ATTEMPTS do
				local success, error = pcall(function()
					self._dataStore:SetAsync("joins_" .. userId, newCount)
				end)

				if success then
					self:_log("Updated DataStore join count for user", userId, "to", newCount)
					break
				else
					self:_log("DataStore set attempt", attempt, "failed for user", userId .. ":", error)
					if attempt < DATASTORE_RETRY_ATTEMPTS then
						task.wait(exponentialBackoff(attempt, 0.1))
					end
				end
			end
		end)
	end

	return newCount
end

-- Public API Methods

function WebhookLib:SendMessage(content, overrides, threadId)
	if not content then
		self:_log("SendMessage: content parameter is required")
		return false
	end

	local filteredContent = truncateText(self:_filterText(content), MAX_CONTENT_LENGTH)
	overrides = overrides or {}

	local payload = {
		content = filteredContent,
		username = overrides.username or self._config.username,
		avatar_url = overrides.avatar_url or self._config.avatar_url
	}

	local body = safeJSONEncode(payload)
	if not body then
		self:_log("SendMessage: Failed to encode JSON payload")
		return false
	end

	local url = buildWebhookUrl(self._url, threadId)

	local httpRequest = {
		Url = url,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = body
	}

	local messageMetadata = {
		type = "message",
		content = filteredContent,
		threadId = threadId
	}

	self:_queueRequest(httpRequest, nil, nil, self._config.track_message_ids, messageMetadata)
	self:_log("Queued text message:", filteredContent:sub(1, 50) .. (#filteredContent > 50 and "..." or ""))
	if threadId then
		self:_log("Target thread ID:", threadId)
	end
	return true
end

function WebhookLib:SendMessageInThread(content, threadId, overrides)
	if not threadId then
		self:_log("SendMessageInThread: threadId parameter is required")
		return false
	end

	return self:SendMessage(content, overrides, threadId)
end

function WebhookLib:SendEmbed(embedTable, threadId)
	if not embedTable or type(embedTable) ~= "table" then
		self:_log("SendEmbed: embedTable must be a valid table")
		return false
	end

	local sanitizedEmbed = self:_sanitizeEmbed(embedTable)

	local payload = {
		username = self._config.username,
		avatar_url = self._config.avatar_url,
		embeds = {sanitizedEmbed}
	}

	local body = safeJSONEncode(payload)
	if not body then
		self:_log("SendEmbed: Failed to encode JSON payload")
		return false
	end

	local url = buildWebhookUrl(self._url, threadId)

	local httpRequest = {
		Url = url,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = body
	}

	local messageMetadata = {
		type = "embed",
		title = sanitizedEmbed.title,
		threadId = threadId
	}

	self:_queueRequest(httpRequest, nil, nil, self._config.track_message_ids, messageMetadata)
	self:_log("Queued embed:", sanitizedEmbed.title or "No title")
	if threadId then
		self:_log("Target thread ID:", threadId)
	end
	return true
end

function WebhookLib:SendEmbedInThread(embedTable, threadId)
	if not threadId then
		self:_log("SendEmbedInThread: threadId parameter is required")
		return false
	end

	return self:SendEmbed(embedTable, threadId)
end

function WebhookLib:SendMultipleEmbeds(embeds, threadId)
	if not embeds or type(embeds) ~= "table" or #embeds == 0 then
		self:_log("SendMultipleEmbeds: embeds must be a non-empty array")
		return false
	end

	-- Limit to Discord's maximum and sanitize
	local sanitizedEmbeds = {}
	for i = 1, math.min(#embeds, MAX_EMBEDS_PER_MESSAGE) do
		if type(embeds[i]) == "table" then
			table.insert(sanitizedEmbeds, self:_sanitizeEmbed(embeds[i]))
		end
	end

	if #sanitizedEmbeds == 0 then
		self:_log("SendMultipleEmbeds: No valid embeds found in array")
		return false
	end

	local payload = {
		username = self._config.username,
		avatar_url = self._config.avatar_url,
		embeds = sanitizedEmbeds
	}

	local body = safeJSONEncode(payload)
	if not body then
		self:_log("SendMultipleEmbeds: Failed to encode JSON payload")
		return false
	end

	local url = buildWebhookUrl(self._url, threadId)

	local httpRequest = {
		Url = url,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = body
	}

	local messageMetadata = {
		type = "multiple_embeds",
		count = #sanitizedEmbeds,
		threadId = threadId
	}

	self:_queueRequest(httpRequest, nil, nil, self._config.track_message_ids, messageMetadata)
	self:_log("Queued", #sanitizedEmbeds, "embeds")
	if threadId then
		self:_log("Target thread ID:", threadId)
	end
	return true
end

function WebhookLib:EditMessage(messageId, content, embeds)
	if not messageId then
		self:_log("EditMessage: messageId parameter is required")
		return false
	end

	if not content and not embeds then
		self:_log("EditMessage: Either content or embeds parameter is required")
		return false
	end

	local messageUrl = buildMessageUrl(self._url, messageId)
	if not messageUrl then
		self:_log("EditMessage: Failed to build message URL")
		return false
	end

	local payload = {}

	if content then
		payload.content = truncateText(self:_filterText(content), MAX_CONTENT_LENGTH)
	end

	if embeds then
		if type(embeds) ~= "table" then
			self:_log("EditMessage: embeds must be a table")
			return false
		end

		local sanitizedEmbeds = {}
		if embeds[1] then
			-- Array of embeds
			for i = 1, math.min(#embeds, MAX_EMBEDS_PER_MESSAGE) do
				if type(embeds[i]) == "table" then
					table.insert(sanitizedEmbeds, self:_sanitizeEmbed(embeds[i]))
				end
			end
		else
			-- Single embed object
			table.insert(sanitizedEmbeds, self:_sanitizeEmbed(embeds))
		end

		payload.embeds = sanitizedEmbeds
	end

	local body = safeJSONEncode(payload)
	if not body then
		self:_log("EditMessage: Failed to encode JSON payload")
		return false
	end

	local httpRequest = {
		Url = messageUrl,
		Method = "PATCH",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = body
	}

	self:_queueRequest(httpRequest)
	self:_log("Queued message edit for ID:", messageId)
	return true
end

function WebhookLib:DeleteMessage(messageId)
	if not messageId then
		self:_log("DeleteMessage: messageId parameter is required")
		return false
	end

	local messageUrl = buildMessageUrl(self._url, messageId)
	if not messageUrl then
		self:_log("DeleteMessage: Failed to build message URL")
		return false
	end

	local httpRequest = {
		Url = messageUrl,
		Method = "DELETE",
		Headers = {}
	}

	self:_queueRequest(httpRequest, function()
		-- Remove from stored messages if tracked
		local key, _ = self:_findMessageById(messageId)
		if key then
			self._messageIds[key] = nil
			self:_log("Removed message ID from storage:", messageId)
		end
	end)

	self:_log("Queued message deletion for ID:", messageId)
	return true
end

function WebhookLib:SendJoinMessage(player, threadId)
	if not player or not player:IsA("Player") then
		self:_log("SendJoinMessage: Invalid player object provided")
		return false
	end

	task.spawn(function()
		local joinCount = self:_incrementJoinCount(player.UserId)
		local avatarUrl = self:_getPlayerAvatar(player.UserId)
		local totalPlayers = #Players:GetPlayers()

		local embed = {
			title = "🎮 Player Joined",
			description = string.format("**%s** has joined the game!", player.DisplayName),
			color = 0x00ff00, -- Green
			thumbnail = {
				url = avatarUrl
			},
			fields = {
				{
					name = "👤 Username",
					value = player.Name,
					inline = true
				},
				{
					name = "🏷️ Display Name",
					value = player.DisplayName,
					inline = true
				},
				{
					name = "🆔 User ID",
					value = tostring(player.UserId),
					inline = true
				},
				{
					name = "📊 Join Count",
					value = tostring(joinCount),
					inline = true
				},
				{
					name = "👥 Players Online",
					value = tostring(totalPlayers),
					inline = true
				},
				{
					name = "📅 Account Age",
					value = tostring(player.AccountAge) .. " days",
					inline = true
				}
			},
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			footer = {
				text = "Player Activity • Join Event"
			}
		}

		self:SendEmbed(embed, threadId)
	end)

	return true
end

function WebhookLib:SendLeaveMessage(player, threadId)
	if not player or not player:IsA("Player") then
		self:_log("SendLeaveMessage: Invalid player object provided")
		return false
	end

	task.spawn(function()
		local joinCount = self:_getJoinCount(player.UserId)
		local avatarUrl = self:_getPlayerAvatar(player.UserId)
		local totalPlayers = math.max(0, #Players:GetPlayers() - 1) -- Player still in list when event fires

		local embed = {
			title = "👋 Player Left",
			description = string.format("**%s** has left the game.", player.DisplayName),
			color = 0xff0000, -- Red
			thumbnail = {
				url = avatarUrl
			},
			fields = {
				{
					name = "👤 Username",
					value = player.Name,
					inline = true
				},
				{
					name = "🏷️ Display Name",
					value = player.DisplayName,
					inline = true
				},
				{
					name = "🆔 User ID",
					value = tostring(player.UserId),
					inline = true
				},
				{
					name = "📊 Total Joins",
					value = tostring(joinCount),
					inline = true
				},
				{
					name = "👥 Players Online",
					value = tostring(totalPlayers),
					inline = true
				},
				{
					name = "⏱️ Session Length",
					value = "Unknown", -- Could be calculated if session start time was tracked
					inline = true
				}
			},
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			footer = {
				text = "Player Activity • Leave Event"
			}
		}

		self:SendEmbed(embed, threadId)
	end)

	return true
end

function WebhookLib:SendCustomEvent(name, data, threadId)
	if not name then
		self:_log("SendCustomEvent: name parameter is required")
		return false
	end

	local fields = {}
	if data and type(data) == "table" then
		for key, value in pairs(data) do
			-- Limit number of fields to prevent payload bloat
			if #fields >= 25 then break end

			table.insert(fields, {
				name = truncateText(tostring(key), 256),
				value = truncateText(tostring(value), MAX_EMBED_FIELD_VALUE_LENGTH),
				inline = true
			})
		end
	end

	local embed = {
		title = "🔔 " .. truncateText(self:_filterText(name), MAX_EMBED_TITLE_LENGTH),
		color = self._config.default_color,
		fields = fields,
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		footer = {
			text = "Custom Event"
		}
	}

	return self:SendEmbed(embed, threadId)
end

function WebhookLib:GetStoredMessages()
	if not self._config.track_message_ids then
		self:_log("GetStoredMessages: Message ID tracking is disabled")
		return {}
	end

	local messages = {}
	for key, data in pairs(self._messageIds) do
		table.insert(messages, {
			key = key,
			id = data.id,
			timestamp = data.timestamp,
			metadata = data.metadata
		})
	end

	-- Sort by timestamp (newest first)
	table.sort(messages, function(a, b)
		return a.timestamp > b.timestamp
	end)

	return messages
end

function WebhookLib:GetLatestMessageId()
	if not self._config.track_message_ids then
		self:_log("GetLatestMessageId: Message ID tracking is disabled")
		return nil
	end

	local latest = nil
	local latestTime = 0

	for _, data in pairs(self._messageIds) do
		if data.timestamp > latestTime then
			latestTime = data.timestamp
			latest = data.id
		end
	end

	return latest
end

function WebhookLib:ClearStoredMessages()
	self._messageIds = {}
	self._messageCount = 0
	self:_log("Cleared all stored message IDs")
end

function WebhookLib:SetWebhookUrl(url)
	if not url or type(url) ~= "string" or url == "" then
		self:_log("SetWebhookUrl: Invalid URL provided")
		return false
	end

	self._url = url
	self:_log("Webhook URL updated successfully")
	return true
end

function WebhookLib:SetDefaultUsername(username)
	if username then
		self._config.username = tostring(username)
		self:_log("Default username updated to:", username)
		return true
	end
	return false
end

function WebhookLib:SetDefaultAvatarUrl(avatarUrl)
	if avatarUrl then
		self._config.avatar_url = tostring(avatarUrl)
		self:_log("Default avatar URL updated successfully")
		return true
	end
	return false
end

function WebhookLib:SetDefaultColor(color)
	if type(color) == "number" and color >= 0 and color <= 0xFFFFFF then
		self._config.default_color = math.floor(color)
		self:_log("Default color updated to:", string.format("0x%06X", color))
		return true
	end
	return false
end

function WebhookLib:EnableDebug(enabled)
	local wasEnabled = self._config.debug
	self._config.debug = not not enabled

	if enabled and not wasEnabled then
		print("[WebhookLib] Debug logging enabled")
	elseif not enabled and wasEnabled then
		print("[WebhookLib] Debug logging disabled")
	end

	return true
end

function WebhookLib:EnableQueue(enabled, rateLimit)
	local wasEnabled = self._config.queue_enabled
	self._config.queue_enabled = not not enabled

	if rateLimit and type(rateLimit) == "number" and rateLimit > 0 then
		self._config.queue_rate_limit = rateLimit
	end

	if enabled and not wasEnabled then
		self:_log("Queue system enabled")
		if self._config.queue_rate_limit then
			self:_log("Rate limit set to:", self._config.queue_rate_limit, "requests/second")
		end
		self:_startQueueProcessor()
	elseif not enabled and wasEnabled then
		self:_log("Queue system disabled")
	end

	return true
end

function WebhookLib:EnableMessageTracking(enabled)
	local wasEnabled = self._config.track_message_ids
	self._config.track_message_ids = not not enabled

	if enabled and not wasEnabled then
		self:_log("Message ID tracking enabled")
	elseif not enabled and wasEnabled then
		self:_log("Message ID tracking disabled")
		self:ClearStoredMessages()
	end

	return true
end

function WebhookLib:GetQueueSize()
	return #self._requestQueue
end

function WebhookLib:IsQueueEnabled()
	return self._config.queue_enabled
end

function WebhookLib:IsMessageTrackingEnabled()
	return self._config.track_message_ids
end

function WebhookLib:GetConfiguration()
	return deepCopy(self._config)
end

function WebhookLib:Shutdown()
	if self._shutdown then return end

	self._shutdown = true
	self:_log("Shutdown initiated...")

	-- Give pending requests time to complete
	local timeout = 10 -- seconds
	local startTime = getCurrentTimestamp()

	while #self._requestQueue > 0 and (getCurrentTimestamp() - startTime) < timeout do
		task.wait(0.1)
	end

	if #self._requestQueue > 0 then
		self:_log("Shutdown completed with", #self._requestQueue, "requests still pending")
	else
		self:_log("Shutdown completed successfully")
	end
end

return WebhookLib

--[[
═══════════════════════════════════════════════════════════════════════════════
                                EXAMPLE USAGE
═══════════════════════════════════════════════════════════════════════════════

-- EXAMPLE 1: Minimal Setup (No Queue, No Rate Limiting)
local WebhookLib = require(game.ReplicatedStorage.WebhookLib)
local webhook = WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN")

-- This sends messages immediately without queueing
webhook:SendMessage("🎮 Server started!")

-- EXAMPLE 2: With Queue Enabled and Message Tracking
local webhook = WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN", {
    username = "My Game Bot",
    queue_enabled = true, -- Enables queueing but no rate limiting
    debug = true,
    track_message_ids = true -- Enable message ID tracking for editing/deleting
})

-- EXAMPLE 3: With Queue, Rate Limiting, and Message Tracking
local webhook = WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN", {
    username = "🎮 My Awesome Game",
    debug = true,
    queue_rate_limit = 2, -- 2 requests per second (automatically enables queue)
    filter_profanity = true,
    default_color = 0x0099ff,
    banned_words = {"custom", "bad", "words"}, -- Adds to default list
    track_message_ids = true, -- Track message IDs for editing/deleting
    max_stored_messages = 50 -- Store up to 50 message IDs
})

-- EXAMPLE 4: Thread Support
local THREAD_ID = "123456789012345678" -- Your Discord thread ID

-- Send message to a specific thread
webhook:SendMessageInThread("Hello from thread!", THREAD_ID)

-- Send embed to a specific thread
webhook:SendEmbedInThread({
    title = "Thread Message",
    description = "This is sent to a specific thread",
    color = 0x00ff00
}, THREAD_ID)

-- Alternative syntax (using optional threadId parameter)
webhook:SendMessage("Hello thread!", nil, THREAD_ID)
webhook:SendEmbed({title = "Embed in Thread"}, THREAD_ID)

-- EXAMPLE 5: Message Editing and Deletion
local webhook = WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN", {
    debug = true,
    track_message_ids = true -- Required for editing/deleting
})

-- Send a message
webhook:SendMessage("Original message")

-- Wait a moment for the message to be sent and tracked
task.wait(2)

-- Get the latest message ID
local messageId = webhook:GetLatestMessageId()
if messageId then
    -- Edit the message
    webhook:EditMessage(messageId, "Edited message content!")
    
    -- Wait before deleting
    task.wait(5)
    
    -- Delete the message
    webhook:DeleteMessage(messageId)
end

-- EXAMPLE 6: Manual Message ID Management
-- If you know a specific message ID (from Discord or previous sends)
local knownMessageId = "987654321098765432"

-- Edit with new content
webhook:EditMessage(knownMessageId, "New content here")

-- Edit with new embed
webhook:EditMessage(knownMessageId, nil, {
    title = "Updated Embed",
    description = "This embed replaces the original message",
    color = 0xff0000
})

-- Edit with both content and embed
webhook:EditMessage(knownMessageId, "Updated message", {
    title = "Also Updated Embed",
    color = 0x0099ff
})

-- Delete the message
webhook:DeleteMessage(knownMessageId)

-- EXAMPLE 7: Working with Stored Messages
local webhook = WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN", {
    track_message_ids = true
})

-- Send some messages
webhook:SendMessage("Message 1")
webhook:SendMessage("Message 2")
webhook:SendEmbed({title = "Embed Message"})

-- Wait for messages to be sent and tracked
task.wait(3)

-- Get all stored messages
local storedMessages = webhook:GetStoredMessages()
for _, msg in ipairs(storedMessages) do
    print("Message ID:", msg.id)
    print("Type:", msg.metadata.type)
    print("Timestamp:", msg.timestamp)
    print("---")
end

-- Get the latest message ID
local latestId = webhook:GetLatestMessageId()
print("Latest message ID:", latestId)

-- Clear stored messages
webhook:ClearStoredMessages()

-- EXAMPLE 8: Player Events with Thread Support
local PLAYER_THREAD = "123456789012345678"

game.Players.PlayerAdded:Connect(function(player)
    pcall(function()
        -- Send join message to specific thread
        webhook:SendJoinMessage(player, PLAYER_THREAD)
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        -- Send leave message to specific thread
        webhook:SendLeaveMessage(player, PLAYER_THREAD)
    end)
end)

-- EXAMPLE 9: Custom Events with Thread Support
local EVENT_THREAD = "987654321098765432"

webhook:SendCustomEvent("🎯 Player Achievement", {
    ["Player"] = "john_doe",
    ["Achievement"] = "First Victory!",
    ["Score"] = "9,999",
    ["Time"] = os.date("%c"),
    ["Difficulty"] = "Hard Mode"
}, EVENT_THREAD)

-- EXAMPLE 10: Runtime Configuration
webhook:EnableMessageTracking(true) -- Enable message tracking at runtime
webhook:EnableDebug(true)
webhook:EnableQueue(true, 3) -- Enable queue with 3 requests/second

-- Check configuration
print("Message tracking enabled:", webhook:IsMessageTrackingEnabled())
print("Queue enabled:", webhook:IsQueueEnabled())
print("Queue size:", webhook:GetQueueSize())

-- EXAMPLE 11: Advanced Message Management
local webhook = WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN", {
    debug = true,
    track_message_ids = true,
    queue_rate_limit = 1 -- 1 request per second
})

-- Function to send and track a message
local function sendTrackedMessage(content)
    webhook:SendMessage(content)
    task.wait(2) -- Wait for message to be sent
    local id = webhook:GetLatestMessageId()
    print("Sent message with ID:", id)
    return id
end

-- Send messages and get their IDs
local msg1Id = sendTrackedMessage("This is message 1")
local msg2Id = sendTrackedMessage("This is message 2")
local msg3Id = sendTrackedMessage("This is message 3")

-- Edit the first message
if msg1Id then
    webhook:EditMessage(msg1Id, "Message 1 has been edited!")
end

-- Delete the second message
if msg2Id then
    webhook:DeleteMessage(msg2Id)
end

-- Edit the third message with an embed
if msg3Id then
    webhook:EditMessage(msg3Id, "Message 3 updated", {
        title = "Updated Embed",
        description = "This message now has an embed too!",
        color = 0x00ff00
    })
end

-- EXAMPLE 12: Error Handling for Message Operations
local function safeEditMessage(messageId, content, embeds)
    local success = pcall(function()
        return webhook:EditMessage(messageId, content, embeds)
    end)
    
    if success then
        print("Message edit queued successfully")
    else
        warn("Failed to queue message edit")
    end
end

local function safeDeleteMessage(messageId)
    local success = pcall(function()
        return webhook:DeleteMessage(messageId)
    end)
    
    if success then
        print("Message deletion queued successfully")
    else
        warn("Failed to queue message deletion")
    end
end

-- EXAMPLE 13: Complete Production Setup
local function setupProductionWebhook()
    local success, webhook = pcall(function()
        return WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN", {
            username = "🎮 Production Game",
            debug = false, -- Disable debug in production
            filter_profanity = true,
            queue_rate_limit = 2, -- Prevent Discord rate limiting
            max_retries = 5,
            track_message_ids = true, -- Enable for message management
            max_stored_messages = 100 -- Store up to 100 message IDs
        })
    end)
    
    if success then
        print("WebhookLib initialized successfully")
        
        -- Send startup message
        pcall(function()
            webhook:SendMessage("🚀 Production server started successfully!")
        end)
        
        return webhook
    else
        warn("Failed to initialize WebhookLib:", webhook)
        return nil
    end
end

local webhook = setupProductionWebhook()

-- Graceful Shutdown with Message Cleanup
game:BindToClose(function()
    if webhook then
        print("Shutting down webhook...")
        
        -- Send shutdown message
        pcall(function()
            webhook:SendMessage("🔄 Server shutting down...")
        end)
        
        -- Wait for messages to send
        webhook:Shutdown()
        task.wait(2)
        
        print("Webhook shutdown complete")
    end
end)

-- EXAMPLE 14: Message Batch Operations
local function batchEditMessages(webhook, messageIds, newContent)
    for i, messageId in ipairs(messageIds) do
        webhook:EditMessage(messageId, newContent .. " (Message " .. i .. ")")
        task.wait(0.5) -- Small delay between operations
    end
end

local function batchDeleteMessages(webhook, messageIds)
    for _, messageId in ipairs(messageIds) do
        webhook:DeleteMessage(messageId)
        task.wait(0.5) -- Small delay between operations
    end
end

-- EXAMPLE 15: Comprehensive Feature Demo
local webhook = WebhookLib.new("https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN", {
    username = "🤖 Feature Demo Bot",
    debug = true,
    track_message_ids = true,
    queue_rate_limit = 2,
    filter_profanity = true
})

-- Send various types of messages
webhook:SendMessage("Welcome to the feature demo!")

local threadId = "123456789012345678" -- Replace with actual thread ID
webhook:SendMessageInThread("This message is in a thread!", threadId)

webhook:SendEmbed({
    title = "Demo Embed",
    description = "This demonstrates embed functionality",
    color = 0x0099ff,
    fields = {
        {name = "Feature", value = "Rich Embeds", inline = true},
        {name = "Status", value = "✅ Working", inline = true}
    }
})

-- Wait and then demonstrate editing
task.wait(3)
local latestId = webhook:GetLatestMessageId()
if latestId then
    webhook:EditMessage(latestId, nil, {
        title = "Updated Demo Embed",
        description = "This embed has been edited!",
        color = 0xff6600
    })
end

print("Demo complete! Check your Discord channel.")
--]]
