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

REGISTER_VALUES = {
    zero: 0,
    ra: 1,
    sp: 2,
    gp: 3,
    tp: 4,

    t0: 5,
    t1: 6,
    t2: 7,

    s0: 8,
    s1: 9,

    a0: 10,
    a1: 11,
    a2: 12,
    a3: 13,
    a4: 14,
    a5: 15,
    a6: 16,
    a7: 17,

    s2: 18,
    s3: 19,
    s4: 20,
    s5: 21,
    s6: 22,
    s7: 23,
    s8: 24,
    s9: 25,
    s10: 26,
    s11: 27,

    t3: 28,
    t4: 29,
    t5: 30,
    t6: 31
}.freeze

InstrArgType = {
    OPCODE:     6,
    REG:        5,
    IMM_5:      5,
    IMM_10:     10,
    IMM_15:     15,
    INDEX:      26
}.freeze



class InstructionArg
    attr_reader :type, :bit_offset

    def initialize(type, bit_offset)
    raise "Unknown arg type: #{type}" unless InstrArgType.key?(type)
    @type = type
    @bit_offset = bit_offset
  end

  def width
    InstrArgType[@type]
  end

  def to_s
    "#{@type}(offset=#{@bit_offset}, width=#{width})"
  end
end

class Instruction
  attr_reader :name, :opcode_value, :args

  def initialize(name, opcode_value, args)
    @name = name
    @opcode_value = opcode_value
    @args = args
  end

  def to_s
    "Instruction(#{name}=0b#{opcode_value.to_s(2).rjust(6,'0')}, args=[#{args.map(&:to_s).join(', ')}])"
  end
end

INSTRUCTIONS = {
  ADD:     Instruction.new(:ADD,     OPCODES[:ADD],
            [
                InstructionArg.new(:OPCODE, 0),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:REG,    11)
            ]),
  OR:      Instruction.new(:OR,      OPCODES[:OR],
            [
                InstructionArg.new(:OPCODE, 0),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:REG,    11)
            ]),
  SLTI:    Instruction.new(:SLTI,    OPCODES[:SLTI],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:IMM_15, 0)
            ]),
  ST:      Instruction.new(:ST,      OPCODES[:ST],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:IMM_15, 0)
            ]),
  BEXT:    Instruction.new(:BEXT,    OPCODES[:BEXT],
            [
                InstructionArg.new(:OPCODE, 0),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:REG,    11)
            ]),
  SUB:     Instruction.new(:SUB,     OPCODES[:SUB],
            [
                InstructionArg.new(:OPCODE, 0),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:REG,    11)
            ]),
  SSAT:    Instruction.new(:SSAT,    OPCODES[:SSAT],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:IMM_5,  11)
            ]),
  LDP:     Instruction.new(:LDP,     OPCODES[:LDP],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:REG,    11),
                InstructionArg.new(:IMM_10, 0)
            ]),
  BEQ:     Instruction.new(:BEQ,     OPCODES[:BEQ],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:IMM_15, 0)
            ]),
  LW:      Instruction.new(:LW,      OPCODES[:LW],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:IMM_15, 0)
            ]),
  SYSCALL: Instruction.new(:SYSCALL, OPCODES[:SYSCALL],
            [
                InstructionArg.new(:OPCODE, 0)
            ]),
  J:       Instruction.new(:J,       OPCODES[:J],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:INDEX,  0)
            ]),
  USAT:    Instruction.new(:USAT,    OPCODES[:USAT],
            [
                InstructionArg.new(:OPCODE, 26),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
                InstructionArg.new(:IMM_5,  11)
            ]),
  CLZ:     Instruction.new(:CLZ,     OPCODES[:CLZ],
            [
                InstructionArg.new(:OPCODE, 0),
                InstructionArg.new(:REG,    21),
                InstructionArg.new(:REG,    16),
            ])
}.freeze

# Для удобства: маппинг opcode_value → Instruction
OPCODE_TO_INSTRUCTION = INSTRUCTIONS.each_with_object({}) do |(name, instr), hash|
  hash[instr.opcode_value] = instr
end.freeze
