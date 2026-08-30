
local M = {}

local function place_and_play()

	local playlist = '37i9dQZEVXcQ6uI4eZ2X1i'

	-- should stop whatever is already plaing before
	hl.dispatch(hl.dsp.exec_cmd("playerctl -a pause"))
	hl.dispatch(hl.dsp.exec_cmd("sleep 1 && playerctl -p spotify open spotify:playlist:" .. playlist .. " & sleep 1 && playerctl -p spotify play"))
	hl.dispatch(hl.dsp.window.move({ monitor = '0', window = 'class:Spotify'}))
	hl.dispatch(hl.dsp.window.fullscreen({ window = 'class:Spotify' }))
end

function M.make_music()
	if #hl.get_windows({ class = "Spotify" }) > 0 then
		place_and_play()
		return
	end

	hl.dispatch(hl.dsp.exec_cmd("spotify-launcher &"))

	local attempts = 0
	local t
	t = hl.timer(function()
	  attempts = attempts + 1
	  if #hl.get_windows({ class = "Spotify" }) > 0 then
	      t:set_enabled(false)
	      place_and_play()
	  elseif attempts >= 20 then
	      t:set_enabled(false) -- give up after ~10s
	  end
	end, { timeout = 100, type = "repeat" })
end


return M
