;
; LAB 2_2.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 1:48:15 PM
; 
;
; Ket noi port cua avr vao dip switch, gia su do la porta
; viet chuong trinh hien gia tri porta * 9 len 4 led 7 doan
; PORT A KET NOI DIP SWITCH
; PORT B KET NOI 4 LED
; PC0 PC1 KET NOI NLE0 NLE1

                   .EQU OUTPORT = PORTB
		   .EQU SR_ADR = 0X100 ; DIA CHI CHUA CAC SO BCD
		   .ORG 0
		   RJMP MAIN
		   .ORG 0X40 ; DUA CHUONG TRINH CHINH RA KHOI VUNG INTERRUPTS
 MAIN:    
                   LDI R16, HIGH(RAMEND)
		   OUT SPH, R16
		   LDI R16, LOW(RAMEND)
		   OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

                   LDI R16, 0X03
                   OUT DDRC, R16 ; PC0 PC1 OUTPUT

	           CBI PORTC, 0 ; KHOA NGO RA U2
	           CBI PORTC, 1 ; KHOA NGO RA U3

		   LDI R16, 0X00
	           OUT DDRA, R16 ; PORTA LA INPUT

	           LDI R16, 0XFF
	           OUT DDRB, R16 ; PORTB LA OUTPUT

		   LDI R20, 0X00
		   LDI R21, 0X00
	  
START:  
                   LDI R23, 9 ; PINA * 9

                   IN R17, PINA
		   COM R17
                   MUL R17, R23
		   MOVW R24, R0

                   RCALL BIN16_BCD
                   RCALL SCAN_4LA
                   RJMP START

;------------------------------------------------
; BIN16_BCD CHUYEN SO NHI PHAN 16 BIT SANG SO BCD 4 DIGIT
; INPUT R25:R24 = SO NHI PHAN 16 BIT
; OUTPUT R21, R20 = BCD NEN, R21 TRONG SO CAO
; SU DUNG CTC DIV16_8 , 10 = SO CHIA
BIN16_BCD: 
                   CLR R20
                   CLR R21
		   RCALL DIV16_8
		   MOV R20, R16 ; R20 = DU : BCD DON VI
		   RCALL DIV16_8
		   SWAP R16 ; BCD CHUC LEN 4 BIT CAO
		   OR R20, R16 ; GHEP BCD NEN
		   RCALL DIV16_8 ; BCD TRAM
		   MOV R21, R16
		   RCALL DIV16_8 ; BCD NGAN
		   SWAP R16
		   OR R21, R16
		   RET
;-------------------------------------------------
; DIV16_8 CHIA 2 SO NHI PHAN 16 BIT CHO 8 BIT
; INPUT R25:R24 LA SO BI CHIA, SO CHIA = 10
; OUTPUT R25:R24 = THUONG SO, R16 LA DU SO
; SD R28:R29 DE CAT THUONG SO TAM
DIV16_8: 
             CLR R28
             CLR R29
GT_DV: 
             SBIW R24, 10
             BRCS LT_DV ; C = 1 KHONG CHIA DUOC
	     ADIW R28, 1
	     RJMP GT_DV
LT_DV: 
             ADIW R24, 10 ; LAY LAI DU SO
             MOV R16, R24 ; R16 = DU SO
	     MOVW R24, R28 ; R24 = THUONG SO
	     RET

;-------------------------------------------------
; BCD_UNP TACH SO BCD NEN THANH KHONG NEN
; INPUT R20 = SO BCD NEN CHUC - DON VI
;       R21 = SO BCD NEN NGAN - TRAM
; OUTPUT CAT VAO 4 O NHO DAU SRAM
BCD_UNP: 
                 LDI XH, HIGH(SR_ADR)
                 LDI XL, LOW(SR_ADR) 
		 MOV R17, R20 ; LAY BCD NEN TRONG SO THAP
		 ANDI R17, 0X0F ; LAY BCD DON VI
		 ST X+, R17
		 MOV R17, R20
		 SWAP R17
		 ANDI R17, 0X0F ; LAY BCD CHUC
		 ST X+, R17
		 MOV R17, R21 ; LAY BCD NEN TRONG SO CAO
		 ANDI R17, 0X0F ; LAY BCD TRAM
		 ST X+, R17
		 MOV R17, R21
		 SWAP R17
		 ANDI R17, 0X0F ; LAY BCD NGAN
		 ST X+, R17
		 RET

;--------------------------------------------------
SCAN_4LA:
             RCALL BCD_UNP
             LDI R18, 4 ; SO LAN QUET LED
             LDI R19, 0XFE ; 1111 1110 LED 0 BAT DAU
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
DELAY20MS:         LDI R22, 0X00 
	           OUT TCCR0A, R22 ; TIMER 0 MODE NOR
	           LDI R22, 0X00
	           OUT TCCR0B, R22 ; MODE NOR STOP
		   LDI R22, -157
                   OUT TCNT0, R22 ; NAP GIA TRI BAN DAU
                   LDI R22, 0X05 ; RUN, CHIA 1024
		   OUT TCCR0B, R22
WAIT:     IN R22, TIFR0 ; DOC CO BAO TRAN
          SBRS R22, TOV0
	  RJMP WAIT ; NEU CHUA TRAN, NHAY LAI WAIT
	  OUT TIFR0, R22 ; XOA CO BAO TRAN
	  LDI R22, 0X00 ; STOP
	  OUT TCCR0B, R22
	  RET


