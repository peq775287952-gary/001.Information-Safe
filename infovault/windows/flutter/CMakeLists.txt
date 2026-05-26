cmake_minimum_required(VERSION 3.14)
project(flutter_wrapper_plugin)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Ephemeral directory setup
if(NOT EXISTS "${FLUTTER_MANAGED_DIR}")
    message(FATAL_ERROR "Flutter managed directory not found: ${FLUTTER_MANAGED_DIR}")
endif()

add_library(flutter_wrapper_plugin STATIC
    "${FLUTTER_MANAGED_DIR}/cpp/flutter_wrapper.cc"
)

target_include_directories(flutter_wrapper_plugin
    PUBLIC "${FLUTTER_MANAGED_DIR}/cpp"
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../runner"
)

add_dependencies(flutter_wrapper_plugin flutter)

set_property(TARGET flutter_wrapper_plugin PROPERTY POSITION_INDEPENDENT_CODE ON)
