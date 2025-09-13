#include <iostream>
#include "cppfuncs.hpp"

namespace mytest {
    const float test_var = 114.514;
}  // namespace mytest

namespace mycpp {
    float cpp_func() {
        std::cout << "[" __FILE__ ":" << __LINE__ << "]" << "Hello from C++!" << std::endl;
        return mytest::test_var;
    }
}  // namespace mycpp

float cpp_func() {
    return mycpp::cpp_func();
}
