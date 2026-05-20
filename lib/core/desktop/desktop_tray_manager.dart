import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopTrayManager extends WindowListener {
  static final DesktopTrayManager instance = DesktopTrayManager._();
  DesktopTrayManager._();

  static const MethodChannel _channel = MethodChannel('com.pacey.app/tray');
  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;
    if (_initialized) return;

    // 1. Initialize window manager
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);

    // 2. Initialize native tray
    _channel.setMethodCallHandler(_handleMethodCall);
    try {
      await _channel.invokeMethod('initTray');
    } catch (e) {
      // Clean fallback if platform doesn't support system tray
      debugPrint('Failed to initialize native tray: $e');
    }

    _initialized = true;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTrayIconClick':
        await _showWindow();
        break;
      case 'onTrayMenuItemClick':
        final String? key = call.arguments as String?;
        if (key == 'show_window') {
          await _showWindow();
        } else if (key == 'exit_app') {
          await _exitApp();
        }
        break;
    }
  }

  // WindowListener methods
  @override
  void onWindowClose() async {
    final prefs = await SharedPreferences.getInstance();
    final minimizeToTray = prefs.getBool('minimizeToTray') ?? true;
    if (minimizeToTray) {
      await windowManager.hide();
    } else {
      await _exitApp();
    }
  }

  Future<void> _showWindow() async {
    final isMinimized = await windowManager.isMinimized();
    if (isMinimized) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _exitApp() async {
    try {
      await _channel.invokeMethod('destroyTray');
    } catch (e) {
      debugPrint('Failed to destroy native tray: $e');
    }
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }
}
