require_relative 'assembler'
require_relative 'riscv_regs'

ctx = AssemblerContext.new

ctx.assemble do
    add   ra, s0, s1
    or_op ra, s0, s1
    sub   ra, s0, s1

    bext  ra, s0, s1

    set_label 'jmp_target'

    slti  ra, s0, 10

    st    ra, 16, s0
    ldp   ra, s0, 16, s1
    ssat  ra, s0, 16
    usat  ra, s0, 16

    beq ra, s0, 16

    lw  ra, 16, s0
    syscall
    j    'jmp_target'
    clz  ra, s0
end
