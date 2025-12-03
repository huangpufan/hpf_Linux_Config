"""
Tests for system checks and prerequisites
"""

import asyncio
import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock, AsyncMock

from tui_installer.models import AppState, Category
from tui_installer.system import check_sudo, check_ssh, check_wsl, check_system


class TestCheckSudo:
    """Test sudo availability check"""

    @pytest.mark.asyncio
    async def test_check_sudo_available(self):
        """Should return True when sudo -n succeeds"""
        mock_proc = MagicMock()
        mock_proc.returncode = 0
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_sudo()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_sudo_unavailable(self):
        """Should return False when sudo -n fails"""
        mock_proc = MagicMock()
        mock_proc.returncode = 1
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_sudo()
        
        assert result is False

    @pytest.mark.asyncio
    async def test_check_sudo_real(self):
        """Real sudo check (depends on system config)"""
        # This test will pass or fail based on actual system sudo config
        result = await check_sudo()
        assert isinstance(result, bool)


class TestCheckSSH:
    """Test SSH configuration check"""

    @pytest.mark.asyncio
    async def test_check_ssh_authenticated(self):
        """Should return True when SSH to GitHub succeeds (returncode 1)"""
        mock_proc = MagicMock()
        mock_proc.returncode = 1  # GitHub returns 1 for authenticated but no shell
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_ssh()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_ssh_full_success(self):
        """Should return True when SSH returns 0"""
        mock_proc = MagicMock()
        mock_proc.returncode = 0
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_ssh()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_ssh_not_configured(self):
        """Should return False when SSH fails (returncode not 0 or 1)"""
        mock_proc = MagicMock()
        mock_proc.returncode = 255  # Connection refused or similar
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_ssh()
        
        assert result is False


class TestCheckWSL:
    """Test WSL detection"""

    @pytest.mark.asyncio
    async def test_check_wsl_detected(self, tmp_path: Path):
        """Should return True when /proc/version contains 'microsoft'"""
        mock_content = "Linux version 5.15.0-1-microsoft-standard-WSL2"
        
        with patch('builtins.open', create=True) as mock_open:
            mock_open.return_value.__enter__ = lambda s: s
            mock_open.return_value.__exit__ = MagicMock(return_value=False)
            mock_open.return_value.read = MagicMock(return_value=mock_content)
            
            result = await check_wsl()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_wsl_not_detected(self):
        """Should return False when not running under WSL"""
        mock_content = "Linux version 5.15.0-generic"
        
        with patch('builtins.open', create=True) as mock_open:
            mock_open.return_value.__enter__ = lambda s: s
            mock_open.return_value.__exit__ = MagicMock(return_value=False)
            mock_open.return_value.read = MagicMock(return_value=mock_content)
            
            result = await check_wsl()
        
        assert result is False

    @pytest.mark.asyncio
    async def test_check_wsl_file_not_found(self):
        """Should return False when /proc/version doesn't exist"""
        with patch('builtins.open', side_effect=FileNotFoundError()):
            result = await check_wsl()
        
        assert result is False

    @pytest.mark.asyncio
    async def test_check_wsl_real(self):
        """Real WSL check (depends on system)"""
        result = await check_wsl()
        assert isinstance(result, bool)


class TestCheckSystem:
    """Test combined system check"""

    @pytest.fixture
    def mock_state(self) -> AppState:
        """Create empty app state"""
        category_data = {
            "id": "test",
            "name": "Test",
            "icon": "🧪",
            "tools": []
        }
        cat = Category.__new__(Category)
        cat.id = "test"
        cat.name = "Test"
        cat.icon = "🧪"
        cat.tools = []
        
        return AppState([cat])

    @pytest.mark.asyncio
    async def test_check_system_updates_state(self, mock_state: AppState):
        """check_system should update all state flags"""
        with patch('tui_installer.system.check_sudo', return_value=True), \
             patch('tui_installer.system.check_ssh', return_value=True), \
             patch('tui_installer.system.check_wsl', return_value=True):
            
            await check_system(mock_state)
        
        assert mock_state.has_sudo is True
        assert mock_state.has_ssh is True
        assert mock_state.is_wsl is True

    @pytest.mark.asyncio
    async def test_check_system_all_false(self, mock_state: AppState):
        """check_system should handle all checks failing"""
        with patch('tui_installer.system.check_sudo', return_value=False), \
             patch('tui_installer.system.check_ssh', return_value=False), \
             patch('tui_installer.system.check_wsl', return_value=False):
            
            await check_system(mock_state)
        
        assert mock_state.has_sudo is False
        assert mock_state.has_ssh is False
        assert mock_state.is_wsl is False

    @pytest.mark.asyncio
    async def test_check_system_mixed(self, mock_state: AppState):
        """check_system should handle mixed results"""
        with patch('tui_installer.system.check_sudo', return_value=True), \
             patch('tui_installer.system.check_ssh', return_value=False), \
             patch('tui_installer.system.check_wsl', return_value=True):
            
            await check_system(mock_state)
        
        assert mock_state.has_sudo is True
        assert mock_state.has_ssh is False
        assert mock_state.is_wsl is True

    @pytest.mark.asyncio
    async def test_check_system_real(self, mock_state: AppState):
        """Real system check (integration test)"""
        await check_system(mock_state)
        
        # All values should be booleans
        assert isinstance(mock_state.has_sudo, bool)
        assert isinstance(mock_state.has_ssh, bool)
        assert isinstance(mock_state.is_wsl, bool)


class TestSystemCheckConcurrency:
    """Test concurrent system checks"""

    @pytest.mark.asyncio
    async def test_multiple_concurrent_checks(self):
        """Multiple concurrent system checks should not interfere"""
        results = await asyncio.gather(
            check_sudo(),
            check_ssh(),
            check_wsl()
        )
        
        assert len(results) == 3
        assert all(isinstance(r, bool) for r in results)

