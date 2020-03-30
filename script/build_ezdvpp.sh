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
ezdvpp_version="1.1.0"

function download_code()
{
    if [ -d ${script_path}/ezdvpp ];then
        echo "EZdvpp code if found..."
        return 0
    else
        if [[ ${download_mode} == "local" ]];then
            echo "WARNING: no ezdvpp code found."
            read -p "Do you want to download from internet?(y/n, default:y)" confirm
            if [[ ${confirm}"X" != "X" && ${confirm} != "y" && ${confirm} != "Y" ]];then
                echo "ERROR: no ezdvpp code found and no download choice, please put ezdvpp code in ${script_path}/ezdvpp path manually."
                return 1
            fi
        fi
    fi
    echo "Download ezdvpp code..."
    ezdvpp_download_url="https://github.com/Atlas200dk/sdk-ezdvpp/archive/1.1.0.tar.gz"
    wget -O ${script_path}/${ezdvpp_version}.ing ${ezdvpp_download_url} --no-check-certificate
    if [[ $? -ne 0 ]];then
        echo "ERROR: download failed, please check ${ezdvpp_download_url} connection."
        return 1
    fi

    mv ${script_path}/${ezdvpp_version}.ing ${script_path}/${ezdvpp_version}
    tar -zxvf ${script_path}/${ezdvpp_version} -C ${script_path} 1>/dev/null
    if [[ $? -ne 0 ]];then
        echo "ERROR: uncompress ezdvpp tar.gz file failed, please check ${ezdvpp_download_url} connection."
        return 1
    fi
    mv ${script_path}/sdk-ezdvpp ${script_path}/ezdvpp
    rm -rf ${script_path}/${ezdvpp_version}
    rm -rf ${script_path}/${ezdvpp_version}.ing
    return 0

}

function build_ezdvpp()
{
    echo "Build ezdvpp..."
    atlas_target=`grep "TARGET" ${DDK_HOME}/ddk_info | awk -F '"' '{print $4}'`
    if [[ $? -ne 0 ]];then
        echo "ERROR: can not get TARGET from ${DDK_HOME}/ddk_info, please check your env"
        return 1
    fi

    atlas_target=`echo ${atlas_target} | sed 's/ //g' `
     make clean mode=${atlas_target} -C ${script_path}/ezdvpp 1>/dev/null
    if [[ $? -ne 0 ]];then
        echo "ERROR: compile ezdvpp failed, please check the env."
        return 1
    fi
    make install mode=${atlas_target} -C ${script_path}/ezdvpp 1>/dev/null
    if [[ $? -ne 0 ]];then
        echo "ERROR: compile ezdvpp failed, please check the env."
        return 1
    fi
}

main()
{
    #download code
    download_code
    if [[ $? -ne 0 ]];then
        return 1
    fi

    build_ezdvpp

    if [[ $? -ne 0 ]];then
        return 1
    fi

    echo "Finish to Build ezdvpp."
    exit 0
}

main
