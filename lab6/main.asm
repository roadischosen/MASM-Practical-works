.586
.model flat, stdcall

include ..\modules\longop.inc
include ..\modules\module.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \lib\kernel32.lib
includelib \lib\user32.lib

.data
Value	db 64 dup(255)
Result	dd 0
Caption db "Lab 6", 0
Text	db "Count of the most significant set bits (assume 1F): xx", 0
Buffer	db 130 dup(0)
.code
main:
	mov byte ptr[Value+60], 0

	push offset Buffer
	push offset Value
	push 64
	call StrHex

	invoke MessageBox, 0, ADDR Buffer, ADDR Caption, 0

	push offset Result
	push 64
	push offset Value
	call LongOp_MSOnes

	push offset [Text+52]
	push offset Result
	push 1
	call StrHex
	invoke MessageBox, 0, ADDR Text, ADDR Caption, 0

	invoke ExitProcess, 0
end main
