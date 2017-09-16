.586

.model flat, stdcall

include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \lib\kernel32.lib
includelib \lib\user32.lib

.data
	lab2_caption db "Лабораторна робота №2", 0
	made_by db "Виконав: Земін Володимир", 0
	
	vendor db 13 dup(0)
	vendor_caption db "vendor info", 0

	res dd 16 dup(0)
	
	cpuid_text db "EAX	xxxxxxxx", 13, 10,
				  "EBX	xxxxxxxx", 13, 10,
				  "ECX	xxxxxxxx", 13, 10,
				  "EDX	xxxxxxxx", 0
	
	cpuid_caption  db "cpuid xxxxxxxxh", 0
	
.code

;ця процедура записує 8 символів HEX коду числа
;перший параметр - 32-бітове число
;другий параметр - адреса буфера тексту
DwordToStrHex proc
	push ebp
	mov ebp,esp
	mov ebx,[ebp+8] ;другий параметр
	mov edx,[ebp+12] ;перший параметр
	xor eax,eax
	mov edi,7
@next:
	mov al,dl
	and al,0Fh ;виділяємо одну шістнадцяткову цифру
	add ax,48 ;так можна тільки для цифр 0-9
	cmp ax,58
	jl @store
	add ax,7 ;для цифр A,B,C,D,E,F
@store:
	mov [ebx+edi],al
	shr edx,4
	dec edi
	cmp edi,0
	jge @next
	pop ebp
	ret 8
DwordToStrHex endp

; параметр процедури -- параметр інструкції cpuid
ShowCPUID proc
	push ebp
	mov ebp, esp
	mov eax, [ebp+8]
	cpuid
	mov dword ptr[res], eax
	mov dword ptr[res+4], ebx
	mov dword ptr[res+8], ecx
	mov dword ptr[res+12], edx
	push [res]
	push offset [cpuid_text+4]
	call DwordToStrHex
	push [res+4]
	push offset [cpuid_text+18]
	call DwordToStrHex
	push [res+8]
	push offset [cpuid_text+32]
	call DwordToStrHex
	push [res+12]
	push offset [cpuid_text+46]
	call DwordToStrHex
	push [ebp+8]
	push offset [cpuid_caption+6]
	call DwordToStrHex
	invoke MessageBoxA, 0, ADDR cpuid_text, ADDR cpuid_caption, 0
	pop ebp
	ret 4
ShowCPUID endp

main:
	invoke MessageBoxA, 0, ADDR made_by, ADDR lab2_caption, 0
	
	mov eax, 0
	cpuid
	mov dword ptr[vendor], ebx
	mov dword ptr[vendor+4], edx
	mov dword ptr[vendor+8], ecx
	invoke MessageBoxA, 0, ADDR vendor, ADDR vendor_caption, 0

	push 0
	call ShowCPUID
	
	push 1
	call ShowCPUID
	
	push 2
	call ShowCPUID

	mov ebp, 80000000h
@for0to5:
	push ebp
	call ShowCPUID
	inc ebp
	cmp ebp, 80000005h
	jle @for0to5
	
	push 80000008h
	call ShowCPUID

	invoke ExitProcess, 0
end main
