# 关于 milvus-distributed 内存泄露的调查报告及解决方案

## 测试程序

`create index` 失败时发生内存泄露，测试程序 `mem_leak.cpp`
```cpp
#include <iostream>
#include <vector>
#include <cstdlib>
#include <unistd.h>
#include "segcore/collection_c.h"
#include "indexbuilder/index_c.h"

const char* idx_param=""
"params: <\n"
"  key: \"metric_type\"\n"
"  value: \"L2\"\n"
">\n"
"params: <\n"
"  key: \"dim\"\n"
"  value: \"128\"\n"
">\n"
"params: <\n"
"  key: \"SLICE_SIZE\"\n"
"  value: \"4\"\n"
">\n";
// "params: <\n"
// "  key: \"index_type\"\n"
// "  value: \"FLAT\""
// ">\n";


int main()
{
    std::vector<float> array(10000*128);
    for(int i=0;i<1000;i++){
        CIndex idx;
        auto st=CreateIndex("",idx_param,&idx);
        if(st.error_code){
            std::cout << "create index error code:" << st.error_code << std::endl; 
        }

        st=BuildFloatVecIndexWithoutIds(idx,10000*128,array.data());
        if(st.error_code){
            std::cout << "build index error code:" << st.error_code << std::endl;
            std::cout << (char*)st.error_msg << std::endl;
            std::free((void*)st.error_msg);
        }
        DeleteIndex(idx);
        if(i%100 ==0) sleep(5);
    }
    return 0;
}
```
编译命令
```bash
g++ mem_leak.cpp -o mem_leak -std=c++11 -lmilvus_indexbuilder -g -I/home/cyf/work/milvus-distributed/internal/core/output/include -L/home/cyf/work/milvus-distributed/internal/core/output/lib
```
运行 `mem_leak`，使用 `htop` 命令可以观察到 `mem_leak` 程序所占用的内存一直在上升

`create index` 则成功则无内存泄露,测试程序 `mem_leak.cpp`，运行以下程序，可以观察到程序内存稳定不变
```cpp
#include <iostream>
#include <vector>
#include <cstdlib>
#include <unistd.h>
#include "segcore/collection_c.h"
#include "indexbuilder/index_c.h"

const char* idx_param=""
"params: <\n"
"  key: \"metric_type\"\n"
"  value: \"L2\"\n"
">\n"
"params: <\n"
"  key: \"dim\"\n"
"  value: \"128\"\n"
">\n"
"params: <\n"
"  key: \"SLICE_SIZE\"\n"
"  value: \"4\"\n"
">\n"
"params: <\n"
"  key: \"index_type\"\n"
"  value: \"FLAT\""
">\n";


int main()
{
    std::vector<float> array(10000*128);
    for(int i=0;i<1000;i++){
        CIndex idx;
        auto st=CreateIndex("",idx_param,&idx);
        if(st.error_code){
            std::cout << "create index error code:" << st.error_code << std::endl; 
        }

        st=BuildFloatVecIndexWithoutIds(idx,10000*128,array.data());
        if(st.error_code){
            std::cout << "build index error code:" << st.error_code << std::endl;
            std::cout << (char*)st.error_msg << std::endl;
            std::free((void*)st.error_msg);
        }
        DeleteIndex(idx);
        if(i%100 ==0) sleep(5);
    }
    return 0;
}
```

## 原因
内存泄露是 `boost` 库 `1.65` 的 `boost::stacktrace::stacktrace()`引入的

 `create index` 失败时，`milvus_indexbuilder` 会抛出一个异常, 在异常的构造函数中调用 `boost::stacktrace::stacktrace()` 生成程序的调用堆栈

## 复现
最简单的复现程序，`stack_tracing.cpp`
```cpp
#define BOOST_STACKTRACE_USE_BACKTRACE
#include <boost/stacktrace.hpp>
#include <unistd.h>
#include <iostream>

void f1(){
    auto stack_info = boost::stacktrace::stacktrace();
    std::cout << stack_info;
}

void f2(){
    f1();
}

void f3(){
    f2();
}

void f4(){
    f3();
}

int main(){
    for(int i=0;i<1000;i++){
        f4();
        if(i%100 == 0) sleep(2);
    }
}
```
编译脚本
```bash
g++ stack_tracing.cpp -o stack_tracing -std=c++11 -ldl -lbacktrace
```
运行 `stack_tracing` ，使用  `htop` 命令可以观察到 `stack_tracing` 程序所占用的内存一直在上升

## 解决方案
<https://www.boost.org/doc/libs/develop/doc/html/stacktrace/configuration_and_build.html> `boost` 的文档里面提到这样一句话
```txt
In header only mode library could be tuned by macro. If one of the link macro from above is defined, you have to manually link with one of the libraries: 
```
`BOOST_STACKTRACE_USE_BACKTRACE` 这个宏只在头文件模式中有效，但是我们开发环境的 `boost` 是使用 `apt-get` 安装的，不是纯粹的头文件模式

把`BOOST_STACKTRACE_USE_BACKTRACE` 这个宏去掉，内存泄露就消失了，**猜测** 可能是 `boost 1.65` 的一个`bug`，际权开发机手动编译安装 `boost 1.71` 就没有内存泄露

## 验证
最简单的验证程序，`stack_tracing.cpp`
```cpp
// #define BOOST_STACKTRACE_USE_BACKTRACE
#include <boost/stacktrace.hpp>
#include <unistd.h>
#include <iostream>

void f1(){
    auto stack_info = boost::stacktrace::stacktrace();
    std::cout << stack_info;
}

void f2(){
    f1();
}

void f3(){
    f2();
}

void f4(){
    f3();
}

int main(){
    for(int i=0;i<1000;i++){
        f4();
        if(i%100 == 0) sleep(2);
    }
}
```
运行 `stack_tracing` ，使用  `htop` 命令可以观察到 `stack_tracing` 程序所占用的内存稳定不变

在 `milvus-distributed`项目中把 `milvus-distributed/internal/core/src/utils/EasyAssert.cpp` 文件第 `14` 行的 `#define BOOST_STACKTRACE_USE_BACKTRACE` 注释掉，重新编译生成 `libmilvus_indexbuilder.so`

再重新重新运行 `create_index`失败含内存泄露的 `mem_leak`，`htop` 可以观察程序内存占用不在上升 

## 具体工作
麻烦桂霖把 `milvus-distributed/internal/core/src/utils/EasyAssert.cpp` 文件第 `14` 行的 `#define BOOST_STACKTRACE_USE_BACKTRACE` 注释掉

## 解答
Q: 为什么 `r0.2` 那个版本上没有触发这个内存泄露呢？

A: `r0.2` 只支持在手动调用`create index`，传入的`index param` 确保 `crete index` 成功，所以没有触发 