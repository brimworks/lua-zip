
# If you put your libzip in a non-standard directory you can
# configure it as such:
#  -DLIBZIP_LIBRARY=/opt/libzip/lib/libzip.dylib -DLIBZIP_INCLUDE_DIR=/opt/libzip/include
CMAKE_FLAGS=-H. -Bbuild

all: build
	cmake --build build

build:
	cmake $(CMAKE_FLAGS)

test: all
	cd build && ctest -V

clean:
	rm -rf build

.PHONY: clean test all
