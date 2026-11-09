#include <cstddef>
#include <cstdio>
#include <vector>

int main() {
    std::vector<int> numbers;
    numbers.reserve(1000);

    for (int i = 0; i < 1000; ++i) {
        if (i % 2 == 0) {
            numbers.push_back(i * 3);
        } else {
            numbers.push_back(-i * 2);
        }
    }

    const std::size_t len = numbers.size();
    for (std::size_t i = 0; i < len; ++i) {
        for (std::size_t j = i + 1; j < len; ++j) {
            if (numbers[j] < numbers[i]) {
                const int temp = numbers[i];
                numbers[i] = numbers[j];
                numbers[j] = temp;
            }
        }
    }

    std::printf("Done. Element 500: %d\n", numbers[500]);
    return 0;
}
