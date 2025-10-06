#include "spu.hpp"
#include "spu_gen.hpp"

#include <iostream>
#include <fstream>
#include <vector>
#include <cstdint>
#include <bitset>

void SPU::set_err_state(spu_error new_err_state) {
    err_state_ = new_err_state;
}

spu_error SPU::get_err_state() {
    return err_state_;
}

void SPU::load_memory_from_bin(const std::string& filename) {
    std::ifstream file(filename, std::ios::binary);
    if (!file.is_open()) {
        std::cerr << "Cannot open file: " << filename << std::endl;
        return;
    }

    file.seekg(0, std::ios::end);
    size_t size = static_cast<size_t>(file.tellg());
    file.seekg(0, std::ios::beg);

    if (size % sizeof(uint32_t) != 0) {
        std::cerr << "Warning: File size is not a multiple of 4 bytes. Truncating." << std::endl;
    }

    size_t count = size / sizeof(uint32_t);
    memory_.resize(count);

    file.read(reinterpret_cast<char*>(memory_.data()), count * sizeof(uint32_t));
    file.close();

    // Вывод в бинарном виде с ведущими нулями до 32 бит
    for (size_t i = 0; i < count; ++i) {
        std::cout << "memory[" << i << "] = "
                  << std::bitset<32>(memory_[i])
                  << std::endl;
    }
}

void SPU::disasm_all_instr() {
    for (unsigned instr_ind = 0; instr_ind < memory_.size(); instr_ind++) {
        disassemble_instruction(memory_[instr_ind]);
    }
}
