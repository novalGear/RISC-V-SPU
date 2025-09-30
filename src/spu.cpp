#include spu.h

SPU::SPU() {}

void SPU::set_err_state(spu_error new_err_state) {
    err_state_ = new_err_state;
}

spu_error SPU::get_err_state() {
    return err_state_;
}

