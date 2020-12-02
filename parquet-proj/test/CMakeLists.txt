add_executable(parquet_test
        test_hello.cpp
        )

include(FetchContent)
FetchContent_Declare(googletest
        URL "https://github.com/google/googletest/archive/release-1.10.0.tar.gz")
set(BUILD_GMOCK CACHE BOOL OFF)
set(INSTALL_GTEST CACHE BOOL OFF)
FetchContent_MakeAvailable(googletest)

target_link_libraries(parquet_test
        gtest_main
        )

# Defines `gtest_discover_tests()`.
#include(GoogleTest)
#gtest_discover_tests(milvusd_test)