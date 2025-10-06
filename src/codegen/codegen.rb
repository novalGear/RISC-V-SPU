require_relative '../architecture'
require_relative '../asm/riscv_regs.rb'

def format_register_enum(registers)
  sorted = registers.sort_by { |_, v| v }
  lines = sorted.map do |name, value|
    if value == 0
      "    #{name} = 0"
    else
      "    #{name}"
    end
  end
  lines.join(",\n")
end

def format_opcode_table(opcodes)
  # Сортируем по значению для читаемости (не обязательно)
  sorted = opcodes.sort_by { |_, v| v }
  sorted.map do |name, value|
    bin_str = "0b#{value.to_s(2).rjust(6, '0')}"
    "    { #{bin_str}, \"#{name}\" }"
  end.join(",\n")
end

def format_register_names_array()
  names = Array.new(32) { "nullptr" }
  REGISTER_VALUES.each do |name, idx|
    names[idx] = "\"#{name}\""
  end
  names.join(",\n    ")
end

# Генерация ТОЛЬКО декодера
def gen_decoder_implementation()
  instr_by_opcode_offset = OPCODE_TO_INSTRUCTION.values.group_by do |instr|
    opcode_arg = instr.args.find { |arg| arg.type == :OPCODE }
    raise "No OPCODE arg in #{instr.name}" unless opcode_arg
    opcode_arg.bit_offset
  end

    switch_blocks = instr_by_opcode_offset.sort_by(&:first).reverse.map do |offset, instrs|
    cases = instrs.map do |instr|
      operand_args = instr.args.reject { |arg| arg.type == :OPCODE }
      if operand_args.empty?
        body = "return {};"
      else
        values = operand_args.map do |arg|
          mask = (1 << arg.width) - 1
          mask_hex = "0x#{mask.to_s(16).upcase}"
          "(instr >> #{arg.bit_offset}) & #{mask_hex}"
        end
        body = "return { #{values.join(', ')} };"
      end
      "case #{instr.opcode_value}: #{body}"
    end.join("\n            ")

    mask = (1 << 6) - 1
    mask_hex = "0x#{mask.to_s(16).upcase}"
    <<~CPP
      {
          uint8_t opcode = static_cast<uint8_t>((instr >> #{offset}) & #{mask_hex});
          switch (opcode) {
              #{cases}
              default: break;
          }
      }
    CPP
  end

  <<~CPP
    std::vector<uint32_t> decode_instruction_args(uint32_t instr) {
    #{switch_blocks.join("\n        ")}
        return {};
    }
  CPP
end

def gen_disassembler_implementation()
    instr_by_opcode_offset = OPCODE_TO_INSTRUCTION.values.group_by do |instr|
        opcode_arg = instr.args.find { |arg| arg.type == :OPCODE }
        raise "No OPCODE arg in #{instr.name}" unless opcode_arg
        opcode_arg.bit_offset
    end

    switch_blocks = instr_by_opcode_offset.sort_by(&:first).reverse.map do |offset, instrs|
        cases = instrs.map do |instr|
        operand_args = instr.args.reject { |arg| arg.type == :OPCODE }

        if operand_args.empty?
            body = "std::cout << \"#{instr.name}\" << \"\\n\"; return;"
        else
            # Генерируем цепочку вывода: std::cout << "ADD " << REG_NAMES[...] << ", " << ...;
            output_parts = ["std::cout << \"#{instr.name} \""]
            operand_args.each_with_index do |arg, i|
            output_parts << "<< \", \"" if i > 0 # запятая перед всеми, кроме первого
            case arg.type
            when :REG
                reg_val = "(instr >> #{arg.bit_offset}) & 0x1F"
                output_parts << "<< REG_NAMES[#{reg_val}]"
            when :IMM_5, :IMM_10, :IMM_15, :INDEX
                imm_mask = (1 << arg.width) - 1
                imm_val = "(instr >> #{arg.bit_offset}) & 0x#{imm_mask.to_s(16).upcase}"
                # Приведение к int32_t для корректного вывода знаковых чисел
                output_parts << "<< static_cast<int32_t>(#{imm_val})"
            else
                output_parts << "<< \"?\""
            end
            end
            output_parts << " << \"\\n\"; return;"
            body = output_parts.join(" ")
        end
        "case #{instr.opcode_value}: #{body}"
        end.join("\n            ")

        mask = (1 << 6) - 1
        mask_hex = "0x#{mask.to_s(16).upcase}"
        <<~CPP
        {
            uint8_t opcode = static_cast<uint8_t>((instr >> #{offset}) & #{mask_hex});
            switch (opcode) {
                #{cases}
                default: break;
            }
        }
        CPP
    end

    <<~CPP
        void disassemble_instruction(uint32_t instr) {
        #{switch_blocks.join("\n        ")}
            std::cout << "UNKNOWN";
        }
    CPP
end


def gen_arch_hdr()

    max_reg_index = REGISTER_VALUES.values.max
    reg_names_array = Array.new(max_reg_index + 1, '"<invalid>"') # заполняем заглушками
    REGISTER_VALUES.each do |name, index|
        reg_names_array[index] = "\"#{name}\""
    end
    reg_names_content = reg_names_array.map { |s| "    #{s}" }.join(",\n")

    header_content = <<~HDR
    #pragma once

    #include <cstdint>
    #include <vector>
    #include <string>
    #include <unordered_map>

    enum class Register: uint8_t {
    #{format_register_enum(REGISTER_VALUES)}
    };

    enum class spu_error: uint8_t {
        NONE,
        INVALID_INSTRUCTION,
        UNALIGNED_MEMORY_ACCESS,
        DIVISION_BY_ZERO,
    };

    // Opcode info
    struct OpcodeInfo {
        uint8_t value;
        const char* name;
    };

    // Глобальная таблица всех опкодов (для отладки и валидации)
    inline const std::unordered_map<uint8_t, const char*>& get_opcode_name_map() {
        static const std::unordered_map<uint8_t, const char*> map = {
    #{format_opcode_table(OPCODES)}
        };
        return map;
    }

    inline const char* const REG_NAMES[] = {
    #{reg_names_content}
    };

    inline bool is_valid_opcode(uint8_t value) {
        return get_opcode_name_map().count(value) > 0;
    }

    inline const char* opcode_to_name(uint8_t value) {
        auto it = get_opcode_name_map().find(value);
        return (it != get_opcode_name_map().end()) ? it->second : "UNKNOWN";
    }

    HDR
end

def gen_spu_hdr()
    header_content =  <<~HDR
    #pragma once

    #include <cstdint>
    #include <vector>

    std::vector<uint32_t> decode_instruction_args(uint32_t instr);
    void disassemble_instruction(uint32_t instr);

    HDR
end


# === Сборка и запись ===

arch_hdr_content = gen_arch_hdr
spu_gen_hdr_content = gen_spu_hdr
decoder_content = gen_decoder_implementation
disasm_content = gen_disassembler_implementation

# Записываем заголовок
File.write("./src/spu/architecture.hpp", arch_hdr_content)
File.write("./src/spu/spu_gen.hpp", spu_gen_hdr_content)

# Записываем обе реализации в ОДИН .cpp файл
cpp_content = <<~CPP
  #include "architecture.hpp"
  #include <iostream>
  #include <vector>
  #include <string>

  #{decoder_content}

  #{disasm_content}
  CPP

File.write("./src/spu/spu_gen.cpp", cpp_content)

puts "Сгенерировано:"
puts "  ./src/spu/architecture.hpp"
puts "  ./src/spu/spu_gen.hpp"
puts "  ./src/spu/spu_gen.cpp"
