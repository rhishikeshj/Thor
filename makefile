# Specify the device and the SDK that you want to run the tests on
# Options for SDK :
# 1. iphoneos : The device
# 2. iphonesimulator<version> : The simulator with the specified version. For example : iphonesimulator8.3
SDK ?= iphonesimulator

# Options for Device
# 1. If you are running on a connected device, the name of the device. For example, HS iPhone 6
# 2. Name of the simulator on which to run. For example, iPhone 6
DEVICE ?= iPhone 6

cleanup-state:
	osascript reset_simulator.script; killall "iOS Simulator";

build:
	xcodebuild -project Thor.xcodeproj -scheme Thor -sdk $(SDK) -destination "name=$(DEVICE)" clean build -jobs 8

test:build
	xcodebuild -project Thor.xcodeproj -scheme Thor -sdk $(SDK) -destination "name=$(DEVICE)" test -jobs 8; $(MAKE) cleanup-state

coverage:test
	sh XcodeCoverage/getcov -s

all:coverage
