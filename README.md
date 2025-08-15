<div align="center">
  <img src="https://github.com/Bluezly/iconforgrowstock/blob/main/eec925e4-7dc7-4d71-873e-754f2150cc25.png?raw=true" alt="WebhookLib Logo" width="120" height="120">
  
  # WebhookLib
  
  ### 🚀 Production-Quality Discord Webhook Library for Roblox
  
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
  [![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](https://github.com/WebhookLib/WebhookLib/releases)
  [![Roblox Model](https://img.shields.io/badge/Roblox-Model-00A2FF.svg)](https://create.roblox.com/store/asset/101200026339651/WebhookLib)
  [![Website](https://img.shields.io/badge/Website-webhooklib.luau.page-purple.svg)]([WebhookLib.github.io](https://webhooklib.github.io/))
  [![Stars](https://img.shields.io/github/stars/WebhookLib/WebhookLib.svg)](https://github.com/WebhookLib/WebhookLib/stargazers)
  [![Issues](https://img.shields.io/github/issues/WebhookLib/WebhookLib.svg)](https://github.com/WebhookLib/WebhookLib/issues)
  [![Downloads](https://img.shields.io/badge/downloads-50-brightgreen.svg)](https://create.roblox.com/store/asset/101200026339651/WebhookLib)
  <!-- [![DevForum](https://img.shields.io/badge/DevForum-Coming%20Soon-orange.svg)](https://devforum.roblox.com) -->
  
  [📖 Documentation](http://webhooklib.luau.page/) • [🛒 Get Model](https://create.roblox.com/store/asset/101200026339651/WebhookLib) • [🐛 Report Issues](https://github.com/WebhookLib/WebhookLib/issues) • [💬 Discussions](https://github.com/WebhookLib/WebhookLib/discussions)

</div>

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [🚀 Quick Start](#-quick-start)
- [📦 Installation](#-installation)
- [🛠️ Configuration](#️-configuration)
- [📚 Usage Examples](#-usage-examples)
- [🧵 Thread Support](#-thread-support)
- [✏️ Message Management](#️-message-management)
- [🎯 Advanced Features](#-advanced-features)
- [⚙️ API Reference](#️-api-reference)
- [🔧 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [👨‍💻 Author](#-author)

---

## ✨ Features

WebhookLib is a comprehensive Discord webhook solution designed specifically for Roblox server environments. It provides enterprise-grade functionality with zero external dependencies.

### 🔥 Core Features
- **📨 Rich Message Support** - Send text messages, embeds, and multi-embed messages
- **👥 Player Notifications** - Automatic join/leave messages with Roblox avatars
- **🧵 Thread Support** - Send messages directly to Discord threads
- **✏️ Message Editing** - Edit webhook messages after sending
- **🗑️ Message Deletion** - Delete webhook messages programmatically
- **🔍 Message ID Tracking** - Track and manage sent message IDs
- **🛡️ Content Filtering** - Built-in profanity filter with customizable word lists
- **⚡ Smart Rate Limiting** - Optional request queueing with exponential backoff
- **💾 DataStore Integration** - Persistent join count tracking with caching
- **🔄 Robust Error Handling** - Automatic retries with intelligent backoff
- **🚀 Production Ready** - Thread-safe, non-blocking operations
- **🐛 Debug Logging** - Comprehensive logging for development and troubleshooting

### 🎯 Advanced Capabilities
- **Avatar Caching** - Automatic Roblox avatar fetching with TTL caching
- **Automatic Sanitization** - Text truncation and content validation
- **Custom Events** - Flexible custom event logging system
- **Runtime Configuration** - Dynamic settings without restarts
- **Graceful Shutdown** - Ensures message delivery during server shutdown
- **Memory Efficient** - Optimized for high-traffic servers
- **Batch Operations** - Edit or delete multiple messages efficiently

---

## 🚀 Quick Start

Get started with WebhookLib in less than 5 minutes!

### Prerequisites
1. **Enable HTTP Requests** in your Roblox game settings
2. Create a Discord webhook URL ([Guide](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks))
3. Use the webhook proxy: `https://webhook.lewisakura.moe/api/webhooks/YOUR_ID/YOUR_TOKEN`

### Basic Setup

```lua
-- Get WebhookLib from ReplicatedStorage
local WebhookLib = require(game.ReplicatedStorage.WebhookLib)

-- Initialize webhook with message tracking
local webhook = WebhookLib.new("https://webhook.lewisakura.moe/api/webhooks/YOUR_ID/YOUR_TOKEN", {
    username = "🎮 Test Bot",
    debug = false,
    track_message_ids = true -- Enable message ID tracking
})

-- Send your first message
webhook:SendMessage("🎮 Hello from Roblox!")
```

### Test Result
<div align="center">
  <img src="https://github.com/Bluezly/iconforgrowstock/blob/main/image.png?raw=true" alt="WebhookLib Test Result" width="600">
  <p><i>Example of WebhookLib embed output in Discord</i></p>
</div>

---

## 📦 Installation

### Method 1: Roblox Model (Recommended)
1. Get the model: [WebhookLib on Roblox](https://create.roblox.com/store/asset/101200026339651/WebhookLib)
2. Insert into **ReplicatedStorage**
3. Rename to `WebhookLib`

### Method 2: Manual Installation
1. Create a ModuleScript in ReplicatedStorage named `WebhookLib`
2. Copy the [source code](https://github.com/WebhookLib/WebhookLib/blob/main/WebhookLib.lua)
3. Paste into the ModuleScript

### Game Settings Configuration
**⚠️ CRITICAL:** Enable HTTP Requests in your game settings:
1. Go to **Game Settings** → **Security**
2. Enable **"Allow HTTP Requests"**
3. Save changes

---

## 🛠️ Configuration

WebhookLib offers extensive configuration options for production environments:

```lua
local webhook = WebhookLib.new("YOUR_WEBHOOK_URL", {
    -- Basic Settings
    username = "🤖 Game Bot",
    avatar_url = "https://example.com/bot-avatar.png",
    default_color = 0x0099ff, -- Hex color for embeds
    
    -- Performance & Reliability
    queue_enabled = true,        -- Enable request queueing
    queue_rate_limit = 2,        -- Requests per second
    max_retries = 5,             -- Retry failed requests
    retry_backoff_base = 1,      -- Base retry delay (seconds)
    
    -- Content & Caching
    filter_profanity = true,     -- Enable content filtering
    cache_ttl_avatar = 600,      -- Avatar cache TTL (10 minutes)
    
    -- Message Management
    track_message_ids = true,    -- Enable message ID tracking
    max_stored_messages = 100,   -- Maximum stored message IDs
    
    -- Data & Debugging
    datastore_name = "GameWebhooks", -- Custom DataStore name
    debug = false,               -- Production: false, Development: true
    
    -- Custom banned words (adds to defaults)
    banned_words = {"spam", "toxic", "annoying"}
})
```

### Configuration Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `username` | string | "Roblox Game" | Default webhook username |
| `avatar_url` | string | Default Roblox avatar | Default webhook avatar |
| `default_color` | number | 0x00ff00 | Default embed color (hex) |
| `queue_enabled` | boolean | false | Enable request queueing |
| `queue_rate_limit` | number | nil | Requests per second limit |
| `max_retries` | number | 3 | Maximum retry attempts |
| `filter_profanity` | boolean | false | Enable content filtering |
| `debug` | boolean | false | Enable debug logging |
| `cache_ttl_avatar` | number | 300 | Avatar cache TTL (seconds) |
| `datastore_name` | string | "WebhookLib_JoinCounts" | DataStore name |
| `track_message_ids` | boolean | false | Enable message ID tracking |
| `max_stored_messages` | number | 100 | Maximum stored message IDs |

---

## 📚 Usage Examples

### 🎯 Simple Text Messages
```lua
local WebhookLib = require(game.ReplicatedStorage.WebhookLib)
local webhook = WebhookLib.new("YOUR_WEBHOOK_URL")

-- Basic message
webhook:SendMessage("🎮 Server started successfully!")

-- Message with custom settings
webhook:SendMessage("📢 Special announcement!", {
    username = "📢 Admin",
    avatar_url = "https://example.com/admin-avatar.png"
})
```

### 🎨 Rich Embeds
```lua
-- Create rich embed
local embed = {
    title = "🏆 Game Statistics",
    description = "Current server performance metrics",
    color = 0x0099ff, -- Blue
    fields = {
        {name = "👥 Players Online", value = tostring(#game.Players:GetPlayers()), inline = true},
        {name = "⏰ Server Uptime", value = "2 hours 15 minutes", inline = true},
        {name = "🌍 Region", value = "US-East", inline = true}
    },
    thumbnail = {
        url = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
    },
    footer = {text = "Automated Report"},
    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
}

webhook:SendEmbed(embed)
```

### 👥 Player Join/Leave Notifications
```lua
-- Automatic player notifications with avatars and join counts
game.Players.PlayerAdded:Connect(function(player)
    pcall(function() -- Always wrap in pcall for production
        webhook:SendJoinMessage(player)
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        webhook:SendLeaveMessage(player)
    end)
end)
```

### 🔄 Multiple Embeds
```lua
local embeds = {
    {
        title = "📈 Player Stats",
        color = 0x00ff00,
        fields = {{name = "Active Players", value = "25", inline = true}}
    },
    {
        title = "⚠️ Server Health", 
        color = 0xffaa00,
        fields = {{name = "Memory Usage", value = "78%", inline = true}}
    },
    {
        title = "🎯 Recent Events",
        color = 0xff0000,
        fields = {{name = "Last Restart", value = "2 hours ago", inline = true}}
    }
}

webhook:SendMultipleEmbeds(embeds)
```

---

## 🧵 Thread Support

WebhookLib supports sending messages directly to Discord threads:

### Basic Thread Usage
```lua
local THREAD_ID = "123456789012345678" -- Your Discord thread ID

-- Send message to thread
webhook:SendMessageInThread("Hello from thread!", THREAD_ID)

-- Send embed to thread
webhook:SendEmbedInThread({
    title = "Thread Message",
    description = "This is sent to a specific thread",
    color = 0x00ff00
}, THREAD_ID)

-- Alternative syntax using optional threadId parameter
webhook:SendMessage("Hello thread!", nil, THREAD_ID)
webhook:SendEmbed({title = "Embed in Thread"}, THREAD_ID)
```

### Player Events in Threads
```lua
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
```

### Custom Events in Threads
```lua
local EVENT_THREAD = "987654321098765432"

webhook:SendCustomEvent("🎯 Player Achievement", {
    ["Player"] = "john_doe",
    ["Achievement"] = "First Victory!",
    ["Score"] = "9,999",
    ["Time"] = os.date("%c")
}, EVENT_THREAD)
```

---

## ✏️ Message Management

WebhookLib provides powerful message editing and deletion capabilities:

### Message ID Tracking Setup
```lua
local webhook = WebhookLib.new("YOUR_WEBHOOK_URL", {
    track_message_ids = true,    -- Enable message ID tracking
    max_stored_messages = 50,    -- Store up to 50 message IDs
    debug = true
})
```

### Editing Messages
```lua
-- Send a message
webhook:SendMessage("Original message")

-- Wait for message to be sent and tracked
task.wait(2)

-- Get the latest message ID
local messageId = webhook:GetLatestMessageId()
if messageId then
    -- Edit with new content
    webhook:EditMessage(messageId, "Edited message content!")
    
    -- Edit with new embed
    webhook:EditMessage(messageId, nil, {
        title = "Updated Embed",
        description = "This embed replaces the original message",
        color = 0xff0000
    })
    
    -- Edit with both content and embed
    webhook:EditMessage(messageId, "Updated message", {
        title = "Also Updated Embed",
        color = 0x0099ff
    })
end
```

### Deleting Messages
```lua
-- Delete using tracked message ID
local messageId = webhook:GetLatestMessageId()
if messageId then
    webhook:DeleteMessage(messageId)
end

-- Delete using known message ID
local knownMessageId = "987654321098765432"
webhook:DeleteMessage(knownMessageId)
```

### Managing Stored Messages
```lua
-- Get all stored messages
local storedMessages = webhook:GetStoredMessages()
for _, msg in ipairs(storedMessages) do
    print("Message ID:", msg.id)
    print("Type:", msg.metadata.type)
    print("Timestamp:", msg.timestamp)
end

-- Get the latest message ID
local latestId = webhook:GetLatestMessageId()
print("Latest message ID:", latestId)

-- Clear stored messages
webhook:ClearStoredMessages()

-- Check if message tracking is enabled
print("Message tracking:", webhook:IsMessageTrackingEnabled())
```

### Batch Operations
```lua
-- Batch edit multiple messages
local function batchEditMessages(webhook, messageIds, newContent)
    for i, messageId in ipairs(messageIds) do
        webhook:EditMessage(messageId, newContent .. " (Message " .. i .. ")")
        task.wait(0.5) -- Small delay between operations
    end
end

-- Batch delete multiple messages
local function batchDeleteMessages(webhook, messageIds)
    for _, messageId in ipairs(messageIds) do
        webhook:DeleteMessage(messageId)
        task.wait(0.5) -- Small delay between operations
    end
end
```

---

## 🎯 Advanced Features

### 🚀 Production Setup with Message Management
```lua
local function initializeWebhook()
    local success, webhook = pcall(function()
        return WebhookLib.new("YOUR_WEBHOOK_URL", {
            username = "🎮 Production Server",
            debug = false,                -- Disable debug for production
            filter_profanity = true,      -- Enable content filtering
            queue_enabled = true,         -- Enable queueing
            queue_rate_limit = 1,         -- 1 request per second
            max_retries = 5,              -- More retries for reliability
            cache_ttl_avatar = 900,       -- 15-minute cache
            track_message_ids = true,     -- Enable message management
            max_stored_messages = 100     -- Store up to 100 message IDs
        })
    end)
    
    if success then
        print("✅ WebhookLib initialized successfully")
        return webhook
    else
        warn("❌ Failed to initialize WebhookLib:", webhook)
        return nil
    end
end

local webhook = initializeWebhook()

-- Graceful shutdown handling
game:BindToClose(function()
    if webhook then
        print("🔄 Shutting down webhook...")
        
        -- Send shutdown message
        pcall(function()
            webhook:SendMessage("🔄 Server shutting down...")
        end)
        
        webhook:Shutdown()
        wait(3) -- Allow time for pending messages
        print("✅ Webhook shutdown complete")
    end
end)
```

### ⚡ High-Traffic Server Configuration
```lua
-- Optimized for servers with many players
local webhook = WebhookLib.new("YOUR_WEBHOOK_URL", {
    username = "🏢 High-Traffic Server",
    queue_enabled = true,
    queue_rate_limit = 5,         -- Higher rate limit
    cache_ttl_avatar = 1800,      -- 30-minute cache
    max_retries = 3,              -- Fewer retries for speed
    filter_profanity = true,
    debug = false,                -- Always false in production
    track_message_ids = false     -- Disable for performance if not needed
})

-- Batch notifications to reduce spam
local recentJoins = {}

game.Players.PlayerAdded:Connect(function(player)
    table.insert(recentJoins, player.Name)
    
    -- Send batch notification every 5 players or 30 seconds
    if #recentJoins >= 5 then
        local joinList = table.concat(recentJoins, ", ")
        webhook:SendMessage("👥 **" .. #recentJoins .. " players joined:** " .. joinList)
        recentJoins = {}
    end
end)
```

### 🔧 Runtime Configuration
```lua
-- Modify settings during runtime
webhook:SetDefaultUsername("🤖 Updated Bot Name")
webhook:SetDefaultColor(0xff6600)         -- Orange
webhook:EnableDebug(true)                 -- Enable debugging
webhook:EnableQueue(true, 3)              -- Enable queue with 3 req/sec
webhook:EnableMessageTracking(true)       -- Enable message tracking

-- Check current status
print("Queue enabled:", webhook:IsQueueEnabled())
print("Message tracking:", webhook:IsMessageTrackingEnabled())
print("Pending requests:", webhook:GetQueueSize())

-- Get current configuration
local config = webhook:GetConfiguration()
print("Current username:", config.username)
print("Debug mode:", config.debug)
print("Track messages:", config.track_message_ids)
```

---

## ⚙️ API Reference

### Constructor

#### `WebhookLib.new(url, options?)`
Creates a new WebhookLib instance.

**Parameters:**
- `url` (string): Discord webhook URL (required)
- `options` (table): Configuration options (optional)

**Returns:** WebhookLib instance

---

### Core Methods

#### `webhook:SendMessage(content, overrides?, threadId?)`
Send a plain text message.

**Parameters:**
- `content` (string): Message content (required)
- `overrides` (table): Temporary username/avatar overrides (optional)
- `threadId` (string): Discord thread ID (optional)

**Returns:** boolean - Success status

#### `webhook:SendMessageInThread(content, threadId, overrides?)`
Send a message to a specific Discord thread.

**Parameters:**
- `content` (string): Message content (required)
- `threadId` (string): Discord thread ID (required)
- `overrides` (table): Temporary username/avatar overrides (optional)

**Returns:** boolean - Success status

#### `webhook:SendEmbed(embedTable, threadId?)`
Send a single rich embed.

**Parameters:**
- `embedTable` (table): Discord embed object (required)
- `threadId` (string): Discord thread ID (optional)

**Returns:** boolean - Success status

#### `webhook:SendEmbedInThread(embedTable, threadId)`
Send an embed to a specific Discord thread.

**Parameters:**
- `embedTable` (table): Discord embed object (required)
- `threadId` (string): Discord thread ID (required)

**Returns:** boolean - Success status

#### `webhook:SendMultipleEmbeds(embeds, threadId?)`
Send multiple embeds in one message.

**Parameters:**
- `embeds` (array): Array of embed objects (required, max 10)
- `threadId` (string): Discord thread ID (optional)

**Returns:** boolean - Success status

---

### Message Management Methods

#### `webhook:EditMessage(messageId, content?, embeds?)`
Edit an existing webhook message.

**Parameters:**
- `messageId` (string): Discord message ID (required)
- `content` (string): New message content (optional)
- `embeds` (table/array): New embed(s) (optional)

**Returns:** boolean - Success status

#### `webhook:DeleteMessage(messageId)`
Delete an existing webhook message.

**Parameters:**
- `messageId` (string): Discord message ID (required)

**Returns:** boolean - Success status

#### `webhook:GetStoredMessages()`
Get all stored message IDs with metadata.

**Returns:** array - Array of message objects

#### `webhook:GetLatestMessageId()`
Get the most recently sent message ID.

**Returns:** string/nil - Latest message ID or nil

#### `webhook:ClearStoredMessages()`
Clear all stored message IDs.

**Returns:** void

---

### Player Methods

#### `webhook:SendJoinMessage(player, threadId?)`
Send automatic join notification with avatar and join count.

**Parameters:**
- `player` (Player): Roblox Player instance (required)
- `threadId` (string): Discord thread ID (optional)

**Returns:** boolean - Success status

#### `webhook:SendLeaveMessage(player, threadId?)`
Send automatic leave notification.

**Parameters:**
- `player` (Player): Roblox Player instance (required)
- `threadId` (string): Discord thread ID (optional)

**Returns:** boolean - Success status

---

### Utility Methods

#### `webhook:SendCustomEvent(name, data?, threadId?)`
Log custom events with structured data.

**Parameters:**
- `name` (string): Event name (required)
- `data` (table): Event data fields (optional)
- `threadId` (string): Discord thread ID (optional)

**Returns:** boolean - Success status

#### `webhook:SetWebhookUrl(url)`
Update webhook URL at runtime.

#### `webhook:SetDefaultUsername(username)`
Update default username.

#### `webhook:EnableDebug(enabled)`
Toggle debug logging.

#### `webhook:EnableQueue(enabled, rateLimit?)`
Toggle request queueing.

#### `webhook:EnableMessageTracking(enabled)`
Toggle message ID tracking.

#### `webhook:GetQueueSize()`
Get number of pending requests.

#### `webhook:IsQueueEnabled()`
Check if queueing is enabled.

#### `webhook:IsMessageTrackingEnabled()`
Check if message tracking is enabled.

#### `webhook:Shutdown()`
Graceful shutdown with pending request completion.

---

## 🔧 Troubleshooting

### Common Issues

#### "HTTP requests are not enabled for this game"
**Solution:**
1. Go to Game Settings → Security
2. Enable "Allow HTTP Requests"
3. Save and republish your game

#### "Webhook URL is invalid or expired"
**Solution:**
1. Verify your Discord webhook URL is correct
2. Use the proxy URL format: `https://webhook.lewisakura.moe/api/webhooks/ID/TOKEN`
3. Ensure the webhook hasn't been deleted in Discord

#### Messages not appearing in Discord
**Solution:**
1. Check your webhook URL is correct
2. Enable debug mode: `debug = true`
3. Check the Developer Console for error messages
4. Verify the Discord channel permissions

#### Message editing/deletion not working
**Solution:**
1. Ensure `track_message_ids = true` is enabled
2. Wait a moment after sending before editing/deleting
3. Verify the message ID is correct
4. Check that the webhook has permission to manage messages

#### Thread messages not appearing
**Solution:**
1. Verify the thread ID is correct
2. Ensure the webhook has permission to send messages in the thread
3. Check that the thread is not archived or locked

#### Rate limiting issues
**Solution:**
```lua
-- Enable queue with rate limiting
local webhook = WebhookLib.new("YOUR_URL", {
    queue_enabled = true,
    queue_rate_limit = 1  -- 1 request per second
})
```

### Debug Mode

Enable comprehensive logging for troubleshooting:

```lua
local webhook = WebhookLib.new("YOUR_URL", {
    debug = true,  -- Enable detailed logging
    track_message_ids = true  -- Enable message tracking for debugging
})

-- Check logs in Developer Console
```

### Performance Tips

1. **Use queueing for high-traffic servers**
2. **Set appropriate cache TTL values**
3. **Disable debug mode in production**
4. **Use pcall() for error handling**
5. **Implement graceful shutdown**
6. **Disable message tracking if not needed for better performance**
7. **Use batch operations for multiple message edits/deletions**

---

## 🤝 Contributing

We welcome contributions to WebhookLib! Here's how you can help:

### Ways to Contribute
- 🐛 **Report bugs** via [Issues](https://github.com/WebhookLib/WebhookLib/issues)
- 💡 **Suggest features** in [Discussions](https://github.com/WebhookLib/WebhookLib/discussions)
- 📖 **Improve documentation**
- 🧪 **Submit test cases**
- 🔧 **Fix bugs and add features**

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in Roblox Studio
5. Submit a pull request

### Coding Standards
- Follow existing code style
- Add comprehensive comments
- Include error handling
- Test all features thoroughly
- Update documentation as needed

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 WebhookLib

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👨‍💻 Author

<div align="center">
  
  **Created with ❤️ by [Bluezly](https://github.com/Bluezly)**
  
  [![GitHub](https://img.shields.io/badge/GitHub-Bluezly-black?logo=github)](https://github.com/Bluezly)
  [![Website](https://img.shields.io/badge/Website-bluezly.exid.me-blue?logo=globe)](https://www.bluezly.exid.me/)
  [![Roblox](https://img.shields.io/badge/Roblox-Profile-00A2FF?logo=roblox)](https://www.roblox.com/users/192179263/profile)
  
  ---
  
  ### 🌟 Support the Project
  
  If WebhookLib has been helpful for your projects, consider:
  
  - ⭐ **Starring** the repository
  - 🔄 **Sharing** with other developers  
  - 🐛 **Reporting issues** you encounter
  - 💡 **Suggesting improvements**
  - 🤝 **Contributing** to the codebase
  
  ---
  
  ### 📞 Support & Community
  
  - 📖 **Documentation:** [webhooklib.luau.page](http://webhooklib.luau.page/)
  - 🛒 **Roblox Model:** [Get WebhookLib](https://create.roblox.com/store/asset/101200026339651/WebhookLib)
  - 🐛 **Issues:** [GitHub Issues](https://github.com/WebhookLib/WebhookLib/issues)
  - 💬 **Discussions:** [GitHub Discussions](https://github.com/WebhookLib/WebhookLib/discussions)
  - 🌐 **Creator Website:** [bluezly.exid.me](https://www.bluezly.exid.me/)
  - 🎮 **DevForum:** Coming Soon!
  
  **Made for the Roblox development community** 🎮
  
</div>

---

<div align="center">
  <sub>Built with Lua • Designed for Roblox • Powered by Discord Webhooks</sub>
</div>
