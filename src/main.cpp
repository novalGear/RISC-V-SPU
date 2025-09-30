#include "assembler.hpp"

#include <iostream>
#include <vector>
#include <string>
#include <sstream>

// Пример использования в контексте RISC-ассемблера
int main() {
    // 🔧 Примеры входных строк — как они могут выглядеть в .asm файле
    std::vector<std::string> testCases = {
        "ADD R1, R2, R3",
        "LW R4, 100(R5)",
        "BEQ R1, R0, label1",
        "LI R7, 255",
        "SW R2, 200(R6)",
        "HALT",
        "  ADD   R1 , R2 , R3  ",  // с лишними пробелами
        "BEQ,R1,R0,label1"          // без пробелов после запятых
    };

    std::cout << "=== Парсинг RISC-инструкций ===\n\n";

    for (const auto& line : testCases) {
        auto tokens = parseInstruction(line);

        std::cout << "Вход: \"" << line << "\"\n";
        std::cout << "Выход: [";
        for (size_t i = 0; i < tokens.size(); ++i) {
            std::cout << "\"" << tokens[i] << "\"";
            if (i < tokens.size() - 1) std::cout << ", ";
        }
        std::cout << "]\n";
        std::cout << "Количество токенов: " << tokens.size() << "\n";
        std::cout << "----------------------------------------\n";
    }

    return 0;
}
