SHELL := /bin/bash

# Rez variables, setting these to sensible values if we are not building from rez
REZ_BUILD_PROJECT_VERSION ?= NOT_SET
REZ_BUILD_INSTALL_PATH ?= /usr/local
REZ_BUILD_SOURCE_PATH ?= $(shell dirname $(lastword $(abspath $(MAKEFILE_LIST))))
BUILD_ROOT := $(REZ_BUILD_SOURCE_PATH)/build
REZ_BUILD_PATH ?= $(BUILD_ROOT)
REZ_PYTHON_MAJOR_VERSION ?= 3

# Build time locations
SOURCE_DIR := $(BUILD_ROOT)/opencv/
BUILD_TYPE = Release
BUILD_DIR = ${REZ_BUILD_PATH}/BUILD/$(BUILD_TYPE)

# Source
REPOSITORY_URL := https://github.com/opencv/opencv.git
TAG ?= $(REZ_BUILD_PROJECT_VERSION)

# Installation prefix
PREFIX ?= ${REZ_BUILD_INSTALL_PATH}

PYTHON_VERSION_MAJOR ?= $(REZ_PYTHON_MAJOR_VERSION)
PYTHON_EXECUTABLE ?= $(shell which python$(PYTHON_VERSION_MAJOR))
PYTHON_ROOT ?= $(realpath $(dir $(PYTHON_EXECUTABLE))/../)
PYTHON_LIBRARY ?= $(shell find $(PYTHON_ROOT)/lib/ -name libpython*.so)

# CMake Arguments
CMAKE_ARGS := -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
	-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
	-DBUILD_PERF_TESTS=OFF \
	-DBUILD_TESTS=OFF \
	-DPYTHON3_EXECUTABLE=$(PYTHON_EXECUTABLE) \
	-DPYTHON3_LIBRARY=$(PYTHON_LIBRARY) \
	-DOPENCV_PYTHON3_INSTALL_PATH=lib/python-$(PYTHON_VERSION_MAJOR) \
	-DPYTHON3_LIMITED_API=ON \
	-DBUILD_opencv_python2=OFF \
	-DCMAKE_SKIP_RPATH=ON

$(info $$CMAKE_ARGS is [${CMAKE_ARGS}])
# Warn about building master if no tag is provided
ifeq "$(TAG)" "NOT_SET"
$(warning "No tag was specified, main will be built. You can specify a tag: TAG=v2.1.0")
TAG:=master
endif


.PHONY: build install test clean
.DEFAULT: build

$(BUILD_DIR): # Prepare build directories
	mkdir -p $(BUILD_ROOT)
	mkdir -p $(BUILD_DIR)

$(SOURCE_DIR): | $(BUILD_DIR) # Clone the repository
	cd $(BUILD_ROOT) && git clone $(REPOSITORY_URL)

build: $(SOURCE_DIR) # Checkout the correct tag and build
	cd $(SOURCE_DIR) && git checkout $(TAG)
	cd $(BUILD_DIR) && cmake $(CMAKE_ARGS) $(SOURCE_DIR) && make


install: build
	mkdir -p $(PREFIX)
	cd $(BUILD_DIR) && make install
	mkdir -p $(PREFIX)/cmake
	cp -rf $(REZ_BUILD_SOURCE_PATH)/cmake/* $(PREFIX)/cmake/

test: build # Run the tests in the build
	$(MAKE) -C $(BUILD_DIR) test

clean:
	rm -rf $(BUILD_ROOT)
