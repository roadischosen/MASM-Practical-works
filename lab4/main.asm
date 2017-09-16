.586
.model flat, stdcall


include ..\modules\module.inc
include ..\modules\longop.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data

CaptionAdd db "A + B", 0
CaptionSub db "A - B", 0
ResText db 250 dup(0)

AddA db 44 dup(0) ;352b
AddB db 44 dup(0)
Sum  db 44 dup(0)

SubA db 96 dup(0) ;768b
SubB db 96 dup(0)
Diff db 96 dup(0)

.code
main:

	mov ecx, 0
	setAB1:
		mov ax, 8001h
		mov word ptr[AddA+4*ecx], 1
		mov word ptr[AddA+4*ecx+2], ax
		mov dword ptr[AddB+4*ecx], 80000001h
		inc ax
		inc ecx
		cmp ecx, 44
	jl setAB1
	
	push offset Sum
	push offset AddB
	push offset AddA
	call LongOp_Add44
	
	push offset ResText
	push offset Sum
	push 44
	call StrHex
	
	invoke MessageBox, 0, ADDR ResText, ADDR CaptionAdd, 0
	
	mov ecx, 9
	setAB2:
		mov dword ptr[AddA+4*ecx], ecx
		mov dword ptr[AddB+4*ecx], 1
		inc ecx
		cmp ecx, 20
	jl setAB2
	
	push offset Sum
	push offset AddB
	push offset AddA
	call LongOp_Add44
	
	push offset ResText
	push offset Sum
	push 44
	call StrHex
	
	invoke MessageBox, 0, ADDR ResText, ADDR CaptionAdd, 0

	mov ecx, 9
	setAB3:
		mov dword ptr[SubA+4*ecx], 0
		mov dword ptr[SubB+4*ecx], ecx
		inc ecx
		cmp ecx, 33
	jl setAB3
	
	push offset Diff
	push offset SubB
	push offset SubA
	call LongOp_Sub96
	
	push offset ResText
	push offset Diff
	push 96
	call StrHex
	
	invoke MessageBox, 0, ADDR ResText, ADDR CaptionSub, 0

    invoke ExitProcess, 0
end main
end