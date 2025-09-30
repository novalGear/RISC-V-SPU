
require_relative 'asm_DSL'
require_relative 'int32_array.rb'

OPCODES = {
        ADD:        0b011000,
        OR:         0b010000,
        SLTI:       0b111101,
        ST:         0b111000,
        BEXT:       0b001111,
        SUB:        0b111001,
        SSAT:       0b111111,
        LDP:        0b110101,
        BEQ:        0b010110,
        LW:         0b111110,
        SYSCALL:    0b010101,
        J:          0b110000,
        USAT:       0b100010,
        CLZ:        0b011100,
    }.freeze

class AssemblerContext
    attr_reader :pc, :label_map, :unfilled_jmp_map, :code

    def initialize
        @pc = 0
        @label_map = {}
        @unfilled_jmp_map = {}
        @code = Int32Array.new(0)
    end

    def pc=(new_pc)
        @pc = new_pc
    end

    def add_unfilled_jmp(label_name)
        if label_name.is_a?(String) && !label_name.empty?
            @unfilled_jmp_map[@pc] = label_name
        else
            raise ArgumentError, "Unallowed label name: #{label_name.inspect}"
        end
    end

    def get_label_address(label_name)
        @label_map[label_name]
    end

    def advance_pc()
        @pc += 4
    end

    def to_s
        "AssemblerContext(pc=#{@pc}), labels=#{@label_map})"
    end

    def dump_code
        @code.each_with_index do |value, index|
            # next if value == 0  # опционально: пропуск нулей
            puts "#{index}: #{'%032b' % (value & 0xFFFFFFFF)}"
        end
    end

    def assemble(&block)
        context = self
        RiscvRegister::REGISTERS.each do |name, val|
            context.define_singleton_method(name) { val }
        end
        context.instance_eval(&block) if block_given?
        context.fill_jmps()
        # self
    end

    # может быть через хэш таблицу задавать количество аргументов каждой инструкции, их размер в битах и смещение?
    include InstructionHandlers

    def fill_jmps()
        @unfilled_jmp_map.each do |pc, label_name|
            target_addr = get_label_address(label_name)
            encode_JMP(pc, target_addr)
        end
    end

    def encode_dflt(opcode1, arg1, arg2, arg3, arg4, opcode2)
        raise "arg1 too big" if arg1 > 31 || arg1 < 0
        raise "arg2 too big" if arg2 > 31 || arg2 < 0
        raise "arg3 too big" if arg3 > 31 || arg3 < 0
        raise "arg4 too big" if arg4 > 31 || arg4 < 0
        raise "opcode1 too big" if opcode1 > 63 || opcode1 < 0
        raise "opcode2 too big" if opcode2 > 63 || opcode2 < 0

        instr = (opcode1 << 26) | (arg1 << 21) | (arg2 << 16) | (arg3 << 11) | (arg4 << 6) | opcode2

        # Найти имя инструкции по opcode2
        op1_name = OPCODES.key(opcode1)&.to_s&.downcase || 'none'
        op2_name = OPCODES.key(opcode2)&.to_s&.downcase || 'none'
        # Найти имена регистров
        arg1_name = RiscvRegister.to_name(arg1)
        arg2_name = RiscvRegister.to_name(arg2)
        arg3_name = RiscvRegister.to_name(arg3)
        arg4_name = RiscvRegister.to_name(arg4)

        puts "encode_dflt:"
        puts "pc = #{@pc}"

        # Форматирование примечаний с отступами
        op1_name_str = "#{op1_name}"
        op2_name_str = "#{op2_name}"
        arg1_str = arg1_name ? "#{arg1_name}(#{arg1})" : 'None'
        arg2_str = arg2_name ? "#{arg2_name}(#{arg2})" : 'None'
        arg3_str = arg3_name ? "#{arg3_name}(#{arg3})" : 'None'
        arg4_str = arg4_name ? "#{arg4_name}(#{arg4})" : 'None'

        puts sprintf("%-7s  %-7s %-7s %-7s %-7s %-7s", op1_name_str, arg1_str, arg2_str, arg3_str, arg4_str, op2_name_str)
        puts sprintf("%06b   %05b   %05b   %05b   %05b   %06b", opcode1, arg1, arg2, arg3, arg4, opcode2)

        @code.push(instr)
        advance_pc()
    end

    def encode_arithmetic(opcode, reg1, reg2, reg3)
        raise "reg1 too big" if reg1 > 31 || reg1 < 0
        raise "reg2 too big" if reg2 > 31 || reg2 < 0
        raise "reg3 too big" if reg3 > 31 || reg3 < 0
        raise "opcode too big" if opcode > 63 || opcode < 0

        instr = (reg1 << 21) | (reg2 << 16) | (reg3 << 11) | opcode

        # Найти имя инструкции по opcode
        op_name = OPCODES.key(opcode)&.to_s&.downcase || 'unknown'

        # Найти имена регистров
        reg1_name = RiscvRegister.to_name(reg1)
        reg2_name = RiscvRegister.to_name(reg2)
        reg3_name = RiscvRegister.to_name(reg3)

        puts "encode_arithmetic:"
        puts "pc = #{@pc}"

        # Форматирование примечаний с отступами
        op_name_str = "#{op_name}"
        reg1_str = reg1_name ? "#{reg1_name}(#{reg1})" : 'None'
        reg2_str = reg2_name ? "#{reg2_name}(#{reg2})" : 'None'
        reg3_str = reg3_name ? "#{reg3_name}(#{reg3})" : 'None'

        puts sprintf("%-7s  %-6s  %-6s  %-6s", op_name_str, reg1_str, reg2_str, reg3_str)
        puts sprintf("%05b   %05b   %05b   %06b", reg1, reg2, reg3, opcode)

        @code.push(instr)
        advance_pc()
    end

    def encode_imm15_instr(opcode, arg1, arg2, imm15)
        raise "arg1 too big" if arg1 > 31 || arg1 < 0
        raise "arg2 too big" if arg2 > 31 || arg2 < 0
        raise "imm10 too big" if imm15 > (2 ** 15 - 1) || imm15 < 0
        raise "opcode too big" if opcode > 63 || opcode < 0

        instr = (opcode << 26) | (arg1 << 21) | (arg2 << 16) | imm15

        # Найти имя инструкции по opcode
        op_name = OPCODES.key(opcode)&.to_s&.downcase || 'unknown'

        # Найти имена регистров
        arg1_name = RiscvRegister.to_name(arg1)
        arg2_name = RiscvRegister.to_name(arg2)

        puts "encode_imm15_instr:"
        puts "pc = #{@pc}"

        # Форматирование примечаний с отступами
        op_name_str = "#{op_name}"
        arg1_str = arg1_name ? "#{arg1_name}(#{arg1})" : 'None'
        arg2_str = arg2_name ? "#{arg2_name}(#{arg2})" : 'None'
        imm15_str = "#{imm15}(imm15)"

        puts sprintf("%-7s  %-6s  %-6s  %-8s", op_name_str, arg1_str, arg2_str, imm15_str)
        puts sprintf("%06b   %05b   %05b   %015b", opcode, arg1, arg2, imm15)

        @code.push(instr)
        advance_pc()
    end

    def encode_imm10_instr(opcode, arg1, arg2, arg3, imm10)
        raise "arg1 too big"  if arg1 > 31 || arg1 < 0
        raise "arg2 too big"  if arg2 > 31 || arg2 < 0
        raise "arg3 too big"  if arg3 > 31 || arg3 < 0
        raise "imm10 too big" if imm10 > (2 **10 - 1) || imm10 < 0
        raise "opcode too big" if opcode > 63 || opcode < 0

        instr = (opcode << 26) | (arg1 << 21) | (arg2 << 16) | (arg3 << 11) | imm10

        # Найти имя инструкции по opcode
        op_name = OPCODES.key(opcode)&.to_s&.downcase || 'unknown'

        # Найти имена регистров
        arg1_name = RiscvRegister.to_name(arg1)
        arg2_name = RiscvRegister.to_name(arg2)
        arg3_name = RiscvRegister.to_name(arg3)

        puts "encode_imm10_instr:"
        puts "pc = #{@pc}"

        # Форматирование примечаний с отступами
        op_name_str = "#{op_name}"
        arg1_str = arg1_name ? "#{arg1_name}(#{arg1})" : 'None'
        arg2_str = arg2_name ? "#{arg2_name}(#{arg2})" : 'None'
        arg3_str = arg3_name ? "#{arg3_name}(#{arg3})" : 'None'
        imm10_str = "#{imm10}(imm10)"

        puts sprintf("%-7s  %-6s  %-6s  %-6s  %-7s", op_name_str, arg1_str, arg2_str, arg3_str, imm10_str)
        puts sprintf("%06b   %05b   %05b   %05b   %010b", opcode, arg1, arg2, arg3, imm10)

        @code.push(instr)
        advance_pc()
    end

    def encode_JMP(pc, target)
        index = (target % 2 ** 28) >> 2
        raise "target too big" if index > (2 ** 26 - 1) || index < 0
        instr = (OPCODES[:J] << 26) | index

        puts "encode_JMP:"
        puts "pc = #{pc}"

        puts sprintf("jmp      %-26s", "#{index}")
        puts sprintf("%06b   %026b", OPCODES[:J], index)

        @code[pc >> 4] = instr
        advance_pc()
    end

    def encode_syscall(code)
        raise "code too big" if code > (2 ** 20 - 1) || code < 0
        instr = (code << 6) | OPCODES[:SYSCALL]

        puts "encode_syscall:"
        puts "pc = #{@pc}"

        puts sprintf("%-27s  syscall", "#{code}")
        puts sprintf("%026b   %06b", code, OPCODES[:SYSCALL])

        @code.push(instr)
        advance_pc()
    end

end
