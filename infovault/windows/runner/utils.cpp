#include "utils.h"
#include <flutter_windows.h>
#include <io.h>
#include <iostream>
#include <shellapi.h>

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE *unused;
    if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
      _dup2(_fileno(stdout), 1);
    }
    if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
      _dup2(_fileno(stdout), 2);
    }
    std::ios::sync_with_stdio();
    FlutterDesktopResyncOutputStreams();
  }
}

std::vector<std::string> GetCommandLineArguments() {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return std::vector<std::string>();
  }

  std::vector<std::string> command_line_arguments;
  command_line_arguments.reserve(argc);

  for (int i = 0; i < argc; i++) {
    int length = ::WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, nullptr, 0,
                                        nullptr, nullptr);
    if (length == 0) {
      command_line_arguments.push_back("");
      continue;
    }

    std::string argument(length, '\0');
    int converted = ::WideCharToMultiByte(CP_UTF8, 0, argv[i], -1,
                                           argument.data(), length, nullptr,
                                           nullptr);
    if (converted == 0) {
      command_line_arguments.push_back("");
      continue;
    }

    // Remove null terminator
    argument.pop_back();
    command_line_arguments.push_back(argument);
  }

  ::LocalFree(argv);
  return command_line_arguments;
}
