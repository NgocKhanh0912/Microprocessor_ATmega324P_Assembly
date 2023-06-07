;
; LAB 1_1.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 12:20:31 AM
;
;
; Port A ket noi voi dip switch
; Port B ket noi voi bar led

	  .ORG 0
	  RJMP MAIN
	  .ORG 0X40 ; dua chuong trinh thoat ra khoi vung interrupts
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
	  IN R16, PINA ; DOC GIA TRI DIP SWITCH
	  LDI R17, 5 
	  ADD R16, R17 ; CONG THEM 5
	  OUT PORTB, R16 ; XUAT RA BAR LED
	  RJMP LOOP

