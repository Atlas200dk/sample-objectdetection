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

# ************************parse remote port****************************************
# Description:  parse remote port
# ******************************************************************************
function parse_remote_port()
{
    remote_port=`grep HOST_PORT ~/ide_daemon/ide_daemon.cfg | awk -F '=' '{print $2}'`

    if [[ ${remote_port}"X" == "X" ]];then
        remote_port="22118"
    fi
}

# ************************check remote file****************************************
# Description:  upload a file
# $1: remote file(relative ~/xxxxx)
# ******************************************************************************
function check_remote_file()
{
    filePath=$1
    if [ ! -n ${filePath} ];then
        return 1
    fi
    ret=`IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "wc -l ${filePath}"`
    if [[ $? -ne 0 ]];then
        return 1
    fi

    return 0
}


# ************************uplooad file****************************************
# Description:  upload a file
# $1: local file(absolute)
# $2: remote file path
# ******************************************************************************
function upload_file()
{
    local_file=$1
    remote_path=$2

    file_name=`basename ${local_file}`
    remote_file="${remote_path}/${file_name}"

    #check remote path
    check_remote_file ${remote_file}

    #check whether overwrite remote file
    if [[ $? -eq 0 ]];then
        if [[ ${is_overwrite} == "false" ]];then
            echo "${remote_file} already exists, skip to upload it."
            return 0
        else
            ret=`IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "rm ${remote_file}"`
            if [[ $? -ne 0 ]];then
                echo "ERROR: delete ${remote_host}:${remote_file} failed, please check /var/log/syslog for details."
                return 1
            fi
        fi
    fi

    ret=`IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "mkdir -p ${remote_path}"`
    if [[ $? -ne 0 ]];then
        echo "ERROR: mkdir ${remote_host}:${remote_path} failed, please check /var/log/syslog for details."
        return 1
    fi

    #copy to remote path
    ret=`IDE-daemon-client --host ${remote_host}:${remote_port} --sync ${local_file} ${remote_path}`
    if [[ $? -ne 0 ]];then
        echo "ERROR: sync ${local_file} to ${remote_host}:${remote_path} failed, please check /var/log/syslog for details."
        return 1
    fi
    return 0
}

# ************************uplooad tar.gz file****************************************
# Description:  upload a file
# $1: local file(absolute)
# $2: remote path
# $3: is_uncompress(true/false, default:true)
# ******************************************************************************
function upload_tar_file()
{
    local_file=$1
    remote_path=$2

    file_name=`basename ${local_file}`
    remote_file="${remote_path}/${file_name}"

    upload_file ${local_file} ${remote_path}
    if [[ $? -ne 0 ]];then
        return 1
    fi

    #uncompress tar.gz file
    if [[ ${is_uncompress}"X" != "falseX" ]];then
        ret=`IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "tar -xvf ${remote_file} -C ${remote_path}/"`
        if [[ $? -ne 0 ]];then
            echo "ERROR: uncompress ${remote_host}:${remote_file} failed, please check /var/log/syslog for details."
            return 1
        fi

        ret=`IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "rm ${remote_file}"`
        if [[ $? -ne 0 ]];then
            echo "ERROR: delete ${remote_host}:${remote_file} failed, please check /var/log/syslog for details."
            return 1
        fi
    fi
    return 0

}

# ************************uplooad path****************************************
# Description:  upload a file
# $1: local path(absolute)
# $2: remote path
# $3: ignore_local_path(true/false, default=false)
#    #${local_path}
#    #      |-----path1
#    #              |-----path11
#    #                        |----file1
#    #      |-----path2
#    #              |-----file2
#    #true: upload file1 to ${remote_path}/file1
#    #      upload file2 to ${remote_path}/file2
#    #false/empty: upload file1 upload to ${remote_path}/path1/path11/file1
#    #             upload file2 to ${remote_path}/path2/file2
# $4: is_uncompress(true/fase, default:true)
# ******************************************************************************
function upload_path()
{
    local_path=$1
    remote_supper_path=$2
    ignore_local_path=$3
    is_uncompress=$4

    file_list=`find ${local_path} -name "*"`
    for file in ${file_list}
    do
        if [[ -d ${file} ]];then
            continue
        fi
        file_extension="${file##*.}"
        
        if [[ ${ignore_local_path}"X" == "trueX" ]];then
            remote_file_path=${remote_supper_path}
        else
            remote_file=`echo ${file} | sed "s#${local_path}#${remote_supper_path}#g"`
            remote_file_path=`dirname ${remote_file}`
        fi

        if [[ ${file_extension} == "tar" ]];then
            upload_tar_file ${file} ${remote_file_path} ${is_uncompress}
            if [[ $? -ne 0 ]];then
                return 1
            fi
        else
            upload_file ${file} ${remote_file_path}
            if [[ $? -ne 0 ]];then
                return 1
            fi
        fi
    done
    
    return 0
}

# ************************deploy app libs ***************************************
# Description:  upload a file
# $1: app_name
# $2: app path(absolute)
# $4: remote_host(host ip)
# ******************************************************************************
function deploy_app_lib_path()
{
    app_name=$1
    app_path=$2
    remote_host=$3
    
    iRet=`IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "rm -rf ~/HIAI_PROJECTS/ascend_workspace/${app_name}/out"`
    if [[ $? -ne 0 ]];then
        echo "ERROR: delete ${remote_host}:./HIAI_PROJECTS/ascend_workspace/${app_name}/out/* failed, please check /var/log/syslog for details."
        return 1
    fi

    upload_path ${app_path}/${app_name}/out "~/HIAI_PROJECTS/ascend_workspace/${app_name}/out"
    if [[ $? -ne 0 ]];then
        return 1
    fi
    iRet=`IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "chmod +x ~/HIAI_PROJECTS/ascend_workspace/${app_name}/out/ascend_${app_name}"`
    if [[ $? -ne 0 ]];then
        echo "ERROR: change excution mode ${remote_host}:./HIAI_PROJECTS/ascend_workspace/${app_name}/out/* failed, please check /var/log/syslog for details."
        return 1
    fi
}
