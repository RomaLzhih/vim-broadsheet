#include <vector>
#include <map>

namespace demo {

template <typename T>
class Index {
 public:
  explicit Index(const std::vector<T>& items) : items_(items) {}

  static int count(const std::vector<T>& xs) {
    int total = 0;
    for (const auto& v : xs) total += 1;
    return total;
  }

 private:
  std::vector<T> items_;
};

typedef unsigned long usize;
struct Pair { int a; int b; };
enum Colour { kRed, kGreen };

int run(std::map<int, int>& m) {
  try {
    if (m.empty()) throw 42;
    while (m.size() > 100) break;
  } catch (int e) {
    return -1;
  }
  return 0;
}

}  // namespace demo
