;
; LAB 1_1.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 12:17:58 AM
;
;
; Viet chuong trinh doc lien tuc trang thai cua DIP Switch va gui ra bar LED. Neu Swich o trang thai OFF, LED tuong ung se tat.

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
	 IN R16, PINA ; DOC TRANG THAI DIP SWITCH
	 LDI R17, 0XFF
	 EOR R16, R17   ; NEU DIP SWITCH OFF TUONG UNG VOI MUC LOGIC 1, LED TUONG UNG SE SANG. NEN TA CAN PHAI DAO NGUOC GIA TRI DOC VE TU DIP SWITCH
	 OUT PORTB, R16 ; XUAT RA LED
	 RJMP LOOP

