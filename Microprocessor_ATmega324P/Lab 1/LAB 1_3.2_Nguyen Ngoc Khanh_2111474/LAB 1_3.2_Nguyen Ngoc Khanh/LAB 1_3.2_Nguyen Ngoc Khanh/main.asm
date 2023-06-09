;
; LAB 1_3.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 11:47:47 AM
; 
;
; Ket noi 1 switch den 1 chan port cua AVR, ket noi module BAR LED den 1 port cua AVR, ket noi LCD den 1 port cua AVR
; Viet chuong trinh dem so lan nhan nut va xuat ket qua ra barled, dong thoi xuat ra LCD co chong rung
; GIAO TIEP LCD 4 BIT

; PB0:3 NOI LAN LUOT VOI RS RW E CUA LCD, PB4:7 NOI VOI D4:7 CUA LCD

; PA0:7 NOI VOI BAR LED
; PC0 NOI VOI SWITCH

                .DEF COUNT = R20 ; BIEN DEM SO LAN NHAN SWITCH
		.EQU LCD = PORTB ; PORTB HIEN THI LCD
		.EQU LCD_DR = DDRB
       	        .EQU RS = 0
	        .EQU RW = 1
	        .EQU E = 2
	        .EQU CR = 0X0D
	        .EQU NULL = 0X00
		.EQU BUF = 0X200 ; DIA CHI SRAM LUU SO LAN NHAN SWITCH
                .ORG 0
	        RJMP MAIN
	        .ORG 0X40
MAIN: 
                LDI R16, HIGH(RAMEND)
                OUT SPH, R16
                LDI R16, LOW(RAMEND)
	        OUT SPL, R16 ; dua stack len vung dia chi cao

	        LDI R16, 0X00
	        OUT DDRC, R16 ; PC0 LA INPUT
	        SBI PORTC, 0 ; DIEN TRO KEO LEN PC0

		LDI R16, 0XFF
		OUT DDRA, R16 ; PORTA XUAT RA BARLED

		LDI R16, 0XFF
		OUT LCD_DR, R16 ; PORTB LA PORT XUAT LCD
		LDI R16, 0X00
		OUT LCD, R16 ; GIA TRI BAN DAU PORTB = 0
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

		LDI COUNT, 0 ; BAN DAU CHUA NHAN SWITCH THI SO LAN NHAN BANG 0
	   
START: 
            LDI R16, 1
            RCALL DELAY_US ; DELAY 100US

	    CBI LCD, RS ; GHI LENH
	    LDI R17, 0X01 ; XOA MAN HINH
	    RCALL OUT_LCD
	    LDI R16, 20 
	    RCALL DELAY_US ; DELAY 2MS SAU LENH CLEAR DISPLAY

	    CBI LCD, RS
	    LDI R17, 0X82 ; CON TRO BAT DAU O HANG 1 VI TRI SO 3
	    RCALL CURS_POS
	    LDI ZH, HIGH(TAB<<1) ; Z TRO DAU BANG TRA KI TU
	    LDI ZL, LOW(TAB<<1)
	   
LINE1: 
            LPM R17, Z+ ; LAY MA ASCII KY TU TU FLASH ROM
            CPI R17, CR ; KIEM TRA CO PHAI KY TU XUONG DONG HAY KHONG
	    BREQ DOWN ; NEU LA KI TU XUONG DONG, NHAY TOI DOWN

	    LDI R16,1 ; DELAY 100US
	    RCALL DELAY_US

	    SBI LCD, RS ; RS = 1 GHI DATA HIEN THI RA LCD
	    RCALL OUT_LCD 
	    RJMP LINE1
DOWN:
            LDI R16,1
            RCALL DELAY_US ; DELAY 100US

	    CBI LCD, RS ; RS = 0 GHI LENH
	    LDI R17, 0XC7 ; CON TRO BAT DAU O DONG 2 VI TRI SO 8
	    RCALL CURS_POS
LINE2: 
            MOV R17, COUNT
            ORI R17, 0X30

	    LDI R16,1
	    RCALL DELAY_US

	    SBI LCD, RS
	    RCALL OUT_LCD

            OUT PORTA, COUNT
WAIT: 
            LDI R16,1
            RCALL DELAY_US
            SBIC PINC, 0
            RJMP WAIT
	    LDI R16, 200
	    RCALL DELAY_US ; CHONG RUNG PHIM BANG DELAY
	    SBIC PINC, 0
            RJMP WAIT
	    INC COUNT ; NEU PHIM CO NHAN, TANG SO DEM LEN 1
	    RJMP START


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
OUT_LCD: 
                 LDI R16, 1 
                 RCALL DELAY_US
		 IN R16, LCD ; DOC PORT LCD
		 ANDI R16, (1<<RS) ; LOC BIT RS
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


;---------------------------------------------------
; DELAY_US TAO TRE R16 X 100US ( FOSC = 8MHZ ) ( NEU FOSC = 1MHZ THI LDI R16,25 )
; INPUT R16 HE SO NHAN THOI GIAN TRE [1:255]
;---------------------------------------------------
DELAY_US:         MOV R15,R16
                  LDI R16,200
L1:		  MOV R14,R16
L2:               DEC R14
                  NOP
		  BRNE L2
		  DEC R15
		  BRNE L1
		  RET


.ORG 0X0300
;--------------------------------------
TAB: .DB "SO LAN NHAN",0X0D

