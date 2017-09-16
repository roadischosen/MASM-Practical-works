.586
.model flat, stdcall


include ..\modules\module.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
TextBuf db 64 dup(0)
Caption db "Lab 3", 0

DigitBuffer db 1200 dup(0)

Sizes dd 1, 1, 2, 2, 4, 4, 8, 8, 4, 4, 4, 8, 8, 8, 10, 10, 10

Values 	db 19
		db -19
		dw 19
		dw -19
		dd 19
		dd -19
		dq 19
		dq -19
		dd 19.0
		dd -38.0
		dd 19.19
		dq 19.0
		dq -38.0
		dq 19.19
		dt 19.0
		dt -38.0
		dt 19.19

.code
main:
	mov edi, offset DigitBuffer
	mov esi, offset Values
	mov ebx, 0
	cycle:
		push edi
	
		push edi
		push esi
		push dword ptr[Sizes+ebx]
		call StrHex
	
		mov edi, eax
		mov byte ptr[edi], 0Ah
		inc edi
	
		push edi
		push esi
		push dword ptr[Sizes+ebx]
		call StrBin 
	
		mov edi, eax
		mov byte ptr[edi], 0Ah
		inc edi
	
		pop eax
		invoke MessageBox, 0, eax, ADDR Caption, 0
	
		add esi, dword ptr[Sizes+ebx]
		add ebx, 4
		cmp ebx, 68
	jne cycle

	push offset DigitBuffer
	push 1200
	call SaveToClipboard

    invoke ExitProcess, 0
end main
end
