"""
Theme configuration with absolute hex colors.

Uses Catppuccin Mocha color palette for consistent appearance
across different terminal themes.
"""

from rich.style import Style


class Theme:
    """
    Fixed color theme using hex values to override terminal colors.
    
    Based on Catppuccin Mocha palette:
    https://github.com/catppuccin/catppuccin
    """
    
    # Base colors (backgrounds)
    BASE = "#1e1e2e"      # Main background
    MANTLE = "#181825"    # Darker background
    SURFACE0 = "#313244"  # Surface
    SURFACE1 = "#45475a"  # Elevated surface
    SURFACE2 = "#585b70"  # Higher surface
    
    # Text colors
    TEXT = "#cdd6f4"      # Primary text
    SUBTEXT1 = "#bac2de"  # Secondary text
    SUBTEXT0 = "#a6adc8"  # Tertiary text
    OVERLAY2 = "#9399b2"  # Dimmed text
    OVERLAY1 = "#7f849c"  # More dimmed
    OVERLAY0 = "#6c7086"  # Most dimmed
    
    # Accent colors
    BLUE = "#89b4fa"      # Primary accent
    SKY = "#89dceb"       # Light blue
    CYAN = "#94e2d5"      # Cyan/Teal
    GREEN = "#a6e3a1"     # Success
    YELLOW = "#f9e2af"    # Warning
    PEACH = "#fab387"     # Orange accent
    RED = "#f38ba8"       # Error
    MAROON = "#eba0ac"    # Secondary red
    PINK = "#f5c2e7"      # Pink accent
    MAUVE = "#cba6f7"     # Purple accent
    LAVENDER = "#b4befe"  # Soft purple
    
    # Semantic colors (mapped from palette)
    PRIMARY = BLUE
    SUCCESS = GREEN
    WARNING = YELLOW
    ERROR = RED
    INFO = SKY
    MUTED = OVERLAY0
    
    # Pre-built styles for common use cases
    @classmethod
    def title(cls) -> Style:
        """Title style - bold primary"""
        return Style(color=cls.PRIMARY, bold=True)
    
    @classmethod
    def title_focused(cls) -> Style:
        """Focused title"""
        return Style(color=cls.CYAN, bold=True)
    
    @classmethod
    def dim(cls) -> Style:
        """Dimmed text"""
        return Style(color=cls.OVERLAY0)
    
    @classmethod
    def text(cls) -> Style:
        """Normal text"""
        return Style(color=cls.TEXT)
    
    @classmethod
    def success(cls) -> Style:
        """Success text"""
        return Style(color=cls.GREEN, bold=True)
    
    @classmethod
    def warning(cls) -> Style:
        """Warning text"""
        return Style(color=cls.YELLOW, bold=True)
    
    @classmethod
    def error(cls) -> Style:
        """Error text"""
        return Style(color=cls.RED, bold=True)
    
    @classmethod
    def info(cls) -> Style:
        """Info text"""
        return Style(color=cls.SKY)
    
    @classmethod
    def selected_row(cls) -> Style:
        """Selected/highlighted row background"""
        return Style(bgcolor=cls.SURFACE0)
    
    @classmethod
    def panel_bg(cls) -> Style:
        """Panel background"""
        return Style(bgcolor=cls.BASE)
    
    @classmethod
    def header_bg(cls) -> Style:
        """Header background"""
        return Style(color=cls.TEXT, bgcolor=cls.BASE)
    
    @classmethod
    def border_focused(cls) -> Style:
        """Focused panel border"""
        return Style(color=cls.CYAN, bold=True)
    
    @classmethod
    def border_unfocused(cls) -> Style:
        """Unfocused panel border"""
        return Style(color=cls.SURFACE2)


# Status icons with absolute colors
STATUS_STYLES = {
    "pending": (Style(color=Theme.OVERLAY0), "⚪", "待装"),
    "running": (Style(color=Theme.BLUE, bold=True), "🔵", "运行"),
    "success": (Style(color=Theme.GREEN, bold=True), "🟢", "完成"),
    "failed": (Style(color=Theme.RED, bold=True), "🔴", "失败"),
    "skipped": (Style(color=Theme.OVERLAY1), "⚫", "跳过"),
}

