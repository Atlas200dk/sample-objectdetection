#!/bin/bash
#
#   =======================================================================
#
# Copyright (C) 2018, Hisilicon Technologies Co., Ltd. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   1 Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#   2 Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#   3 Neither the names of the copyright holders nor the names of the
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#   =======================================================================

# ************************Variable*********************************************

script_path="$( cd "$(dirname "$0")" ; pwd -P )"

download_mode=$1
opencv_version="3.4.2"

function download_code()
{
    if [ -d ${script_path}/opencv ];then
        echo "opencv code is found..."
        return 0
    else
        if [[ ${download_mode} == "local" ]];then
            echo "WARNING: no opencv code found."
            read -p "Do you want to download from internet?(y/n, default:y)" confirm
            if [[ ${confirm}"X" != "X" && ${confirm} != "y" && ${confirm} != "Y" ]];then
                echo "ERROR: no opencv code found and no download choice, please put opencv code in ${script_path}/opencv path manually."
                return 1
            fi
        fi
    fi
    echo "Downloading opencv code..."
    opencv_download_url="https://codeload.github.com/opencv/opencv/tar.gz/${opencv_version}"
    wget -O ${script_path}/${opencv_version}.ing ${opencv_download_url} --no-check-certificate
    if [[ $? -ne 0 ]];then
        echo "ERROR: download failed, please check ${opencv_download_url} connection."
        return 1
    fi

    mv ${script_path}/${opencv_version}.ing ${script_path}/${opencv_version}
    tar -zxvf ${script_path}/${opencv_version} -C ${script_path} 1>/dev/null
    if [[ $? -ne 0 ]];then
        echo "ERROR: uncompress opencv tar.gz file failed, please check ${opencv_download_url} connection."
        return 1
    fi
    mv ${script_path}/opencv-${opencv_version} ${script_path}/opencv
    rm -rf ${script_path}/${opencv_version}
    rm -rf ${script_path}/${opencv_version}.ing
    return 0

}

function build_opencv()
{
    echo "Build opencv..."
    OPENCV_CMAKE_PARAS_HOST="g++ -DCV_HISI_MODE=HOST -DWITH_CAROTENE=OFF -DENABLE_NEON=OFF -DWITH_OPENCL=ON -DWITH_OPENCLAMDBLAS=ON -DWITH_OPENCLAMDFFT=ON -DWITH_PTHREADS_PF=ON -DBUILD_opencv_java_bindings_generator=OFF -DBUILD_JAVA=OFF"
    OPENCV_COMPILE_FLAGS="-DWITH_IPP=OFF -DWITH_OPENEXR=OFF -DBUILD_OPENEXR=OFF -DSOFTFP=ON -DBUILD_DOCS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_WITH_DEBUG_INFO=OFF -DBUILD_opencv_apps=OFF -DBUILD_opencv_contrib=OFF -DBUILD_opencv_gpu=OFF -DBUILD_opencv_nonfree=OFF -DBUILD_opencv_superres=OFF -DBUILD_opencv_ts=OFF -DWITH_CUDA=OFF -DBUILD_opencv_world=ON -DCV_HISI=ON -DBUILD_IPP_IW=OFF -DBUILD_ITT=OFF -DBUILD_PACKAGE=OFF -DWITH_IPP=OFF -DBUILD_opencv_python_bindings_generator=OFF -DCPACK_BINARY_STGZ=OFF -DCPACK_BINARY_TGZ=OFF -DCPACK_BINARY_TZ=OFF -DCPACK_SOURCE_TBZ2=OFF -DCPACK_SOURCE_TGZ=OFF -DCPACK_SOURCE_TXZ=OFF -DCPACK_SOURCE_TZ=OFF -DCV_TRACE=OFF -DWITH_CUBLAS=OFF -DWITH_CUFFT=OFF -DWITH_EIGEN=OFF -DWITH_GPHOTO2=OFF -DWITH_GSTREAMER=OFF -DWITH_GTK=OFF -DWITH_ITT=OFF -DWITH_LAPACK=OFF -DWITH_MATLAB=OFF -DWITH_NVCUVID=OFF -DWITH_V4L=OFF -DBUILD_JPEG=ON -DBUILD_ZLIB=ON -DBUILD_TIFF=ON -DBUILD_WEBP=ON -DBUILD_JASPER=ON -DBUILD_PNG=ON -DENABLE_CXX11=ON -DWITH_VTK=OFF -DWITH_1394=OFF"

    cd ${script_path}/opencv/platforms/linux/ && rm -rf build64 && mkdir build64 && cd build64 && cmake -DCMAKE_BUILD_TYPE=Release ${OPENCV_CMAKE_PARAS_HOST} -DCMAKE_INSTALL_PREFIX=../install_dir ${OPENCV_COMPILE_FLAGS} -DCMAKE_TOOLCHAIN_FILE=../gnu.toolchain.cmake ../../../ > config.log && make install > build.log
    
    if [[ $? -ne 0 ]];then
        echo "ERROR: build opencv failed, please check build.log in ${script_path}/opencv/platforms/linux/build64/"
        return 1
    fi
    
    mkdir -p ${HOME}/ascend_ddk/include/third_party/opencv
    mkdir -p ${HOME}/ascend_ddk/host/lib

    install_prefix=${script_path}/opencv/platforms/linux/install_dir
    mkdir -p ${install_prefix}

    cp -rdp ${script_path}/opencv/platforms/linux/install_dir/include/* ${HOME}/ascend_ddk/include/third_party/opencv/
    cp -rdp ${install_prefix}/lib/* ${HOME}/ascend_ddk/host/lib

    cd ${install_prefix}/lib && tar -cvf ${script_path}/opencv_lib.tar ./* >> ${script_path}/opencv/platforms/linux/build64/build.log
    cd ${script_path}
}

main()
{
    atlas_target=`grep "TARGET" ${DDK_HOME}/ddk_info | awk -F '"' '{print $4}'`
    if [[ $? -ne 0 ]];then
        echo "ERROR: can not get TARGET from ${DDK_HOME}/ddk_info, please check your env"
        return 1
    fi

    if [[ ${atlas_target} == "Atlas DK" ]];then
        exit 0
    fi

    #download code
    download_code
    if [[ $? -ne 0 ]];then
        return 1
    fi

    build_opencv

    if [[ $? -ne 0 ]];then
        return 1
    fi

    echo "Finish to Build opencv."
    exit 0
}

main
