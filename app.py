from __future__ import annotations

import os
import re
from dataclasses import dataclass
from pathlib import Path

from rich.columns import Columns
from rich.console import Group
from rich.panel import Panel
from rich.rule import Rule
from rich.table import Table
from rich.text import Text
from textual import events
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal, Vertical
from textual.widgets import Footer, Static


STATE_PATH = Path.home() / ".config" / "wezterm" / "terminalcolor_state.lua"
WEZTERM_CONFIG = Path.home() / ".config" / "wezterm" / "wezterm.lua"

OPACITY_PRESETS = [1.00, 0.96, 0.92, 0.88, 0.84, 0.78]
BLUR_PRESETS = [0, 8, 14, 18, 24]
FONT_PRESETS = [12.0, 13.0, 14.0, 15.0, 16.0]
PADDING_PRESETS = {
    "snug": {"left": 4, "right": 4, "top": 2, "bottom": 2},
    "comfy": {"left": 8, "right": 8, "top": 5, "bottom": 5},
    "airy": {"left": 14, "right": 14, "top": 8, "bottom": 8},
}
TAB_MODES = {
    "fancy": "fancy tabs + add button",
    "retro": "square tabs",
    "minimal": "status bar only",
}


@dataclass(frozen=True)
class ThemeSpec:
    theme_id: str
    name: str
    tag: str
    accent: str
    accent_soft: str
    background: str
    surface: str
    panel: str
    text: str
    muted: str
    success: str
    warning: str
    danger: str


@dataclass
class ThemeState:
    theme_id: str = "graphite_ocean"
    opacity: float = 0.92
    blur: int = 18
    font_size: float = 13.0
    padding: str = "comfy"
    tab_mode: str = "fancy"
    right_status: bool = True


THEMES = [
    ThemeSpec("velvet_night", "Velvet Night", "plum / gold", "#f56b8a", "#d99cff", "#120d1d", "#1a1330", "#241a40", "#f7f2ff", "#aa9fbe", "#64d6a4", "#ffbf69", "#ff6d6d"),
    ThemeSpec("forest_reactor", "Forest Reactor", "green / glass", "#68f59a", "#b2ff66", "#07120d", "#0d1d16", "#143126", "#ebfff5", "#8db9a3", "#66f2b1", "#f1d36b", "#ff7d7d"),
    ThemeSpec("arctic_signal", "Arctic Signal", "cyan / steel", "#61dafb", "#8ef6e4", "#08131b", "#10202c", "#183041", "#edf8ff", "#9db7c7", "#6ce5b1", "#f8c555", "#ff7676"),
    ThemeSpec("amber_ledger", "Amber Ledger", "amber / brass", "#ffb454", "#ffd36f", "#151009", "#23190f", "#342414", "#fff7ea", "#c3a98a", "#7be0ad", "#ffd26e", "#ff7a62"),
    ThemeSpec("sakura_circuit", "Sakura Circuit", "rose / slate", "#ff7eb6", "#d7a7ff", "#170f18", "#241627", "#35213a", "#fff0f8", "#c4a5b8", "#72e2b8", "#ffc56f", "#ff7b84"),
    ThemeSpec("graphite_ocean", "Graphite Ocean", "blue / ink", "#70a5ff", "#4ce0d2", "#09121d", "#101b2b", "#1a2d43", "#eef4ff", "#9fb0c8", "#68ddb0", "#f4c25b", "#ff7b7b"),
    ThemeSpec("ember_dusk", "Ember Dusk", "orange / ember", "#ff8c42", "#ffcf70", "#160d0a", "#241511", "#362019", "#fff4ef", "#c8a89a", "#7dd9b6", "#ffd37a", "#ff7a66"),
    ThemeSpec("aurora_mint", "Aurora Mint", "mint / aqua", "#5eead4", "#7dd3fc", "#061514", "#0c211f", "#133330", "#eafffb", "#8dbeb8", "#5df2b5", "#f8d66d", "#ff7d91"),
    ThemeSpec("monsoon_ink", "Monsoon Ink", "storm / violet", "#8f7dff", "#58c4ff", "#0c1020", "#151a2e", "#202743", "#edf1ff", "#98a4c8", "#67ddb2", "#f3c46c", "#ff8080"),
    ThemeSpec("desert_neon", "Desert Neon", "sand / neon", "#ffd166", "#59f8e8", "#121109", "#1d1a10", "#2d2818", "#fffbea", "#c8bd97", "#7be1a6", "#ffd166", "#ff7f68"),
]

THEME_MAP = {theme.theme_id: theme for theme in THEMES}


def next_value(options: list, current):
    try:
        index = options.index(current)
    except ValueError:
        index = -1
    return options[(index + 1) % len(options)]


def parse_state_file(path: Path) -> ThemeState:
    if not path.exists():
        return ThemeState()

    content = path.read_text(encoding="utf-8")

    def get_string(key: str, default: str) -> str:
        match = re.search(rf"{key}\s*=\s*\"([^\"]+)\"", content)
        return match.group(1) if match else default

    def get_float(key: str, default: float) -> float:
        match = re.search(rf"{key}\s*=\s*([0-9.]+)", content)
        return float(match.group(1)) if match else default

    def get_int(key: str, default: int) -> int:
        match = re.search(rf"{key}\s*=\s*([0-9]+)", content)
        return int(match.group(1)) if match else default

    def get_bool(key: str, default: bool) -> bool:
        match = re.search(rf"{key}\s*=\s*(true|false)", content)
        if not match:
            return default
        return match.group(1) == "true"

    state = ThemeState(
        theme_id=get_string("theme", "graphite_ocean"),
        opacity=get_float("opacity", 0.92),
        blur=get_int("blur", 18),
        font_size=get_float("font_size", 13.0),
        padding=get_string("padding", "comfy"),
        tab_mode=get_string("tab_mode", "fancy"),
        right_status=get_bool("right_status", True),
    )

    if state.theme_id not in THEME_MAP:
        state.theme_id = "graphite_ocean"
    if state.opacity not in OPACITY_PRESETS:
        state.opacity = 0.92
    if state.blur not in BLUR_PRESETS:
        state.blur = 18
    if state.font_size not in FONT_PRESETS:
        state.font_size = 13.0
    if state.padding not in PADDING_PRESETS:
        state.padding = "comfy"
    if state.tab_mode not in TAB_MODES:
        state.tab_mode = "fancy"

    return state


def write_state_file(state: ThemeState) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    content = "\n".join(
        [
            "return {",
            f'  theme = "{state.theme_id}",',
            f"  opacity = {state.opacity:.2f},",
            f"  blur = {state.blur},",
            f"  font_size = {state.font_size:.1f},",
            f'  padding = "{state.padding}",',
            f'  tab_mode = "{state.tab_mode}",',
            f"  right_status = {'true' if state.right_status else 'false'},",
            "}",
            "",
        ]
    )
    STATE_PATH.write_text(content, encoding="utf-8")


def touch_wezterm_config() -> None:
    if WEZTERM_CONFIG.exists():
        os.utime(WEZTERM_CONFIG, None)


class WezTermThemeManager(App[None]):
    TITLE = "WezTerm Theme Manager"
    SUB_TITLE = "save to wezterm state"

    CSS = """
    Screen {
      layout: vertical;
      background: #0b1017;
      color: #eef2f7;
    }

    #body {
      layout: horizontal;
      height: 1fr;
    }

    #sidebar {
      width: 36;
      min-width: 30;
      padding: 1;
    }

    #content {
      width: 1fr;
      padding: 1 1 1 0;
    }

    #theme-list {
      height: 16;
      margin: 0 0 1 0;
    }

    #help {
      height: 1fr;
    }

    #hero {
      height: 10;
      margin: 0 1 1 0;
    }

    #workspace {
      height: 1fr;
      margin: 0 1 1 0;
    }
    """

    BINDINGS = [
        Binding("up", "prev_theme", "Prev theme"),
        Binding("down", "next_theme", "Next theme"),
        Binding("left", "prev_theme", "Prev theme"),
        Binding("right", "next_theme", "Next theme"),
        Binding("o", "next_opacity", "Opacity"),
        Binding("b", "next_blur", "Blur"),
        Binding("f", "next_font", "Font"),
        Binding("p", "next_padding", "Padding"),
        Binding("t", "next_tab_mode", "Tabs"),
        Binding("r", "toggle_status", "Status"),
        Binding("s", "save", "Save"),
        Binding("q", "quit", "Quit"),
    ]

    def __init__(self) -> None:
        super().__init__()
        self.state = parse_state_file(STATE_PATH)
        self.theme_index = next(
            (index for index, theme in enumerate(THEMES) if theme.theme_id == self.state.theme_id),
            0,
        )
        self.status_message = "Press s to save the current preset into WezTerm."

    def compose(self) -> ComposeResult:
        yield Horizontal(
            Vertical(
                Static(id="theme-list"),
                Static(id="help"),
                id="sidebar",
            ),
            Vertical(
                Static(id="hero"),
                Static(id="workspace"),
                id="content",
            ),
            id="body",
        )
        yield Footer()

    def on_mount(self) -> None:
        self._refresh_ui()

    def on_key(self, event: events.Key) -> None:
        if event.key.isdigit():
            if event.key == "0":
                index = 9
            else:
                index = int(event.key) - 1
            if 0 <= index < len(THEMES):
                self.theme_index = index
                self.state.theme_id = THEMES[index].theme_id
                self._refresh_ui()
                event.stop()

    @property
    def theme(self) -> ThemeSpec:
        return THEMES[self.theme_index]

    def action_next_theme(self) -> None:
        self.theme_index = (self.theme_index + 1) % len(THEMES)
        self.state.theme_id = self.theme.theme_id
        self._refresh_ui()

    def action_prev_theme(self) -> None:
        self.theme_index = (self.theme_index - 1) % len(THEMES)
        self.state.theme_id = self.theme.theme_id
        self._refresh_ui()

    def action_next_opacity(self) -> None:
        self.state.opacity = next_value(OPACITY_PRESETS, self.state.opacity)
        self._refresh_ui()

    def action_next_blur(self) -> None:
        self.state.blur = next_value(BLUR_PRESETS, self.state.blur)
        self._refresh_ui()

    def action_next_font(self) -> None:
        self.state.font_size = next_value(FONT_PRESETS, self.state.font_size)
        self._refresh_ui()

    def action_next_padding(self) -> None:
        names = list(PADDING_PRESETS)
        self.state.padding = next_value(names, self.state.padding)
        self._refresh_ui()

    def action_next_tab_mode(self) -> None:
        names = list(TAB_MODES)
        self.state.tab_mode = next_value(names, self.state.tab_mode)
        self._refresh_ui()

    def action_toggle_status(self) -> None:
        self.state.right_status = not self.state.right_status
        self._refresh_ui()

    def action_save(self) -> None:
        write_state_file(self.state)
        touch_wezterm_config()
        self.status_message = f"Saved to {STATE_PATH} and touched {WEZTERM_CONFIG.name} for reload."
        self._refresh_ui()

    def _refresh_ui(self) -> None:
        theme = self.theme
        self.sub_title = f"{theme.name} | opacity {self.state.opacity:.2f} | font {self.state.font_size:.1f}"
        self.query_one("#theme-list", Static).update(self._render_theme_list(theme))
        self.query_one("#help", Static).update(self._render_help(theme))
        self.query_one("#hero", Static).update(self._render_hero(theme))
        self.query_one("#workspace", Static).update(self._render_workspace(theme))

    def _render_theme_list(self, theme: ThemeSpec) -> Panel:
        rows: list[Text] = [
            Text("10 presets", style=f"bold {theme.text}"),
            Text("1-9 / 0 jumps directly. Arrows move one theme at a time.", style=theme.muted),
            Rule(style=theme.panel),
        ]

        for index, candidate in enumerate(THEMES, start=1):
            key = "0" if index == 10 else str(index)
            line = Text()
            is_active = index - 1 == self.theme_index
            if is_active:
                line.append(">> ", style=theme.accent)
                line.append(f"{key}. {candidate.name}", style=f"bold {theme.background} on {candidate.accent}")
            else:
                line.append("   ", style=theme.muted)
                line.append(f"{key}. {candidate.name}", style=candidate.accent)
            line.append(f"  {candidate.tag}", style=theme.muted)
            rows.append(line)

        return Panel(
            Group(*rows),
            title="Themes",
            border_style=theme.accent,
            style=f"on {theme.surface}",
        )

    def _render_help(self, theme: ThemeSpec) -> Panel:
        table = Table.grid(padding=(0, 1))
        table.add_column(style=f"bold {theme.accent}")
        table.add_column(style=theme.text)
        table.add_row("o", "cycle opacity")
        table.add_row("b", "cycle blur")
        table.add_row("f", "cycle font size")
        table.add_row("p", "cycle padding preset")
        table.add_row("t", "cycle tab mode")
        table.add_row("r", "toggle right status")
        table.add_row("s", "save into WezTerm")
        table.add_row("q", "quit")

        status = Text(self.status_message, style=theme.text)

        return Panel(
            Group(
                Text("Manager keys", style=f"bold {theme.text}"),
                table,
                Rule(style=theme.panel),
                Text("Last save", style=f"bold {theme.text}"),
                status,
            ),
            title="Controls",
            border_style=theme.accent_soft,
            style=f"on {theme.surface}",
        )

    def _render_hero(self, theme: ThemeSpec) -> Panel:
        chips = Text()
        for label, color in [
            ("Accent", theme.accent),
            ("Soft", theme.accent_soft),
            ("Success", theme.success),
            ("Warning", theme.warning),
            ("Danger", theme.danger),
        ]:
            chips.append(f" {label} ", style=f"bold {theme.background} on {color}")
            chips.append("  ")

        return Panel(
            Group(
                Text("WEZTERM THEME MANAGER", style=f"bold {theme.text}"),
                Text(
                    "This tool writes a saved state file that your WezTerm config reads on reload.",
                    style=theme.muted,
                ),
                Rule(style=theme.panel),
                Text(f"State file: {STATE_PATH}", style=theme.accent),
                Text("Press s to persist. WezTerm will pick it up after reload or auto-reload.", style=theme.text),
                chips,
            ),
            title=f"Active Preset / {theme.name}",
            border_style=theme.accent,
            style=f"on {theme.surface}",
        )

    def _render_workspace(self, theme: ThemeSpec):
        return Columns(
            [self._render_current_panel(theme), self._render_native_panel(theme)],
            equal=True,
            expand=True,
        )

    def _render_current_panel(self, theme: ThemeSpec) -> Panel:
        settings = Table.grid(expand=True, padding=(0, 1))
        settings.add_column(style=f"bold {theme.accent}")
        settings.add_column(style=theme.text)
        settings.add_row("Theme", theme.name)
        settings.add_row("Opacity", f"{self.state.opacity:.2f}")
        settings.add_row("Blur", f"{self.state.blur}")
        settings.add_row("Font", f"{self.state.font_size:.1f} pt")
        settings.add_row("Padding", self.state.padding)
        settings.add_row("Tab mode", self.state.tab_mode)
        settings.add_row("Right status", "on" if self.state.right_status else "off")

        swatches = Table.grid(expand=True, padding=(0, 1))
        swatches.add_column(style=f"bold {theme.accent}")
        swatches.add_column()
        swatches.add_column(style=theme.text)
        for label, color in [
            ("bg", theme.background),
            ("surface", theme.surface),
            ("panel", theme.panel),
            ("accent", theme.accent),
            ("soft", theme.accent_soft),
            ("text", theme.text),
        ]:
            swatches.add_row(label, Text("    ", style=f"on {color}"), color.upper())

        return Panel(
            Group(
                Text("Saved WezTerm values", style=f"bold {theme.text}"),
                settings,
                Rule(style=theme.panel),
                Text("Color tokens", style=f"bold {theme.text}"),
                swatches,
            ),
            title="Current Output",
            border_style=theme.accent_soft,
            style=f"on {theme.surface}",
        )

    def _render_native_panel(self, theme: ThemeSpec) -> Panel:
        keys = Table.grid(expand=True, padding=(0, 1))
        keys.add_column(style=f"bold {theme.accent}")
        keys.add_column(style=theme.text)
        keys.add_row("Cmd+Shift+P", "theme picker overlay")
        keys.add_row("Cmd+Shift+O", "opacity picker overlay")
        keys.add_row("Cmd+Shift+B", "blur picker overlay")
        keys.add_row("Cmd+Shift+F", "font size picker")
        keys.add_row("Cmd+Shift+T", "tab mode picker")
        keys.add_row("Cmd+Shift+[ / ]", "previous / next theme")
        keys.add_row("Cmd+Shift+U", "toggle right status")
        keys.add_row("Cmd+Shift+K", "command palette")

        components = Text()
        components.append("Native WezTerm surfaces:\n", style=f"bold {theme.text}")
        components.append("• fancy / retro / minimal tab bar\n", style=theme.text)
        components.append("• custom tab titles\n", style=theme.text)
        components.append("• right status bar\n", style=theme.text)
        components.append("• InputSelector overlay menus\n", style=theme.text)
        components.append("• opacity / blur / padding / font size\n", style=theme.text)
        components.append("• window frame colors", style=theme.text)

        snippet = Text()
        snippet.append("return {\n", style=theme.muted)
        snippet.append(f'  theme = "{self.state.theme_id}",\n', style=theme.accent)
        snippet.append(f"  opacity = {self.state.opacity:.2f},\n", style=theme.accent)
        snippet.append(f"  blur = {self.state.blur},\n", style=theme.accent)
        snippet.append(f"  font_size = {self.state.font_size:.1f},\n", style=theme.accent)
        snippet.append("  ...\n", style=theme.muted)
        snippet.append("}", style=theme.muted)

        return Panel(
            Group(
                Text("WezTerm native components", style=f"bold {theme.text}"),
                components,
                Rule(style=theme.panel),
                Text("In-WezTerm hotkeys", style=f"bold {theme.text}"),
                keys,
                Rule(style=theme.panel),
                Text("State preview", style=f"bold {theme.text}"),
                snippet,
            ),
            title="WezTerm Integration",
            border_style=theme.accent,
            style=f"on {theme.surface}",
        )


if __name__ == "__main__":
    WezTermThemeManager().run()
