#include "flutter_window.h"

#include <optional>
#include <memory>
#include <string>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Setup the custom tray method channel
  SetupTrayChannel();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  DestroyTray();

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Handle native Win32 tray messages
  if (message == WM_TRAYICON) {
    if (lparam == WM_LBUTTONUP) {
      if (channel_) {
        channel_->InvokeMethod("onTrayIconClick", nullptr);
      }
      return 0;
    } else if (lparam == WM_RBUTTONUP || lparam == WM_CONTEXTMENU) {
      ShowPopupMenu();
      return 0;
    }
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::SetupTrayChannel() {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "com.pacey.app/tray",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "initTray") {
          InitTray();
          result->Success();
        } else if (call.method_name() == "destroyTray") {
          DestroyTray();
          result->Success();
        } else {
          result->NotImplemented();
        }
      });
}

void FlutterWindow::InitTray() {
  if (tray_initialized_) return;

  HWND hwnd = GetNativeWindow();
  nid_ = {};
  nid_.cbSize = sizeof(nid_);
  nid_.hWnd = hwnd;
  nid_.uID = 1;
  nid_.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
  nid_.uCallbackMessage = WM_TRAYICON;

  // Try to load the app icon, fallback to default application icon
  nid_.hIcon = ::LoadIcon(::GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  if (!nid_.hIcon) {
    nid_.hIcon = ::LoadIcon(nullptr, IDI_APPLICATION);
  }

  wcscpy_s(nid_.szTip, L"Pacey");

  if (::Shell_NotifyIconW(NIM_ADD, &nid_)) {
    tray_initialized_ = true;
  }
}

void FlutterWindow::DestroyTray() {
  if (!tray_initialized_) return;

  ::Shell_NotifyIconW(NIM_DELETE, &nid_);
  tray_initialized_ = false;
}

void FlutterWindow::ShowPopupMenu() {
  HWND hwnd = GetNativeWindow();
  HMENU hMenu = ::CreatePopupMenu();
  if (hMenu) {
    ::AppendMenuW(hMenu, MF_STRING, 1, L"Open Pacey");
    ::AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    ::AppendMenuW(hMenu, MF_STRING, 2, L"Exit");

    POINT pt;
    ::GetCursorPos(&pt);
    ::SetForegroundWindow(hwnd);
    int id = ::TrackPopupMenu(hMenu, TPM_RETURNCMD | TPM_NONOTIFY, pt.x, pt.y, 0, hwnd, nullptr);
    ::DestroyMenu(hMenu);

    if (id == 1) {
      if (channel_) {
        channel_->InvokeMethod("onTrayIconClick", nullptr);
      }
    } else if (id == 2) {
      if (channel_) {
        channel_->InvokeMethod("onTrayMenuItemClick", std::make_unique<flutter::EncodableValue>("exit_app"));
      }
    }
  }
}
