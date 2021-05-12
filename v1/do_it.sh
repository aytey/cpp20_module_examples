#!/bin/bash

set -eu

cc="g++-11"
cflags="-fmodules-ts -std=c++20"

rm -rf gcm.cache

$cc $cflags -c -x c++-system-header cstdint

$cc $cflags -c -x c++-system-header iostream

$cc $cflags -o moo.o -c moo.cpp 

$cc $cflags -o main.o -c main.cpp 

$cc $cflags -o main moo.o main.o

./main

# EOF
