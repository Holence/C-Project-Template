#include <iostream>
#include "cppfuncs.hpp"
#include "generated/autoconf.h"

namespace mytest {
    const float test_var = CONFIG_CPP_FLOAT / 1000.0;
}  // namespace mytest

namespace mycpp {
    float cpp_func() {
        std::cout << "[" __FILE__ ":" << __LINE__ << "] " << "Hello from C++!" << std::endl;
        return mytest::test_var;
    }
}  // namespace mycpp

// wrapper function
float cpp_func() {
    return mycpp::cpp_func();
}
