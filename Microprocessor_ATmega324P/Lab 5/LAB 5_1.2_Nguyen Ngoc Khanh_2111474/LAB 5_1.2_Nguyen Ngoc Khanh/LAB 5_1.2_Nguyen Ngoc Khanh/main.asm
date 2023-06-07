;
; LAB 5_1.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/7/2023 4:08:22 AM
;
;
; do ADC o che do vi sai

; ket noi UART0 voi khoi RS232 va ket noi cap USB - Serial vao may tinh
; chinh VR1 o muc dien ap 2.5V, dua vao ADC0

; viet chuong trinh thuc hien cac yeu cau sau:
; khoi dong ADC o che do vi sai voi 2 kenh ngo vao la ADC0 va ADC1
; do loi khuech dai la 10, dien ap tham chieu Vref = 2.56V
; khoi dong ADC o che do free running
; hien thi dien ap VR1 len LCD

; UART o day co baud rate 9600, 1 stop bit, no parity, no handshake
; chon HEX Enable tren Hercules
; viet chuong trinh thuc hien lay mau tin hieu dua vao ADC0 va gui len may tinh su dung UART0 voi khung truyen nhu sau sau moi 1s
; thoi gian delay 1s tao boi ham delay hoac timer
; o day su dung interrupts timer 1 mode CTC kenh A

; PD0 (RXD0) va PD1 (RXD1) ket noi voi RS232

; PORTB KET NOI VOI LCD
; RS = PB0, RW = PB1, EN = PB2, PB4:7 = D4:7
                 
				.DEF FLAG = R23
                                .DEF COUNT = R22
                                .DEF ADC_LOW = R20
				.DEF ADC_HIGH = R21
		                .DEF DATA_TRANS = R19
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

                        ; SETTING_USART:
                        RCALL USART_INIT ; KHOI DONG USART

MAIN:
                ; SETTING_ADC:
                LDI R16, 0B11001001 ; VREF LA 2.56V, MODE VI SAI, NGO VAO ADC0 (-), ADC1 (+), HIEU CHINH PHAI, DO LOI GAIN = 10
                STS ADMUX, R16
WAIT:				
                LDI R16, 0B11100110 ; CHO PHEP ADC, BAT DAU CHUYEN DOI, Fckadc = 125K Hz, MODE FREE RUN
                STS ADCSRA, R16

                LDS R18, ADCSRA ; DOC CO ADIF
                SBRS R18, ADIF ; NEU CO ADIF = 1 BAO CHUYEN DOI XONG, BO QUA LENH TIEP THEO
                RJMP WAIT
                STS ADCSRA, R18 ; XOA CO ADIF

                LDS ADC_LOW, ADCL ; DOC ADCL TRUOC, LUU VAO R20
                LDS ADC_HIGH, ADCH ; DOC ADCH SAU, LUU VAO R21

                LDI R16, 0B01100110 ; CAM ADC DE ON DINH CHO LAN CHUYEN DOI TIEP THEO
                STS ADCSRA, R16
USART: 
                                LDI R16, 0XFF
                                MOV DATA_TRANS, R16 ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN 0XFF TRUOC

				MOV DATA_TRANS, ADC_LOW ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN ADCL

				MOV DATA_TRANS, ADC_HIGH ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN ADCH

				LDI R16, 0X55
				MOV DATA_TRANS, R16 ; TRONG KHUNG TRUYEN 0X55 ADCH ADCL 0XFF
				RCALL USART_TRANS ; TRUYEN 0X55
VR1:            
                    LDI R16, 1
                    RCALL DELAY_128US ; DELAY 128US
	            CBI LCD, RS ; GHI LENH
	            LDI R17, 0X01 ; XOA MAN HINH
	            RCALL OUT_LCD

	            LDI R16, 20 
	            RCALL DELAY_128US ; DELAY SAU LENH CLEAR DISPLAY
	            CBI LCD, RS
	            LDI R17, 0X80 ; CON TRO BAT DAU O HANG 1 VI TRI SO 4
	            RCALL OUT_LCD 

                    LDI ZH,HIGH(DATA << 1) ; Z TRO DAU BANG TRA KI TU
	            LDI ZL,LOW(DATA << 1)
LINE1:         
                    LPM R17, Z+ ; LAY MA ASCII KY TU TU FLASH ROM
                    CPI R17, 0X0D ; KIEM TRA CO PHAI KY TU XUONG DONG HAY KHONG
	            BREQ DOWN ; NEU LA KI TU XUONG DONG, NHAY TOI DOWN
	            LDI R16, 1 ; DELAY 128US
	            RCALL DELAY_128US
	            SBI LCD, RS ; RS = 1 GHI DATA HIEN THI RA LCD
	            RCALL OUT_LCD ; GHI MA ASCII RA LCD
	            RJMP LINE1
DOWN:           
                    LDI R16, 1
                    RCALL DELAY_128US ; DELAY 128US
	            CBI LCD, RS ; RS = 0 GHI LENH
	            LDI R17, 0XC4 ; CON TRO BAT DAU O DONG 2 VI TRI SO 5
	            RCALL OUT_LCD
LINE2:          
                    LPM R17, Z+
                    CPI R17, 0X00 ; KIEM TRA CO PHAI KI TU KET THUC HAY KHONG
	            BREQ STOP
	            LDI R16, 1
	            RCALL DELAY_128US
	            SBI LCD, RS
	            RCALL OUT_LCD
	            RJMP LINE2
STOP:   
                LDI R16, 1
                RCALL DELAY_128US ; DELAY SAU LENH GHI LCD
                RCALL DELAY_1S ; DELAY 1S CHO LAN CHUYEN DOI ADC TIEP THEO
                RJMP WAIT ; TRO LAI DOC TIEP ADC
                
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
FLAG_SET:
                 CPI FLAG, 1
                 BRNE FLAG_SET ; DOI DELAY XONG, NGAT HOAN THANH
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

;------------------------------------------------------------
DATA: .DB "DIEN AP VR1 LA",0X0D,"2.5V",0X00