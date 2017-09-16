.686
.xmm
.model flat, C

.code 
ScalarProduct_FPU proc result:DWORD, A:DWORD, B:DWORD, NUM:DWORD
	
	mov eax, result
	mov ebx, A
	mov ecx, B
	mov edx, NUM

	fld dword ptr[ebx+4*edx-2]
	fmul dword ptr[ecx+4*edx-2]
	dec edx

	cycle:
		fld dword ptr[ebx+4*edx]
		fmul dword ptr[ecx+4*edx]
		fadd
		dec edx
		cmp edx, 0 
	jge cycle

	fstp dword ptr[eax]
	ret

ScalarProduct_FPU endp
end