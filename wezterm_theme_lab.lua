local M = {}

local HOME = os.getenv("HOME")
local STATE_PATH = HOME .. "/.config/wezterm/terminalcolor_state.lua"

local THEMES = {
  velvet_night = {
    name = "Velvet Night",
    tag = "plum / gold",
    accent = "#f56b8a",
    accent_soft = "#d99cff",
    background = "#120d1d",
    surface = "#1a1330",
    panel = "#241a40",
    text = "#f7f2ff",
    muted = "#aa9fbe",
    success = "#64d6a4",
    warning = "#ffbf69",
    danger = "#ff6d6d",
  },
  forest_reactor = {
    name = "Forest Reactor",
    tag = "green / glass",
    accent = "#68f59a",
    accent_soft = "#b2ff66",
    background = "#07120d",
    surface = "#0d1d16",
    panel = "#143126",
    text = "#ebfff5",
    muted = "#8db9a3",
    success = "#66f2b1",
    warning = "#f1d36b",
    danger = "#ff7d7d",
  },
  arctic_signal = {
    name = "Arctic Signal",
    tag = "cyan / steel",
    accent = "#61dafb",
    accent_soft = "#8ef6e4",
    background = "#08131b",
    surface = "#10202c",
    panel = "#183041",
    text = "#edf8ff",
    muted = "#9db7c7",
    success = "#6ce5b1",
    warning = "#f8c555",
    danger = "#ff7676",
  },
  amber_ledger = {
    name = "Amber Ledger",
    tag = "amber / brass",
    accent = "#ffb454",
    accent_soft = "#ffd36f",
    background = "#151009",
    surface = "#23190f",
    panel = "#342414",
    text = "#fff7ea",
    muted = "#c3a98a",
    success = "#7be0ad",
    warning = "#ffd26e",
    danger = "#ff7a62",
  },
  sakura_circuit = {
    name = "Sakura Circuit",
    tag = "rose / slate",
    accent = "#ff7eb6",
    accent_soft = "#d7a7ff",
    background = "#170f18",
    surface = "#241627",
    panel = "#35213a",
    text = "#fff0f8",
    muted = "#c4a5b8",
    success = "#72e2b8",
    warning = "#ffc56f",
    danger = "#ff7b84",
  },
  graphite_ocean = {
    name = "Graphite Ocean",
    tag = "blue / ink",
    accent = "#70a5ff",
    accent_soft = "#4ce0d2",
    background = "#09121d",
    surface = "#101b2b",
    panel = "#1a2d43",
    text = "#eef4ff",
    muted = "#9fb0c8",
    success = "#68ddb0",
    warning = "#f4c25b",
    danger = "#ff7b7b",
  },
  ember_dusk = {
    name = "Ember Dusk",
    tag = "orange / ember",
    accent = "#ff8c42",
    accent_soft = "#ffcf70",
    background = "#160d0a",
    surface = "#241511",
    panel = "#362019",
    text = "#fff4ef",
    muted = "#c8a89a",
    success = "#7dd9b6",
    warning = "#ffd37a",
    danger = "#ff7a66",
  },
  aurora_mint = {
    name = "Aurora Mint",
    tag = "mint / aqua",
    accent = "#5eead4",
    accent_soft = "#7dd3fc",
    background = "#061514",
    surface = "#0c211f",
    panel = "#133330",
    text = "#eafffb",
    muted = "#8dbeb8",
    success = "#5df2b5",
    warning = "#f8d66d",
    danger = "#ff7d91",
  },
  monsoon_ink = {
    name = "Monsoon Ink",
    tag = "storm / violet",
    accent = "#8f7dff",
    accent_soft = "#58c4ff",
    background = "#0c1020",
    surface = "#151a2e",
    panel = "#202743",
    text = "#edf1ff",
    muted = "#98a4c8",
    success = "#67ddb2",
    warning = "#f3c46c",
    danger = "#ff8080",
  },
  desert_neon = {
    name = "Desert Neon",
    tag = "sand / neon",
    accent = "#ffd166",
    accent_soft = "#59f8e8",
    background = "#121109",
    surface = "#1d1a10",
    panel = "#2d2818",
    text = "#fffbea",
    muted = "#c8bd97",
    success = "#7be1a6",
    warning = "#ffd166",
    danger = "#ff7f68",
  },
}

local THEME_ORDER = {
  "velvet_night",
  "forest_reactor",
  "arctic_signal",
  "amber_ledger",
  "sakura_circuit",
  "graphite_ocean",
  "ember_dusk",
  "aurora_mint",
  "monsoon_ink",
  "desert_neon",
}

local OPACITY_PRESETS = { 1.00, 0.96, 0.92, 0.88, 0.84, 0.78 }
local BLUR_PRESETS = { 0, 8, 14, 18, 24 }
local FONT_PRESETS = { 12.0, 13.0, 14.0, 15.0, 16.0 }
local PADDING_PRESETS = {
  snug = { left = 4, right = 4, top = 2, bottom = 2 },
  comfy = { left = 8, right = 8, top = 5, bottom = 5 },
  airy = { left = 14, right = 14, top = 8, bottom = 8 },
}
local PADDING_ORDER = { "snug", "comfy", "airy" }
local TAB_MODES = {
  fancy = {
    name = "Fancy Tabs",
    use_fancy_tab_bar = true,
    show_tabs_in_tab_bar = true,
    show_new_tab_button_in_tab_bar = true,
  },
  retro = {
    name = "Retro Tabs",
    use_fancy_tab_bar = false,
    show_tabs_in_tab_bar = true,
    show_new_tab_button_in_tab_bar = false,
  },
  minimal = {
    name = "Minimal Bar",
    use_fancy_tab_bar = false,
    show_tabs_in_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,
  },
}
local TAB_ORDER = { "fancy", "retro", "minimal" }

local DEFAULT_STATE = {
  theme = "graphite_ocean",
  opacity = 0.92,
  blur = 18,
  font_size = 13.0,
  padding = "comfy",
  tab_mode = "fancy",
  right_status = true,
}

local function shallow_copy(tbl)
  local copy = {}
  for key, value in pairs(tbl) do
    copy[key] = value
  end
  return copy
end

local function index_of(values, current)
  for i, value in ipairs(values) do
    if value == current then
      return i
    end
  end
  return 1
end

local function cycle(values, current, step)
  local index = index_of(values, current)
  local next_index = ((index - 1 + step) % #values) + 1
  return values[next_index]
end

local function normalize_state(raw)
  local state = shallow_copy(DEFAULT_STATE)
  if type(raw) ~= "table" then
    return state
  end

  for key, value in pairs(raw) do
    state[key] = value
  end

  if THEMES[state.theme] == nil then
    state.theme = DEFAULT_STATE.theme
  end
  if PADDING_PRESETS[state.padding] == nil then
    state.padding = DEFAULT_STATE.padding
  end
  if TAB_MODES[state.tab_mode] == nil then
    state.tab_mode = DEFAULT_STATE.tab_mode
  end
  if type(state.right_status) ~= "boolean" then
    state.right_status = DEFAULT_STATE.right_status
  end

  return state
end

local function read_state()
  local ok, result = pcall(dofile, STATE_PATH)
  if ok then
    return normalize_state(result)
  end
  return shallow_copy(DEFAULT_STATE)
end

local function write_state(state)
  local file = assert(io.open(STATE_PATH, "w"))
  local lines = {
    "return {",
    string.format('  theme = "%s",', state.theme),
    string.format("  opacity = %.2f,", state.opacity),
    string.format("  blur = %d,", state.blur),
    string.format("  font_size = %.1f,", state.font_size),
    string.format('  padding = "%s",', state.padding),
    string.format('  tab_mode = "%s",', state.tab_mode),
    string.format("  right_status = %s,", tostring(state.right_status)),
    "}",
    "",
  }
  file:write(table.concat(lines, "\n"))
  file:close()
end

local function build_colors(theme)
  return {
    foreground = theme.text,
    background = theme.background,
    cursor_bg = theme.accent,
    cursor_border = theme.accent,
    cursor_fg = theme.background,
    selection_bg = theme.panel,
    selection_fg = theme.text,
    split = theme.accent_soft,
    scrollbar_thumb = theme.accent_soft,
    compose_cursor = theme.warning,
    ansi = {
      theme.surface,
      theme.danger,
      theme.success,
      theme.warning,
      theme.accent,
      theme.accent_soft,
      theme.muted,
      theme.text,
    },
    brights = {
      theme.panel,
      theme.danger,
      theme.success,
      theme.warning,
      theme.accent,
      theme.accent_soft,
      theme.text,
      "#ffffff",
    },
    indexed = {
      [16] = theme.warning,
      [17] = theme.danger,
    },
    tab_bar = {
      background = theme.surface,
      active_tab = {
        bg_color = theme.panel,
        fg_color = theme.text,
        intensity = "Bold",
      },
      inactive_tab = {
        bg_color = theme.surface,
        fg_color = theme.muted,
      },
      inactive_tab_hover = {
        bg_color = theme.panel,
        fg_color = theme.text,
      },
      new_tab = {
        bg_color = theme.surface,
        fg_color = theme.accent_soft,
      },
      new_tab_hover = {
        bg_color = theme.panel,
        fg_color = theme.text,
      },
    },
  }
end

local function build_window_frame(wezterm, theme)
  return {
    active_titlebar_bg = theme.background,
    active_titlebar_fg = theme.text,
    inactive_titlebar_bg = theme.surface,
    inactive_titlebar_fg = theme.muted,
    active_titlebar_border_bottom = theme.panel,
    inactive_titlebar_border_bottom = theme.panel,
    button_fg = theme.text,
    button_bg = theme.surface,
    button_hover_fg = theme.background,
    button_hover_bg = theme.accent,
    font = wezterm.font("JetBrains Mono"),
    font_size = 12,
  }
end

local function build_overrides(wezterm, state)
  local theme = THEMES[state.theme]
  local tab_mode = TAB_MODES[state.tab_mode]
  return {
    colors = build_colors(theme),
    font_size = state.font_size,
    window_background_opacity = state.opacity,
    text_background_opacity = 1.0,
    macos_window_background_blur = state.blur,
    window_padding = shallow_copy(PADDING_PRESETS[state.padding]),
    use_fancy_tab_bar = tab_mode.use_fancy_tab_bar,
    show_tabs_in_tab_bar = tab_mode.show_tabs_in_tab_bar,
    show_new_tab_button_in_tab_bar = tab_mode.show_new_tab_button_in_tab_bar,
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = false,
    window_frame = build_window_frame(wezterm, theme),
  }
end

local function toast(window, message)
  if window and window.toast_notification then
    window:toast_notification("WezTerm Theme Lab", message, nil, 3000)
  end
end

local function save_and_apply(wezterm, window, state, message)
  write_state(state)
  wezterm.reload_configuration()
  toast(window, message)
end

local function theme_choices()
  local choices = {}
  for _, theme_id in ipairs(THEME_ORDER) do
    local theme = THEMES[theme_id]
    table.insert(choices, {
      id = theme_id,
      label = string.format("%s  |  %s", theme.name, theme.tag),
    })
  end
  return choices
end

local function simple_choices(values, suffix)
  local choices = {}
  for _, value in ipairs(values) do
    table.insert(choices, {
      id = tostring(value),
      label = string.format("%s%s", tostring(value), suffix),
    })
  end
  return choices
end

local function named_choices(values, mapping)
  local choices = {}
  for _, value in ipairs(values) do
    local entry = mapping[value]
    local label = entry
    if type(entry) == "table" then
      label = entry.name
    end
    table.insert(choices, {
      id = value,
      label = string.format("%s  |  %s", value, label),
    })
  end
  return choices
end

local function trim_title(title, max_width)
  local limit = math.max(8, max_width - 4)
  if #title <= limit then
    return title
  end
  return title:sub(1, limit - 1) .. "…"
end

local function register_events(wezterm)
  local act = wezterm.action

  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local colors = config.colors and config.colors.tab_bar or {}
    local active = colors.active_tab or { bg_color = "#1a2d43", fg_color = "#eef4ff" }
    local inactive = colors.inactive_tab or { bg_color = "#101b2b", fg_color = "#9fb0c8" }
    local hovered = colors.inactive_tab_hover or inactive

    local palette = inactive
    if tab.is_active then
      palette = active
    elseif hover then
      palette = hovered
    end

    local title = trim_title(tab.active_pane.title or "shell", max_width)
    return {
      { Background = { Color = palette.bg_color } },
      { Foreground = { Color = palette.fg_color } },
      { Text = string.format(" %d %s ", tab.tab_index + 1, title) },
    }
  end)

  wezterm.on("update-right-status", function(window, pane)
    local state = read_state()
    if not state.right_status then
      window:set_right_status("")
      return
    end

    local theme = THEMES[state.theme]
    local workspace = window:active_workspace()
    local clock = wezterm.strftime("%H:%M")

    window:set_right_status(wezterm.format({
      { Background = { Color = theme.surface } },
      { Foreground = { Color = theme.accent } },
      { Text = " " .. theme.name .. " " },
      { Background = { Color = theme.panel } },
      { Foreground = { Color = theme.text } },
      { Text = string.format("  %.2f alpha  ", state.opacity) },
      { Foreground = { Color = theme.accent_soft } },
      { Text = string.format("%0.1f pt  ", state.font_size) },
      { Foreground = { Color = theme.muted } },
      { Text = workspace .. "  " .. clock .. " " },
    }))
  end)

  return {
    theme_picker = act.InputSelector({
      title = "Pick WezTerm theme",
      choices = theme_choices(),
      fuzzy = true,
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id then
          return
        end
        local state = read_state()
        state.theme = id
        save_and_apply(wezterm, window, state, "Theme saved: " .. THEMES[id].name)
      end),
    }),
    opacity_picker = act.InputSelector({
      title = "Pick opacity",
      choices = simple_choices(OPACITY_PRESETS, ""),
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id then
          return
        end
        local state = read_state()
        state.opacity = tonumber(id)
        save_and_apply(wezterm, window, state, "Opacity saved: " .. id)
      end),
    }),
    blur_picker = act.InputSelector({
      title = "Pick blur",
      choices = simple_choices(BLUR_PRESETS, ""),
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id then
          return
        end
        local state = read_state()
        state.blur = tonumber(id)
        save_and_apply(wezterm, window, state, "Blur saved: " .. id)
      end),
    }),
    font_picker = act.InputSelector({
      title = "Pick font size",
      choices = simple_choices(FONT_PRESETS, " pt"),
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id then
          return
        end
        local state = read_state()
        state.font_size = tonumber(id)
        save_and_apply(wezterm, window, state, "Font size saved: " .. id .. " pt")
      end),
    }),
    tab_picker = act.InputSelector({
      title = "Pick tab bar mode",
      choices = named_choices(TAB_ORDER, TAB_MODES),
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id then
          return
        end
        local state = read_state()
        state.tab_mode = id
        save_and_apply(wezterm, window, state, "Tab bar mode: " .. TAB_MODES[id].name)
      end),
    }),
    padding_picker = act.InputSelector({
      title = "Pick padding",
      choices = named_choices(PADDING_ORDER, {
        snug = "tight frame",
        comfy = "default spacing",
        airy = "wide frame",
      }),
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id then
          return
        end
        local state = read_state()
        state.padding = id
        save_and_apply(wezterm, window, state, "Padding preset: " .. id)
      end),
    }),
    next_theme = wezterm.action_callback(function(window, pane)
      local state = read_state()
      state.theme = cycle(THEME_ORDER, state.theme, 1)
      save_and_apply(wezterm, window, state, "Theme saved: " .. THEMES[state.theme].name)
    end),
    prev_theme = wezterm.action_callback(function(window, pane)
      local state = read_state()
      state.theme = cycle(THEME_ORDER, state.theme, -1)
      save_and_apply(wezterm, window, state, "Theme saved: " .. THEMES[state.theme].name)
    end),
    toggle_status = wezterm.action_callback(function(window, pane)
      local state = read_state()
      state.right_status = not state.right_status
      save_and_apply(wezterm, window, state, "Right status " .. (state.right_status and "enabled" or "disabled"))
    end),
  }
end

function M.build(wezterm)
  local state = read_state()
  local overrides = build_overrides(wezterm, state)
  local helpers = register_events(wezterm)
  local act = wezterm.action

  return {
    automatically_reload_config = true,
    font = wezterm.font_with_fallback({
      "JetBrains Mono",
      "Hiragino Sans GB",
      "Songti SC",
      "STHeiti",
      "PingFang SC",
      "Symbols Nerd Font Mono",
      "Menlo",
    }),
    font_size = overrides.font_size,
    colors = overrides.colors,
    window_background_opacity = overrides.window_background_opacity,
    text_background_opacity = overrides.text_background_opacity,
    macos_window_background_blur = overrides.macos_window_background_blur,
    window_decorations = "RESIZE",
    window_padding = overrides.window_padding,
    window_frame = overrides.window_frame,
    default_cursor_style = "BlinkingBar",
    cursor_blink_rate = 600,
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = overrides.use_fancy_tab_bar,
    show_tabs_in_tab_bar = overrides.show_tabs_in_tab_bar,
    show_new_tab_button_in_tab_bar = overrides.show_new_tab_button_in_tab_bar,
    status_update_interval = 1000,
    scrollback_lines = 10000,
    keys = {
      { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
      { key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = true }) },
      { key = "Enter", mods = "CMD", action = "ToggleFullScreen" },
      { key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
      { key = "D", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
      { key = "P", mods = "CMD|SHIFT", action = helpers.theme_picker },
      { key = "O", mods = "CMD|SHIFT", action = helpers.opacity_picker },
      { key = "B", mods = "CMD|SHIFT", action = helpers.blur_picker },
      { key = "F", mods = "CMD|SHIFT", action = helpers.font_picker },
      { key = "T", mods = "CMD|SHIFT", action = helpers.tab_picker },
      { key = "Y", mods = "CMD|SHIFT", action = helpers.padding_picker },
      { key = "]", mods = "CMD|SHIFT", action = helpers.next_theme },
      { key = "[", mods = "CMD|SHIFT", action = helpers.prev_theme },
      { key = "U", mods = "CMD|SHIFT", action = helpers.toggle_status },
      { key = "K", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },
    },
  }
end

return M
