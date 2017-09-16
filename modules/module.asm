.586
.model flat, c

include ..\modules\longop.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.code

;процедура StrHex записує текст шістнадцятькового коду
;перший параметр - адреса буфера результату (рядка символів)
;другий параметр - адреса числа
;третій параметр - розрядність числа у байтах
;повертає адресу кінцевого нуля в eax
StrHex proc
	push ebp
	mov ebp, esp

	push ebx
	push esi

	mov ecx, [ebp+8] ; bytes count
	cmp ecx, 0
	jle @exitp
		mov esi, [ebp+12] ; number addr
		mov ebx, [ebp+16] ; buffer addr
		@cycle:
			mov dl, byte ptr[esi+ecx-1] ;байт числа - це дві hex-цифри
			mov al, dl
			shr al, 4 ;старша цифра
			call HexSymbol_MY
			mov byte ptr[ebx], al
			mov al, dl ;молодша цифра
			call HexSymbol_MY
			mov byte ptr[ebx+1], al
			mov eax, ecx
			cmp eax, 4
			jle @next
				dec eax
				and eax, 3 ;проміжок розділює групи по вісім цифр
				cmp al, 0
				jne @next
					mov byte ptr[ebx+2], 32 ;код символа проміжку
					inc ebx
			@next:
			add ebx, 2
			dec ecx
		jnz @cycle
		mov byte ptr[ebx], 0 ;рядок закінчується нулем
		mov eax, ebx
	@exitp:

	pop esi
	pop ebx

	pop ebp
	ret 12
StrHex endp

;процедура StrBin записує текст двійкового коду
;перший параметр - адреса буфера результату (рядка символів)
;другий параметр - адреса числа
;третій параметр - розрядність числа у байтах
;повертає адресу кінцевого нуля в eax
StrBin proc
	push ebx
	push esi

	push ebp
	mov ebp,esp
	mov ecx, [ebp+16] ;кількість байтів числа
	cmp ecx, 0
	jle @exitp
		mov esi, [ebp+20] ;адреса числа
		mov ebx, [ebp+24] ;адреса буфера результату
		@cycle:
			mov dl, byte ptr[esi+ecx-1] ;байт числа - це дві hex-цифри
			mov al, dl
			shr al, 4 ;старша цифра
			call Str4bits
			mov dword ptr[ebx], eax
			mov byte ptr[ebx+4], " "
			mov al, dl ;молодша цифра
			call Str4bits
			mov dword ptr[ebx+5], eax
			mov byte ptr[ebx+9], " "
			mov eax, ecx
			add ebx, 10
			dec ecx
		jnz @cycle
		dec ebx
		mov byte ptr[ebx], 0 ;рядок закінчується нулем
		mov eax, ebx
	@exitp:
	pop ebp
	pop esi
	pop ebx
	ret 12
StrBin endp

; input -- Nibble in al 
; output - str repr of its bin value
;          in eax, ready to mov into memory (reverse-ordered)
Str4bits proc
	push ebx
	push ecx
	
	mov bl, 1
	cycle:
		shl ecx, 8
		mov cl, 30h
		test al, bl
		jz zero
			or cl, 1
		zero:
		shl bl, 1
		test bl, 1111b
	jnz cycle

	mov eax, ecx

	pop ecx
	pop ebx
		
Str4bits endp

;ця процедура обчислює код hex-цифри
;параметр - значення AL
;результат -> AL
HexSymbol_MY proc
	and al, 0Fh
	add al, 48 ;так можна тільки для цифр 0-9
	cmp al, 58
	jl @exitp
	add al, 7 ;для цифр A,B,C,D,E,F
	@exitp:
	ret
HexSymbol_MY endp
; StrDec(dword num_ptr, dword size, dword res_ptr)
StrDec proc
	push ebp
	mov ebp, esp

	push ebx
	push esi
	push edi

	mov esi, dword ptr[ebp+8]
	mov ebx, dword ptr[ebp+12]
	mov edi, dword ptr[ebp+16]

	cycle:
		push esi
		push ebx
		push esi
		call LongOp_Div10
		add al, 48
		mov byte ptr[edi], al
		inc edi

		xor ecx, ecx
		check:
		cmp ecx, ebx
		je endch
			add ecx, 1
			cmp byte ptr[esi+ecx-1], 0
		je check

	jmp cycle
	endch:
	mov byte ptr[edi], 0

	mov esi, dword ptr[ebp+16]
	dec edi
	while_s:
	cmp esi, edi
	ja while_end
		mov bl, byte ptr[esi]
		mov bh, byte ptr[edi]
		mov byte ptr[esi], bh
		mov byte ptr[edi], bl
		inc esi
		dec edi
	jmp while_s
	while_end:

	pop edi
	pop esi
	pop ebx

	pop ebp
	ret 12
StrDec endp

;StrFloat32(dword float, dword_ptr res_str)
StrFloat32 proc float: dword, dest: dword
	local bcd_temp: tbyte
	local scale: dword
	
	mov edi, dest
	mov esi, float

	test esi, 80000000h ; place a sign -- if any
	jz positive
		mov byte ptr[edi], "-"
		inc edi
	positive:
	
	and esi, 7FFFFFFFh  ; cut off a sign bit
	jz zero
	
	cmp esi, 7FFFFFh	; unnormalized number -- error
	jle err
	
	cmp esi, 7F800000h  ; if exp == E(max) then it's nan (unsigned) or inf (signed)
	ja nan
	je inf
	
	mov scale, esi
	fld scale
	mov scale, 1000000
	fimul scale
	fbstp bcd_temp
	
	mov ebx, edi
	lea edx, bcd_temp
	mov ecx, 9
	cycle:
		cmp ecx, 6
		jne @f
			mov byte ptr[edi], "."
			inc edi
		@@:
		xor ah, ah
		mov al, [edx]
		inc edx
		shl ax, 4
		shr al, 4
		add ax, 3030h
		mov [edi], al
		mov [edi+1], ah
		add edi, 2
	loop cycle
	
	dec edi
	skip_zeros:
		cmp byte ptr[edi], "0"
		jne next
		dec edi
	jmp skip_zeros

	next:
	push edi
	reverse:
		mov al, [edi]
		mov ah, [ebx]
		mov [edi], ah
		mov [ebx], al
		inc ebx
		dec edi
		cmp ebx, edi
	jbe reverse
	
	pop edi
	inc edi
	jmp exit
	
	inf:
		mov dword ptr[edi], "fni"
		jmp add3
		
	err:
		mov edi, [ebp+12]
		mov dword ptr[edi], "rre"
		jmp add3

	nan:
		mov edi, [ebp+12]
		mov dword ptr[edi], "nan"
		jmp add3
		
	zero:
		mov edi, [ebp+12]
		mov dword ptr[edi], "0.0"
		
	add3:
		add edi, 3
	exit:
		mov byte ptr[edi], 0
		
	ret
StrFloat32 endp

; Write a text into the clipboard
; SaveToClipboard(char* text, dword size)
SaveToClipboard proc
	push ebp
	mov ebp, esp
	mov edx, dword ptr[ebp+8]
	inc edx
    invoke GlobalAlloc, 2, edx  ; 2 -- const for moveable memory
    mov ebx, eax
    invoke GlobalLock, dword ptr[ebx]
    
	mov ecx, dword ptr[ebp+8]
    mov esi, dword ptr[ebp+12]
    mov edi, eax
    rep movsb

    invoke GlobalUnlock, dword ptr[ebx]
    
    invoke OpenClipboard, 0
    invoke EmptyClipboard
    invoke SetClipboardData, 1, dword ptr[ebx]
    invoke CloseClipboard
	pop ebp
	ret 8
SaveToClipboard endp

end
