#include <cstdio>
#include <string>
#include <string_view>

int main() {
    const std::string base = "  abcdefghijklmnopqrstuvwxyz-abcdefghijklmnopqrstuvwxyz  ";
    const std::size_t begin = base.find_first_not_of(' ');
    const std::size_t end = base.find_last_not_of(' ');
    const std::string_view clean(base.data() + begin, end - begin + 1);

    int match_count = 0;
    for (int i = 0; i < 5000; ++i) {
        if (clean.find("jkl") != std::string_view::npos) {
            ++match_count;
        }
        if (clean.size() >= 3 && clean.compare(clean.size() - 3, 3, "xyz") == 0) {
            ++match_count;
        }
        const std::string_view sub = clean.substr(2, 8);
        (void)sub;
    }
    std::printf("Done. Matches: %d\n", match_count);
    return 0;
}
