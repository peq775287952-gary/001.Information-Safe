#ifndef RUNNER_RUNNER_WINDOW_H_
#define RUNNER_RUNNER_WINDOW_H_

#include "flutter_window.h"

class RunnerWindow : public FlutterWindow {
 public:
  explicit RunnerWindow(const flutter::DartProject& project)
      : FlutterWindow(project) {}
  virtual ~RunnerWindow() = default;
};

#endif
