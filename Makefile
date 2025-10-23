# ---------------------------
# Настройки проекта
# ---------------------------
SCHEME := Rasp
# путь к директории с .xcodeproj ниже
PROJECT := .
BUNDLE_ID := com.example.Raspy
SIMULATOR_ID := 2E6EAA1D-2AFB-4424-951F-F4319F9FB615
DERIVED_DATA := $(PROJECT)/DerivedData

# ---------------------------
# Цели
# ---------------------------
.PHONY: build run clean

# Собрать проект
build:
	@echo "=== BUILD PROJECT ==="
	xcodebuild -scheme $(SCHEME) \
	    -project $(PROJECT)/Raspy.xcodeproj \
	    -destination "id=$(SIMULATOR_ID)" \
	    -derivedDataPath $(DERIVED_DATA) \
	    clean build

# Установить и запустить на симуляторе
run: build
	@echo "=== RUN ON SIMULATOR ==="
	APP_PATH=$$(find $(DERIVED_DATA)/Build/Products/Debug-iphonesimulator -name "*.app" | head -n 1); \
	if [ -z "$$APP_PATH" ]; then echo "App not found"; exit 1; fi; \
	echo "Using app: $$APP_PATH"; \
	xcrun simctl shutdown $(SIMULATOR_ID) || true; \
	xcrun simctl boot $(SIMULATOR_ID); \
	xcrun simctl install $(SIMULATOR_ID) "$$APP_PATH"; \
	xcrun simctl launch $(SIMULATOR_ID) $(BUNDLE_ID)

# Очистка сборки
clean:
	@echo "=== CLEAN DERIVED DATA ==="
	rm -rf $(DERIVED_DATA)
