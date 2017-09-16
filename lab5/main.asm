.586
.model flat, stdcall

include ..\modules\longop.inc
include ..\modules\module.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \lib\kernel32.lib
includelib \lib\user32.lib

.data
n		   dd 48
factor     dd 1, 7 dup(0)
sqr		   dd 13 dup(0)
factor_str db 70 dup(0)
sqr_str    db 120 dup(0)
part	   dd 7 dup(0ffffffffh)
res        dd 8 dup(0)
res_str    db 100 dup(0)
sqr_part   dd 14 dup(0)
sqr_part_str db 200 dup(0)
caption	   db "Lab 5", 0

.code
main:
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
	push offset factor
	push 7*4
	call StrHex

	invoke MessageBox, 0, ADDR factor_str, ADDR caption, 0

	push 7
	push offset sqr
	push offset factor
	push offset factor
	call LongOp_Mul

	push offset sqr_str
	push offset sqr
	push 13*4
	call StrHex

	invoke MessageBox, 0, ADDR sqr_str, ADDR caption, 0

	push 7
	push offset res
	push 0ffffffffh
	push offset part
	call LongOp_Mul_Nx32

	push offset res_str
	push offset res
	push 8*4
	call StrHex

	invoke MessageBox, 0, ADDR res_str, ADDR caption, 0

	push 7
	push offset sqr_part
	push offset part
	push offset part
	call LongOp_Mul

	push offset sqr_part_str
	push offset sqr_part
	push 14*4
	call StrHex

	invoke MessageBox, 0, ADDR sqr_part_str, ADDR caption, 0

	invoke ExitProcess, 0
end main