;
; LAB 5_1.3_Nguyen Ngoc Khanh.asm
;
; Created: 5/7/2023 4:09:33 AM
; 
;
; do nhiet do su dung MCP9701
; ket noi cam bien vao header J73
; ket noi tin hieu dien ap V_TEMP tren header J18 toi ADC0
; viet chuong trinh do gia tri dien ap V_TEMP 
; tinh ra gia tri nhiet do va hien thi len LCD

; Vout = Tc x Ta + V0c
; Ta la nhiet do moi truong
; Tc la he so nhiet = 19.53 mV
; V0c la dien ap tai 0 do C = 400 mV
; Ta = (ADC/4) - 20.5
; Ta x 10 = [(ADC x 10)/4] - 205

; PORTB KET NOI VOI LCD
; RS = PB0, RW = PB1, EN = PB2, PB4:7 = D4:7

                                .DEF FLAG = R23
				.DEF COUNT = R22
				.DEF ADC_LOW = R24
				.DEF ADC_HIGH = R25
				.EQU DATA = 0X200 ; LUU DATA VUA NHAN DUOC VAO FLASH DE TRUY XUAT RA LCD
				.EQU LCD = PORTB
				.EQU LCD_DR = DDRB
				.EQU RS = 0
				.EQU RW = 1
				.EQU E = 2
				.ORG 0
				RJMP START
				.ORG 0X1A
		                RJMP COMPARE_MATCH ; SO SANH KENH 1A
				.ORG 0X40 ; THOAT KHOI VUNG INTERRUPTS
START:
                        LDI R16, HIGH(RAMEND)
                        OUT SPH, R16
                        LDI R16, LOW(RAMEND) ; DUA STACK LEN VUNG DIA CHI CAO
                        OUT SPL, R16

                        SEI ; CHO PHEP NGAT TOAN CUC
	                LDI R16, (1 << OCIE1A) ; CHO PHEP NGAT KHI TIMER1 TRAN
	                STS TIMSK1, R16

                        ; SETTING_LCD:				
                        LDI R16, 0XFF
		        OUT LCD_DR, R16 ; PORTB LA PORT XUAT
		        LDI R16, 0X00
		        OUT LCD, R16 ; GIA TRI BAN DAU PORTB = 0

                        LDI R16, 250
		        RCALL DELAY_128US ; CTC DELAY 128US X R16 = 32MS
		        LDI R16, 250
		        RCALL DELAY_128US ; CTC DELAY 128US X R16 = 32MS

		        CBI LCD, RS ; RS = 0 GHI LENH
		        LDI R17, 0X30 ; MA LENH 30 LAN 1
		        RCALL OUT_LCD4
		        LDI R16, 42
		        RCALL DELAY_128US ; DELAY 5.376MS

		        CBI LCD, RS ; RS = 0 GHI LENH
		        LDI R17, 0X30 ; MA LENH 30 LAN 2
		        RCALL OUT_LCD4
		        LDI R16, 2
		        RCALL DELAY_128US ; DELAY 256US

		        CBI LCD, RS ; RS = 0 GHI LENH
		        LDI R17, 0X30 ; MA LENH 30 LAN 3
		        RCALL OUT_LCD4
		        LDI R16, 2
		        RCALL DELAY_128US ; DELAY 256US

		        CBI LCD, RS ; RS = 0 GHI LENH
		        LDI R17, 0X20 ; MA LENH 20 
		        RCALL OUT_LCD4

		        LDI R18, 0X28 ; FUNCTION SET 2 DONG FONT 5X8 MODE 4 BIT
		        LDI R19, 0X01 ; CLEAR DISPLAY
		        LDI R20, 0X0C ; DISPLAY ON, CON TRO OFF
		        LDI R21, 0X06 ; ENTRY MODE SET DICH PHAI CON TRO, DDRAM TANG 1 DIA CHI
		        RCALL INIT_LCD4 ; CTC KHOI DONG LCD 4 BIT

MAIN:
                                ; SETTING_ADC:
                                LDI R16, 0B01000000 ; VREF LA AVCC= 5V , NGO VAO ADC0, HIEU CHINH PHAI, 11000000 NEU LA 2.56V
				STS ADMUX, R16
				LDI R16, 0B11000110 ; CHO PHEP ADC, BAT DAU CHUYEN DOI, Fckadc = 125K Hz
				STS ADCSRA, R16
WAIT:          
                                LDS R18, ADCSRA ; DOC CO ADIF
				SBRS R18, ADIF ; NEU CO ADIF = 1 BAO CHUYEN DOI XONG, BO QUA LENH TIEP THEO
                                RJMP WAIT
                                STS ADCSRA, R18 ; XOA CO ADIF
				LDS ADC_LOW, ADCL ; DOC ADCL TRUOC, LUU VAO R20
				LDS ADC_HIGH, ADCH ; DOC ADCH SAU, LUU VAO R21

TINH_Ta:            
                                RCALL MUL10 ; NHAN ADC CHO 10
                                RCALL DIV4 ; CHIA 4
				LDI R16, 205
				SUB ADC_LOW, R16 ; TRU [(ADC x 10)/4] VOI 205
				LDI R16, 0
				SBC ADC_HIGH, R16 ; TRU ADC_HIGH VOI CARRY NEU CO
				
				; GIA SU Ta > 10 do C (tuc la Ta x 10 > 100)

				; CHIA LAN 1 LAY SO THAP PHAN SAU DAU PHAY CUA Ta
                                RCALL DIV16_8
				ORI R16, 0X30 ; CHUYEN R16 SANG MA ASCII
                                LDI ZH, HIGH(DATA + 3) ; Z TRO DIA CHI DATA + 3 CHUA 1 SO THAP PHAN SAU DAU PHAY
				LDI ZL, LOW(DATA + 3)
				ST Z, R16

				LDI R18, '.'
				LDI ZH, HIGH(DATA + 2) ; Z TRO DIA CHI DATA + 2 CHUA DAU CHAM
				LDI ZL, LOW(DATA + 2)
				ST Z, R18

				; CHIA LAN 2 LAY HANG DON VI VA HANG CHUC CUA Ta
				RCALL DIV16_8
				ORI R16, 0X30
				LDI ZH, HIGH(DATA + 1) ; Z TRO DIA CHI DATA + 1 CHUA HANG DON VI
				LDI ZL, LOW(DATA + 1)
				ST Z, R16
				
				ORI R24, 0X30
				LDI ZH, HIGH(DATA) ; Z TRO DIA CHI DATA CHUA HANG CHUC
				LDI ZL, LOW(DATA)
				ST Z, R24

XUAT_LCD:  
                    LDI COUNT, 4 ; DEM SO KI TU DA XUAT RA LCD
                    LDI R16, 1
                    RCALL DELAY_128US ; DELAY 128US
	            CBI LCD, RS ; GHI LENH
	            LDI R17, 0X01 ; XOA MAN HINH
	            RCALL OUT_LCD
	            LDI R16, 20 
	            RCALL DELAY_128US ; DELAY SAU LENH CLEAR DISPLAY
	            CBI LCD, RS
	            LDI R17, 0X80 ; CON TRO BAT DAU O DONG 1 VI TRI DAU TIEN
	            RCALL CURS_POS ; XUAT LENH RA LCD CHI VI TRI CON TRO
                    LDI ZH, HIGH(DATA) ; Z TRO DIA CHI DATA
                    LDI ZL, LOW(DATA)
LINE:
                    LD R17, Z+
	            SBI LCD, RS
	            LDI R16, 1
	            RCALL DELAY_128US
	            RCALL OUT_LCD
                    DEC COUNT
                    BRNE LINE			
    
                    RCALL DELAY_1S
                    RCALL DELAY_1S
                    RJMP MAIN
                
;---------------------------------------------------------------------
; INIT LCD4 KHOI DONG LCD GHI 4 BYTE MA LENH THEO GIAO TIEP 4 BIT
; FUNCTION SET R18 = 0X28 2 DONG FONT 5X8 GIAO TIEP 4 BIT
; CLEAR DISPLAY R19 = 0X01 XOA MAN HINH
; DISPLAY ON/OFF CONTROL R20 = 0X0C MAN HINH ON, CON TRO OFF
; ENTRY MODE SET R21 = 0X06 DICH PHAI CON TRO , DC DDRAM TANG LEN 1 DVI

INIT_LCD4:
                   CBI LCD, RS ; GHI LENH
	           MOV R17, R18 ; FUNCTION SET
	           RCALL OUT_LCD ; GHI RA LCD

	           MOV R17, R19 ; CLEAR DISPLAY
	           RCALL OUT_LCD ; GHI RA LCD

	           LDI R16, 20
	           RCALL DELAY_128US ; DELAY 2.56 MS

	           MOV R17, R20 ; DISPLAY ON/OFF CONTROL
	           RCALL OUT_LCD ; GHI RA LCD

	           MOV R17, R21 ; ENTRY MODE SET
	           RCALL OUT_LCD ; GHI RA LCD
	           RET


;--------------------------------------------------------
; OUT LCD4 GHI MA LENH/ DATA RA LCD
; INPUT R17 CHUA MA LENH/ DATA 4 BIT CAO

OUT_LCD4: 
                       OUT LCD, R17
                       SBI LCD, E
		       CBI LCD, E
		       RET

;------------------------------------------------------------
; OUT_LCD GHI 1 BYTE MA LENH/DATA RA LCD
; CHIA LAM 2 LAN GHI 4 BIT
; INPUT R17 CHUA MA LENH/DATA
; RS = 0/1 LENH/DATA
; RW = 0 GHI
; SU DUNG OUT_LCD4

OUT_LCD: 
                      LDI R16, 1 
                      RCALL DELAY_128US

		      IN R16, LCD ; DOC PORT LCD
		      ANDI R16, (1<<RS) ; LOC BIT RS

		      PUSH R16 ; LUU TRU R16
		      PUSH R17 ; LUU TRU R17

		      ANDI R17, 0XF0 ; LAY 4 BIT CAO
		      OR R17, R16 ; GHEP BIT RS
		      RCALL OUT_LCD4 ; GHI RA LCD

		      LDI R16, 1
		      RCALL DELAY_128US

		      POP R17
		      POP R16

		      SWAP R17 ; SWAP 2 NIBBLE 
		      ANDI R17, 0XF0 ; LAY 4 BIT THAP CHUYEN THANH CAO
		      OR R17, R16 ; GHEP BIT RS
		      RCALL OUT_LCD4 ; GHI RA LCD
		      RET
		        

;-------------------------------------------------------------
; MUL10 NHAN SO NHI PHAN 16 BIT (ADC) CHO 8 BIT (10), KET QUA 16 BIT
; INPUT: ADC_HIGH:LOW SO BI NHAN 16 BIT, 10 LA SO NHAN 8 BIT
; NHAN 10 DE BAO TOAN 1 CHU SO LE SAU DAU CHAM
; OUTPUT: ADC_HIGH:LOW

MUL10:
                LDI R16, 10
                MUL ADC_LOW, R16 ; NHAN BYTE THAP SO BI NHAN VOI SO NHAN
                MOVW R2, R0 ; CHUYEN TICH BYTE THAP (1) VAO R3:R2
                MUL ADC_HIGH, R16 ; NHAN BYTE CAO SO BI NHAN VOI SO NHAN CHO TICH BYTE CAO (2)
                ADD R3, R0 ; CONG BYTE THAP TICH (2) VOI BYTE CAO TICH (1)
                MOV ADC_LOW, R2 ; CHUYEN KET QUA NHAN BYTE THAP VAO ADC_LOW
                MOV ADC_HIGH, R3 ; CHUYEN KET QUA NHAN BYTE CAO VAO ADC_HIGH
                RET



;-------------------------------------------------------------
; DIV4 CHIA SO NHI PHAN 16BIT VIN CHO 4 BANG CACH DICH TRAI BYTE 2 LAN
; INPUT: ADC_HIGH:LOW
; OUTPUT: ADC_HIGH:LOW
;         R22 = COUNT

DIV4: 
                LDI COUNT, 2 ; SO DEM = 2
AGAIN:	            
                LSR ADC_HIGH
                ROR ADC_LOW ; CHIA 2 KET QUA
                DEC COUNT
                BRNE AGAIN
                RET

;--------------------------------------------------------------
; DIV16_8 CHIA 2 SO NHI PHAN 16 BIT CHO 8 BIT
; INPUT R25:R24 LA ADC_HIGH:LOW LA SO BI CHIA, SO CHIA = 10 
; OUTPUT R14 = THUONG SO, R16 LA DU SO
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

;--------------------------------------------------------------
; DELAY_128US TAO DELAY BANG INTERRUPTS TIMER 1 CTC KENH A
; TIMER 1 8MHZ CHIA 1024, MOI XUNG CHUA TRONG R16 LA 128US
; DELAY 128US X R16

DELAY_128US:       
	         STS OCR1AL, R16 ; OCR1AL CHUA HET R16 NEN KHONG CAN XET DEN OCR1AH
	         LDI R16, 0X00 
	         STS TCCR1A, R16 ; TIMER 1
	         LDI R16, 0X0D
	         STS TCCR1B, R16 ; MODE CTC CHIA 1024 START
SET_FLAG:
                 CPI FLAG, 1
                 BRNE SET_FLAG ; KIEM TRA DA TRAN (DA DELAY DU THOI GIAN) HAY CHUA?
                 CLR FLAG
                 RET

;------------------------------------------------------------------------------
; CURS_POS DAT CON TRO TAI DIA CHI CO TRONG R17
CURS_POS:
                     LDI R16, 1
		     RCALL DELAY_128US
		     CBI LCD, RS ; GHI LENH
		     RCALL OUT_LCD
		     RET


;----------------------------------------------------------
; COMPARE_MATCH CAM NGAT TOAN CUC CHO DEN KHI CO LENH DELAY TIEP THEO, DUNG TIMER 1

COMPARE_MATCH:
                         LDI FLAG, 1
                         LDI R16, 0X00
			 STS TCCR1B, R16 ; DUNG TIMER 1
			 RETI


;--------------------------------------------------------------
DELAY_1S:
				LDI R18, 31 ; NAP SO LAN LOOP CHO R18
LP1:
				LDI R16, 250
				RCALL DELAY_128US ; DELAY 0.032s x 31 = 0.992s
                                DEC R18
				BRNE LP1
				LDI R16, 63
				RCALL DELAY_128US ; DELAY 8.064ms
				RET