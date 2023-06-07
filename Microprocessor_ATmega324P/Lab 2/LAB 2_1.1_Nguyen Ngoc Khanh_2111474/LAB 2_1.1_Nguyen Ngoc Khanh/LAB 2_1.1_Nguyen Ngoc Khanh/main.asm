;
; LAB 2_1.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 1:40:54 PM
; 
;
; Viet chuong trinh delay 0.5ms su dung timer 0 tao song vuong 1K Hz tren chan PA0


                   .ORG 0
		   RJMP MAIN
		   .ORG 0X40 ; DUA CHUONG TRINH CHINH RA KHOI VUNG INTERRUPTS
MAIN:  
           LDI R16, HIGH(RAMEND)
           OUT SPH, R16
	   LDI R16, LOW(RAMEND)
	   OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

	   LDI R16, 0X01
	   OUT DDRA, R16 ; PA0 OUTPUT
	   LDI R17, 0X00 
	   OUT TCCR0A, R17 ; TIMER 0 MODE NOR
	   LDI R17, 0X00
	   OUT TCCR0B, R17 ; MODE NOR STOP
START: 
           SBI PORTA, 0 ; MUC CAO CUA XUNG VUONG
           LDI R17, -62 ; CLK CHIA 64, F = 8MHZ
	   RCALL DELAY500US

	   CBI PORTA, 0 ; MUC THAP CUA XUNG VUONG
	   LDI R17, -62
	   RCALL DELAY500US
	   RJMP START


;--------------------------------------------------------
DELAY500US:
            OUT TCNT0, R17 ; NAP GIA TRI BAN DAU
            LDI R17, 0X03 ; RUN, CHIA 64
            OUT TCCR0B, R17
WAIT: 
          IN R17, TIFR0
          SBRS R17, TOV0
	  RJMP WAIT
	  OUT TIFR0, R17
	  LDI R17, 0X00 ; STOP
	  OUT TCCR0B, R17
	  RET
; TH = 62x8 + 5x0,125 (CTCHINH) + 15x0,125 (CTCON)= 498,5 (US) -> SS = 0,3%
; TH = 62x8 + 7x0,125 (CTCHINH) + 15x0,125 (CTCON)= 498,75 (US) -> SS = 0,25%

