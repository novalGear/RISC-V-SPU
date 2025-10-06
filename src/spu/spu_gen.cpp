#include "architecture.hpp"
#include <iostream>
#include <vector>
#include <string>

std::vector<uint32_t> decode_instruction_args(uint32_t instr) {
{
    uint8_t opcode = static_cast<uint8_t>((instr >> 26) & 0x3F);
    switch (opcode) {
        case 61: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 0) & 0x7FFF };
            case 56: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 0) & 0x7FFF };
            case 63: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 11) & 0x1F };
            case 53: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 11) & 0x1F, (instr >> 0) & 0x3FF };
            case 22: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 0) & 0x7FFF };
            case 62: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 0) & 0x7FFF };
            case 48: return { (instr >> 0) & 0x3FFFFFF };
            case 34: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 11) & 0x1F };
        default: break;
    }
}

        {
    uint8_t opcode = static_cast<uint8_t>((instr >> 0) & 0x3F);
    switch (opcode) {
        case 24: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 11) & 0x1F };
            case 16: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 11) & 0x1F };
            case 15: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 11) & 0x1F };
            case 57: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F, (instr >> 11) & 0x1F };
            case 21: return {};
            case 28: return { (instr >> 21) & 0x1F, (instr >> 16) & 0x1F };
        default: break;
    }
}

    return {};
}


void disassemble_instruction(uint32_t instr) {
{
    uint8_t opcode = static_cast<uint8_t>((instr >> 26) & 0x3F);
    switch (opcode) {
        case 61: std::cout << "SLTI " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << static_cast<int32_t>((instr >> 0) & 0x7FFF)  << "\n"; return;
            case 56: std::cout << "ST " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << static_cast<int32_t>((instr >> 0) & 0x7FFF)  << "\n"; return;
            case 63: std::cout << "SSAT " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << static_cast<int32_t>((instr >> 11) & 0x1F)  << "\n"; return;
            case 53: std::cout << "LDP " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << REG_NAMES[(instr >> 11) & 0x1F] << ", " << static_cast<int32_t>((instr >> 0) & 0x3FF)  << "\n"; return;
            case 22: std::cout << "BEQ " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << static_cast<int32_t>((instr >> 0) & 0x7FFF)  << "\n"; return;
            case 62: std::cout << "LW " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << static_cast<int32_t>((instr >> 0) & 0x7FFF)  << "\n"; return;
            case 48: std::cout << "J " << static_cast<int32_t>((instr >> 0) & 0x3FFFFFF)  << "\n"; return;
            case 34: std::cout << "USAT " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << static_cast<int32_t>((instr >> 11) & 0x1F)  << "\n"; return;
        default: break;
    }
}

        {
    uint8_t opcode = static_cast<uint8_t>((instr >> 0) & 0x3F);
    switch (opcode) {
        case 24: std::cout << "ADD " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << REG_NAMES[(instr >> 11) & 0x1F]  << "\n"; return;
            case 16: std::cout << "OR " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << REG_NAMES[(instr >> 11) & 0x1F]  << "\n"; return;
            case 15: std::cout << "BEXT " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << REG_NAMES[(instr >> 11) & 0x1F]  << "\n"; return;
            case 57: std::cout << "SUB " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F] << ", " << REG_NAMES[(instr >> 11) & 0x1F]  << "\n"; return;
            case 21: std::cout << "SYSCALL" << "\n"; return;
            case 28: std::cout << "CLZ " << REG_NAMES[(instr >> 21) & 0x1F] << ", " << REG_NAMES[(instr >> 16) & 0x1F]  << "\n"; return;
        default: break;
    }
}

    std::cout << "UNKNOWN";
}

