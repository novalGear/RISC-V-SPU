#pragma once

class SPU: {
private:
    spu_error err_state_ = 0;
    std::vector<uint64_t> regs_;

    void set_err_state(spu_error new_err_state);
    int execute_instr();

public:
    spu_error get_err_state();
    int execute_programm();
}
