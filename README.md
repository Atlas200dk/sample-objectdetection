EN|[CN](README_cn.md)

# Object Detection<a name="EN-US_TOPIC_0167609448"></a>

The object detection application runs on the Atlas 200 DK or the AI acceleration cloud server and implements the inference function by using Faster R-CNN object detection network.

## Prerequisites<a name="en-us_topic_0182554604_section137245294533"></a>

Before using an open source application, ensure that:

-   Mind Studio  has been installed.
-   The Atlas 200 DK developer board has been connected to  Mind Studio, the cross compiler has been installed, the SD card has been prepared, and basic information has been configured.

## Software Preparation<a name="en-us_topic_0182554604_section181111827718"></a>

Before running the application, obtain the source code package and configure the environment as follows.

1.  Obtain the source code package.

    Download all the code in the sample-objectdetection repository at  [https://github.com/Ascend/sample-objectdetection](https://github.com/Ascend/sample-objectdetection)  to any directory on Ubuntu Server where  Mind Studio  is located as the  Mind Studio  installation user, for example,  _/home/ascend/sample-objectdetection_.

2.  <a name="en-us_topic_0182554604_li2074865610364"></a>Obtain the source network model required by the application.

    Obtain the source network model and its weight file used in the application by referring to  [Table 1](#en-us_topic_0182554604_table19942111763710), and save them to any directory on the Ubuntu server where  Mind Studio  is located (for example,  **$HOME/ascend/models/faster\_rcnn**).

    **Table  1**  Models used in the detection network application

    <a name="en-us_topic_0182554604_table19942111763710"></a>
    <table><thead align="left"><tr id="en-us_topic_0182554604_row611318123710"><th class="cellrowborder" valign="top" width="11.959999999999999%" id="mcps1.2.4.1.1"><p id="en-us_topic_0182554604_p81141820376"><a name="en-us_topic_0182554604_p81141820376"></a><a name="en-us_topic_0182554604_p81141820376"></a>Model Name</p>
    </th>
    <th class="cellrowborder" valign="top" width="8.07%" id="mcps1.2.4.1.2"><p id="en-us_topic_0182554604_p13181823711"><a name="en-us_topic_0182554604_p13181823711"></a><a name="en-us_topic_0182554604_p13181823711"></a>Model Description</p>
    </th>
    <th class="cellrowborder" valign="top" width="79.97%" id="mcps1.2.4.1.3"><p id="en-us_topic_0182554604_p1717182378"><a name="en-us_topic_0182554604_p1717182378"></a><a name="en-us_topic_0182554604_p1717182378"></a>Model Download Path</p>
    </th>
    </tr>
    </thead>
    <tbody><tr id="en-us_topic_0182554604_row1119187377"><td class="cellrowborder" valign="top" width="11.959999999999999%" headers="mcps1.2.4.1.1 "><p id="en-us_topic_0182554604_p7118189378"><a name="en-us_topic_0182554604_p7118189378"></a><a name="en-us_topic_0182554604_p7118189378"></a>faster_rcnn</p>
    </td>
    <td class="cellrowborder" valign="top" width="8.07%" headers="mcps1.2.4.1.2 "><p id="en-us_topic_0182554604_p151818183718"><a name="en-us_topic_0182554604_p151818183718"></a><a name="en-us_topic_0182554604_p151818183718"></a>Network model for object detection.</p>
    <p id="en-us_topic_0182554604_p8394945195815"><a name="en-us_topic_0182554604_p8394945195815"></a><a name="en-us_topic_0182554604_p8394945195815"></a>It is a Faster R-CNN model based on Caffe.</p>
    </td>
    <td class="cellrowborder" valign="top" width="79.97%" headers="mcps1.2.4.1.3 "><p id="en-us_topic_0182554604_p611318163718"><a name="en-us_topic_0182554604_p611318163718"></a><a name="en-us_topic_0182554604_p611318163718"></a>Download the source network model file and its weight file by referring to<strong id="en-us_topic_0182554604_b17606155113121"><a name="en-us_topic_0182554604_b17606155113121"></a><a name="en-us_topic_0182554604_b17606155113121"></a> README.md</strong> in <a href="https://github.com/Ascend/models/tree/master/computer_vision/object_detect/faster_rcnn" target="_blank" rel="noopener noreferrer">https://github.com/Ascend/models/tree/master/computer_vision/object_detect/faster_rcnn</a>.</p>
    </td>
    </tr>
    </tbody>
    </table>

3.  Convert the source network model to a Da Vinci model.
    1.  Choose  **Tool \> Convert Model**  from the main menu of  Mind Studio. The **Convert Model**  page is displayed.
    2.  On the **Convert Model**  page, set **Model File**  and  **Weight File**  to the model file and weight file downloaded in  [2](#en-us_topic_0182554604_li2074865610364), respectively.
        -   Set  **Model Name**  to the model name in  [Table 1](#en-us_topic_0182554604_table19942111763710):  **faster\_rcnn**.
        -   Retain default values for other parameters.

            **Figure  1**  faster\_rcnn model conversion configuration<a name="en-us_topic_0182554604_fig79252510407"></a>  
            ![](doc/source/img/faster_rcnn-model-conversion-configuration.jpg "faster_rcnn-model-conversion-configuration")


    3.  Click  **OK**  to start model conversion.

        After successful conversion, a .om Da Vinci model file is generated in the  **$HOME/tools/che/model-zoo/my-model/fast\_rcnn**  directory.

4.  Log in to Ubuntu Server where  Mind Studio  is located as the  Mind Studio  installation user and set the environment variable  **DDK\_HOME**.

    **vim \~/.bashrc**

    Run the following commands to add the environment variables  **DDK\_HOME**  and  **LD\_LIBRARY\_PATH**  to the last line:

    **export DDK\_HOME=/home/XXX/tools/che/ddk/ddk**

    **export LD\_LIBRARY\_PATH=$DDK\_HOME/uihost/lib**

    >![](public_sys-resources/icon-note.gif) **NOTE:**   
    >-   **XXX**  indicates the  Mind Studio  installation user, and  **/home/XXX/tools**  indicates the default installation path of the DDK.  
    >-   If the environment variables have been added, skip this step.  

    Enter  **:wq!**  to save and exit.

    Run the following command for the environment variable to take effect:

    **source \~/.bashrc**


## Deployment<a name="en-us_topic_0182554604_section3723145213347"></a>

1.  Access the root directory where the cvnetworkverify application code is located as the  Mind Studio  installation user, for example,  **_/home/ascend/sample-objectdetection_**.
2.  Run the deployment script to prepare the project environment, including compiling and deploying the ascenddk public library and application.

    bash deploy.sh  _host\_ip_ _model\_mode_

    -   _host\_ip_: For the Atlas 200 DK developer board, this parameter indicates the IP address of the developer board. For the AI acceleration cloud server, this parameter indicates the IP address of the host.
    -   _model\_mode_  indicates the deployment mode of the model file. The default setting is  **internet**.
        -   **local**: If the Ubuntu system where  Mind Studio  is located is not connected to the network, use the local mode. In this case, download the dependent common code library ezdvpp to the  **sample-objectdetection/script**  directory by referring to the  [Downloading Dependent Code Library](#en-us_topic_0182554604_section92241245122511).
        -   **internet**: Indicates the online deployment mode. If the Ubuntu system where  Mind Studio  is located is connected to the network, use the Internet mode. In this case, download the dependent code library ezdvpp online.


    Example command:

    **bash deploy.sh 192.168.1.2**

3.  Upload the generated Da Vinci offline model and images to be inferred to the directory of the  **HwHiAiUser**  user on the host. For details, see  [Table 1](#en-us_topic_0182554604_table19942111763710).

    For example, upload the model file  **faster\_rcnn.om**  to the  **/home/HwHiAiUser/models**  directory on the host.

    The image requirements are as follows:

    -   Format: JPG, PNG, and BMP.
    -   Width of the input image: the value is an integer ranging from 16px to 4096px.
    -   Height of the input image: the value is an integer ranging from 16px to 4096px.


## Running<a name="en-us_topic_0182554604_section87121843104920"></a>

1.  Log in to the Host as the  **HwHiAiUser**  user in SSH mode on Ubuntu Server where  Mind Studio  is located.

    **ssh HwHiAiUser@**_host\_ip_

    For the Atlas 200 DK, the default value of  _**host\_ip**_  is  **192.168.1.2**  \(USB connection mode\) or  **192.168.0.2**  \(NIC connection mode\).

    For the AI acceleration cloud server,  _**host\_ip**_  indicates the IP address of the server where  Mind Studio  is located.

2.  Go to the path of the executable file of object detection application.

    **cd \~/HIAI\_PROJECTS/ascend\_workspace/objectdetection/out**

3.  Run the application.

    Run the  **run\_object\_detection\_faster\_rcnn.py**  script to save the images which are generated by inference to the specified path.

    Example command:

    **python3 run\_object\_detection\_faster\_rcnn.py -m  _\~/models/faster\_rcnn.om_  -w  _800_  -h  _600_  -i**

    **_./example.jpg_ -o  _./out_  -c  _21_**

    -   **-m/--model\_path**: offline model path
    -   **-w/model\_width**: width of the input image of a model. The value is an integer ranging from 16 to 4096.
    -   **-h/model\_height**: height of the input image of a model. The value is an integer ranging from 16 to 4096.
    -   **-i/input\_path**: directory or path of the input image. You can enter multiple paths.
    -   **-o/output\_path**: directory for storing output images. The default setting is the current directory.
    -   **-c/output\_categories**: number of Faster R-CNN detection categories \(including the background\). The value is an integer ranging from 2 to 32. The default value is  **21**.

    For other parameters, run the  **python3 run\_object\_detection\_faster\_rcnn.py --help**  command. For details, see the help information.


## Downloading Dependent Code Library<a name="en-us_topic_0182554604_section92241245122511"></a>

Download the dependent software libraries to the  **sample-objectdetection/script**  directory.

**Table  2**  Download the dependent software library

<a name="en-us_topic_0182554604_table6701646132617"></a>
<table><thead align="left"><tr id="en-us_topic_0182554604_row177421045163614"><th class="cellrowborder" valign="top" width="33.33333333333333%" id="mcps1.2.4.1.1"><p id="en-us_topic_0182554604_p574264511368"><a name="en-us_topic_0182554604_p574264511368"></a><a name="en-us_topic_0182554604_p574264511368"></a>Module Name</p>
</th>
<th class="cellrowborder" valign="top" width="33.33333333333333%" id="mcps1.2.4.1.2"><p id="en-us_topic_0182554604_p1474224573615"><a name="en-us_topic_0182554604_p1474224573615"></a><a name="en-us_topic_0182554604_p1474224573615"></a>Module Description</p>
</th>
<th class="cellrowborder" valign="top" width="33.33333333333333%" id="mcps1.2.4.1.3"><p id="en-us_topic_0182554604_p1174264533610"><a name="en-us_topic_0182554604_p1174264533610"></a><a name="en-us_topic_0182554604_p1174264533610"></a>Download Address</p>
</th>
</tr>
</thead>
<tbody><tr id="en-us_topic_0182554604_row20743104593620"><td class="cellrowborder" valign="top" width="33.33333333333333%" headers="mcps1.2.4.1.1 "><p id="en-us_topic_0182554604_p19743145183614"><a name="en-us_topic_0182554604_p19743145183614"></a><a name="en-us_topic_0182554604_p19743145183614"></a>EZDVPP</p>
</td>
<td class="cellrowborder" valign="top" width="33.33333333333333%" headers="mcps1.2.4.1.2 "><p id="en-us_topic_0182554604_p11743164543616"><a name="en-us_topic_0182554604_p11743164543616"></a><a name="en-us_topic_0182554604_p11743164543616"></a>Encapsulates the DVPP interface and provides image and video processing capabilities, such as color gamut conversion and image / video conversion</p>
</td>
<td class="cellrowborder" valign="top" width="33.33333333333333%" headers="mcps1.2.4.1.3 "><p id="en-us_topic_0182554604_p87434456368"><a name="en-us_topic_0182554604_p87434456368"></a><a name="en-us_topic_0182554604_p87434456368"></a><a href="https://github.com/Ascend/sdk-ezdvpp" target="_blank" rel="noopener noreferrer">https://github.com/Ascend/sdk-ezdvpp</a></p>
<p id="en-us_topic_0182554604_p4743154512368"><a name="en-us_topic_0182554604_p4743154512368"></a><a name="en-us_topic_0182554604_p4743154512368"></a>After the download, keep the folder name <span class="filepath" id="en-us_topic_0182554604_filepath17433454366"><a name="en-us_topic_0182554604_filepath17433454366"></a><a name="en-us_topic_0182554604_filepath17433454366"></a><b>ezdvpp</b></span>.</p>
</td>
</tr>
</tbody>
</table>

