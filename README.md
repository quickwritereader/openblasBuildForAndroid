# openblasBuildForAndroid

Run   
./compand all  

Run just for spesific architectures  

./compand arm64-v8a x86_64  

*Architectures*  
armeabi armv7a arm64-v8a mips mips64  x86 x86_64  


##How to build test executable and test on device
Assuming you build openblas and all its files are inside output folder.  
Go to **test/jni** folder and open terminal and run 
```
    export NDKROOT=`locate ndk-bundle | head -n 1` ;
    ${NDKROOT}/ndk-build
```    
(**if you want binaries for 64bits** use  ```${NDKROOT}/ndk-build NDK_APPLICATION_MK=Application21.mk``` )   
It should leave executable binaries in **test/libs** folder named **testblas.x** 
PLug your device and copy appropriate exec file with **adb**. Assuming you cd to directory where exe file resides  
``` 
 ${NDKROOT}/../platform-tools/adb push testblas.x /data/local/tmp/
```
Next you should open shell
```
  ${NDKROOT}/../platform-tools/adb shell
```
Inside that shell
``` 
  cd /data/local/tmp
  chmod 755 testblas.x 
  /testblas.x
```










