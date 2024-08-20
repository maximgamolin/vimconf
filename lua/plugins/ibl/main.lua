-- Настройка цветных отступов
local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}

require("ibl").setup({indent = {highlight = highlight},whitespace = {highlight = {"RainbowRedSpace", "RainbowYellowSpace", "RainbowBlueSpace", "RainbowGreenSpace", "RainbowVioletSpace", "RainbowCyanSpace"}}})


