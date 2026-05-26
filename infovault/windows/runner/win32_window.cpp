#include "win32_window.h"
#include <flutter_windows.h>
#include <dwmapi.h>
#include <string>

Win32Window::Win32Window() : window_handle_(nullptr) {}

Win32Window::~Win32Window() {
  Destroy();
}

bool Win32Window::Create(const std::wstring& title, Point origin, Size size) {
  Destroy();

  window_class_name_ = L"FLUTTER_RUNNER_WIN32_WINDOW";

  WNDCLASS window_class = {};
  window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class.lpszClassName = window_class_name_.c_str();
  window_class.style = CS_HREDRAW | CS_VREDRAW;
  window_class.cbClsExtra = 0;
  window_class.cbWndExtra = 0;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.hIcon = nullptr;
  window_class.hbrBackground = nullptr;
  window_class.lpszMenuName = nullptr;
  window_class.lpfnWndProc = WndProc;

  if (!RegisterClass(&window_class)) {
    return false;
  }

  DWORD style = WS_OVERLAPPEDWINDOW | WS_VISIBLE;
  DWORD ex_style = WS_EX_APPWINDOW;

  RECT rect = {static_cast<LONG>(origin.x), static_cast<LONG>(origin.y),
               static_cast<LONG>(origin.x + size.width),
               static_cast<LONG>(origin.y + size.height)};

  AdjustWindowRectEx(&rect, style, FALSE, ex_style);

  HWND window = CreateWindowEx(
      ex_style, window_class_name_.c_str(), title.c_str(), style,
      rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top,
      nullptr, nullptr, GetModuleHandle(nullptr), this);

  if (!window) {
    return false;
  }

  window_handle_ = window;
  return true;
}

void Win32Window::Destroy() {
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  UnregisterClass(window_class_name_.c_str(), nullptr);
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

bool Win32Window::OnCreate() {
  return true;
}

void Win32Window::OnDestroy() {}

LRESULT Win32Window::MessageHandler(HWND hwnd, UINT const message,
                                     WPARAM const wparam,
                                     LPARAM const lparam) noexcept {
  return DefWindowProc(hwnd, message, wparam, lparam);
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                       UINT const message,
                                       WPARAM const wparam,
                                       LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));
    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    EnableChildWindowDpiMessage(window);
    return that->OnCreate() ? TRUE : FALSE;
  }

  auto that = reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
  if (that != nullptr) {
    LRESULT result = that->MessageHandler(window, message, wparam, lparam);
    if (message == WM_DESTROY) {
      that->window_handle_ = nullptr;
      that->OnDestroy();
      if (that->quit_on_close_) {
        PostQuitMessage(0);
      }
    }
    return result;
  }

  return DefWindowProc(window, message, wparam, lparam);
}
