;
; LAB 2_1.2.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 1:41:56 PM
; 
;
; Viet chuong trinh tao 1 xung vuong 64us su dung timer 0 o che do normal mode, ngo ra su dung chan OC0

                   .ORG 0
		   RJMP MAIN
		   .ORG 0X40 ; DUA CHUONG TRINH RA KHOI VUNG INTERRUPTS
MAIN:  
           LDI R16, HIGH(RAMEND)
           OUT SPH, R16
	   LDI R16, LOW(RAMEND)
	   OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

	   LDI R16, 0X08
	   OUT DDRB, R16 ; PB3 OUTPUT OC0A

	   LDI R17, 0X00 
	   OUT TCCR0A, R17 ; TIMER 0 MODE NOR
	   LDI R17, 0X00
	   OUT TCCR0B, R17 ; MODE NOR STOP
START: 
           SBI PORTB, 3 ; MUC CAO CUA XUNG VUONG
           LDI R17, -32 ; 255 + 1 - 32 = 224 = E0
	   RCALL DELAY32US

	   CBI PORTB, 3 ; MUC THAP CUA XUNG VUONG
	   LDI R17, -32 
	   RCALL DELAY32US
	   RJMP START

;--------------------------------------------------------

DELAY32US:  OUT TCNT0, R17 ; NAP GIA TRI BAN DAU
            LDI R17, 0X02 ; RUN, CHIA 8
            OUT TCCR0B, R17
WAIT:     IN R17, TIFR0 ; DOC CO BAO TRAN
          SBRS R17, TOV0 
	  RJMP WAIT ; NEU CHUA TRAN, NHAY LAI WAIT
	  OUT TIFR0, R17 ; XOA CO BAO TRAN
	  LDI R17, 0X00 ; STOP
	  OUT TCCR0B, R17
	  RET