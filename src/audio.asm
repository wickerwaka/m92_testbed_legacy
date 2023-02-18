CPU 186
BITS 16
ORG 0

CODE_SEG equ 0x0000
DATA_SEG equ 0x0000

IDB equ 0xfff
PRC equ 0xfeb
PMC1 equ 0xf0a
EXIC0 equ 0xf4c
EXIC1 equ 0xf4d
EXIC2 equ 0xf4e
RFM equ 0xfe1
WTC equ 0xfe8

;
; DEFINE SECTIONS
; Must come first in this file, no includes before it


; Code, 32KB max, accessed via CS or CODE_SEG. Near calls only
section .text start=0 vstart=0
; Read only data, 32KB max, accessed via CS: or DATA_SEG
section .data start=0x8000 vstart=0x8000
; RAM. Uninitialized. Accessed via RAM_SEG or SS:
section .bss start=0xa0000

; VECTOR TABLE MUST COME FIRST
section .text
	dd 24 dup (generic_handler)
	dd p0_handler
	dd p1_handler
	dd (256 - 26) dup (generic_handler)

;
; MODULES
;

%include "src/util.asm"

;
; MAIN ENTRYPOINT
;
section .text
entry:
	mov ax, 0xa000
	mov ss, ax
	mov ds, ax
	mov sp, 0xf00

	call config_system
	sti

.loop:
	jmp .loop



config_system:
	push ds
	mov ax, 0xff00 ; default IDB
	mov ds, ax
	mov ax, 0x9f00
	mov [IDB], ah
	mov ds, ax ; new IDB

	mov byte [PRC], 0x4c
	mov byte [PMC1], 0x80

	mov byte [EXIC0], 0x47
	mov byte [EXIC1], 0x07
	mov byte [EXIC2], 0x47

	mov byte [RFM], 0x00
	mov word [WTC], 0x5555

	mov byte [PRC], 0x0c

	pop ds
	ret


align 4
p0_handler:
	nop
	nop
	nop
	nop
	db 0x0f, 0x92 ; FINI
	iret

align 4
p1_handler:
	push ax
	mov al, ss:[0x8044]
	mov ss:[0x8046], al
	mov ss:[0x8044], al
	pop ax
	db 0x0f, 0x92 ; FINI
	iret

align 4
generic_handler:
	nop
	iret

;
; RAM accessed via DATA_SEG or ss:
;
section .bss

;
; V35 STARTUP
;

section .text_start start=0x1fff0 vstart=0
startup:
	cli
	jmp CODE_SEG:entry
	db 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0



