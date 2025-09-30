prog example:
    ADD  rd, rs, rt
    OR   rd, rs, rt
    SUB  rd, rs, rt

    BEXT rd, rs1, rs2

    SLTI rt, rs, 10

    ST   rt, offset(base)
    LDP  rt1, rt2, offset(base)
    SSAT rd, rs, 31
    USAT rsm rs, 31

    BEQ  rs, rt, offset

    LD   rt, offset
    SYSCALL 60
    J    target
    CLZ  rd, rs
end
