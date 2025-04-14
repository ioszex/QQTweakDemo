#
#  QQTweakDemo Makefile - 自动构建并安装到 rootless 设备
#

TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e

# 设置包类型
export THEOS_PACKAGE_SCHEME = rootless
export DEBUG = 0

# 设置目标进程
INSTALL_TARGET_PROCESSES = QQ

# 设备信息
THEOS_DEVICE_IP = 192.168.15.246
THEOS_DEVICE_PORT = 22

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = QQTweakDemo

QQTweakDemo_FILES = QQTweakDemo.xm
QQTweakDemo_CFLAGS = -fobjc-arc -w
QQTweakDemo_LOGOS_DEFAULT_GENERATOR = internal

CXXFLAGS += -std=c++11
CCFLAGS += -std=c++11

export THEOS_STRICT_LOGOS = 0
export ERROR_ON_WARNINGS = 0
export LOGOS_DEFAULT_GENERATOR = internal

include $(THEOS_MAKE_PATH)/tweak.mk

# 清理 packages 目录
clean::
	@echo -e "\033[31m==>\033[0m Cleaning packages…"
	@rm -rf .theos packages

# 编译并自动安装
after-package::
	@echo -e "\033[32m==>\033[0m Packaging complete."
	@DEB_FILE=$$(ls -t packages/*.deb | head -1); \
	PACKAGE_NAME=$$(basename "$$DEB_FILE" | cut -d'_' -f1); \
	echo -e "\033[34m==>\033[0m Installing $$PACKAGE_NAME to device…"; \
	ssh root@$(THEOS_DEVICE_IP) "rm -rf /tmp/$${PACKAGE_NAME}.deb"; \
	scp "$$DEB_FILE" root@$(THEOS_DEVICE_IP):/tmp/$${PACKAGE_NAME}.deb; \
	ssh root@$(THEOS_DEVICE_IP) "dpkg -i --force-overwrite /tmp/$${PACKAGE_NAME}.deb && rm -f /tmp/$${PACKAGE_NAME}.deb"
