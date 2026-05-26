#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>
#include <windowsx.h>
#include <string>

class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
  };

  struct Size {
    unsigned int width;
    unsigned int height;
  };

  Win32Window();
  virtual ~Win32Window();

  bool Create(const std::wstring& title, Point origin, Size size);
  void Destroy();

  HWND GetHandle() const { return window_handle_; }

  void SetQuitOnClose(bool quit_on_close) { quit_on_close_ = quit_on_close; }

  RECT GetClientArea();

 protected:
  virtual bool OnCreate();
  virtual void OnDestroy();
  virtual LRESULT MessageHandler(HWND window, UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  HWND window_handle_ = nullptr;
  bool quit_on_close_ = false;

 private:
  static LRESULT CALLBACK WndProc(HWND const window, UINT const message,
                                   WPARAM const wparam,
                                   LPARAM const lparam) noexcept;

  std::wstring window_class_name_;
};

#endif
