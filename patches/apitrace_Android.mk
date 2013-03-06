LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := egltrace
LOCAL_MODULE_TAGS := debug eng

include $(BUILD_SHARED_LIBRARY)

# Below we hook the whole process of configuring and compiling apitrace,
# described in $(TOPDIR)external/apitrace/INSTALL.markdown. We override
# the $(linked_module): targed, which is already defined by
# $(BUILD_SHARED_LIBRARY) - by default it would want to compile the
# library out of some source files.
# The rules will end up with /lib/egltrace.so inside system.img.
MY_APITRACE_ROOT := $(TOPDIR)external/apitrace
MY_APITRACE_NDK_BZ2 := android-ndk-r8-linux-x86.tar.bz2
MY_APITRACE_NDK := android-ndk-r8

apitrace:
	$(hide) # apitrace: run cmake for the host if it has not been run
	$(hide) if [ ! -e $(MY_APITRACE_ROOT)/build/Makefile ] ; then \
		cd $(MY_APITRACE_ROOT) && cmake -H. -Bbuild ; \
	fi
	$(hide) # apitrace: compile for the host
	$(hide) make -C $(MY_APITRACE_ROOT)/build
	$(hide) # apitrace: download NDK archive if it is not present
	$(hide) if [ ! -e $(MY_APITRACE_ROOT)/$(MY_APITRACE_NDK_BZ2) ] ; then \
		cd $(MY_APITRACE_ROOT) && \
		curl -O http://dl.google.com/android/ndk/$(MY_APITRACE_NDK_BZ2) ; \
	fi
	$(hide) # apitrace: extract NDK archive if it is not extracted
	$(hide) if [ ! -e $(MY_APITRACE_ROOT)/$(MY_APITRACE_NDK) ] ; then \
		cd $(MY_APITRACE_ROOT) && \
		tar -jxf $(MY_APITRACE_NDK_BZ2) ; \
	fi
	$(hide) # apitrace: run cmake for android if it has not been run
	$(hide) if [ ! -e $(MY_APITRACE_ROOT)/build-b2g/Makefile ] ; then \
		cd $(MY_APITRACE_ROOT) && \
		ANDROID_NDK=$(MY_APITRACE_NDK) \
		cmake \
		-DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/android.toolchain.cmake \
		-DANDROID_API_LEVEL=9 -H. -Bbuild-b2g ; \
	fi
	$(hide) # apitrace: compile for android
	$(hide) make -C $(MY_APITRACE_ROOT)/build-b2g
	$(hide) # apitrace: copy the library to where the build system expects it
	$(hide) mkdir -p $(dir $@)
	$(hide) cp $(MY_APITRACE_ROOT)/build-b2g/wrappers/egltrace$(TARGET_SHLIB_SUFFIX) $@

$(linked_module): apitrace
