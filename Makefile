# ---------------------------
# Настройки проекта
# ---------------------------

SCHEME := Rasp
# путь к директории с .xcodeproj ниже
PROJECT := $(HOME)/git/my-repos/Raspy-iOS
BUNDLE_ID := kartavkun.Raspy
DERIVED_DATA := $(PROJECT)/DerivedData
SIMULATOR_ID := iPhone 17

.DEFAULT_GOAL := run

# ---------------------------
# Цели
# ---------------------------
.PHONY: build run clean

# Собрать проект
build:
	@echo "=== BUILD PROJECT ==="
	xcodebuild -scheme $(SCHEME) \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR_ID)' \
		clean build -quiet

# Установить и запустить на симуляторе
run: build
	@echo "=== RUN ON SIMULATOR ==="
	# включаем симулятор (если он ещё не запущен)
	xcrun simctl boot "$(SIMULATOR_ID)" || true

	# ставим билд
	xcrun simctl install booted $(DERIVED_DATA)/Build/Products/Debug-iphonesimulator/Raspy.app

	# запускаем приложение
	xcrun simctl launch booted $(BUNDLE_ID)

# Очистка сборки
clean:
	@echo "=== CLEAN DERIVED DATA ==="
	rm -rf $(DERIVED_DATA)
