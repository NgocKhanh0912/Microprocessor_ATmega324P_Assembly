;
; LAB 2_2.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 1:47:22 PM
; 
;
; ket noi 1 port cua avr vao header J34. Ket noi 2 chan port khac vao tin hieu nLE0 va nLE1 tren header J82
; Set jumper de cap nguon cho LED 7 doan
; Viet chuong trinh hien thi so 0123 len 4 LED 7 doan, su dung timer 0 de quet LED

; PORT B KET NOI VOI J34
; PC0 VA PC1 NOI VOI NLE0 VA NLE1

                   .EQU OUTPORT = PORTB
		   .EQU SR_ADR = 0X100 ; DIA CHI SRAM LUU CAC SO 0123
		   .ORG 0
		   RJMP MAIN
		   .ORG 0X40 ; DUA CHUONG TRINH RA KHOI VUNG INTERRUPTS
MAIN: 
          LDI R16, HIGH(RAMEND)
	  OUT SPH, R16
	  LDI R16, LOW(RAMEND)
	  OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

          LDI R16, 0X03
          OUT DDRC, R16 ; PC0 PC1 OUTPUT

	  CBI PORTC, 0 ; KHOA NGO RA U2
	  CBI PORTC, 1 ; KHOA NGO RA U3

	  LDI R16, 0XFF
	  OUT DDRB, R16 ; PORTB LA OUTPUT

	  LDI XH, HIGH(SR_ADR)
	  LDI XL, LOW(SR_ADR) ; LAY DIA CHI SRAM DE LUU 0123
	  LDI R17, 3
	  ST X+, R17
	  LDI R17, 2
	  ST X+, R17
	  LDI R17, 1
	  ST X+, R17
	  LDI R17, 0
	  ST X, R17

START:    RCALL SCAN_4LA
          RJMP START

;--------------------------------------------------
SCAN_4LA: 
              LDI R18, 4 ; SO LAN QUET LED
              LDI R19, 0XFE ; 1111 1110, LED 0 BAT DAU
              LDI XH, HIGH(SR_ADR)
              LDI XL, LOW(SR_ADR)
LOOP: 
              LDI R17, 0XFF ; LAM TOI CAC DEN

              OUT OUTPORT, R17
	      SBI PORTC, 1 ; MO U3
	      CBI PORTC, 1 ; KHOA U3

	      LD R17, X+ ; NAP SO BCD TU SRAM
	      RCALL GET_7SEG ; LAY MA 7 DOAN

	      OUT OUTPORT, R17 ; XUAT MA 7 DOAN
	      SBI PORTC, 0 ; MO U2
	      CBI PORTC, 0 ; KHOA U2

	      OUT OUTPORT, R19 ; XUAT MA QUET LED O U3
	      SBI PORTC, 1 ; MO U3
	      CBI PORTC, 1 ; KHOA U3

	      RCALL DELAY20MS
	      SEC ; C = 1 CHUAN BI QUAY TRAI
	      ROL R19 ; MA QUET LED KE TIEP
	      DEC R18
	      BRNE LOOP ; QUAY LAI LOOP KHI CHUA QUET DU 4 LAN
	      RET

;---------------------------------------------------
GET_7SEG: 
                  LDI ZH, HIGH(TAB << 1)
                  LDI ZL, LOW(TAB << 1)
		  ADD R30, R17 ; CONG OFFSET VAO ZL
		  LDI R17, 0
		  ADC R31, R17 ; CONG CARRY NEU CO
		  LPM R17, Z ; LAY MA 7 DOAN
		  RET

;---------------------------------
TAB: .DB 0XC0,0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
     .DB 0XC6,0XA1,0X86,0X8E
;-----------------------------------
; TAN SO QUET 50HZ = 20MS
DELAY20MS:         LDI R20, 0X00 
	           OUT TCCR0A, R20 ; TIMER 0 MODE NOR
	           LDI R20, 0X00
	           OUT TCCR0B, R20 ; MODE NOR STOP
		   LDI R20, -157
                   OUT TCNT0, R20 ; NAP GIA TRI BAN DAU
                   LDI R20, 0X05 ; RUN, CHIA 1024
		   OUT TCCR0B, R20
WAIT:     IN R20, TIFR0
          SBRS R20, TOV0
	  RJMP WAIT
	  OUT TIFR0, R20
	  LDI R20, 0X00 ; STOP
	  OUT TCCR0B, R20
	  RET
