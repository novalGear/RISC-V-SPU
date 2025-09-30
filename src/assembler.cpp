#include <vector>
#include <string>
#include <sstream>

std::unordered_map<std::string, HandlerFunc> instruction_map = {
    {"ADD",  handle_ADD},
    {"OR",   handle_OR},
    {"SLTI", handle_SLTI},
    {"ST",   handle_ST},
    {"BEXT", handle_BEXT},
    {"SUB",  handle_SUB},
    {"SSAT", handle_SSAT},
    {"LDP",  handle_LDP},
    {"BEQ",  handle_BEQ},
    {"LD",   handle_LD},
    {"SYSCALL", handle_SYSCALL},
    {"J",    handle_J},
    {"USAT", handle_USAT},
    {"CLZ",  handle_CLZ}
};

std::vector<std::string> parseInstruction(const std::string& line) {
    std::vector<std::string> tokens;
    std::string token;
    std::stringstream ss(line);

    // Разбиваем по запятым
    while (std::getline(ss, token, ',')) {
        std::stringstream ss2(token);
        std::string word;
        // Разбиваем каждый токен по пробелам
        while (ss2 >> word) {
            tokens.push_back(word);
        }
    }

    return tokens;
}

uint64_t assembleInstruction(std::vector<std::string> tokens) {
    assert(tokens.size() > 0);

    auto handler_pair = instruction_map.find(tokens[0]);
    if (handler_pair != instruction_map.end()) {
        handler_pair->second(tokens);
    } else {
        throw std::invalid_argument("Unknown instruction: " + tokens[0]);
    }
}

void handle_ADD(Operand& op) {
    // реализация ADD
    op.result = op.src1 + op.src2;
}

void handle_OR(Operand& op) {
    op.result = op.src1 | op.src2;
}

void handle_SLTI(Operand& op) {
    op.result = (op.src1 < op.src2) ? 1 : 0;
}

// ... и так далее для всех остальных

void handle_ST(Operand& op) { /* ... */ }
void handle_BEXT(Operand& op) { /* ... */ }
void handle_SUB(Operand& op) { /* ... */ }
void handle_SSAT(Operand& op) { /* ... */ }
void handle_LDP(Operand& op) { /* ... */ }
void handle_BEQ(Operand& op) { /* ... */ }
void handle_LD(Operand& op) { /* ... */ }
void handle_SYSCALL(Operand& op) { /* ... */ }
void handle_J(Operand& op) { /* ... */ }
void handle_USAT(Operand& op) { /* ... */ }
void handle_CLZ(Operand& op) { /* ... */ }
