#include "spu.hpp"
#include "spu_gen.hpp"
#include <iostream>

int main() {
    SPU spu;

    spu.load_memory_from_bin("./data/output.bin");
    spu.disasm_all_instr();

    return 0;
}
