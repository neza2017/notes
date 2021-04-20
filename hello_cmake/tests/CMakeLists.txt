add_executable(hello_cmake_test
    hello_cmake_test.cpp)

include(FetchContent)
FetchContent_Declare(googletest
        URL "https://github.com/google/googletest/archive/release-1.10.0.tar.gz")
set(BUILD_GMOCK CACHE BOOL OFF)
set(INSTALL_GTEST CACHE BOOL OFF)
FetchContent_MakeAvailable(googletest)

target_link_libraries(hello_cmake_test
        gtest_main
        hello_cmake
)