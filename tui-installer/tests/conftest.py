"""
Pytest configuration and fixtures
"""

import pytest
from pathlib import Path

from tui_installer.config import Config
from tui_installer.models import AppState, Category, Tool, Status


# Sample test configuration
SAMPLE_CONFIG = {
    "categories": [
        {
            "id": "test",
            "name": "测试分类",
            "icon": "🧪",
            "tools": [
                {
                    "id": "tool1",
                    "name": "测试工具1",
                    "description": "用于测试的工具",
                    "script": "test/tool1.sh",
                    "requires_sudo": False,
                    "check_cmd": "true"
                },
                {
                    "id": "tool2",
                    "name": "测试工具2",
                    "description": "另一个测试工具",
                    "script": "test/tool2.sh",
                    "requires_sudo": True,
                    "check_cmd": "false"
                }
            ]
        },
        {
            "id": "empty",
            "name": "空分类",
            "icon": "📦",
            "tools": []
        }
    ]
}


@pytest.fixture
def sample_config() -> dict:
    """Provide sample configuration dict"""
    return SAMPLE_CONFIG.copy()


@pytest.fixture
def temp_script_root(tmp_path: Path) -> Path:
    """Create temporary script root directory"""
    script_root = tmp_path / "scripts"
    script_root.mkdir()
    
    # Create test scripts
    test_dir = script_root / "test"
    test_dir.mkdir()
    
    (test_dir / "tool1.sh").write_text("#!/bin/bash\necho 'Tool 1'\nexit 0\n")
    (test_dir / "tool2.sh").write_text("#!/bin/bash\necho 'Tool 2'\nexit 0\n")
    
    return script_root


@pytest.fixture
def config(tmp_path: Path, temp_script_root: Path) -> Config:
    """Create Config instance with test data"""
    config_file = tmp_path / "config.json"
    import json
    config_file.write_text(json.dumps(SAMPLE_CONFIG))
    return Config(config_file, temp_script_root)


@pytest.fixture
def app_state(config: Config) -> AppState:
    """Create AppState with loaded categories"""
    categories = config.load()
    return AppState(categories)

