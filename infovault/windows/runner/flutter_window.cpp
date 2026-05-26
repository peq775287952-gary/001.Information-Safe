#include "flutter_window.h"
#include <optional>

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  flutter::FlutterViewController::ViewProperties view_properties = {
      .width = static_cast<double>(frame.right - frame.left),
      .height = static_cast<double>(frame.bottom - frame.top),
  };

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      view_properties, project_);
  HWND host = flutter_controller_->GetNativeWindow()->GetNativeWindow();
  ::SetParent(host, GetHandle());
  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }
  Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                                       WPARAM const wparam,
                                       LPARAM const lparam) noexcept {
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
      flutter_controller_->ForceRedraw();
      break;
    case WM_RESIZE:
      flutter_controller_->ForceRedraw();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
