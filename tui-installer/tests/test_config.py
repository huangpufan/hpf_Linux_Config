"""
Tests for configuration management
"""

import json
import pytest
from pathlib import Path

from tui_installer.config import Config, DATA_DIR, PACKAGE_DIR


class TestConfig:
    """Test Config class"""
    
    def test_load_from_file(self, tmp_path: Path, temp_script_root: Path, sample_config: dict):
        """Config should load from JSON file"""
        config_file = tmp_path / "test_config.json"
        config_file.write_text(json.dumps(sample_config))
        
        config = Config(config_file, temp_script_root)
        categories = config.load()
        
        assert len(categories) == 2
        assert categories[0].id == "test"
        assert len(categories[0].tools) == 2
    
    def test_missing_config_file(self, tmp_path: Path, temp_script_root: Path):
        """Config should raise FileNotFoundError for missing file"""
        config = Config(tmp_path / "nonexistent.json", temp_script_root)
        
        with pytest.raises(FileNotFoundError):
            config.load()
    
    def test_from_file_classmethod(self, tmp_path: Path, sample_config: dict):
        """Config.from_file should create instance from path"""
        config_file = tmp_path / "config.json"
        config_file.write_text(json.dumps(sample_config))
        
        config = Config.from_file(str(config_file))
        
        assert config.config_file == config_file
    
    def test_package_data_dir_exists(self):
        """Package data directory should exist"""
        assert PACKAGE_DIR.exists()
        assert DATA_DIR.exists()
    
    def test_bundled_config_exists(self):
        """Bundled tools_config.json should exist"""
        config_file = DATA_DIR / "tools_config.json"
        assert config_file.exists()
        
        # Verify it's valid JSON
        with open(config_file) as f:
            data = json.load(f)
        
        assert "categories" in data
        assert len(data["categories"]) > 0

