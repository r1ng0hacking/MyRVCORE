CC = riscv32-unknown-linux-gnu-gcc
OBJDIR = obj/
C_FLAGS = -pie -c
IMEMNAME = imemfile.dat

CC_MARCH = rv32i
CC_MABI  = ilp32

AS_MARCH = rv32i
AS_MABI  = ilp32
AS_FLAGS = -fpic

imemfile.dat:a.out
	riscv32-unknown-linux-gnu-objcopy -O verilog -S $(OBJDIR)a.out imemfile.dat
a.out:start main
	riscv32-unknown-linux-gnu-ld -e _start --section-start=.text=0 $(OBJDIR)start.o $(OBJDIR)main.o -o $(OBJDIR)a.out
start:
	riscv32-unknown-linux-gnu-as $(AS_FLAGS) -march=$(AS_MARCH) -mabi=$(AS_MABI) start.s -o $(OBJDIR)start.o
main:
	$(CC) $(C_FLAGS) -march=$(CC_MARCH) -mabi=$(CC_MABI) main.c -o $(OBJDIR)main.o
clean:
	rm -rf $(OBJDIR)*
	rm -rf imemfile.dat
