.586
.model flat, c

.code
;процедура StrHex записує текст шістнадцятькового коду
;перший параметр - адреса буфера результату (рядка символів)
;другий параметр - адреса числа
;третій параметр - розрядність числа у байтах
;повертає адресу кінцевого нуля в eax
StrHex proc sz: dword, number: dword, buffer: dword
	
	push ebx
	push esi

	mov ecx, sz ; bytes count
	cmp ecx, 0
	jle @exitp
		mov esi, number ; number addr
		mov ebx, buffer ; buffer addr
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

	ret
StrHex endp

HexSymbol_MY proc
	and al, 0Fh
	add al, 48 ;так можна тільки для цифр 0-9
	cmp al, 58
	jl @exitp
	add al, 7 ;для цифр A,B,C,D,E,F
	@exitp:
	ret
HexSymbol_MY endp

end