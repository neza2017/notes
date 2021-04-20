#include <gtest/gtest.h>
#include "hello_cmake.h"

TEST(hello, hello){
    int x = hello_cmake(5);
    ASSERT_EQ(x,0);
}