#!/bin/bash
script_path="$( cd "$(dirname "$0")" ; pwd -P )"


function main()
{
    om_name=$(find ${script_path}/model/ -name "*.om")
    if [[ om_name = "" ]];then
        echo "please push your model file in sample_classification/src/model "
        return 1
    fi
    om_name=$(basename ${om_name})
    cp ${script_path}/graph.template ${script_path}/graph.config
    sed -i "s#\${MODEL_PATH}#../../src/model/${om_name}#g"  ${script_path}/graph.config
    if [ $? != 0 ];then
	echo "gengrate graph.config error !"
	return 1
    fi 
    return 0	
}
main

