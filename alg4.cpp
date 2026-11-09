#include <cstdio>
#include <string>

int main() {
    std::string text;
    text.reserve(10000);
    for (int i = 0; i < 2000; ++i) {
        text.append("abc");
        if (i % 10 == 0) {
            text.append("-");
        }
    }
    std::printf("Done. Length: %zu\n", text.size());
    return 0;
}
