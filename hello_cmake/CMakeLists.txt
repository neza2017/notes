cmake_minimum_required(VERSION 3.14...3.17 FATAL_ERROR)
project(hello_cmake)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(hello_cmake STATIC)
include_directories( ${PROJECT_SOURCE_DIR})

target_sources(hello_cmake PUBLIC
    hello_cmake.cpp
    )

add_subdirectory(tests)