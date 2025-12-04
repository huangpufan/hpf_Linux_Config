"""
Application-wide constants for tui-installer.

Centralizes magic numbers to improve code readability and maintainability.
"""

# =============================================================================
# UI Constants
# =============================================================================

# Rich Live display refresh rate (frames per second)
# Lower rate saves CPU; input triggers immediate refresh anyway
UI_REFRESH_RATE = 10  # Hz

# Keyboard input polling interval
# ~60 Hz provides responsive feel without excessive CPU usage
INPUT_POLL_INTERVAL = 0.016  # seconds (~60 Hz = 1000ms / 60)

# Maximum log lines to display in UI
# Balance between visibility and memory/performance
LOG_DISPLAY_LINES = 50

# =============================================================================
# Execution Constants
# =============================================================================

# Default script execution timeout
# 5 minutes should be enough for most installations
SCRIPT_DEFAULT_TIMEOUT = 300  # seconds (5 minutes)

# Timeout for sudo credential refresh
SUDO_REFRESH_TIMEOUT = 5.0  # seconds

# =============================================================================
# State/Check Constants
# =============================================================================

# Timeout for check_cmd verification
CHECK_CMD_TIMEOUT = 5.0  # seconds

# Maximum concurrent tool checks during verification
MAX_CONCURRENT_CHECKS = 10

# =============================================================================
# Logging Constants
# =============================================================================

# Maximum log lines to keep in memory per tool
# Uses deque to automatically discard oldest entries
LOG_MAX_ENTRIES = 500

# Directory for storing persistent log files
# Uses XDG Base Directory specification
LOG_DIR_NAME = "tui-installer"

# Whether to enable persistent log storage (write full logs to file)
# Set to True to preserve complete logs for large compilation tasks
LOG_PERSIST_ENABLED = True

