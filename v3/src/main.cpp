import quack;
import<iostream>;

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
