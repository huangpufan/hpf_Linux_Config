"""
Configuration management
"""

import json
from pathlib import Path
from typing import List

from .models import Category


class Config:
    """Application configuration"""
    
    def __init__(self, config_file: Path, script_root: Path):
        self.config_file = config_file
        self.script_root = script_root
        self._data = None
    
    def load(self) -> List[Category]:
        """Load configuration and create category objects"""
        if not self.config_file.exists():
            raise FileNotFoundError(f"配置文件不存在: {self.config_file}")
        
        with open(self.config_file) as f:
            self._data = json.load(f)
        
        categories = [
            Category(cat_data, self.script_root) 
            for cat_data in self._data.get("categories", [])
        ]
        
        return categories
    
    @classmethod
    def default(cls):
        """Create configuration with default paths"""
        base_dir = Path(__file__).parent.parent
        config_file = base_dir / "tools_config.json"
        script_root = base_dir.parent / "install-script"
        return cls(config_file, script_root)


