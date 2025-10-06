#pragma once

#include <cstdint>
#include <vector>
#include <string>
#include <unordered_map>

enum class Register: uint8_t {
    zero = 0,
    ra,
    sp,
    gp,
    tp,
    t0,
    t1,
    t2,
    s0,
    s1,
    a0,
    a1,
    a2,
    a3,
    a4,
    a5,
    a6,
    a7,
    s2,
    s3,
    s4,
    s5,
    s6,
    s7,
    s8,
    s9,
    s10,
    s11,
    t3,
    t4,
    t5,
    t6
};

enum class spu_error: uint8_t {
    NONE,
    INVALID_INSTRUCTION,
    UNALIGNED_MEMORY_ACCESS,
    DIVISION_BY_ZERO,
};

// Opcode info
struct OpcodeInfo {
    uint8_t value;
    const char* name;
};

// Глобальная таблица всех опкодов (для отладки и валидации)
inline const std::unordered_map<uint8_t, const char*>& get_opcode_name_map() {
    static const std::unordered_map<uint8_t, const char*> map = {
    { 0b001111, "BEXT" },
    { 0b010000, "OR" },
    { 0b010101, "SYSCALL" },
    { 0b010110, "BEQ" },
    { 0b011000, "ADD" },
    { 0b011100, "CLZ" },
    { 0b100010, "USAT" },
    { 0b110000, "J" },
    { 0b110101, "LDP" },
    { 0b111000, "ST" },
    { 0b111001, "SUB" },
    { 0b111101, "SLTI" },
    { 0b111110, "LW" },
    { 0b111111, "SSAT" }
    };
    return map;
}

inline const char* const REG_NAMES[] = {
    "zero",
    "ra",
    "sp",
    "gp",
    "tp",
    "t0",
    "t1",
    "t2",
    "s0",
    "s1",
    "a0",
    "a1",
    "a2",
    "a3",
    "a4",
    "a5",
    "a6",
    "a7",
    "s2",
    "s3",
    "s4",
    "s5",
    "s6",
    "s7",
    "s8",
    "s9",
    "s10",
    "s11",
    "t3",
    "t4",
    "t5",
    "t6"
};

inline bool is_valid_opcode(uint8_t value) {
    return get_opcode_name_map().count(value) > 0;
}

inline const char* opcode_to_name(uint8_t value) {
    auto it = get_opcode_name_map().find(value);
    return (it != get_opcode_name_map().end()) ? it->second : "UNKNOWN";
}

