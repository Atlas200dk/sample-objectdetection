#!/bin/bash

script_path="$( cd "$(dirname ${BASH_SOURCE})" ; pwd -P )"
remote_host=$1
ezdvpp_version="1.2.0"
DEVICE_LIB_PATH="${HOME}/ascend_ddk/device/lib"

. ${script_path}/func_util.sh
function download_code()
{
    #检测本地有没有代码，没有就下载
    if [ -d ${script_path}/ezdvpp ];then
        echo "EZdvpp code if found..."
        return 0
    else
        echo "Download ezdvpp code..."
        ezdvpp_download_url="https://gitee.com/Atlas200DK/sdk-ezdvpp/repository/archive/1.2.0?format=tar.gz"
        wget -O ${script_path}/${ezdvpp_version}.ing ${ezdvpp_download_url} --no-check-certificate 1>/dev/null 2>&1
        if [[ $? -ne 0 ]];then
            echo "ERROR: download failed, please check ${ezdvpp_download_url} connection."
            return 1
        fi
    fi

    mv ${script_path}/${ezdvpp_version}.ing ${script_path}/${ezdvpp_version}
    tar -zxvf ${script_path}/${ezdvpp_version} -C ${script_path} 1>/dev/null
    if [[ $? -ne 0 ]];then
        echo "ERROR: uncompress ezdvpp tar.gz file failed, please check ${ezdvpp_download_url} connection."
        return 1
    fi
    mv ${script_path}/sdk-ezdvpp ${script_path}/ezdvpp
    rm -rf ${script_path}/${ezdvpp_version}
    return 0
}

function build_ezdvpp()
{
    echo "Build ezdvpp..."
    make clean -C ${script_path}/ezdvpp 1>/dev/null
    if [[ $? -ne 0 ]];then
        echo "ERROR: compile ezdvpp failed, please check the env."
        return 1
    fi

    make install -C ${script_path}/ezdvpp 1>/dev/null
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
		
    echo "Start to deploy ezdvpp"
    upload_file "${DEVICE_LIB_PATH}/libascend_ezdvpp.so" "~/HIAI_PROJECTS/ascend_lib"
    if [ $? -ne 0 ];then
        return 1
    fi
    echo "Finish to deploy ezdvpp"

    return 0
}
main
