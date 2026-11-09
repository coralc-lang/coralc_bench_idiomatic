#include <cstdint>
#include <cstdio>
#include <vector>

int main() {
    std::vector<std::int32_t> numbers;
    numbers.reserve(5000);
    for (int i = 0; i < 5000; ++i) {
        if (i % 2 == 0) {
            numbers.push_back(i * 3);
        } else {
            numbers.push_back(-i * 2);
        }
    }
    for (std::size_t i = 0; i < 5000; ++i) {
        numbers[i] = static_cast<std::int32_t>(
            static_cast<std::uint32_t>(numbers[i]) + static_cast<std::uint32_t>(i));
    }
    std::printf("Done. Element 2500: %d\n", numbers[2500]);
    return 0;
}
