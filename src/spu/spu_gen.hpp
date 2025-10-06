#pragma once

#include <cstdint>
#include <vector>

std::vector<uint32_t> decode_instruction_args(uint32_t instr);
void disassemble_instruction(uint32_t instr);

