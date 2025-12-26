[org 0x7c00]

    ; 1. Заголовок совместимости для реального железа
    jmp short start
    nop
    times 33 db 0     ; Заглушка под BIOS Parameter Block (чтобы BIOS не затер код)

start:
    ; 2. Полная инициализация сегментов
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00    ; Стек растет вниз от загрузчика
    sti

    mov [BOOT_DRIVE], dl ; Сохраняем номер диска, переданный BIOS

    ; 3. Сброс дисковой системы (важно для реальных флешек)
    mov ah, 0
    mov dl, [BOOT_DRIVE]
    int 0x13

    ; 4. Загрузка ядра с диска
    call load_kernel

    ; 5. Переход в графический режим 320x200 (VGA 13h)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    ; 6. Переход в защищенный режим
    call switch_to_pm
    jmp $

%include "gdt.asm"

load_kernel:
    mov ah, 0x02
    mov al, 32          ; Читаем 32 сектора (ядро должно влезть)
    mov ch, 0           ; Цилиндр 0
    mov dh, 0           ; Головка 0
    mov cl, 2           ; Сектор 2 (сразу после загрузчика)
    mov dl, [BOOT_DRIVE]
    mov bx, 0x1000      ; Адрес в памяти (0x1000)
    int 0x13
    jc disk_error       ; Если ошибка — выводим 'E'
    ret

disk_error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    jmp $

[bits 16]
switch_to_pm:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp 0x08:init_pm    ; Дальний прыжок в 32-битный сегмент

[bits 32]
init_pm:
    mov ax, 0x10        ; Настройка сегментов данных (DATA_SEG из GDT)
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000    ; Стек в безопасном месте
    mov esp, ebp
    
    call 0x1000         ; Прыгаем в ядро (kernel_entry -> main)
    jmp $

BOOT_DRIVE db 0
times 510-($-$$) db 0
dw 0xaa55               ; Магическая сигнатура загрузчика
