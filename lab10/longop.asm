.586
.model flat, c

.data

oper1 dd ?
sz  dd ?

.code

; LongOp_Sub(dword op1_ptr, dword op2_ptr, dword diff_ptr, dword size_in_dwords)
LongOp_Sub proc op1: dword, op2: dword, diff: dword, size_in_dwords: dword
	
	mov esi, op1
	mov edx, op2
	mov edi, diff

	mov ecx, 0
	clc
	pushfd
	SubAB:
		mov eax, dword ptr[esi+4*ecx]
		popfd
		sbb eax, dword ptr[edx+4*ecx]
		pushfd
		mov dword ptr[edi+4*ecx], eax
		inc ecx
		cmp ecx, size_in_dwords
	jl SubAB
	popfd
	ret 
LongOp_Sub endp

; LongOp_Add(dword op1_ptr, dword op2_ptr, dword sum_ptr, dword size_in_dwords)
LongOp_Add proc op1: dword, op2: dword, sum: dword, size_in_dwords: dword
	
	push esi
	push edi

	mov esi, op1
	mov edx, op2
	mov edi, sum

	mov ecx, 0
	clc
	pushfd

	AddAB:
		mov eax, dword ptr[esi+4*ecx]
		popfd
		adc eax, dword ptr[edx+4*ecx]
		pushfd
		mov dword ptr [edi+4*ecx], eax
		inc ecx
		cmp ecx, size_in_dwords
	jl AddAB
	popfd
	pop edi
	pop esi

	ret
LongOp_Add endp

; LongOp_Mul(dword op1_ptr, dword op2_ptr, dword prod_ptr, dword size_in_dwords)
LongOp_Mul proc op1: dword, op2: dword, prod: dword, size_in_dwords: dword
	
	mov eax, op1
	mov dword ptr[oper1], eax
	mov eax, size_in_dwords
	mov dword ptr[sz], eax

	push ebp
	mov ecx, op2
	mov edi, prod
	mov ebx, 0
	cycle:
		mov esi, 0
		clc
		pushfd
		mov ebp, 0
		cycle2:
			mov eax, dword ptr[oper1]
			mov eax, dword ptr[eax+4*esi]
			mul dword ptr[ecx+4*ebx]
			popfd
			adc dword ptr[edi+4*esi], eax
			pushfd

			mov eax, ebp
			sahf
			adc dword ptr[edi+4*esi+4], edx
			lahf
			mov ebp, eax
			inc esi
			cmp esi, dword ptr[sz]
		jl cycle2
		popfd
		adc dword ptr[edi+4*esi], 0
		add edi, 4
		inc ebx
		cmp ebx, dword ptr[sz]
	jl cycle
	
	pop ebp
	ret
LongOp_Mul endp

end