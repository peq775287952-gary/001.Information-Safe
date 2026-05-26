cmake_minimum_required(VERSION 3.14)
project(runner)

add_executable(${BINARY_NAME}
    "main.cpp"
    "flutter_window.cpp"
    "runner_window.cpp"
    "utils.cpp"
    "win32_window.cpp"
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_plugin)

target_compile_definitions(${BINARY_NAME} PRIVATE
    "-DAPPLICATION_ID=\"${APPLICATION_ID}\""
)

# Disable Windows macros that cause issues
add_compile_definitions(
    WIN32_LEAN_AND_MEAN
    NOMINMAX
)

# Resource file
set(RUNNER_RESOURCE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/runner.rc" "")
if(EXISTS "${RUNNER_RESOURCE_FILE}")
    target_sources(${BINARY_NAME} PRIVATE "${RUNNER_RESOURCE_FILE}")
endif()
