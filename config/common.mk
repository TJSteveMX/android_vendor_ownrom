PRODUCT_BRAND ?= ownrom

SUPERUSER_EMBEDDED := true

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
	if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
		echo $(TARGET_SCREEN_WIDTH); \
	else \
	echo $(TARGET_SCREEN_HEIGHT); \
	fi )
	
# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/ownrom/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
	if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
		if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
			echo $(1); \
			exit 0; \
		fi;
	fi;
	echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/ownrom/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/ownrom/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
	ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
	ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
	keyguard.no_require_sim=true \
	ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
	ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
	ro.com.android.wifi-watchlist=GoogleGuest \
	ro.setupwizard.enterprise_mode=1 \
	ro.com.android.dateformat=MM-dd-yyyy \
	ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
ro.build.selinux=1

# Disable multithreaded dexopt by default
PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.dalvik.multithread=false

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/ownrom/CHANGELOG.mkdn:system/etc/CHANGELOG-CM.txt

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/ownrom/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/ownrom/prebuilt/common/bin/50-ownrom.sh:system/addon.d/50-ownrom.sh \
    vendor/ownrom/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/bin/otasigcheck.sh:system/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/ownrom/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/etc/init.local.rc:root/init.ownrom.rc

# Bring in camera effects
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/ownrom/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so


# This is OwnROM!!
PRODUCT_COPY_FILES += \
    vendor/ownrom/config/permissions/com.ownrom.android.xml:system/etc/permissions/com.ownrom.android.xml

# T-Mobile theme engine
include vendor/ownrom/config/themes_common.mk

# Required OwnROM packages
PRODUCT_PACKAGES += \
Development \
LatinIME \
BluetoothExt

# Optional OwnROM packages
PRODUCT_PACKAGES += \
VoicePlus \
Basic \
libemoji

# Custom OwnROM packages
PRODUCT_PACKAGES += \
Launcher3 \
Trebuchet \
AudioFX \
CMWallpapers \
CMFileManager \
Eleven \
LockClock \
CMHome

# OwnROM (from CM) Hardware Abstraction Framework
PRODUCT_PACKAGES += \
org.cyanogenmod.hardware \
org.cyanogenmod.hardware.xml

# Extra tools in OwnROM
PRODUCT_PACKAGES += \
libsepol \
openvpn \
e2fsck \
mke2fs \
tune2fs \
bash \
nano \
htop \
powertop \
lsof \
mount.exfat \
fsck.exfat \
mkfs.exfat \
mkfs.f2fs \
fsck.f2fs \
fibmap.f2fs \
ntfsfix \
ntfs-3g \
gdbserver \
micro_bench \
oprofiled \
sqlite3 \
strace

# Openssh
PRODUCT_PACKAGES += \
scp \
sftp \
ssh \
sshd \
sshd_config \
ssh-keygen \
start-ssh

# rsync
PRODUCT_PACKAGES += \
rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
libstagefright_soft_ffmpegadec \
libstagefright_soft_ffmpegvdec \
libFFmpegExtractor \
libnamparser

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
procmem \
procrank \
Superuser \
su

PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.root_access=3
else

PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.root_access=0

endif

PRODUCT_PACKAGE_OVERLAYS += vendor/ownrom/overlay/common

# version
OWNROM_RELEASE = false
OWNROM_VERSION_MAJOR = 2.0
OWNROM_VERSION_MINOR = -BETA

# release
ifeq ($(RELEASE),true)
	OWNROM_VERSION := UNOFFICIAL-OwnROM-$(OWNROM_VERSION_MAJOR)$(OWNROM_VERSION_MINOR)-$(OWNROM_BUILD)
else
	OWNROM_VERSION_STATE := $(shell date +%Y.%m.%d)
	OWNROM_VERSION := UNOFFICIAL-OwnROM-V$(OWNROM_VERSION_MAJOR)$(OWNROM_VERSION_MINOR)-$(OWNROM_VERSION_STATE)-$(OWNROM_BUILD)
endif

OWNROM_DISPLAY_VERSION := $(OWNROM_VERSION)

# statistics identity
PRODUCT_PROPERTY_OVERRIDES += \
	ro.ownrom.version=$(OWNROM_VERSION) \
	ro.ownrom.releasetype=$(OWNROM_BUILDTYPE) \
	ro.modversion=$(OWNROM_VERSION)

PRODUCT_PROPERTY_OVERRIDES += \
	ro.ownrom.display.version=$(OWNROM_DISPLAY_VERSION)

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk

$(call inherit-product-if-exists, vendor/extra/product.mk)
