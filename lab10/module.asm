.586
.model flat, c

.code
;��������� StrHex ������ ����� ����������������� ����
;������ �������� - ������ ������ ���������� (����� �������)
;������ �������� - ������ �����
;����� �������� - ���������� ����� � ������
;������� ������ �������� ���� � eax
StrHex proc sz: dword, number: dword, buffer: dword
	
	push ebx
	push esi

	mov ecx, sz ; bytes count
	cmp ecx, 0
	jle @exitp
		mov esi, number ; number addr
		mov ebx, buffer ; buffer addr
		@cycle:
			mov dl, byte ptr[esi+ecx-1] ;���� ����� - �� �� hex-�����
			mov al, dl
			shr al, 4 ;������ �����
			call HexSymbol_MY
			mov byte ptr[ebx], al
			mov al, dl ;������� �����
			call HexSymbol_MY
			mov byte ptr[ebx+1], al
			mov eax, ecx
			cmp eax, 4
			jle @next
				dec eax
				and eax, 3 ;������� ������� ����� �� ��� ����
				cmp al, 0
				jne @next
					mov byte ptr[ebx+2], 32 ;��� ������� �������
					inc ebx
			@next:
			add ebx, 2
			dec ecx
		jnz @cycle
		mov byte ptr[ebx], 0 ;����� ���������� �����
		mov eax, ebx
	@exitp:

	pop esi
	pop ebx

	ret
StrHex endp

HexSymbol_MY proc
	and al, 0Fh
	add al, 48 ;��� ����� ����� ��� ���� 0-9
	cmp al, 58
	jl @exitp
	add al, 7 ;��� ���� A,B,C,D,E,F
	@exitp:
	ret
HexSymbol_MY endp

end