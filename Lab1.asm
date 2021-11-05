; Numeris sąraše- 12.
; A) 12. Programa sukeičia ketvirtą ir devintą simbolius vietomis, o antrą nuo galo padaro ‘+’.
; B) 9. Programa spausdina kiekvieno įvesto baito trečio, ketvirto ir priešpaskutinio bitų sumą.
; C) 10. Programa apskaičiuoja ir išspausdina reiškinio ||a-c| - |b % c - 10|| + min(c%10,b%10) reikšmę

 %include 'yasmmac.inc'
 org 100h
 section .text
	startas:
		macPutString "Deividas Baltuska, 1 kursas, 2 grupe", crlf, '$'
		
		macPutString "Iveskite simboliu eilute (simboliu kiekis 10-80)", crlf, '$'
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; string'o input'as

		mov ah, 0Ah
		mov dx, buferisIvedimui
		int 21h
		macNewLine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; bitu skaiciavimas
		
		mov bx, 0
		mov di, 2
		ciklas:
			mov cl, 0
			
			mov al, [buferisIvedimui+di]
			and al, 8
			shr al, 3
			add cl, al
			
			mov al, [buferisIvedimui+di]
			and al, 16
			shr al, 4
			add cl, al
			
			mov al, [buferisIvedimui+di]
			and al, 64
			shr al, 6
			add cl, al
			
			mov dx, [buferisIvedimui+di]
			mov ah, 0x2
			int 0x21
			macPutString " baito trecio, ketvirto ir priespaskutinio bitu suma: $"
			mov ax, 0
			mov al, cl
			call procPutUInt16
			macNewLine
			
			inc bl
			inc di
		
		cmp bl, [buferisIvedimui+1]
		jne ciklas
		
		macNewLine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; string'o tvarkymas

		mov al, [buferisIvedimui+5]					;sukeitimas 4 ir 9 simboliu
		mov ah, [buferisIvedimui+10]
		mov [buferisIvedimui+5], ah
		mov [buferisIvedimui+10], al
		
		mov bx, 0
		mov bl, [buferisIvedimui+1]
		mov byte [buferisIvedimui+bx], 0x2B			;keiciamas antras is galo simbolis i '+'
		mov byte [buferisIvedimui+bx+3], 0x0A		
		mov byte [buferisIvedimui+bx+4], '$'		
		
		mov ah, 9									;isvedimas 
		mov dx, buferisIvedimui+2
		int 0x21
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; skaiciu input'as
		
		macPutString "Iveskite skaiciu a, b ir c:", crlf, '$'
		call procGetUInt16
		mov [sk1], ax
		macNewLine
		
		call procGetUInt16
		mov [sk2], ax
		macNewLine
		
		call procGetUInt16
		mov [sk3], ax
		macNewLine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ivestu skaiciu skaiciavimas ||a-c| - |b % c - 10|| + min(c%10,b%10)
		mov ax, [sk1]
		mov bx, [sk3]
		cmp ax, bx					; lyginam a ir b
		jae continue1				
		xchg ax, bx					; jeigu a greater or equal, tada sita step praleidziam
		continue1
		sub ax, bx					; is didesnio atimam mazesni
		mov [temp], ax				; issaugotas |a-c|
		
		mov dx, 0
		mov ax, [sk2]
		mov bx, [sk3]
		div bx						; dalinam b/c, liekana dx
		mov ax, dx					; liekana is dx keliam i ax
		mov bx, 10					; i bx ikeliam 10, tai, is ko arba ka atimsim
		cmp ax, 10
		jae continue2				; jeigu ax yra didesnis, arba lygus kaip bx, praleidziam ju sukeitima
		xchg ax, bx
		continue2
		sub ax, bx					; is didesnio atimam mazesni, |b%c-10| issaugotas ax'e
		
		mov bx, [temp]				;ax'e |b%c-10|, bx'e |a-c|
		cmp ax, bx					;jeigu ax didesnis arba lygus, mes ju nekeiciam
		jae continue3
		xchg ax, bx
		continue3
		sub ax, bx					; is didesnio atimam mazesni
		mov [temp], ax				; issaugotas ||a-c|-|b%c-10||
		
		mov dx, 0
		mov ax, [sk2]				; ax'e dabar b
		mov bx, 10					; bx'e dabar 10
		div bx
		mov ax, dx					; b%10 (dx) -> ax
		mov [temp2], ax				; issaugotas b%10 i temp2
		
		mov dx, 0
		mov ax, [sk3]
		mov bx, 10
		div bx						; dalinam c/10, dx'e c%10
		mov ax, dx					;  kuri cia perkeliam i ax, paruosdami darbui (ax = c%10)
		mov bx, [temp2]				; paruosiam palyginimui b%10 (temp2)(bx) ir c%10 (ax)
		cmp ax, bx					; mazesnis skaicius irasomas i ax (min(b%10, c%10))
		jbe continue4				; norint pakeisti i max(), jbe reikia pakeisti i jae
		mov ax, bx
		continue4
		
		add ax, [temp]				; prie min() reiksmes pridedam viso modulio ats ||a-c| - |b % c - 10||
		
		macPutString "Atsakymas: $", crlf
		call procPutUInt16
		
		exit
		
%include 'yasmlib.asm' 
 section data
	buferisIvedimui:
		db 80h, 00h, '******************************************************************************************'
	temp:
		dw 00
	temp2:
		dw 00
	sk1:
		dw 00
	sk2:
		dw 00
	sk3:
		dw 00
	suma:
		dw 00
 section .bss