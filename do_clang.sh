#!/bin/bash

set -euvf

root=clang_build
rm -rf $root
cp -r src $root
cd $root

[ -f main ] && echo "BAD: main exists" && exit 1

# What's our compiler + flags?
cc="clang++-12"
cflags="-Wall -Werror -std=c++20 -stdlib=libc++ -fmodules"

# What flags do we need to generate the pcm files?
mod_flags="-Xclang -emit-module-interface"

# How do we track where all of our modules might be?
module_paths="-fprebuilt-module-path=."


# Generate our 'moo' module
cd mod_moo
module=moo
unit=mod_$module
$cc $cflags $mod_flags $module_paths -c $unit.cpp -o $module.pcm
$cc $cflags $module_paths -c $unit.cpp -o $unit.o
module_paths="$module_paths -fprebuilt-module-path=$(pwd)"
cd ..


# Generate our 'quack' module
cd mod_quack
module=quack
unit=mod_$module
$cc $cflags $mod_flags $module_paths -c $unit.cpp -o $module.pcm
$cc $cflags $module_paths -c $unit.cpp -o $unit.o
module_paths="$module_paths -fprebuilt-module-path=$(pwd)"
cd ..


# Compile main
$cc $cflags $module_paths -c main.cpp -o main.o

# Link everything together
$cc $cflags mod_moo/mod_moo.o mod_quack/mod_quack.o main.o -o main


# Run our binary
echo "Running main ..."
./main

# EOF
