#!/bin/bash

set -eu

# Remove the 'gcm.cache' (we should never see this)
rm -rf gcm.cache

# Path to the mapper file
mapper=$(readlink -f mapper.txt)

# Remove it
rm -rf $mapper

# What's our compiler + flags?
cc="g++-11"
cflags="-fmodules-ts -std=c++20 -fmodule-mapper=$mapper"

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
rm -rf mod_moo
mkdir mod_moo
cd mod_moo
echo "moo $(readlink -f moo.so.gcm)" >> ../mapper.txt

cat <<EOF >moo.mxx
export module moo;

import <cstdint>;

export class Moo
{
  public:
    int16_t moo() { return 10; }
};
EOF

$cc $cflags -x c++ -c moo.mxx
cd ..


# Generate our 'quack' module
rm -rf mod_quack
mkdir mod_quack
cd mod_quack
echo "quack $(readlink -f quack.so.gcm)" >> ../mapper.txt

cat <<EOF >quack.mxx
export module quack;

import moo;

export int oink()
{
  Moo m;
  return m.moo();
}
EOF

$cc $cflags -x c++ -c quack.mxx
cd ..

# Generate our main file
cat << EOF > main.cpp
import quack;
import <iostream>;

int main(void)
{
  std::cout << oink() << std::endl;
  return 0;
}
EOF

# Compile main
g++-11 -std=c++2a -fmodules-ts -fmodule-mapper=mapper.txt -c main.cpp

# Link everything together
g++-11 -std=c++2a -fmodules-ts -fmodule-mapper=mapper.txt mod_moo/moo.o mod_quack/quack.o main.o -o main

# EOF
