#include <cstdint>
#include <cstdio>
#include <vector>

int main() {
    std::vector<std::uint8_t> text;
    text.reserve(10000);

    for (int i = 0; i < 2000; ++i) {
        text.push_back('a');
        text.push_back('b');
        text.push_back('c');
        if (i % 10 == 0) {
            text.push_back('-');
        }
    }
    std::printf("String bytes processed: %zu\n", text.size());
    return 0;
}
