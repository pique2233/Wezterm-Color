# WezTerm Theme Manager

This directory now contains a small Textual manager plus a WezTerm bridge.

## What it does

- stores the selected preset in `~/.config/wezterm/terminalcolor_state.lua`
- lets WezTerm read that state on startup and reload
- gives you 10 custom themes
- lets you switch opacity, blur, font size, padding, tab style, and right status
- wires native WezTerm UI surfaces:
  - `InputSelector` overlays
  - custom tab titles
  - right status bar
  - fancy / retro / minimal tab bar modes
  - command palette

## Run the manager

```bash
cd /Users/liziwen/Desktop/terminalcolor
source .venv/bin/activate
python app.py
```

## Manager keys

- `1-9` / `0`: pick one of the 10 themes
- Arrow keys: previous / next theme
- `o`: cycle opacity
- `b`: cycle blur
- `f`: cycle font size
- `p`: cycle padding
- `t`: cycle tab mode
- `r`: toggle right status
- `s`: save into WezTerm
- `q`: quit

When you press `s`, the manager writes `~/.config/wezterm/terminalcolor_state.lua` and touches `~/.config/wezterm/wezterm.lua` so WezTerm can reload the saved values.

## In WezTerm

These hotkeys work directly inside WezTerm:

- `Cmd+Shift+P`: theme picker
- `Cmd+Shift+O`: opacity picker
- `Cmd+Shift+B`: blur picker
- `Cmd+Shift+F`: font size picker
- `Cmd+Shift+T`: tab mode picker
- `Cmd+Shift+Y`: padding picker
- `Cmd+Shift+[`: previous theme
- `Cmd+Shift+]`: next theme
- `Cmd+Shift+U`: toggle right status
- `Cmd+Shift+K`: command palette

## Files

- `app.py`: the local Textual manager
- `wezterm_theme_lab.lua`: the WezTerm bridge loaded by `~/.config/wezterm/wezterm.lua`
- `~/.config/wezterm/terminalcolor_state.lua`: the saved live preset

## Important

`~/.config/wezterm/wezterm.lua` now loads `/Users/liziwen/Desktop/terminalcolor/wezterm_theme_lab.lua`. If you move this directory, update that path too.
