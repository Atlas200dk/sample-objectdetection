# Copyright (c) Huawei Technologies Co., Ltd. 2019. All rights reserved.

# CMake lowest version requirement
cmake_minimum_required(VERSION 3.5.1)

# project information
project(sample_objectdetection)

# Compile options
add_compile_options(-std=c++11)

# Specify target generation path
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY  "../../outputs")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY  "../../outputs")
set(CMAKE_INSTALL_PREFIX "../../../run")
set(CMAKE_OUTPUT_DIR "out")


set(CMAKE_CXX_FLAGS_RELEASE "-fPIC -O2 -Wall")

#execute_process(COMMAND bash ../../../script/deploy.sh RESULT_VARIABLE ret)
#IF(${ret})
#   message(FATAL_ERROR "some error occured!")
#ENDIF(${ret})


# Header path
include_directories(
.
$ENV{DDK_PATH}/include/inc/
$ENV{DDK_PATH}/include/third_party/protobuf/include
$ENV{DDK_PATH}/include/third_party/cereal/include
$ENV{DDK_PATH}/include/libc_sec/include
$ENV{HOME}/ascend_ddk/include
$ENV{DDK_PATH}/include/third_party/opencv/include
common general_image general_inference general_post
)

if(type STREQUAL host)
    if(target STREQUAL "RC")
        add_compile_options(-DIS_RC)
    endif()

    # add host lib path
    link_directories($ENV{NPU_HOST_LIB} $ENV{HOME}/ascend_ddk/host/lib /home/HwHiAiUser/HIAI_PROJECTS/ascend_lib $ENV{HOME}/ascend_ddk/device/lib)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

    add_executable(main Main.cpp)
    add_library(Host SHARED general_image/general_image.cpp general_post/general_post.cpp)


    if(target STREQUAL "RC")
        target_link_libraries(main matrixdaemon mmpa pthread dl rt)
        target_link_libraries(Host matrixdaemon hiai_common hiai_common media_mini opencv_world)
    else()
        target_link_libraries(main matrix mmpa pthread dl rt)
        target_link_libraries(Host matrix hiai_common)
    endif()

    install(TARGETS main Host DESTINATION ${CMAKE_OUTPUT_DIR})
    install(FILES run_object_detection_faster_rcnn.py DESTINATION ${CMAKE_OUTPUT_DIR})
else()
    add_compile_options(-DCPU_ONLY)

    # add device lib path
    link_directories($ENV{NPU_DEV_LIB} $ENV{HOME}/ascend_ddk/host/lib /home/HwHiAiUser/HIAI_PROJECTS/ascend_lib $ENV{HOME}/ascend_ddk/device/lib)

    add_library(Device SHARED general_inference/general_inference.cpp)

    if(target STREQUAL "RC")
        target_link_libraries(Device Dvpp_api Dvpp_jpeg_decoder Dvpp_jpeg_encoder Dvpp_vpc idedaemon hiai_common media_mini  ascend_ezdvpp)
    else()
        target_link_libraries(Device Dvpp_api Dvpp_jpeg_decoder Dvpp_jpeg_encoder Dvpp_vpc idedaemon)
    endif()

    install(TARGETS Device DESTINATION ${CMAKE_OUTPUT_DIR})
endif()
