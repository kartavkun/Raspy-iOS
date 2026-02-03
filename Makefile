# ---------------------------
# Настройки проекта
# ---------------------------

SCHEME := Rasp                      # shared scheme
WORKSPACE_FILE := Raspy.xcodeproj/project.xcworkspace
PROJECT_DIR := $(HOME)/git/my-repos/Raspy-iOS

BUNDLE_ID := kartavkun.Raspy

DERIVED_DATA := $(PROJECT_DIR)/DerivedData

SIMULATOR_NAME := iPhone 17
DEVICE_ID := 7CDB4FB6-522A-52C8-93CC-2B698FFED57E

SIM_APP := $(DERIVED_DATA)/Build/Products/Debug-iphonesimulator/Raspy.app
DEVICE_APP := $(DERIVED_DATA)/Build/Products/Debug-iphoneos/Raspy.app

# .DEFAULT_GOAL := run-sim

# ---------------------------
# Цели
# ---------------------------

.PHONY: build-sim build-device run-sim install-device clean

# ---------------------------
# Сборка под симулятор
# ---------------------------

build-sim:
	@echo "=== BUILD FOR SIMULATOR ==="
	xcodebuild \
		-workspace $(WORKSPACE_FILE) \
		-scheme $(SCHEME) \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR_NAME)' \
		clean build -quiet

# ---------------------------
# Сборка под устройство
# ---------------------------

build-device:
	@echo "=== BUILD FOR DEVICE ==="
	xcodebuild \
		-workspace $(WORKSPACE_FILE) \
		-scheme $(SCHEME) \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA) \
		-destination 'generic/platform=iOS' \
		-allowProvisioningUpdates \
		clean build -quiet

# ---------------------------
# Запуск на симуляторе
# ---------------------------

run-sim: build-sim
	@echo "=== RUN ON SIMULATOR ==="
	xcrun simctl boot "$(SIMULATOR_NAME)" || true
	xcrun simctl install booted $(SIM_APP)
	xcrun simctl launch booted $(BUNDLE_ID)

# ---------------------------
# Установка и запуск на iPhone
# ---------------------------

install-device: build-device
	@echo "=== INSTALL ON DEVICE ==="
	xcrun devicectl device install app \
		--device $(DEVICE_ID) \
		$(DEVICE_APP)

	xcrun devicectl device process launch \
		--device $(DEVICE_ID) \
		$(BUNDLE_ID)

# ---------------------------
# Очистка
# ---------------------------

clean:
	@echo "=== CLEAN DERIVED DATA ==="
	rm -rf $(DERIVED_DATA)
