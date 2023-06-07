;
; LAB 4_1.3_Nguyen Ngoc Khanh.asm
;
; Created: 5/7/2023 2:42:15 AM
; 
;
; ket noi cac tin hieu len led 7 doan
; su dung ngat COMPARE_MATCH cua timer 1 de xuat so 1234 ra led
; de do tan so quet, dao chan PC0 moi lan chuyen sang led ke tiep
; do xung nay tren oscilloscope

; PORT B KET NOI VOI J34
; PC0 XUAT SONG VUONG
; PA0:1 NOI VOI NLE0 VA NLE1

                   .EQU OUTPORT = PORTB 
		   .EQU SR_ADR = 0X100 ; DIA CHI SRAM LUU CAC SO 1234
		   .ORG 0
		   RJMP MAIN
		   .ORG 0X001A
		   RJMP COMPARE_MATCH ; INTERRUPTS SO SANH KENH 1A
		   .ORG 0X40 ; DUA CHUONG TRINH CHINH RA KHOI VUNG INTERRUPTS
MAIN: 
          LDI R22, 0 ; LAY R22 LAM CO BAO THUC HIEN NGAT

          LDI R16, HIGH(RAMEND)
          OUT SPH, R16
	  LDI R16, LOW(RAMEND)
	  OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

          LDI R16, 0X01
          OUT DDRC, R16 ; PC0 OUTPUT

	  LDI R16, 0X03
          OUT DDRA, R16 ; PA01 OUTPUT

	  CBI PORTA, 0 ; KHOA NGO RA U2
	  CBI PORTA, 1 ; KHOA NGO RA U3

	  LDI R16, 0XFF
	  OUT DDRB, R16 ; PORTB LA OUTPUT

	  LDI XH, HIGH(SR_ADR)
	  LDI XL, LOW(SR_ADR) ; LAY DIA CHI SRAM DE LUU 1234

	  LDI R17, 4
	  ST X+, R17
	  LDI R17, 3
	  ST X+, R17
	  LDI R17, 2
	  ST X+, R17
	  LDI R17, 1
	  ST X, R17

START:    RCALL SCAN_4LA
          RJMP START

;--------------------------------------------------
SCAN_4LA: 
                  LDI R18, 4 ; SO LAN QUET LED
                  LDI R19, 0XFE ; 1111 1110 LED 0 BAT DAU
		  LDI XH, HIGH(SR_ADR)
		  LDI XL, LOW(SR_ADR)
LOOP: 
              LDI R17, 0XFF ; LAM TOI CAC DEN
              OUT OUTPORT, R17
	      SBI PORTA, 1 ; MO U3
	      CBI PORTA, 1 ; KHOA U3

	      LD R17, X+ ; NAP SO BCD TU SRAM
	      RCALL GET_7SEG ; LAY MA 7 DOAN
	      OUT OUTPORT, R17 ; XUAT MA 7 DOAN
	      SBI PORTA, 0 ; MO U2
	      CBI PORTA, 0 ; KHOA U2

	      OUT OUTPORT, R19 ; XUAT MA QUET LED O U3
	      SBI PORTA, 1 ; MO U3
	      CBI PORTA, 1 ; KHOA U3

	      SEI ; CHO PHEP NGAT TOAN CUC
	      LDI R21, (1 << OCIE1A) ; CHO PHEP NGAT KHI TIMER1 TRAN
	      STS TIMSK1, R21
	      RCALL DELAY_20MS

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

;---------------------------------------------------------------------
; MA LED 7 DOAN
TAB: .DB 0XC0,0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
     .DB 0XC6,0XA1,0X86,0X8E

;-----------------------------------
; TAN SO QUET 50HZ = 20MS
COMPARE_MATCH: 
           LDI R22,1
	   LDI R20, 0X01
	   IN R21, PORTC ; DOC PORTC
	   EOR R21, R20 ; DAO BIT CHAN PC0 VOI R16 = 0X01
	   OUT PORTC, R21
	   RETI

;-----------------------------------------------
DELAY_20MS:
          LDI R21, HIGH(1999) ; 50Hz = 0.02s = 20000 XUNG , MOI XUNG 1US
	  STS OCR1AH, R21
	  LDI R21, LOW(1999) ; 20000 - 1 XUNG, DOI NGAT
	  STS OCR1AL, R21

	  LDI R21, 0X00 
	  STS TCCR1A, R21 ; TIMER 1
	  LDI R21, 0X0A
	  STS TCCR1B, R21 ; MODE CTC CHIA 8 START
HERE: 
          CPI R22, 1 ; DOI THUC HIEN CHUONG TRINH NGAT ROI MOI QUAY TRO LAI CHUONG TRINH CHINH
	  BREQ BACK
	  RJMP HERE
BACK:	  
          LDI R21, 0X00
	  STS TCCR1B, R21 ; DUNG TIMER1
 	  CLR R22
          RET

