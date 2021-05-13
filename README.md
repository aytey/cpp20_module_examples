# C++20 Module Examples

**Important**: C++20 modules seem to be a fast-moving target; I fully expect some of this content to (quickly) go out of date. When I refer to a specific tool (e.g., `gcc`), I refer to the version of GCC as given in the *Compilers* section of this document. Any other version may give different results. Basically, I expect this page to get outdated pretty quickly ...


## Purpose

This repository collects together some C++ source files and some simple build scripts that demonstrate how to work with modules. The code is purposefully structured to have both self-contained and non-self-contained modules in different directories. The purpose of the build scripts are to be able to build each module *in its own directory* and then provide enough information to the compiler to locate the binary module files.


## Compilers

These examples have been built using the following versions:

### Host machine

```
$ lsb-release -a
LSB Version:    n/a
Distributor ID: openSUSE
Description:    openSUSE Tumbleweed
Release:        20210417
Codename:       n/a

$ /lib64/libc.so.6 --version
GNU C Library (GNU libc) release release version 2.33 (git 9826b03b74).
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
Configured for x86_64-suse-linux.
Compiled by GNU CC version 10.2.1 20210303 [revision 85977f624a34eac309f9d77a58164553dfc82975].
libc ABIs: UNIQUE IFUNC ABSOLUTE
For bug reporting instructions, please see:
<http://bugs.opensuse.org>.
```

### `gcc`

```
$ g++-11 --version
g++-11 (SUSE Linux) 11.0.0 20210208 (experimental) [revision efcd941e86b507d77e90a1b13f621e036eacdb45]
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

### `clang`

```
$ clang++-12 --version
clang version 12.0.0
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /usr/bin
```

### MSVC

```
$ wine64 cl.exe /Bv
Microsoft (R) C/C++ Optimizing Compiler Version 19.28.29915 for x64
Copyright (C) Microsoft Corporation.  All rights reserved.

Compiler Passes:
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\cl.exe:        Version 19.28.29915.0
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\c1.dll:        Version 19.28.29915.0
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\c1xx.dll:      Version 19.28.29915.0
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\c2.dll:        Version 19.28.29915.0
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\c1xx.dll:      Version 19.28.29915.0
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\link.exe:      Version 14.28.29915.0
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\mspdb140.dll:  Version 14.28.29915.0
 Z:\home\avj\visual_studio\MSVC\14.28.29910\bin\HostX64\x64\1033\clui.dll: Version 19.28.29915.0
```


## Binary modules

Each compiler uses its own terminology for the binary module interfaces:

* `gcc` -- CMI (["Compiled Module Interface"](https://gcc.gnu.org/wiki/cxx-modules)) files; typically have a `.gcm` suffix and end-up in the [`gcm.cache`](https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Module-Mapper.html) directory, unless you use a ["module mapper"](https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Module-Mapper.html) via `-fmodule-mapper`

* `clang` -- PCM (["Precompiled Module"](https://mariusbancila.ro/blog/2020/05/15/modules-in-clang-11/)) types; typically have a `.pcm` suffix adhere to the location specified by `-o`

* MSVC -- IFC files (see: [https://mariusbancila.ro/blog/2020/05/07/modules-in-vc-2019-16-5/](https://mariusbancila.ro/blog/2020/05/07/modules-in-vc-2019-16-5/); unsure what IFC stands for); typically have a `.ifc` suffix and go into the current directory


## Name requirements

It is *not* necessary for the source file "exporting" a given module to be of the same name as the module it is exporting (e.g., when compared to Ada when the source file needs to match the package name). The examples in this repository exploit this fact: `module moo` is defined in `mod_moo.cpp`.

When working with `gcc`, the name of GCM file *does not* have to match the name of the module -- using a mapper file (see: `do_gcc.sh`), you can control the output name, as well the name that `gcc` uses to resolve the module (e.g., `module moo` can be defined in a file `mod_moo.cpp` and be placed into `moo_moo.gcm`, and still be correctly resolved).

When working with `clang`, you can output (via `-o`) the PCM to any name you like; however, unless the PCM name *matches* the module name, you cannot then `import` the module later on. Effectively, there needs to be a 1-to-1 correspondence between the name of the module and the `.pcm` name.

When working with Visual Studio, it seems that the name of the IFC is 1-to-1 with the name of the module (e.g., `module moo` will end-up in `moo.ifc`).



## Compiler support

Both `gcc` and `clang` support ["imported header files"](https://docs.microsoft.com/en-us/cpp/cpp/modules-cpp?view=msvc-160) (e.g., `import <cstdint>`), but Visual Studio *does not*. Conversely, Visual Studio supports ["Standard Library Modules"](https://devblogs.microsoft.com/cppblog/cpp-modules-in-visual-studio-2017/) (e.g., `import std.core`).

Additionally, `gcc` *does not* support imported header files, **without** first generating the the binary module for these headers **explicitly**; `clang` does not need you to generate the files upfront, but you *do* need to have `libc++` installed.

When working with standard library modules in Visual Studio, these are loaded from `<cl version>/ifc/<arch>/<build type>/<module>.ifc` (e.g., `visual_studio/MSVC/14.28.29910/ifc/x64/Debug/std.memory.ifc`). If you do not have the IFC files installed, then you cannot `import core` with MSVC -- I think this means there's no easy way to get the "original" files (== non-binary equivalents) for MSVC.

When working with imported header files in `clang`, these get resolved by the file `/usr/include/c++/v1/module.modulemap` -- *note* this is a `libc++` file!


## Useful links

* [https://github.com/urnathan/libcody](https://github.com/urnathan/libcody) -- provides the ["canonical protocol definition"](https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Module-Mapper.html) for working with GCC's module mapper

* [https://devblogs.microsoft.com/cppblog/standard-c20-modules-support-with-msvc-in-visual-studio-2019-version-16-8/](https://devblogs.microsoft.com/cppblog/standard-c20-modules-support-with-msvc-in-visual-studio-2019-version-16-8/) -- blog post on the current status of C++20 modules in MSVC (as of 2020-09-14)

* [https://gitlab.kitware.com/cmake/cmake/-/merge_requests/5562](https://gitlab.kitware.com/cmake/cmake/-/merge_requests/5562) -- implementation of some of C++20's modules into CMake's Ninja back-end

* [https://gitlab.kitware.com/cmake/cmake/-/issues/18355](https://gitlab.kitware.com/cmake/cmake/-/issues/18355) -- issue for CMake's implementation of C++20 modules

