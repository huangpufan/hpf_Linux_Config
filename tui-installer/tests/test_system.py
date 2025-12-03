"""
Tests for system checks and prerequisites
"""

import asyncio
import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock, AsyncMock

from tui_installer.models import AppState, Category
from tui_installer.system import (
    check_sudo,
    check_ssh_key_exists,
    check_ssh_github,
    check_wsl,
    check_source_changed,
    check_system,
    collect_system_info,
    SystemInfo,
)


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
        result = await check_sudo()
        assert isinstance(result, bool)


class TestCheckSSHKeyExists:
    """Test SSH key file existence check"""

    @pytest.mark.asyncio
    async def test_check_ssh_key_rsa_exists(self, tmp_path: Path):
        """Should return True when id_rsa.pub exists"""
        ssh_dir = tmp_path / ".ssh"
        ssh_dir.mkdir()
        (ssh_dir / "id_rsa.pub").touch()
        
        with patch.object(Path, 'home', return_value=tmp_path):
            result = await check_ssh_key_exists()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_ssh_key_ed25519_exists(self, tmp_path: Path):
        """Should return True when id_ed25519.pub exists"""
        ssh_dir = tmp_path / ".ssh"
        ssh_dir.mkdir()
        (ssh_dir / "id_ed25519.pub").touch()
        
        with patch.object(Path, 'home', return_value=tmp_path):
            result = await check_ssh_key_exists()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_ssh_key_not_exists(self, tmp_path: Path):
        """Should return False when no SSH key exists"""
        ssh_dir = tmp_path / ".ssh"
        ssh_dir.mkdir()
        
        with patch.object(Path, 'home', return_value=tmp_path):
            result = await check_ssh_key_exists()
        
        assert result is False

    @pytest.mark.asyncio
    async def test_check_ssh_key_real(self):
        """Real SSH key check (depends on system)"""
        result = await check_ssh_key_exists()
        assert isinstance(result, bool)


class TestCheckSSHGitHub:
    """Test SSH GitHub configuration check"""

    @pytest.mark.asyncio
    async def test_check_ssh_github_authenticated(self):
        """Should return True when SSH to GitHub succeeds (returncode 1)"""
        mock_proc = MagicMock()
        mock_proc.returncode = 1  # GitHub returns 1 for authenticated but no shell
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_ssh_github()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_ssh_github_full_success(self):
        """Should return True when SSH returns 0"""
        mock_proc = MagicMock()
        mock_proc.returncode = 0
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_ssh_github()
        
        assert result is True

    @pytest.mark.asyncio
    async def test_check_ssh_github_not_configured(self):
        """Should return False when SSH fails (returncode not 0 or 1)"""
        mock_proc = MagicMock()
        mock_proc.returncode = 255  # Connection refused or similar
        mock_proc.wait = AsyncMock(return_value=None)
        
        with patch('asyncio.create_subprocess_exec', return_value=mock_proc):
            result = await check_ssh_github()
        
        assert result is False


class TestCheckWSL:
    """Test WSL detection"""

    @pytest.mark.asyncio
    async def test_check_wsl2_detected(self):
        """Should return (True, 2) when /proc/version contains 'microsoft-standard'"""
        mock_content = "Linux version 5.15.0-1-microsoft-standard-WSL2"
        
        with patch('builtins.open', create=True) as mock_open:
            mock_open.return_value.__enter__ = lambda s: s
            mock_open.return_value.__exit__ = MagicMock(return_value=False)
            mock_open.return_value.read = MagicMock(return_value=mock_content)
            
            is_wsl, version = await check_wsl()
        
        assert is_wsl is True
        assert version == 2

    @pytest.mark.asyncio
    async def test_check_wsl1_detected(self):
        """Should return (True, 1) when /proc/version contains 'microsoft' but not standard"""
        mock_content = "Linux version 4.4.0-microsoft"
        
        with patch('builtins.open', create=True) as mock_open:
            mock_open.return_value.__enter__ = lambda s: s
            mock_open.return_value.__exit__ = MagicMock(return_value=False)
            mock_open.return_value.read = MagicMock(return_value=mock_content)
            
            is_wsl, version = await check_wsl()
        
        assert is_wsl is True
        assert version == 1

    @pytest.mark.asyncio
    async def test_check_wsl_not_detected(self):
        """Should return (False, 0) when not running under WSL"""
        mock_content = "Linux version 5.15.0-generic"
        
        with patch('builtins.open', create=True) as mock_open:
            mock_open.return_value.__enter__ = lambda s: s
            mock_open.return_value.__exit__ = MagicMock(return_value=False)
            mock_open.return_value.read = MagicMock(return_value=mock_content)
            
            is_wsl, version = await check_wsl()
        
        assert is_wsl is False
        assert version == 0

    @pytest.mark.asyncio
    async def test_check_wsl_file_not_found(self):
        """Should return (False, 0) when /proc/version doesn't exist"""
        with patch('builtins.open', side_effect=FileNotFoundError()):
            is_wsl, version = await check_wsl()
        
        assert is_wsl is False
        assert version == 0

    @pytest.mark.asyncio
    async def test_check_wsl_real(self):
        """Real WSL check (depends on system)"""
        is_wsl, version = await check_wsl()
        assert isinstance(is_wsl, bool)
        assert isinstance(version, int)


class TestCheckSourceChanged:
    """Test APT source mirror detection"""

    @pytest.mark.asyncio
    async def test_source_changed_real(self):
        """Real source change check (integration test)"""
        result = await check_source_changed()
        assert isinstance(result, bool)

    @pytest.mark.asyncio
    async def test_source_detection_logic(self):
        """Test the detection logic for common mirrors"""
        # This tests the actual function on the real system
        # The function checks /etc/apt/sources.list for mirror patterns
        result = await check_source_changed()
        
        # Result should be boolean regardless of system config
        assert isinstance(result, bool)


class TestSystemInfo:
    """Test SystemInfo dataclass"""

    def test_os_display_wsl(self):
        """Should format OS display with WSL tag"""
        info = SystemInfo(
            os_name="Ubuntu",
            os_version="22.04",
            is_wsl=True,
            wsl_version=2
        )
        assert info.os_display == "Ubuntu 22.04 (WSL2)"

    def test_os_display_wsl1(self):
        """Should format OS display with WSL1 tag"""
        info = SystemInfo(
            os_name="Ubuntu",
            os_version="20.04",
            is_wsl=True,
            wsl_version=1
        )
        assert info.os_display == "Ubuntu 20.04 (WSL1)"

    def test_os_display_native(self):
        """Should format OS display without WSL tag for native Linux"""
        info = SystemInfo(
            os_name="Debian",
            os_version="12",
            is_wsl=False,
            wsl_version=0
        )
        assert info.os_display == "Debian 12"


class TestCheckSystem:
    """Test combined system check"""

    @pytest.fixture
    def mock_state(self) -> AppState:
        """Create empty app state"""
        cat = Category.__new__(Category)
        cat.id = "test"
        cat.name = "Test"
        cat.icon = "🧪"
        cat.tools = []
        
        return AppState([cat])

    @pytest.mark.asyncio
    async def test_check_system_updates_state(self, mock_state: AppState):
        """check_system should update all state flags"""
        mock_info = SystemInfo(
            os_name="Ubuntu",
            os_version="22.04",
            is_wsl=True,
            wsl_version=2,
            has_sudo=True,
            has_ssh_key=True,
            has_ssh_github=True,
            source_changed=True,
        )
        
        with patch('tui_installer.system.collect_system_info', return_value=mock_info):
            await check_system(mock_state)
        
        assert mock_state.system_info is not None
        assert mock_state.has_sudo is True
        assert mock_state.has_ssh is True
        assert mock_state.is_wsl is True

    @pytest.mark.asyncio
    async def test_check_system_all_false(self, mock_state: AppState):
        """check_system should handle all checks failing"""
        mock_info = SystemInfo(
            os_name="Unknown",
            os_version="",
            is_wsl=False,
            wsl_version=0,
            has_sudo=False,
            has_ssh_key=False,
            has_ssh_github=False,
            source_changed=False,
        )
        
        with patch('tui_installer.system.collect_system_info', return_value=mock_info):
            await check_system(mock_state)
        
        assert mock_state.has_sudo is False
        assert mock_state.has_ssh is False
        assert mock_state.is_wsl is False

    @pytest.mark.asyncio
    async def test_check_system_real(self, mock_state: AppState):
        """Real system check (integration test)"""
        await check_system(mock_state)
        
        # system_info should be populated
        assert mock_state.system_info is not None
        assert isinstance(mock_state.system_info.os_name, str)
        
        # Legacy values should be booleans
        assert isinstance(mock_state.has_sudo, bool)
        assert isinstance(mock_state.has_ssh, bool)
        assert isinstance(mock_state.is_wsl, bool)


class TestCollectSystemInfo:
    """Test collect_system_info function"""

    @pytest.mark.asyncio
    async def test_collect_system_info_real(self):
        """Real system info collection (integration test)"""
        info = await collect_system_info()
        
        assert isinstance(info, SystemInfo)
        assert isinstance(info.os_name, str)
        assert isinstance(info.is_wsl, bool)
        assert isinstance(info.has_sudo, bool)
        assert isinstance(info.has_ssh_key, bool)
        assert isinstance(info.source_changed, bool)


class TestSystemCheckConcurrency:
    """Test concurrent system checks"""

    @pytest.mark.asyncio
    async def test_multiple_concurrent_checks(self):
        """Multiple concurrent system checks should not interfere"""
        results = await asyncio.gather(
            check_sudo(),
            check_ssh_key_exists(),
            check_wsl()
        )
        
        assert len(results) == 3
        assert isinstance(results[0], bool)
        assert isinstance(results[1], bool)
        assert isinstance(results[2], tuple)
