import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  var statusBarItem: NSStatusItem?
  var channel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    channel = FlutterMethodChannel(name: "com.pacey.app/tray", binaryMessenger: controller.engine.binaryMessenger)
    channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handle(call, result: result)
    }
    super.applicationDidFinishLaunching(notification)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initTray":
      initTray(result: result)
    case "destroyTray":
      destroyTray(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initTray(result: @escaping FlutterResult) {
    if statusBarItem == nil {
      statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
      if let button = statusBarItem?.button {
        // Use application icon as status bar icon
        if let appIcon = NSImage(named: NSImage.applicationIconName) {
          button.image = appIcon
          button.image?.size = NSSize(width: 18, height: 18)
        }
        button.action = #selector(statusBarItemClicked(_:))
        button.target = self
      }
      
      let menu = NSMenu()
      let openItem = NSMenuItem(title: "Open Pacey", action: #selector(openApp), keyEquivalent: "")
      openItem.target = self
      menu.addItem(openItem)
      
      menu.addItem(NSMenuItem.separator())
      
      let exitItem = NSMenuItem(title: "Exit", action: #selector(exitApp), keyEquivalent: "")
      exitItem.target = self
      menu.addItem(exitItem)
      
      statusBarItem?.menu = menu
    }
    result(nil)
  }

  private func destroyTray(result: @escaping FlutterResult) {
    if let item = statusBarItem {
      NSStatusBar.system.removeStatusItem(item)
      statusBarItem = nil
    }
    result(nil)
  }

  @objc func statusBarItemClicked(_ sender: AnyObject?) {
    channel?.invokeMethod("onTrayIconClick", arguments: nil)
  }

  @objc func openApp() {
    channel?.invokeMethod("onTrayMenuItemClick", arguments: "show_window")
  }

  @objc func exitApp() {
    channel?.invokeMethod("onTrayMenuItemClick", arguments: "exit_app")
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
