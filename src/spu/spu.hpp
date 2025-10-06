#pragma once

#include <string>

#include "architecture.hpp"

class SPU {
private:
    spu_error err_state_ = spu_error::NONE;
    std::vector<uint64_t> regs_;
    std::vector<uint32_t> memory_;

    void set_err_state(spu_error new_err_state);
    // int execute_instr();
public:
    spu_error get_err_state();
    // int execute_programm();
    void load_memory_from_bin(const std::string& filename);
    void disasm_all_instr();
};
