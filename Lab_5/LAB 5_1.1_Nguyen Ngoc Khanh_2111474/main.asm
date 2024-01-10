;
; LAB 5_1.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/7/2023 4:07:22 AM
;
;
; do tin hieu single end
; ket noi hai tin hieu ADC_VR1 va ADC_VR2 tu header J86 vao hai ngo vao ADC0 (PA0) va ADC1 (PA1)
; ket noi UART0 voi khoi RS232 va ket noi cap USB - Serial vao may tinh
; ket noi ADC_VR1 va ADC_VR2 vao cac test point 

; viet chuong trinh thuc hien cac yeu cau sau:

; chon dien ap Vref la dien ap noi Vcca. khoi dong UART voi cau hinh tu chon
; UART o day co baud rate 9600, 1 stop bit, no parity, no handshake
; chon HEX Enable tren Hercules
; viet chuong trinh thuc hien lay mau tin hieu dua vao ADC0 va gui len may tinh su dung UART0 voi khung truyen nhu sau sau moi 1s
; thoi gian delay 1s tao boi ham delay hoac timer
; o day su dung interrupts timer 1 mode CTC kenh A

; 0X55 ADCH ADCL 0XFF
; thay doi dien ap dua vao ADC0, do bang VOM va so sanh voi ket qua lay mau ADC, dien vao bang bao cao
; ket noi LCD vao 1 port cua AVR, bo sung vao chuong trinh da viet chuc nang tinh toan dien ap dua vao va hien thi len LCD

; thay doi dien ap tham chieu la dien ap 2.56V ben trong, lap lai cac yeu cau tren
; do dien ap tren chan Vref (header J57), su dung VOM

; PORTB KET NOI VOI LCD
; RS = PB0, RW = PB1, EN = PB2, PB4:7 = D4:7

; Vin = (ADC x Vref)/1024
; 10 x Vin = (ADC x 50)/1024
; voi Vref = 5V = Vcca
; nhan Vin cho 10 de giu lai 1 so thap phan sau dau phay

; PD0 (RXD0) va PD1 (RXD1) ket noi voi RS232

                                .DEF FLAG = R23
                                .DEF COUNT = R22
                                .DEF VIN_LOW = R20
				.DEF VIN_HIGH = R21
		                .DEF DATA_TRANS = R19
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

                        RCALL USART_INIT ; KHOI DONG USART

MAIN:
                                ; SETTING_ADC:
                                LDI R16, 0B01000000 ; VREF LA AVCC, NGO VAO ADC0, HIEU CHINH PHAI, 11000000 NEU LA 2.56V
				STS ADMUX, R16
				LDI R16, 0B11000110 ; CHO PHEP ADC, BAT DAU CHUYEN DOI, Fckadc = 125K Hz
				STS ADCSRA, R16
WAIT:          
                                LDS R18, ADCSRA ; DOC CO ADIF
				SBRS R18, ADIF ; NEU CO ADIF = 1 BAO CHUYEN DOI XONG, BO QUA LENH TIEP THEO
				RJMP WAIT
				STS ADCSRA, R18 ; XOA CO ADIF
				LDS VIN_LOW, ADCL ; DOC ADCL TRUOC, LUU VAO R20
				LDS VIN_HIGH, ADCH ; DOC ADCH SAU, LUU VAO R21
USART: 
                                LDI R16, 0XFF
                                MOV DATA_TRANS, R16 ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN 0XFF TRUOC

				MOV DATA_TRANS, VIN_LOW ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN ADCL

				MOV DATA_TRANS, VIN_HIGH ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN ADCH

				LDI R16, 0X55
				MOV DATA_TRANS, R16 ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN 0X55
VIN:            
                                RCALL MUL50 ; NHAN 50
                                RCALL DIV1024 ; CHIA 1024
				CPI VIN_LOW, 10 ; SO SANH VIN VOI 10
				BREQ EQUAL
				BRCS NO ; NEU VIN NHO HON 10, XUAT VIN DUOI DANG 0.X VOI X LA GIA TRI THAP PHAN CUA VIN_LOW
                                        ; NEU VIN LON HON 10, XUAT VIN DUOI DANG X.Y VOI X LA THUONG SO VA Y LA DU SO CUA PHEP CHIA 10
YES:
                                LDI R16, 1
				ORI R16, 0X30 ; CHUYEN R16 SANG MA ASCII
                                LDI ZH, HIGH(DATA) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA)
				ST Z, R16

                                LDI R16, '.'
				LDI ZH, HIGH(DATA + 1) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA + 1)
				ST Z, R16

                                LDI ZH, HIGH(DATA + 2) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA + 2)
				ORI VIN_LOW, 0X30 ; CHUYEN VIN_LOW SANG MA ASCII
				ST Z, VIN_LOW ; LUU GIA TRI VIN_LOW VAO DATA

				RJMP XUAT_LCD
NO:             
                                RCALL DIV10

				LDI ZH, HIGH(DATA) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA)
				ORI R23, 0X30 ; CHUYEN R23 SANG MA ASCII
				ST Z, R23 ; LUU GIA TRI R23 LA THUONG SO VAO DATA

				LDI R16, '.'
				LDI ZH, HIGH(DATA + 1) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA + 1)
				ST Z, R16

				LDI ZH, HIGH(DATA + 2) ; Z TRO DIA CHI DATA + 1 DE LUU DU SO
				LDI ZL, LOW(DATA + 2) 
				ORI VIN_LOW, 0X30 ; CHUYEN VIN_LOW SANG MA ASCII
				ST Z, VIN_LOW

				RJMP XUAT_LCD
EQUAL:         
                                LDI R16, 1
				ORI R16, 0X30 ; CHUYEN R16 SANG MA ASCII
                                LDI ZH, HIGH(DATA) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA)
				ST Z, R16

				LDI R16, '.'
				LDI ZH, HIGH(DATA + 1) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA + 1)
				ST Z, R16

				LDI R16, 0
				ORI R16, 0X30 ; CHUYEN R16 SANG MA ASCII
                                LDI ZH, HIGH(DATA + 2) ; Z TRO DIA CHI DATA
				LDI ZL, LOW(DATA + 2)
				ST Z, R16

				RJMP XUAT_LCD
XUAT_LCD:  
                    LDI COUNT, 3 ; DEM SO KI TU DA XUAT RA LCD
                    LDI R16, 1
                    RCALL DELAY_128US ; DELAY 128US
	            CBI PORTB, RS ; GHI LENH
	            LDI R17, 0X01 ; XOA MAN HINH
	            RCALL OUT_LCD
	            LDI R16, 20 
	            RCALL DELAY_128US ; DELAY SAU LENH CLEAR DISPLAY
	            CBI PORTB, RS
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
		        
;--------------------------------------------------------------
USART_INIT:
	              LDI R16, (1<<TXEN0); CHO PHEP BO PHAT
	   	      STS UCSR0B, R16

		      LDI R16, (1<<UCSZ01)|(1<<UCSZ00) ; 8 BIT DATA/KHONG KT CHAN LE/1 STOP BIT
		      STS UCSR0C, R16

		      LDI R16, 0
		      STS UBRR0H, R16
		      LDI R16, 51 ; BAUD RATE = 9600 UNG VOI FOSC = 8MHZ
		      STS UBRR0L, R16
		
		      RET

;------------------------------------------------------------------
USART_TRANS:
		      LDS R17, UCSR0A
	 	      SBRS R17, UDRE0 ; KIEM TRA UDR0 CO TRONG KHONG (UDRE0 = 1?)
		      RJMP USART_TRANS
		      STS UDR0, DATA_TRANS ; KHI UDR0 TRONG THI CHEP DU LIEU TU DATA_TRANS CHUA THANH GHI CAN XUAT VAO UDR0
		      RET

;-------------------------------------------------------------
; MUL50 NHAN SO NHI PHAN 16 BIT (ADC) CHO 8 BIT (50), KET QUA 16 BIT
; INPUT: VIN_HIGH:VIN_LOW SO BI NHAN 16 BIT, 50 LA SO NHAN 8 BIT
; OUTPUT: VIN_LOW:HIGH

MUL50:
                                LDI R16, 50 ; SO NHAN = 50
                                MUL VIN_LOW, R16 ; NHAN BYTE THAP SO BI NHAN VOI SO NHAN
				MOVW R2, R0 ; CHUYEN TICH BYTE THAP (1) VAO R3:R2
				MUL VIN_HIGH, R16 ; NHAN BYTE CAO SO BI NHAN VOI SO NHAN CHO TICH BYTE CAO (2)
				ADD R3, R0 ; CONG BYTE THAP TICH (2) VOI BYTE CAO TICH (1)
				MOV VIN_LOW, R2 ; CHUYEN KET QUA NHAN BYTE THAP VAO VIN_LOW
				MOV VIN_HIGH, R3 ; CHUYEN KET QUA NHAN BYTE CAO VAO VIN_HIGH
				RET



;-------------------------------------------------------------
; DIV1024 CHIA SO NHI PHAN 16BIT VIN CHO 1024 BANG CACH DICH TRAI BYTE 10 LAN
; INPUT: VIN_HIGH, VIN_LOW
; OUTPUT: VIN_HIGH, VIN_LOW
;         R22 = COUNT

DIV1024: 
                                LDI COUNT, 10 ; SO DEM = 10
AGAIN:	            
                                LSR VIN_HIGH
				ROR VIN_LOW ; CHIA 2 KET QUA
				DEC COUNT
				BRNE AGAIN
				RET

;--------------------------------------------------------------
; DIV10 CHIA VIN CHO 10 DE LAY SO NGUYEN VA LAY PHAN THAP PHAN SAU DAU PHAY 
; VIN_LOW CHUA DU SO
; R23 CHUA THUONG SO

DIV10:             CLR R23 ; R23 CHUA THUONG SO
GT_DV:             SUBI VIN_LOW, 10
                   BRCS LT_DV ; C = 1 KHONG CHIA DUOC
	           INC R23
	           RJMP GT_DV
LT_DV: 
                   LDI R16, 10
                   ADD VIN_LOW, R16 ; LAY LAI DU SO
	           RET

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