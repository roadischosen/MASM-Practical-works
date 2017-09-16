.586
.model flat, stdcall

include ..\modules\longop.inc
include ..\modules\module.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
n		   dd 48
m		   db 5
x		   dd 23
y		   dd 0
y_str0	   db "y = "
y_str	   db 20 dup(0)
factor     dd 1, 7 dup(0)
factor_str db 70 dup(0)
caption	   db "Lab 7", 0

.code
main:
	;mov dword ptr[n], "123"

	mov eax, offset n
	mov ebx, dword ptr[n]
	cycle:
		push 7
		push offset factor
		push ebx
		push offset factor
		call LongOp_Mul_Nx32

		dec ebx
		cmp ebx, 1
	jg cycle
	
	push offset factor_str
	push 7*4
	push offset factor
	call StrDec

	invoke MessageBox, 0, ADDR factor_str, ADDR caption, 0

	mov eax, 5
	mov cl, byte ptr[m]
	shl eax, cl
	xor edx, edx
	mov ebx, dword ptr[x]
	inc ebx
	idiv ebx
	mov dword ptr[y], eax

	push offset y_str
	push 4
	push offset y
	call StrDec

	invoke MessageBox, 0, ADDR y_str0, ADDR caption, 0

	invoke ExitProcess, 0
end main
