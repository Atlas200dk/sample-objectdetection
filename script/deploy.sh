#!/bin/bash
script_path="$( cd "$(dirname "$0")" ; pwd -P )"
app_path="${script_path}/../src"

. ${script_path}/func_util.sh

function build_common()
{
    echo "build common lib..."
    if [ ! -d "${HOME}/ascend_ddk" ];then
        mkdir $HOME/ascend_ddk
        if [[ $? -ne 0 ]];then
            echo "ERROR: Execute mkdir command failed, Please check your environment"
            return 1
        fi
    fi
    bash ${script_path}/build_ezdvpp.sh ${remote_host}
    if [ $? -ne 0 ];then
        echo "ERROR: Failed to deploy ezdvpp"
        return 1
    fi
    return 0
}

check_param_configure()
{
    for i in `cat ${app_path}/param_configure.conf | awk -F'[ =]+' '{print $2}'`
    do
        if [[ ${i} = "" ]];then
            echo "please check your param_configure.conf to make sure that each parameter has a value"
            return 1
        fi
    done 

    #get and check format of remost_host ip
    check_remote_host
    if [ $? -ne 0 ];then
		return 1
    fi 

}


function main()
{
    check_param_configure
    if [ $? -ne 0 ];then
        return 1
    fi
    
    build_common
    if [ $? -ne 0 ];then
        echo "ERROR: Failed to deploy common lib"
        return 1
    fi
	
	echo "Modify param information in graph.config..."
    count=0
	for om_name in $(find ${script_path}/ -name "*.om");do
		let count++
		if [ $count -ge 1 ];then
			break
		fi
    done
    
    if [ $count -eq 0 ];then
        echo "please push your model file in sample_classification/script "
        return 1
    fi
   
   
    om_name=$(basename ${om_name})
    cp ${script_path}/graph.template ${app_path}/graph.config
    sed -i "s#\${MODEL_PATH}#../../script/${om_name}#g"  ${app_path}/graph.config
    if [ $? != 0 ];then
		echo "gengrate graph.config error !"
		return 1
    fi 
    return 0	
}
main

