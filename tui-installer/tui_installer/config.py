"""
Configuration management
"""

import json
from pathlib import Path
from typing import List, Optional

from .models import Category

# Package directory for locating bundled data
PACKAGE_DIR = Path(__file__).parent
DATA_DIR = PACKAGE_DIR / "data"


class Config:
    """Application configuration"""
    
    def __init__(
        self, 
        config_file: Path, 
        script_root: Path,
        *,
        custom_config: Optional[dict] = None
    ):
        self.config_file = config_file
        self.script_root = script_root
        self._data = custom_config
    
    def load(self) -> List[Category]:
        """Load configuration and create category objects"""
        if self._data is None:
            if not self.config_file.exists():
                raise FileNotFoundError(f"配置文件不存在: {self.config_file}")
            
            with open(self.config_file, encoding="utf-8") as f:
                self._data = json.load(f)
        
        categories = [
            Category(cat_data, self.script_root) 
            for cat_data in self._data.get("categories", [])
        ]
        
        return categories
    
    @classmethod
    def default(cls) -> "Config":
        """Create configuration with default paths
        
        Uses bundled config from package data directory.
        Script root is expected at ../install-script relative to project root.
        """
        config_file = DATA_DIR / "tools_config.json"
        # Go up from package dir to project, then to parent for install-script
        project_root = PACKAGE_DIR.parent
        script_root = project_root.parent / "install-script"
        return cls(config_file, script_root)
    
    @classmethod
    def from_file(cls, config_path: str, script_root: Optional[str] = None) -> "Config":
        """Create configuration from custom config file path
        
        Args:
            config_path: Path to configuration JSON file
            script_root: Optional custom script root directory
        """
        config_file = Path(config_path).resolve()
        if script_root:
            scripts = Path(script_root).resolve()
        else:
            scripts = config_file.parent.parent / "install-script"
        return cls(config_file, scripts)


