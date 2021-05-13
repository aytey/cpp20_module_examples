import quack;

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
import<iostream>;
#endif

#if defined(__clang__)
#define COMPILER "clang"
#elif defined(__GNUC__) || defined(__GNUG__)
#define COMPILER "gcc"
#elif defined(_MSC_VER)
#define COMPILER "MSVC"
#else
#error "I don't know what I am"
#endif

int main(void) {
  std::cout << "Compiled with: " << COMPILER << std::endl;
  std::cout << "Module output: " << oink() << std::endl;
  return 0;
}
