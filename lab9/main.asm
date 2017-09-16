.586
.model flat, stdcall

include ..\modules\longop.inc
include ..\modules\module.inc
include \masm32\include\comdlg32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include ..\modules\win.inc

includelib \masm32\lib\comdlg32.lib
includelib \lib\windows.lib
includelib \masm32\include\kernel32.lib
includelib \masm32\include\user32.lib

.data
n		   dd 48
factor_str db 70 dup(0)
factor_ptr	dd ?
copy_ptr	dd ?
fileName	db 255 dup(0)
fileHandler dd ?
rn			db 13, 10, 0
write_res	dd ?

caption		db "Lab 8", 0
type_file	db "Для вибору імені файлу натисніть ОК", 0
done		db "Факторіали записано", 0

.code
ChooseFileName proc
	LOCAL ofn : OPENFILENAME
	invoke RtlZeroMemory, ADDR ofn, SIZEOF ofn
	mov ofn.lStructSize, SIZEOF ofn
	mov ofn.lpstrFile, OFFSET fileName
	mov ofn.nMaxFile, SIZEOF fileName
	invoke GetSaveFileName, ADDR ofn
	ret
ChooseFileName endp

main:
	invoke MessageBoxA, 0, ADDR type_file, ADDR caption, 0
	call ChooseFileName
	cmp eax, 0
	je exit

	invoke CreateFile, ADDR fileName,
						GENERIC_WRITE,
						FILE_SHARE_WRITE,
						0, CREATE_ALWAYS,
						FILE_ATTRIBUTE_NORMAL,
						0
	cmp eax, INVALID_HANDLE_VALUE
	je exit
	mov dword ptr[fileHandler], eax

	invoke GlobalAlloc, GPTR, 7*4
	mov dword ptr[factor_ptr], eax
	mov byte ptr[eax], 1

	invoke GlobalAlloc, GPTR, 7*4
	mov dword ptr[copy_ptr], eax

	mov ebx, 1
	cycle:
	cmp ebx, dword ptr[n]
	ja cycle_end

		push 7
		push copy_ptr
		push ebx
		push factor_ptr
		call LongOp_Mul_Nx32

		push 7*4
		push factor_ptr
		push copy_ptr
		call LongOp_Copy

		push offset factor_str
		push 7*4
		push copy_ptr
		call StrDec

		invoke lstrlen, ADDR factor_str
		invoke WriteFile, fileHandler, ADDR factor_str, eax, ADDR write_res, 0
		invoke lstrlen, ADDR rn
		invoke WriteFile, fileHandler, ADDR rn, eax, ADDR write_res, 0

		inc ebx
	jmp cycle
	cycle_end:

	invoke GlobalFree, factor_ptr
	invoke GlobalFree, copy_ptr

	invoke MessageBoxA, 0, ADDR done, ADDR caption, 0

	exit:
	invoke ExitProcess, 0
end main
