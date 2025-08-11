<div align="center">
  <img src="https://github.com/Bluezly/iconforgrowstock/blob/main/eec925e4-7dc7-4d71-873e-754f2150cc25.png?raw=true" alt="WebhookLib Logo" width="120" height="120">
  
  # WebhookLib
  
  ### 🚀 Production-Quality Discord Webhook Library for Roblox
  
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
  [![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/WebhookLib/WebhookLib/releases)
  [![Roblox Model](https://img.shields.io/badge/Roblox-Model-00A2FF.svg)](https://create.roblox.com/store/asset/101200026339651/WebhookLib)
  [![Website](https://img.shields.io/badge/Website-webhooklib.luau.page-purple.svg)](http://webhooklib.luau.page/)
  [![Stars](https://img.shields.io/github/stars/WebhookLib/WebhookLib.svg)](https://github.com/WebhookLib/WebhookLib/stargazers)
  [![Issues](https://img.shields.io/github/issues/WebhookLib/WebhookLib.svg)](https://github.com/WebhookLib/WebhookLib/issues)
  [![Downloads](https://img.shields.io/badge/downloads-1k+-brightgreen.svg)](https://create.roblox.com/store/asset/101200026339651/WebhookLib)
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

-- Initialize webhook
local webhook = WebhookLib.new("https://webhook.lewisakura.moe/api/webhooks/YOUR_ID/YOUR_TOKEN")

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

### 🎪 Custom Event Logging
```lua
-- Log custom game events with structured data
webhook:SendCustomEvent("🏆 Player Achievement", {
    ["Player"] = "john_doe",
    ["Achievement"] = "First Victory!",
    ["Score"] = "9,999",
    ["Difficulty"] = "Hard Mode",
    ["Time"] = os.date("%c")
})

-- Log errors or important events
webhook:SendCustomEvent("⚠️ Server Warning", {
    ["Type"] = "High Memory Usage",
    ["Value"] = "85%",
    ["Action"] = "Automatic cleanup initiated",
    ["Timestamp"] = os.date("%Y-%m-%d %H:%M:%S")
})
```

---

## 🎯 Advanced Features

### 🚀 Production Setup with Error Handling
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
            cache_ttl_avatar = 900        -- 15-minute cache
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
    debug = false                 -- Always false in production
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
webhook:SetDefaultColor(0xff6600)    -- Orange
webhook:EnableDebug(true)            -- Enable debugging
webhook:EnableQueue(true, 3)         -- Enable queue with 3 req/sec

-- Check current status
print("Queue enabled:", webhook:IsQueueEnabled())
print("Pending requests:", webhook:GetQueueSize())

-- Get current configuration
local config = webhook:GetConfiguration()
print("Current username:", config.username)
print("Debug mode:", config.debug)
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

#### `webhook:SendMessage(content, overrides?)`
Send a plain text message.

**Parameters:**
- `content` (string): Message content (required)
- `overrides` (table): Temporary username/avatar overrides (optional)

**Returns:** boolean - Success status

#### `webhook:SendEmbed(embedTable)`
Send a single rich embed.

**Parameters:**
- `embedTable` (table): Discord embed object (required)

**Returns:** boolean - Success status

#### `webhook:SendMultipleEmbeds(embeds)`
Send multiple embeds in one message.

**Parameters:**
- `embeds` (array): Array of embed objects (required, max 10)

**Returns:** boolean - Success status

---

### Player Methods

#### `webhook:SendJoinMessage(player)`
Send automatic join notification with avatar and join count.

**Parameters:**
- `player` (Player): Roblox Player instance (required)

**Returns:** boolean - Success status

#### `webhook:SendLeaveMessage(player)`
Send automatic leave notification.

**Parameters:**
- `player` (Player): Roblox Player instance (required)

**Returns:** boolean - Success status

---

### Utility Methods

#### `webhook:SendCustomEvent(name, data?)`
Log custom events with structured data.

**Parameters:**
- `name` (string): Event name (required)
- `data` (table): Event data fields (optional)

**Returns:** boolean - Success status

#### `webhook:SetWebhookUrl(url)`
Update webhook URL at runtime.

#### `webhook:SetDefaultUsername(username)`
Update default username.

#### `webhook:EnableDebug(enabled)`
Toggle debug logging.

#### `webhook:EnableQueue(enabled, rateLimit?)`
Toggle request queueing.

#### `webhook:GetQueueSize()`
Get number of pending requests.

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
    debug = true  -- Enable detailed logging
})

-- Check logs in Developer Console
```

### Performance Tips

1. **Use queueing for high-traffic servers**
2. **Set appropriate cache TTL values**
3. **Disable debug mode in production**
4. **Use pcall() for error handling**
5. **Implement graceful shutdown**

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
  [![Roblox](https://img.shields.io/badge/Roblox-Profile-00A2FF?logo=roblox)](https://www.roblox.com/users/YOUR_USER_ID/profile)
  
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
  - 🎮 **DevForum:** Coming Soon!
  
  **Made for the Roblox development community** 🎮
  
</div>

---

<div align="center">
  <sub>Built with Lua • Designed for Roblox • Powered by Discord Webhooks</sub>
</div>
