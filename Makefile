export THEOS_DEVICE_IP=192.168.178.38
export SDKROOT=iphoneos
export SYSROOT=$(THEOS)/sdks/iPhoneOS11.2.sdk
export PACKAGE_VERSION=0.3-2

export ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotchSimulator
NotchSimulator_FILES = Tweak.xm D22AP.xm ProudLock.xm D22APWindow.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += notchsimulator
include $(THEOS_MAKE_PATH)/aggregate.mk
