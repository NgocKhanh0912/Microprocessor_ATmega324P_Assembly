;
; LAB 3_1.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 3:53:05 PM
; 
;
; ket noi cac tin hieu SDA va SCL cua avr vao cac tin hieu tuong ung tren module RTC
; ket noi 1 chan port vao tin hieu MFP
; ket noi LCD 16x2 vao 1 port cua avr
; viet chuong trinh con khoi dong RTC voi thoi gian hien hanh, cau hinh xung MFP voi tan so 1HZ
; cap nhat thoi gian len LCD
; Time: XX:YY:ZZ
; Date: AA/BB/CC

; PORTA giao tiep voi LCD
; SCL noi voi PC0, SDA noi voi PC1

                .DEF COUNT = R20
		.EQU LCD = PORTA ; PORTA HIEN THI LCD
		.EQU LCD_DR = DDRA
		.EQU RS = 0 ; BIT RS PA0
		.EQU RW = 1 ; BIT RW PA1
		.EQU E = 2 ; BIT E PA2
		.EQU SCL = 0 ; KI HIEU CHAN SCL
		.EQU SDA = 1 ; KI HIEU CHAN SDA
		.EQU STO = 7 ; BIT CHO PHEP OSC RTC
		.EQU VBATEN = 3 ; BIT CHO PHEP NGUON DU PHONG
		.EQU NULL = 0X00 ; MA KET THUC CHUOI KI TU
		.EQU CTL_BYTE = 0B11011110
		.EQU RTC_BUF = 0X200 
		.ORG 0 
		RJMP MAIN
		.ORG 0X40
MAIN:  
                LDI R16, HIGH(RAMEND)
                OUT SPH, R16
		LDI R16, LOW(RAMEND)
		OUT SPL, R16 ; DUA STACK LEN DIA CHI CAO
		LDI R16, 0XFF

		OUT LCD_DR, R16 ; PORTA LA PORT XUAT
		LDI R16, 0X00
		OUT LCD, R16 ; GIA TRI BAN DAU PORTA = 0
		LDI R16, 250
		RCALL DELAY_US ; CTC DELAY 100US X R16 = 25MS
		LDI R16, 250
		RCALL DELAY_US ; CTC DELAY 100US X R16 = 25MS

		CBI LCD, RS ; RS = 0 GHI LENH
		LDI R17, 0X30 ; MA LENH 30 LAN 1
		RCALL OUT_LCD4
		LDI R16, 42
		RCALL DELAY_US ; DELAY 4,2MS

		CBI LCD, RS ; RS = 0 GHI LENH
		LDI R17, 0X30 ; MA LENH 30 LAN 2
		RCALL OUT_LCD4
		LDI R16, 2
		RCALL DELAY_US ; DELAY 200US

		CBI LCD, RS ; RS = 0 GHI LENH
		LDI R17, 0X30 ; MA LENH 30 LAN 3
		RCALL OUT_LCD4
		LDI R16, 2
		RCALL DELAY_US ; DELAY 200US

		CBI LCD, RS ; RS = 0 GHI LENH
		LDI R17, 0X20 ; MA LENH 20 
		RCALL OUT_LCD4

		LDI R18, 0X28 ; FUNCTION SET 2 DONG FONT 5X8 MODE 4 BIT
		LDI R19, 0X01 ; CLEAR DISPLAY
		LDI R20, 0X0C ; DISPLAY ON, CON TRO OFF
		LDI R21, 0X06 ; ENTRY MODE SET DICH PHAI CON TRO, DDRAM TANG 1 DIA CHI
		RCALL INIT_LCD4 ; CTC KHOI DONG LCD 4 BIT

		RCALL TWI_INIT 
START:  
		LDI R16, 1 ; CHO 100US
		RCALL DELAY_US 

		CBI LCD, RS ; RS = 0 GHI LENH
		LDI R17, 0X01 ; XOA MAN HINH
		RCALL OUT_LCD
		LDI R16, 20
		RCALL DELAY_US ; DOI 2MS SAU LENH CLEAR DISPLAY

		LDI R17, 0X80 ; CON TRO BAT DAU O DONG 1
		RCALL CURS_POS ; XUAT LENH RA LCD

		LDI ZH, HIGH(MSG1 << 1)
		LDI ZL, LOW(MSG1 << 1) ; Z TRO DAU BANG MSG1
		RCALL MSG_DISP ; GHI MSG1 RA LCD

		LDI R17, 0XC0 ; CON TRO BAT DAU O DONG 2
		RCALL CURS_POS ; XUAT LENH RA LCD
		LDI ZH, HIGH(MSG2 << 1)
		LDI ZL, LOW(MSG2 << 1) ; Z TRO DAU BANG MSG2
		RCALL MSG_DISP ; GHI MSG2 RA LCD



;---------------------------------------------------------------------------------
; DAT BIT SQWEN = 1 , RS[2:0] = 000 CHO DAO DONG 1HZ
; XUAT RA CHAN MFP
;---------------------------------------------------------------------------------
           RCALL TWI_START ; PHAT XUNG START
	   LDI R17, (CTL_BYTE | 0X00) ; TRUY XUAT GHI RTC_TCCR
	   RCALL TWI_WRITE ; GHI RTC + W
	   LDI R17, 0X07 ; DIA CHI THANH GHI CONTROL
	   RCALL TWI_WRITE
	   LDI R17, 0B01000000 ; MFP XUAT XUNG 1HZ
	   RCALL TWI_WRITE
	   RCALL TWI_STOP



;-----------------------------------------------------------------------------------
; DOC CAC THANH GHI 0X00 DEN 0X06 RTC
;-----------------------------------------------------------------------------------
START1: 
                LDI XH, HIGH(RTC_BUF)
                LDI XL, LOW(RTC_BUF)
		LDI COUNT, 7
		RCALL TWI_START ; PHAT XUNG START
		LDI R17, (CTL_BYTE | 0X00) ; TRUY XUAT GHI RTC_TCCR
		RCALL TWI_WRITE ; GHI RTC + W
		LDI R17, 0X00 ; DIA CHI THANH GHI 0X00
	        RCALL TWI_WRITE
		RCALL TWI_START
		LDI R17, (CTL_BYTE | 0X01) ; TRUY XUAT DOC RTC_TCCR
		RCALL TWI_WRITE ; GHI RTC + R
RTC_RD: 
                RCALL TWI_READ
                ST X+, R17
		DEC COUNT
		BRNE RTC_RD
		RCALL TWI_NAK
		RCALL TWI_STOP

CAIDATRTC:
        LDI R22, 0X36 ; CAI DAT PHUT
        LDI XH, HIGH(RTC_BUF)
        LDI XL, LOW(RTC_BUF)
        ST X, R22

        LDI R22, 0X10 ; CAI DAT GIO
        LDI XH, HIGH(RTC_BUF+1)
        LDI XL, LOW(RTC_BUF+1)
        ST X, R22

        LDI R22, 0b01010000 ; CAI DAT GIAY
        LDI XH, HIGH(RTC_BUF-1)
        LDI XL, LOW(RTC_BUF-1)
        ST X, R22

        LDI R22, 0X10 ; CAI DAT NGAY
        LDI XH, HIGH(RTC_BUF+4)
        LDI XL, LOW(RTC_BUF+4)
        ST X, R22
 
        LDI R22, 0X04 ; CAI DAT THANG
        LDI XH, HIGH(RTC_BUF+5)
        LDI XL, LOW(RTC_BUF+5)
        ST X, R22

        LDI R22, 0X23 ; CAI DAT NAM
        LDI XH, HIGH(RTC_BUF+6)
        LDI XL, LOW(RTC_BUF+6)
        ST X, R22

;-----------------------------------------------
; HIEN THI TIME GIO PHUT GIAY
;-----------------------------------------------
START2: 
                LDI R17, 0X0C ; XOA CON TRO
                CBI LCD, RS
		LDI R16, 1 ; CHO 100US
		RCALL DELAY_US
		RCALL OUT_LCD
		LDI COUNT, 3
		LDI R17, 0X87 ; CON TRO BAT DAU O VI TRI GIO DONG 1
		RCALL CURS_POS ; XUAT LENH RA LCD
		LDI XH, HIGH(RTC_BUF+2)
		LDI XL, LOW(RTC_BUF+2)
DISP_NXT1: 
                LD R17, -X ; LAY DATA
		CPI COUNT, 1 ; DATA = SEC
		BRNE D_NXT ; NEU KHAC 1 HIEN THI TIEP
		CBR R17, (1<<STO) ; XOA BIT ST
D_NXT: 
            RCALL NUM_DISP
            DEC COUNT
	    BREQ QUIT1
	    LDI R17, ':'
	    SBI LCD, RS
	    LDI R16, 1
	    RCALL DELAY_US
	    RCALL OUT_LCD
	    RJMP DISP_NXT1


;----------------------------------------------------------------
; HIEN THI NGAY THANG NAM
;--------------------------------------------------------------------
QUIT1:
          LDI XH, HIGH(RTC_BUF+4) ; X TRO BUFFER RTC NGAY
	  LDI XL, LOW(RTC_BUF+4)
	  LDI COUNT, 3
	  LDI R17, 0XC7 ; CON TRO BAT DAU O DONG 2 VI TRI NGAY
	  RCALL CURS_POS ; XUAT LENH RA LCD
DISP_NXT2:
          LD R17, X+
	  RCALL NUM_DISP
	  DEC COUNT
	  BREQ HERE
	  LDI R17, '/'
	  SBI LCD, RS
	  LDI R16, 1
	  RCALL DELAY_US
	  RCALL OUT_LCD
	  RJMP DISP_NXT2
HERE:     RJMP HERE

;-----------------------------------------------------------
NUM_DISP: 
          PUSH R17 ; CAT DATA
	  SWAP R17 ; HOAN VI 2 NIBBLE
	  ANDI R17, 0X0F ; CHE BCD CAO
	  ORI R17, 0X30 ; CHUYEN SANG MA ASCII
	  SBI LCD, RS
	  LDI R16, 1
	  RCALL DELAY_US
	  RCALL OUT_LCD ; HIEN THI GIA TRI
	  POP R17 ; PHUC HOI DATA
	  ANDI R17, 0X0F ; CHE BCD THAP
	  ORI R17, 0X30 ; CHUYEN SANG MA ASCII
	  SBI LCD, RS
	  LDI R16, 1
	  RCALL DELAY_US
	  RCALL OUT_LCD ; HIEN THI GIA TRI
	  RET

;--------------------------------------------------------
; MSG_DISP HIEN THI CHUOI KI TU KET THUC BANG NULL DAT TRONG FLASH ROM
; INPUT Z CHUA DI CHI DAU CHUOI KI TU
; OUTPUT HIEN THI CHUOI KI TU TAI VI TRI CON TRO HIEN HANH
; SU DUNG R16, R17 CTC DELAY_US, OUT_LCD
MSG_DISP:
          LPM R17, Z+ ; LAY MA ASCII KI TU TU FLASH ROM
	  CPI R17, NULL ; KIEM TRA KI TU KET THUC
	  BREQ EXIT_MSG ; NEU LA NULL THOAT
	  LDI R16, 1
	  RCALL DELAY_US
	  SBI LCD, RS ; RS = 1 GHI DATA HIEN THI LCD
	  RCALL OUT_LCD
	  RJMP MSG_DISP ; TIEP TUC HIEN THI KI TU
EXIT_MSG: RET

;---------------------------------------------------------------------
; INIT LCD4 KHOI DONG LCD GHI 4 BYTE MA LENH THEO GIAO TIEP 4 BIT
; FUNCTION SET R18 = 0X28 2 DONG FONT 5X8 GIAO TIEP 4 BIT
; CLEAR DISPLAY R19 = 0X01 XOA MAN HINH
; DISPLAY ON/OFF CONTROL R20 = 0X0C MAN HINH ON, CON TRO OFF
; RENTRY MODE SET R21 = 0X06 DICH PHAI CON TRO , DC DDRAM TANG LEN 1 DVI

INIT_LCD4:
         CBI LCD, RS ; GHI LENH
	 MOV R17, R18
	 RCALL OUT_LCD

	 MOV R17, R19
	 RCALL OUT_LCD
	 LDI R16, 20
	 RCALL DELAY_US

	 MOV R17, R20
	 RCALL OUT_LCD

	 MOV R17, R21
	 RCALL OUT_LCD
	 RET


;--------------------------------------------------------
; OUT LCD4 GHI MA LENH/ DATA RA LCD
; INPUT R17 CHUA MA LENH/ DATA 4 BIT CAO
OUT_LCD4:         OUT LCD, R17
                  SBI LCD, E
		  CBI LCD, E
		  RET

;------------------------------------------------------------
; OUT_LCD GHI 1 BYTE MA LENH/DATA RA LCD
; CHIA LAM 2 LAN GHI 4 BIT
; INPUT R17 CHUA MA LENH/DATA
; RS =0/1 LENH/DATA
; RW = 0 GHI
; SU DUNG OUT_LCD4
OUT_LCD:         LDI R16, 1 
                 RCALL DELAY_US
		 IN R16, LCD ; DOC PORT LCD
		 ANDI R16, (1 << RS) ; LOC BIT RS
		 PUSH R16
		 PUSH R17
		 ANDI R17, 0XF0 ; LAY 4 BIT CAO
		 OR R17, R16 ; GHEP BIT RS
		 RCALL OUT_LCD4 ; GHI RA LCD
		 LDI R16, 1
		 RCALL DELAY_US
		 POP R17
		 POP R16
		 SWAP R17
		 ANDI R17, 0XF0 ; LAY 4 BIT THAP CHUYEN THANH CAO
		 OR R17, R16 ; GHEP BIT RS
		 RCALL OUT_LCD4 ; GHI RA LCD
		 RET

;------------------------------------------------------------------------------
; CURS_POS DAT CON TRO TAI DIA CHI CO TRONG R17
CURS_POS:
                LDI R16, 1
		RCALL DELAY_US
		CBI LCD, RS ; GHI LENH
		RCALL OUT_LCD
		RET
;------------------------------------------------------------------------------
DELAY_US:
                MOV R15, R16 ; NAP DATA CHO R15
		LDI R16, 200
L1:             MOV R14, R16 ; NAP DATA CHO R14
L2:             DEC R14
                NOP
		BRNE L2
		DEC R15
		BRNE L1
		RET


;---------------------------------------------------------
; TWI_INIT KHOI DONG CONG TWI
; TOC DO TRUYEN 100K HZ
TWI_INIT:
                MOV R15, R16 ; TOC DO TRUYEN SCL = 100K HZ
		STS TWBR, R17
		LDI R17, 1
		STS TWSR, R17 ; HE SO DAT TRUOC = 4
		LDI R17, (1<<TWEN) ; CHO PHEP TWI
		STS TWCR, R17
		RET

;--------------------------------------------------------
TWI_START:
                LDI R17, (1<<TWEN) | (1<<TWSTA) | (1<<TWINT) ; CHO PHEP TWI, START, XOA TWINT
		STS TWCR, R17
WAIT_STA: 
                LDS R17, TWCR ; DOC CO TWINT
		SBRS R17, TWINT ; DOI CO TWINT = 1 BAO TRUYEN XONG
		RJMP WAIT_STA
		RET
;--------------------------------------------------------------
TWI_WRITE:
                STS TWDR, R17 ; GHI DATA
		LDI R17, (1<<TWEN) | (1<<TWINT) ; CHO PHEP TWI, XOA TWINT
		STS TWCR, R17
WAIT_WR:
                LDS R17, TWCR ; CHO CO TWINT = 1 BAO TRUYEN XONG
		SBRS R17, TWINT
		RJMP WAIT_WR
		RET
;--------------------------------------------------------------
TWI_READ:
                LDI R17, (1<<TWEN) | (1<<TWINT) | (1<<TWEA) ; CHO PHEP TWI, XOA TWINT , TRA ACK
		STS TWCR, R17
WAIT_RD:
                LDS R17, TWCR ; CHO CO TWINT = 1 BAO TRUYEN XONG
		SBRS R17, TWINT
		RJMP WAIT_RD
		LDS R17, TWDR ; DOC DATA THU DC
		RET
;--------------------------------------------------------------
TWI_NAK:
                LDI R17, (1<<TWEN) | (1<<TWINT) ; CHO PHEP TWI, XOA TWINT , TRA NAK
		STS TWCR, R17
WAIT_NAK:
                LDS R17, TWCR ; CHO CO TWINT = 1 BAO TRUYEN XONG
		SBRS R17, TWINT
		RJMP WAIT_NAK
		RET
;------------------------------------------------------------
TWI_STOP:
                LDI R17, (1<<TWEN) | (1<<TWSTO) | (1<<TWINT) ; CHO PHEP TWI, XOA TWINT , STOP
                STS TWCR, R17
		RET

;---------------------------------------------------------------
.ORG 0X200
MSG1: .DB   "Time:",0X00
MSG2: .DB   "Date:",0X00
