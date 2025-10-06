
module InstructionHandlers

    def add(rd, rs, rt)
        encode_dflt(0, rs, rt, rd, 0, OPCODES[:ADD])
    end

    def or_op(rd, rs, rt)
        encode_dflt(0, rs, rt, rd, 0, OPCODES[:OR])
    end

    def slti(rt, rs, imm15)
        encode_imm15_instr(OPCODES[:SLTI], rs, rt, imm15)
    end

    def st(rt, offset, base)
        encode_imm15_instr(OPCODES[:ST], base, rt, offset)
    end

    def bext(rd, rs1, rs2)
        encode_dflt(0, rd, rs1, rs2, 0, OPCODES[:BEXT])
    end

    def sub(rd, rs, rt)
        encode_dflt(0, rs, rt, rd, 0, OPCODES[:SUB])
    end

    def ssat(rd, rs, imm5)
        encode_imm10_instr(OPCODES[:SSAT], rd, rs, imm5, 0)
    end

    def ldp(rt1, rt2, offset, base)
        encode_imm10_instr(OPCODES[:LDP], base, rt1, rt2, offset)
    end

    def beq(rs, rt, offset)
        encode_imm15_instr(OPCODES[:BEQ], rs, rt, offset)
    end

    def lw(rt, offset, base)
        encode_imm15_instr(OPCODES[:LW], base, rt, offset)
    end

    def syscall()
        encode_syscall()
    end

    def j(label_name)
        if label_name.is_a?(String) && !label_name.empty?
            add_unfilled_jmp(label_name)
        else
            raise ArgumentError, "Unallowed label name: #{label_name.inspect}"
        end
        # оставить место под jmp
        @code.push(0)
        advance_pc()
    end

    def usat(rd, rs, imm5)
        encode_imm10_instr(OPCODES[:USAT], rd, rs, imm5, 0)
    end

    def clz(rd, rs)
        encode_dflt(0, rd, rs, 0, 0, OPCODES[:CLZ])
    end


    def set_label(label_name)
        if label_name.is_a?(String) && !label_name.empty?
            @label_map[label_name] = @pc
        else
            raise ArgumentError, "Unallowed label name: #{label_name.inspect}"
        end
    end
end
