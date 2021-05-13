#!/bin/bash

set -euvfx

root=gcc_build
rm -rf $root
cp -r src $root
cd $root

[ -d gcm.cache ] && echo "BAD: gcm.cache exists" && exit 1

[ -f mapper.txt ] && echo "BAD: mapper.txt exists" && exit 1

[ -f main ] && echo "BAD: main exists" && exit 1

# Path to the mapper file
mapper=$(readlink -f mapper.txt)

# What's our compiler + flags?
cc="g++-11"
error_flags="-Wall -Wextra -Wpedantic -Werror"
mod_flags="-fmodules-ts -fmodule-mapper=$mapper"
cflags="$error_flags $mod_flags -std=c++20"

# Generate modules for our system headers
rm -rf sys_inc
mkdir sys_inc
cd sys_inc
for i in cstdint iostream; do
    echo "/usr/include/c++/11/$i $(readlink -f $i.gcm)" >> ../mapper.txt
    $cc $cflags -c -x c++-system-header $i
done
cd ..


# Generate our 'moo' module
cd mod_moo
module=moo
unit=mod_$module
echo "$module $(readlink -f $module.so.gcm)" >> ../mapper.txt
$cc $cflags -c $unit.cpp -o $unit.o
cd ..


# Generate our 'quack' module
cd mod_quack
module=quack
unit=mod_$module
echo "$module $(readlink -f $module.so.gcm)" >> ../mapper.txt
$cc $cflags -c $unit.cpp -o $unit.o
cd ..


# Compile main
$cc $cflags -c main.cpp -o main.o

# Link everything together
$cc $cflags mod_moo/mod_moo.o mod_quack/mod_quack.o main.o -o main


# Run our binary
echo "Running main ..."
./main

# EOF
