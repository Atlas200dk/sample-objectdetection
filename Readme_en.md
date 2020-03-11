EN|[CN](Readme.md)

# Object Detection<a name="ZH-CN_TOPIC_0208837806"></a>

The object detection application runs on the Atlas 200 DK or the AI acceleration cloud server and implements the inference function by using Faster R-CNN object detection network.


## Prerequisites<a name="zh-cn_topic_0203223280_section137245294533"></a>

Before using an open source application, ensure that:

-   **Mind Studio**  has been installed.
-   The Atlas 200 DK developer board has been connected to  **Mind Studio**, the cross compiler has been installed, the SD card has been prepared, and basic information has been configured.

## Deployment
1. Deployment: choose either faster deployment or conventional deployment as shown below: 

   1.1 Faster deployment, refer to https://gitee.com/Atlas200DK/faster-deploy .
    >![](public_sys-resources/icon-note.gif) **NOTE：**   
    >-   This faster deployment script can quickly deploy multiple cases, select objectdetection case for this project.
    >-   This faster deployment automatically performs code download, model conversion and environment variable configuration. For details, choose conventional deployment method, as shown in 1.2.
    
   1.2 Conventional deployment, refer to : https://gitee.com/Atlas200DK/sample-README/tree/master/sample-objectdetection .
    >![](public_sys-resources/icon-note.gif) **NOTE：**   
    >-   This deployment method requires manually performing code download, model conversion and environment variable configuration. A better understand of the deployment process can be obtained from this method.


## Compile<a name="zh-cn_topic_0203223280_section3723145213347"></a>

1.  Open the corresponding project.


    Enter the “**MindStudio-ubuntu/bin**” directory after decompressing the installation package in the command line as the **Mind Studio** installation user, for example, **$HOME/MindStudio-ubuntu/bin**. Run the following command to start **Mind Studio**:

    **./MindStudio.sh**

    After successfully starting **Mind Studio**, open **sample\_objectdetection**project，as shown in [Figure 1](#zh-cn_topic_0203223280_fig05481157171918).

    **Figure 1**  Open objectdetection project<a name="zh-cn_topic_0203223280_fig05481157171918"></a>  
    

    ![](figures/zh-cn_image_0208253269.png)

2.  Configure related project information in **src/param\_configure.conf**.

    **Figure 2**   Configuration file path<<a name="zh-cn_topic_0203223280_fig0391184062214"></a>  
    ![](figures/配置文件路径.png " Configuration file path<")

    The configuration file is as follows:

    ```
    remote_host=
    ```

    Following parameter configuration needs to be added manually：

    remote\_host：this parameter indicates the IP address of Atlas 200 DK developer board.
    
    An example of configuration is as follows:

    ```
    remote_host=192.168.1.2
    ```

    >![](public_sys-resources/icon-note.gif) **NOTE：**   
    >-   Note that the "" symbol is no need to be used when filling in parameters.

3.  Run the deployment script to adjust the configuration parameters, download and compile 3rd party libraries. Open the Terminal of **Mind Studio** tool, which is under the main code directory, run the following command to execute environment deployment in the backstage, as shown in [Figure 3](#zh-cn_topic_0182554577_fig19292258105419).
    
    **Figure 3**  Execute deployment script<a name="zh-cn_topic_0182554577_fig19292258105419></a>  
    
    ![](figures/deploy_objection.png)
    
    >![](public_sys-resources/icon-note.gif) **NOTE：**   
    >-   Automatic download and compilation will perform if 3rd party libraries are not deployed for the first time of deployment. This process might take some time, please wait patiently. It will not download and compilation repeatedly when recompiling later, deployment is shown as above. 
    >-   Select the HOST IP connected to the developer board when deploying, which is usually the IP of virtual network card. If this IP belongs to the same segment as the developer board IP, it will be selected automatically and deployed. Otherwise, manual entering the IP connected to developer board is required for deployment.


3.  Begin to compile, open **Mind Studio** tool, click **Build \> Build \> Build-Configuration** in the toolbar, shown as [Figure 4](zh-cn_topic_0203223280.md#fig1625447397), **build** and **run** folders will be generated under the directory.

    **Figure 4**  Compilation operation and generated files<a name="zh-cn_topic_0203223280_fig21857144016"></a>  
    

    ![](figures/zh-cn_image_0208253041.png)

    >![](public_sys-resources/icon-note.gif) **NOTE：**   
    >When you compile the project for the first time, **Build \> Build** is gray and not clickable. Your need to click **Build \> Edit Build Configuration**, configure the compilation parameters and then compile.  
    >![](figures/build_configuration.png)  

4.  Upload the images to be inferred to the directory of the  **HwHiAiUser**  user on the host.


    The image requirements are as follows:

    -   Format: JPG, PNG, and BMP.
    -   Width of the input image: the value is an integer ranging from 16px to 4096px.
    -   Height of the input image: the value is an integer ranging from 16px to 4096px.


## Running<a name="zh-cn_topic_0203223280_section1620073406"></a>

1. Find the **Run** button in the toolbar in **Mind Studio** tool, click  **Run \> Run 'sample-objectdetection'**, as shown in[Figure 5](zh-cn_topic_0203223280.md#fig93931954162719), the executable program has been executed on the developer board.

    **Figure 5**  Executed program<a name="zh-cn_topic_0203223280_fig8208744013"></a>  
    

    ![](figures/zh-cn_image_0208253044.png)

     Please ignore the above error, because **Mind Studio** cannot pass parameters for executable programs.  The above steps are to deploy the executable program and the dependent library files to the developer board. This step requires log in to developer board to the corresponding directory file in SSH mode and execute manually. For details, refer to the following steps.

2.  Log in to the Host as the  **HwHiAiUser**  user in SSH mode on Ubuntu Server where  Mind Studio  is located.

    **ssh HwHiAiUser@**_host\_ip_

     For the Atlas 200 DK, the default value of  _**host\_ip**_  is  **192.168.1.2**  \(USB connection mode\) or  **192.168.0.2**  \(NIC connection mode\).

3.  Go to the path of the executable file of object detection application.

    Example command:


    **cd \~/HIAI\_PROJECTS/workspace\_mind\_studio/sample\_objectdetection\_28ac8121/out**

4.  Run the application.

    Run the  **run\_object\_detection\_faster\_rcnn.py**  script to print the inference result on the execution terminal.

    Example command:

    **python3 run\_object\_detection\_faster\_rcnn.py -w  _800_  -h  _600_  -i**

    **_./example.jpg_  -o  _./out_  -c  _21_**

    -   **-w/model\_width**: width of the input image of a model. The value is an integer ranging from 16 to 4096.
    -   **-h/model\_height**: height of the input image of a model. The value is an integer ranging from 16 to 4096.
    -   **-i/input\_path**: directory or path of the input image. You can enter multiple paths.
    -   **-o/output\_path**: directory for storing output images. The default setting is the current directory.
    -   **-c/output\_categories**: number of Faster R-CNN detection categories \(including the background\). The value is an integer ranging from 2 to 32. The default value is  **21**.
    
5.  For other parameters, run the   **python3 run\_object\_detection\_faster\_rcnn.py --help**  command. For details, see the help information.
