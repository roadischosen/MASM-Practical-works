.586
.model flat, c
.data

op1  dd 0
sz   dd 0

.code
; 44b-operands adding
; LongOp_Add44(dword op1_ptr, dword op2_ptr, dword sum_ptr)
LongOp_Add44 proc
	push ebp
	mov ebp, esp

	mov esi, [ebp+8]  ; op1
	mov edx, [ebp+12] ; op2
	mov edi, [ebp+16] ; sum

	mov ecx, 0
	clc

	AddAB:
		mov eax, dword ptr[esi+ecx]
		adc eax, dword ptr[edx+ecx]
		mov dword ptr [edi+ecx], eax
		add ecx, 4
		cmp ecx, 44
	jl AddAB
	
	pop ebp
	ret 12
LongOp_Add44 endp

; 96b substraction
; LongOp_Sub96(dword op1_ptr, dword op2_ptr, dword diff_ptr)
LongOp_Sub96 proc
	push ebp
	mov ebp, esp

	mov esi, [ebp+8]  ; op1
	mov edx, [ebp+12] ; op2
	mov edi, [ebp+16] ; diff

	mov ecx, 0
	clc

	SubAB:
		mov eax, dword ptr[esi+ecx]
		sbb eax, dword ptr[edx+ecx]
		mov dword ptr[edi+ecx], eax
		add ecx, 4
		cmp ecx, 480
	jl SubAB
	
	pop ebp
	ret 12
LongOp_Sub96 endp
; LongOp_Add(dword op1_ptr, dword op2_ptr, dword sum_ptr, dword size_in_dwords)
LongOp_Add proc
	push ebp
	mov ebp, esp

	push esi
	push edi

	mov esi, [ebp+8]  ; op1
	mov edx, [ebp+12] ; op2
	mov edi, [ebp+16] ; sum

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
		cmp ecx, dword ptr[ebp+20]
	jl AddAB
	popfd
	pop edi
	pop esi
	pop ebp
	ret 16
LongOp_Add endp
; LongOp_Mul_Nx32(dword op1_ptr, dword op2, dword prod_ptr, dword op2_size_in_dwords)
LongOp_Mul_Nx32 proc
	push ebp
	mov ebp, esp

	push ebx
	push esi
	push edi

	mov esi, dword ptr[ebp+8]  ; *op1
	mov edi, dword ptr[ebp+16] ; *sum
	mov ebx, 0				   ; index
	mov ecx, 0

	clc
	pushfd

	cycle:
		mov eax, dword ptr[esi+4*ebx]  ; load first op1 dword
		mul dword ptr[ebp+12]		   ; mul with op2
		popfd
		adc eax, ecx				   ; partial sum
		pushfd
		mov dword ptr[edi+4*ebx], eax  ; write a partial sum
		mov ecx, edx

		inc ebx
		cmp ebx, dword ptr[ebp+20]	   ; operands size in dword blocks
	jl cycle
	popfd
	adc ecx, 0
	mov dword ptr[edi+4*ebx], ecx
	
	pop edi
	pop esi
	pop ebx

	pop ebp
	ret 16
LongOp_Mul_Nx32 endp
; Long_Op_MSOnes(dword src_ptr, dword size, dword res_ptr)
; returns the count of most significant high bits in the eax
LongOp_MSOnes proc
	push ebp
	mov ebp, esp
	push ebx
	push esi

	mov eax, 0
	mov ecx, dword ptr[ebp+12]	; size
	mov esi, dword ptr[ebp+8]	; data
	cycle:
		mov dl, byte ptr[esi+ecx-1]
		mov bl, dl
		xor bl, 255
		jz next
			@@:
				shl dl, 1
				jnc finish
				inc eax
			jmp @B
		next:
		add eax, 8
		dec ecx
	jnz cycle
	finish:
	mov ebx, dword ptr[ebp+16]
	mov dword ptr[ebx], eax
	pop esi
	pop ebx
	pop ebp
	ret 8
LongOp_MsOnes endp
; LongOp_Mul(dword op1_ptr, dword op2_ptr, dword prod_ptr, dword size_in_dwords)
LongOp_Mul proc
	push ebp
	mov ebp, esp

	mov eax, dword ptr[ebp+8]
	mov dword ptr[op1], eax
	mov eax, dword ptr[ebp+20]
	mov dword ptr[sz], eax

	mov ecx, dword ptr[ebp+12]
	mov edi, dword ptr[ebp+16]
	mov ebx, 0
	cycle:
		mov esi, 0
		clc
		pushfd
		mov ebp, 0
		cycle2:
			mov eax, dword ptr[op1]
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
	ret 16
LongOp_Mul endp
; LongOp_Div10(dword src_ptr, dword size, dword quot_ptr)
LongOp_Div10 proc
	push ebp
	mov ebp, esp

	push ebx
	push esi
	push edi
	
	mov esi, dword ptr[ebp+8]
	mov ecx, dword ptr[ebp+12]
	mov edi, dword ptr[ebp+16]

	mov al, byte ptr[esi+ecx-1]
	shl ax, 4
	and ah, 1111b
	mov bl, 00010000b
	xor bh, bh
	cycle:
		cmp bl, 1
		ja @f
			mov al, byte ptr[esi+ecx-2]
		@@:
		and ah, 00011111b
		cmp ah, 1010b
		jl @f
			or bh, bl
			sub ah, 1010b
		@@:
		shl ax, 1
		shr bl, 1
	jnz cycle
		mov byte ptr[edi+ecx-1], bh
		xor bh, bh
		or bl, 10000000b
	loop cycle
	xor al, al
	shr ah, 1
	mov al, ah

	pop edi
	pop esi
	pop ebx

	pop ebp
	ret 12
LongOp_Div10 endp

; LongOp_Div10_II(dword src_ptr, dword size, dword quot_ptr)
LongOp_Div10_II proc
	push ebp
	mov ebp, esp

	push ebx
	push esi
	push edi
	
	mov esi, dword ptr[ebp+8]
	mov ecx, dword ptr[ebp+12]
	mov edi, dword ptr[ebp+16]
	
	mov dl, 01010b
	
	xor ah, ah
	cycle:
		mov al, [esi+ecx-1]
		div dl
		mov [edi+ecx-1], al
	loop cycle
	
	mov al, ah

	pop edi
	pop esi
	pop ebx

	pop ebp
	ret 12
LongOp_Div10_II endp

; LongOp_Copy(dword src_ptr, dword dest_ptr, dword size)
LongOp_Copy proc
	push ebp
	mov ebp, esp

	mov eax, dword ptr[ebp+8]
	mov ecx, dword ptr[ebp+16]
	mov ebp, dword ptr[ebp+12]
	cycle:
		mov dl, byte ptr[eax+ecx-1]
		mov byte ptr[ebp+ecx-1], dl
	loop cycle

	pop ebp
	ret 12
LongOp_Copy endp

end
