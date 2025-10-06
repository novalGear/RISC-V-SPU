GCC_FLAGS = -Wextra -Werror -Wall -Wno-gnu-folding-constant

SRC_DIR = src

ASM_DIR = $(SRC_DIR)/asm
SPU_DIR = $(SRC_DIR)/spu
CODEGEN_DIR = $(SRC_DIR)/codegen

SPU_SOURCES = $(wildcard $(SPU_DIR)/*.cpp)


APP_DIR = app
DATA_DIR = data

SPU_EXE = spu

all:
	make compile
	make compile_test
	make test

asm:
	ruby $(ASM_DIR)/main.rb

spu:
	g++ $(SPU_SOURCES) -o $(APP_DIR)/$(SPU_EXE)

codegen:
	ruby $(CODEGEN_DIR)/codegen.rb
