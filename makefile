
Alfa: Alfa.o
	ld -m elf_i386 -o Alfa Alfa.o

Alfa.o: Alfa.asm
	nasm -f elf -g -F stabs Alfa.asm -l Alfa.lst

