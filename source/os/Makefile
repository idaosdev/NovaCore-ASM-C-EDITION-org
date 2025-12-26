# Переменные
CC = gcc
LD = ld
AS = nasm

# Флаги
CFLAGS = -m32 -ffreestanding -fno-pie -fno-common -fno-stack-protector -c
LDFLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary --no-pie
ASFLAGS_BIN = -f bin
ASFLAGS_ELF = -f elf32

# Цели (что собираем)
all: os_image.bin

# Сборка загрузчика
boot.bin: boot.asm gdt.asm
	$(AS) $(ASFLAGS_BIN) boot.asm -o boot.bin

# Сборка мостика прерываний
kernel_entry.o: kernel_entry.asm
	$(AS) $(ASFLAGS_ELF) kernel_entry.asm -o kernel_entry.o

# Сборка Си-ядра
kernel.o: kernel.c
	$(CC) $(CFLAGS) kernel.c -o kernel.o

# Линковка ядра
kernel.bin: kernel_entry.o kernel.o
	$(LD) -o kernel.bin $(LDFLAGS) kernel_entry.o kernel.o

# Склеивание образа диска
os_image.bin: boot.bin kernel.bin
	cat boot.bin kernel.bin > os_image.bin

# Запуск в QEMU
run: all
	qemu-system-x86_64 -drive format=raw,file=os_image.bin

# Очистка мусора
clean:
	rm -rf *.o *.bin os_image.bin
