#pragma once

#include <cstdint>
#include <vector>

enum class Register: uint8_t {
    zero = 0, ra, sp, gp, tp, t0, t1, t2, s0, s1,
      a0, a1, a2, a3, a4, a5, a6, a7, s2, s3, s4,
      s5, s6, s7, s8, s9, s10, s11, t3, t4, t5, t6
}

enum class spu_error: uint8_t {
    NONE,
    INVALID_INSTRUCTION,
    UNALIGNED_MEMORY_ACCESS,
    DIVISION_BY_ZERO,
}

enum class Opcode: uint8_t {
    ADD  = 0b011000,
    OR   = 0b010000,
    SLTI = 0b111101,
    ST   = 0b111000,
    BEXT = 0b001111,
    SUB,
    SSAT,
    LDP,
    BEQ,
    LD,
    SYSCALL,
    J,
    USAT,
    CLZ
}

// architecture.add(ADD, 0b011000, rd = [25:21], rs = [20:16], opcode = [5:0])
