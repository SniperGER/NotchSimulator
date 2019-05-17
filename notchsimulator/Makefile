SHARED_CFLAGS = -fobjc-arc
CFLAGS = -fobjc-arc
ADDITIONAL_OBJCFLAGS = -fobjc-arc
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = notchsimulator
notchsimulator_FILES = NTDRootListController.m NTDAppSettingsController.m NTDD2xSettings.m  OrderedDictionary.m
notchsimulator_INSTALL_PATH = /Library/PreferenceBundles
notchsimulator_FRAMEWORKS = UIKit
notchsimulator_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices
notchsimulator_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/notchsimulator.plist$(ECHO_END)
