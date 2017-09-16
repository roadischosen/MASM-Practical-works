.686
.xmm
.model flat, C

.code
ScalarProduct_SSE proc result:DWORD, A:DWORD, B:DWORD, NUM:DWORD
local temp: dword
	mov edx, result
	mov eax, A
	mov ebx, B
	mov ecx, NUM
	
	shl ecx, 2
	sub ecx, 16
	mov temp, 0
	movss xmm2, temp
	cycle:
		movaps xmm0, xmmword ptr[eax + ecx]
		movaps xmm1, xmmword ptr[ebx + ecx]
		mulps xmm0, xmm1
		addps xmm2, xmm0

		sub ecx, 16
		cmp ecx, 0
	jge cycle

	haddps xmm2, xmm2
	haddps xmm2, xmm2
	movss dword ptr[edx], xmm2
	ret 
ScalarProduct_SSE endp

end
