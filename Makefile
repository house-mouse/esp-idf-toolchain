OSNAME 				:=
ifeq ($(OS),Windows_NT)
	echo "We don't do windows..."
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSNAME = LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OSNAME = OSX
	endif
		UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		OSNAME := $(OSNAME)64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		OSNAME := $(OSNAME)32
	endif
endif

# from https://github.com/espressif/ESP8266_RTOS_SDK
#TOOLCHAIN_LINUX64 = xtensa-lx106-elf-linux64-1.22.0-100-ge567ec7-5.2.0.tar.gz
#TOOLCHAIN_LINUX32 = xtensa-lx106-elf-linux32-1.22.0-100-ge567ec7-5.2.0.tar.gz
#TOOLCHAIN_OSX64   = xtensa-lx106-elf-macos-1.22.0-100-ge567ec7-5.2.0.tar.gz
#TOOLCHAIN_BASE    = https://dl.espressif.com/dl/

#TOOLCHAIN_FILENAME := $(TOOLCHAIN_$(OSNAME))

all: check-and-reinit-submodules crosstool-NG/builds/xtensa-esp32-elf/bin/xtensa-esp32-elf-cc
#all: #FETCHED ESP8266_RTOS_SDK/components/libesphttpd ESP8266_RTOS_SDK/components/heatshrink bin/esptool.py

.PHONY: check-and-reinit-submodules
check-and-reinit-submodules:
	@if git submodule status | egrep -q '^[-]|^[+]' ; then \
		echo "INFO: Need to reinitialize git submodules"; \
		git submodule update --init --recursive; \
	fi

crosstool-NG/builds/xtensa-esp32-elf/bin/xtensa-esp32-elf-cc:
	(cd crosstool-NG && ./bootstrap && ./configure --enable-local && make)
	(cd crosstool-NG && ./ct-ng xtensa-esp32-elf && ./ct-ng build)
	(cd crosstool-NG && chmod -R u+w builds/xtensa-esp32-elf)

#$(TOOLCHAIN_FILENAME):
#	wget -c $(TOOLCHAIN_BASE)$(TOOLCHAIN_FILENAME)

#xtensa-lx106-elf/.FETCHED: $(TOOLCHAIN_FILENAME)
#	tar -xzf $(TOOLCHAIN_FILENAME)
#	touch xtensa-lx106-elf/.FETCHED

ESP8266_RTOS_SDK/components/libesphttpd: components/libesphttpd
	ln -s ../../components/libesphttpd ESP8266_RTOS_SDK/components/libesphttpd

ESP8266_RTOS_SDK/components/heatshrink: components/heatshrink
	ln -s ../../components/heatshrink ESP8266_RTOS_SDK/components/heatshrink

bin/esptool.py: bin esptool/esptool.py
	cp esptool/esptool.py bin/

bin:
	install -d bin

clean:
	rm -rf bin

