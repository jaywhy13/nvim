local options = {
  openweathermap = {
    app_id = {
      value = "d95b6adc9c138b53c94c1dee01cbffe3",
    },
  },
}

-- Adding the weather to the status line
-- I had to define my own formatter because the one in the docs
-- wasn't working.
local lualine_weather = require "weather.lualine"

local function celcius_formatter(data)
  return data.condition_icon .. "  " .. math.floor(data.temp.c) .. "°C"
end

-- Add some additions to the status line at the very end
vim.builtin.lualine.sections.lualine_z = {
  -- Weather
  lualine_weather.custom(celcius_formatter, { pending = "羽", error = "" }),
  -- Current time (we can add Lua expressions and lualine will evaluate them)
  "os.date('%H:%M')",
}

require("weather").setup(options)
