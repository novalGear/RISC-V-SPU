require_relative '../architecture'

class RiscvRegister
    REGISTERS = REGISTER_VALUES.freeze
    VALUE_TO_NAME = REGISTERS.invert.freeze

    def self.valid?(val)
        REGISTERS.key?(val) || REGISTERS.value?(val)
    end

    def self.to_name(value)
        name = VALUE_TO_NAME[value]
        name ? name.to_s : nil
    end

    def self.load_into(binding)
        REGISTERS.each { |name, val| binding.local_variable_set(name, val) }
    end

    def self.to_s
        "RiscvRegister(#{REGISTERS})"
    end
end
