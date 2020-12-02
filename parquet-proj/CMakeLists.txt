cmake_minimum_required(VERSION 3.14...3.17 FATAL_ERROR)

project(parquet_proj)

set(CMAKE_CXX_STANDARD 17)

###################################################################################################
# - cmake modules ---------------------------------------------------------------------------------

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/" ${CMAKE_MODULE_PATH})

###################################################################################################
# - find arrow ------------------------------------------------------------------------------------

option(ARROW_STATIC_LIB "Build and statically link with Arrow libraries" ON)

if(ARROW_STATIC_LIB)
    message(STATUS "BUILDING ARROW")
    include(ConfigureArrow)

    if(ARROW_FOUND)
        message(STATUS "Apache Arrow found in ${ARROW_INCLUDE_DIR}")
    else()
        message(FATAL_ERROR "Apache Arrow not found, please check your settings.")
    endif(ARROW_FOUND)

    add_library(arrow STATIC IMPORTED ${ARROW_LIB})
    add_library(arrow_cuda STATIC IMPORTED ${ARROW_CUDA_LIB})
else()
    find_path(ARROW_INCLUDE_DIR "arrow"
            HINTS "$ENV{ARROW_ROOT}/include")

    find_library(ARROW_LIB "arrow"
            NAMES libarrow
            HINTS "$ENV{ARROW_ROOT}/lib" "$ENV{ARROW_ROOT}/build")

    find_library(ARROW_CUDA_LIB "arrow_cuda"
            NAMES libarrow_cuda
            HINTS "$ENV{ARROW_ROOT}/lib" "$ENV{ARROW_ROOT}/build")

    message(STATUS "ARROW: ARROW_INCLUDE_DIR set to ${ARROW_INCLUDE_DIR}")
    message(STATUS "ARROW: ARROW_LIB set to ${ARROW_LIB}")
    message(STATUS "ARROW: ARROW_CUDA_LIB set to ${ARROW_CUDA_LIB}")

    add_library(arrow SHARED IMPORTED ${ARROW_LIB})
    add_library(arrow_cuda SHARED IMPORTED ${ARROW_CUDA_LIB})
endif(ARROW_STATIC_LIB)

if(ARROW_INCLUDE_DIR AND ARROW_LIB AND ARROW_CUDA_LIB)
    set_target_properties(arrow PROPERTIES IMPORTED_LOCATION ${ARROW_LIB})
    set_target_properties(arrow_cuda PROPERTIES IMPORTED_LOCATION ${ARROW_CUDA_LIB})
endif(ARROW_INCLUDE_DIR AND ARROW_LIB AND ARROW_CUDA_LIB)

add_executable(parquet_proj main.cpp)


add_subdirectory(test)