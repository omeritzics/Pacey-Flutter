import 'dart:io';

class DesktopStartupManager {
  static Future<void> setEnabled(bool enabled) async {
    if (Platform.isLinux) {
      await _setLinuxEnabled(enabled);
    } else if (Platform.isWindows) {
      await _setWindowsEnabled(enabled);
    } else if (Platform.isMacOS) {
      await _setMacOSEnabled(enabled);
    }
  }

  static Future<bool> isEnabled() async {
    if (Platform.isLinux) {
      return await _isLinuxEnabled();
    } else if (Platform.isWindows) {
      return await _isWindowsEnabled();
    } else if (Platform.isMacOS) {
      return await _isMacOSEnabled();
    }
    return false;
  }

  // Linux implementation: Create/delete autostart .desktop file
  static Future<void> _setLinuxEnabled(bool enabled) async {
    final home = Platform.environment['HOME'];
    if (home == null) return;
    final autostartDir = Directory('$home/.config/autostart');
    if (!await autostartDir.exists()) {
      await autostartDir.create(recursive: true);
    }
    final file = File('${autostartDir.path}/pacey.desktop');
    if (enabled) {
      final execPath = Platform.resolvedExecutable;
      final content = '''[Desktop Entry]
Type=Application
Exec=$execPath
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Pacey
Comment=Start Pacey on Startup
''';
      await file.writeAsString(content);
    } else {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  static Future<bool> _isLinuxEnabled() async {
    final home = Platform.environment['HOME'];
    if (home == null) return false;
    final file = File('$home/.config/autostart/pacey.desktop');
    return await file.exists();
  }

  // Windows implementation: Create/delete startup batch file
  static Future<void> _setWindowsEnabled(bool enabled) async {
    final appData = Platform.environment['APPDATA'];
    if (appData == null) return;
    final startupDir = Directory('$appData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup');
    if (!await startupDir.exists()) {
      await startupDir.create(recursive: true);
    }
    final file = File('${startupDir.path}\\pacey_startup.bat');
    if (enabled) {
      final execPath = Platform.resolvedExecutable;
      final content = '@echo off\r\nstart "" "$execPath"\r\n';
      await file.writeAsString(content);
    } else {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  static Future<bool> _isWindowsEnabled() async {
    final appData = Platform.environment['APPDATA'];
    if (appData == null) return false;
    final file = File('$appData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\pacey_startup.bat');
    return await file.exists();
  }

  // macOS implementation: Create/delete LaunchAgent plist file
  static Future<void> _setMacOSEnabled(bool enabled) async {
    final home = Platform.environment['HOME'];
    if (home == null) return;
    final agentsDir = Directory('$home/Library/LaunchAgents');
    if (!await agentsDir.exists()) {
      await agentsDir.create(recursive: true);
    }
    final file = File('${agentsDir.path}/com.omeritzics.pacey.plist');
    if (enabled) {
      final execPath = Platform.resolvedExecutable;
      final content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.omeritzics.pacey</string>
    <key>ProgramArguments</key>
    <array>
        <string>$execPath</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
''';
      await file.writeAsString(content);
    } else {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  static Future<bool> _isMacOSEnabled() async {
    final home = Platform.environment['HOME'];
    if (home == null) return false;
    final file = File('$home/Library/LaunchAgents/com.omeritzics.pacey.plist');
    return await file.exists();
  }
}
