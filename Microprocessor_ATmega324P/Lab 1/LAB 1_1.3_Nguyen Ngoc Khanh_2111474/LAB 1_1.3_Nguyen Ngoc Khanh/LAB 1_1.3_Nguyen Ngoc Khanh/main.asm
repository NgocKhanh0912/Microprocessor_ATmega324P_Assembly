;
; LAB 1_1.3_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 12:31:59 AM
;
;
; Ket noi va thuc hien chuong trinh tinh tich cua 2 nibble cao va thap cua PORTA va gui ra PORT B. Coi nhu 2 nibble nay la 2 so khong dau
; VD: PORTA = 0b0111_1111, thi PORTB = 3*15.

; Port A ket noi voi dip switch
; Port B ket noi voi bar led
	 .ORG 0
	 RJMP MAIN
	 .ORG 0X40 ; dua chuong trinh ra khoi vung interrupts
MAIN: 
	 LDI R16, HIGH(RAMEND)
	 OUT SPH, R16
	 LDI R16, LOW(RAMEND)
	 OUT SPL, R16 ; dua stack len vung dia chi cao
	 LDI R16, 0XFF

	 OUT DDRB, R16 ; KHAI BAO PB0:7 LA NGO RA
	 LDI R16, 0X00

	 OUT DDRA, R16 ; KHAI BAO PA0:7 LA NGO VAO
	 LDI R16, 0XFF
	 OUT PORTA, R16 ; DIEN TRO KEO LEN PA0:7
LOOP: 
	 IN R16, PINA ; DOC TRANG THAI INPUT CUA PORT A

	 MOV R17, R16
	 LDI R19, 0X0F
	 AND R17, R19 ; LAY NIBBLE THAP CUA PORT A

	 MOV R18, R16
	 LDI R19, 0XF0
	 AND R18, R19 ; LAY NIBBLE CAO CUA PORT A
	 SWAP R18

	 MUL R17, R18 ; R0 CHUA KET QUA CUA R17 X R18
	 MOV R16, R0 ; DUA KET QUA CHUA TRONG R0 VAO R16
	 OUT PORTB, R16 ; XUAT KET QUA RA PORB
	 RJMP LOOP
