#!/bin/bash

set -euvfx

root=msvc_build
rm -rf $root
cp -r src $root
cd $root

[ -f main.exe ] && echo "BAD: main.exe exists" && exit 1

# What's our compiler + flags?
cc="wine64 cl.exe"
error_flags="/W4 /WX"
mod_flags="/experimental:module /interface"
cflags="$error_flags $mod_flags /std:c++latest /EHsc /MD"

# How do we track where all of our ifc files are?
module_paths=""

# Generate our 'moo' module
cd mod_moo
module=moo
unit=mod_$module

$cc $cflags $module_paths /c $unit.cpp

# Add the current directory to the module search list
module_paths="$module_paths /ifcSearchDir $(winepath -w $(pwd))"
cd ..


# Generate our 'quack' module
cd mod_quack
module=quack
unit=mod_$module

$cc $cflags $module_paths /c $unit.cpp

# Add the current directory to the module search list
module_paths="$module_paths /ifcSearchDir $(winepath -w $(pwd))"
cd ..


# Compile main
$cc $cflags $module_paths /c main.cpp

# Link everything together
$cc $cflags main.obj mod_moo/mod_moo.obj mod_quack/mod_quack.obj


# Run our binary
echo "Running main ..."
wine64 main.exe


# EOF
