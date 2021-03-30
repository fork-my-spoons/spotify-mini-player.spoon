local obj = {}
obj.__index = obj

-- Metadata
obj.name = "spotify"
obj.version = "1.0"
obj.author = "Pavel Makhov"
obj.homepage = "https://github.com/fork-my-spoons/spotify.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.spotify_indicator = nil
obj.timer = nil
obj.iconPath = hs.spoons.resourcePath("icons")
obj.playIcon = nil
obj.pauseIcon = nil

local artist_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#1d8954'}})
local album_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#1d8954'}})
local track_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#1d8954'}})
local skip_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#1d8954'}})
local play_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#1d8954'}})
local pause_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#1d8954'}})

function refreshWidget()
    if (hs.spotify.isPlaying()) then
        obj.spotify_indicator:setIcon(obj.playIcon, false)
    else
        obj.spotify_indicator:setIcon(obj.pauseIcon, false)
    end
    if (hs.spotify.getCurrentArtist() ~= nil and hs.spotify.getCurrentTrack() ~= nil) then
        obj.spotify_indicator:setTitle(hs.spotify.getCurrentArtist() .. ' - ' .. hs.spotify.getCurrentTrack())
    end
end

function obj:next()
    hs.spotify.next()
    refreshWidget()
end

function obj:prev()
    hs.spotify.previous() 
    refreshWidget()
end

function obj:playpause()
    hs.spotify.playpause() 
    refreshWidget()
end

local function pos()
    return string.rep("a", math.floor(hs.spotify.getPosition() / hs.spotify.getDuration() * 40))
end

local function buildMenu()
    _, img, _ = hs.osascript.javascript("Application('Spotify').currentTrack().artworkUrl()")
    local i = hs.spotify.isPlaying() and play_icon or pause_icon 
    return {
        {
            image = hs.image.imageFromURL(img):setSize({w=128,h=128}),
            title = artist_icon .. hs.styledtext.new(hs.spotify.getCurrentArtist() .. '\n')
                .. album_icon .. hs.styledtext.new(hs.spotify.getCurrentTrack() .. '\n')
                .. track_icon .. hs.styledtext.new(hs.spotify.getCurrentAlbum()),
            fn = hs.spotify.playpause

        },
        { 
            disabled = true,
            title = i
            .. hs.styledtext.new(string.rep("•", math.floor(hs.spotify.getPosition() / hs.spotify.getDuration() * 40)), {color = {hex = '#ffff00'}}) .. 
            hs.styledtext.new(string.rep("•", 40 - math.floor(hs.spotify.getPosition() / hs.spotify.getDuration() * 40)))
        },
        {
            title = "-"
        },
        { 
            title = "Next", 
            image = hs.image.imageFromPath(obj.iconPath .. '/skip-forward.png'):setSize({w=16,h=16}):template(true),
            fn = hs.spotify.next
        },
        { 
            title = "Previous", 
            image = hs.image.imageFromPath(obj.iconPath .. '/skip-back.png'):setSize({w=16,h=16}):template(true),
            fn =  hs.spotify.previous
        }
    }
end

function obj:init(par)
    self.spotify_indicator = hs.menubar.new()
    self.playIcon = hs.image.imageFromPath(obj.iconPath .. '/Spotify_Icon_RGB_Green.png'):setSize({w=16,h=16})
    self.pauseIcon = hs.image.imageFromPath(obj.iconPath .. '/Spotify_Icon_RGB_White.png'):setSize({w=16,h=16})

    self.spotify_indicator:setMenu(buildMenu)
    self.timer = hs.timer.new(1, refreshWidget)
end

function obj:bindHotkeys(mapping)
    local spec = {
        next = hs.fnutils.partial(self.next, self),
        prev = hs.fnutils.partial(self.prev, self),
        playpause = hs.fnutils.partial(self.playpause, self),
      }
      hs.spoons.bindHotkeysToSpec(spec, mapping)
      return self
end

function obj:start()
    self.timer:start()
end

function obj:stop()
    self.timer:stop()
end

return obj