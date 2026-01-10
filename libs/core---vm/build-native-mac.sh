#!/bin/bash
set -e

# Setup directories
ROOT_ARCADE="../../../pxt-arcade"
CORE_LINUX="../core---linux"
CORE_BASE="../base"
CORE_SCREEN_EXT="../screen---ext"
CORE_MIXER_EXT="../mixer---ext"
CORE_MIXER="../mixer"
CORE_CORE="../core"
CORE_VM="."
BUILD_DIR="bld-native"

mkdir -p $BUILD_DIR

# Flags
CXX="clang++"
CXXFLAGS="-std=c++11 -g -O2 -fPIC -I$CORE_VM -I$CORE_LINUX -I$CORE_BASE -I$CORE_SCREEN_EXT -I$CORE_MIXER_EXT -I$CORE_MIXER -I$CORE_CORE -Wno-unused-parameter -D_MACOSX -DPXT_VM"
LDFLAGS="-dynamiclib"
SDL_CFLAGS=$(sdl2-config --cflags)
SDL_LIBS=$(sdl2-config --libs)

echo "Compiling PXT Core sources..."

# Sources (as a simple string to avoid shell array issues)
SRCS="$CORE_VM/scheduler.cpp \
$CORE_VM/target.cpp \
$CORE_VM/verify.cpp \
$CORE_VM/vm.cpp \
$CORE_VM/vmcache.cpp \
$CORE_VM/vmload.cpp \
$CORE_VM/keys.cpp \
$CORE_VM/stubs.cpp \
$CORE_LINUX/platform.cpp \
$CORE_LINUX/dmesg.cpp \
$CORE_LINUX/codalemu.cpp \
$CORE_LINUX/control.cpp \
$CORE_LINUX/config.cpp \
$CORE_BASE/core.cpp \
$CORE_BASE/gc.cpp \
$CORE_BASE/pxt.cpp \
$CORE_BASE/buffer.cpp \
$CORE_BASE/control.cpp \
$CORE_BASE/controlgc.cpp \
$CORE_BASE/loops.cpp \
$CORE_BASE/trig.cpp \
$CORE_BASE/advmath.cpp \
$CORE_SCREEN_EXT/screen.cpp \
$CORE_MIXER_EXT/sound.cpp"

# Copy melody.cpp to build dir to avoid picking up SoundOutput.h from mixer/
# We need to compile it with the include paths set such that it finds the *right* headers if needed,
# but here the issue was implicit local includes.
cp "$CORE_MIXER/melody.cpp" "$BUILD_DIR/melody.cpp"
SRCS="$SRCS $BUILD_DIR/melody.cpp"

OBJS=""
for src in $SRCS; do
    filename=$(basename "$src")
    dirname=$(dirname "$src")
    dirname=$(basename "$dirname")
    
    # special case for our copied file
    if [ "$dirname" == "bld-native" ]; then
        dirname="local"
    fi

    obj="$BUILD_DIR/${dirname}_${filename%.cpp}.o"
    echo "  $src -> $obj"
    $CXX $CXXFLAGS -c "$src" -o "$obj"
    OBJS="$OBJS $obj"
done

echo "Linking libpxt.dylib..."
$CXX $LDFLAGS -o "$BUILD_DIR/libpxt.dylib" $OBJS

echo "Compiling sdlmain.cpp..."
SDL_MAIN="$ROOT_ARCADE/libs/hw---vm/sdlmain.cpp"
# -D__MACOSX__ needed for sdlmain.cpp to define SONAME correctly
$CXX $CXXFLAGS -D__MACOSX__ $SDL_CFLAGS -c "$SDL_MAIN" -o "$BUILD_DIR/sdlmain.o"

echo "Linking pxt-vm-sdl..."
# sdlmain.o is the entry point
$CXX -o "$BUILD_DIR/pxt-vm-sdl" "$BUILD_DIR/sdlmain.o" $SDL_LIBS

echo "Build complete."
echo "Executable: $BUILD_DIR/pxt-vm-sdl"
echo "Shared Lib: $BUILD_DIR/libpxt.dylib"
