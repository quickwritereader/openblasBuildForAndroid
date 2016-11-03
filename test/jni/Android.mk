LOCAL_PATH := $(call my-dir) 
include $(CLEAR_VARS)  
LOCAL_MODULE    := openblas 

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard)
LOCAL_SRC_FILES := \
  ../../output/armv7a/libopenblas.a    
else
LOCAL_SRC_FILES := \
  ../../output/$(TARGET_ARCH_ABI)/libopenblas.a 
endif

include $(PREBUILT_STATIC_LIBRARY)
################################################################################

#nlibs Library
include $(CLEAR_VARS)
LOCAL_MODULE := testblas.x

LOCAL_SRC_FILES := ../test_MMult.c
LOCAL_SRC_FILES += ../MMultOpenBlas.c
LOCAL_SRC_FILES += ../random_matrix.c
LOCAL_SRC_FILES += ../copy_matrix.c
LOCAL_SRC_FILES += ../compare_matrices.c 
LOCAL_SRC_FILES += ../dclock.c
LOCAL_SRC_FILES += ../print_matrix.c
LOCAL_SRC_FILES += ../REF_MMult.c
LOCAL_STATIC_LIBRARIES := openblas 
COMMON_CFLAGS := -w -DFORCE_OPENBLAS_COMPLEX_STRUCT   
 

LOCAL_CFLAGS += $(COMMON_CFLAGS) 
LOCAL_LDLIBS :=  -llog -landroid  -latomic  
LOCAL_C_INCLUDES += \
  $(NDK_PATH)/platforms/$(TARGET_PLATFORM)/arch-$(TARGET_ARCH)/usr/include \
  $(LOCAL_PATH)/..

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a-hard)
LOCAL_C_INCLUDES := \
  $(LOCAL_PATH)/../../output/armv7ainclude \   
else
LOCAL_C_INCLUDES := \
  $(LOCAL_PATH)/../../output/$(TARGET_ARCH_ABI)include \ 
endif
 
include $(BUILD_EXECUTABLE)

################################################################################
