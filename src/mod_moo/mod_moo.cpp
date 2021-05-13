export module moo;

/*
 * MSVC does not support 'Imported header files':
 *
 *    https://docs.microsoft.com/en-us/cpp/cpp/modules-cpp?view=msvc-160
 *
 * So we need to use the 'std' import
 */
#if defined(_MSC_VER)
import std.core;
#else
import<cstdint>;
#endif

export class Moo {
public:
  int16_t moo() { return 10; }
};
