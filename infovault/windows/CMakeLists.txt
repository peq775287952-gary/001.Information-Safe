cmake_minimum_required(VERSION 3.14)
project(infovault LANGUAGES CXX)

set(BINARY_NAME "infovault")
set(APPLICATION_ID "com.infovault.infovault")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_CXX_EXTENSIONS NO)

add_subdirectory(flutter)
add_subdirectory(runner)

# Application bundle
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "." COMPONENT Runtime)

# Flutter library
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "." COMPONENT Runtime)

# Plugin libraries
install(DIRECTORY "${FLUTTER_PLUGIN_DIR}/" DESTINATION "." COMPONENT Runtime
    FILES_MATCHING
    PATTERN "*.dll"
)
