;
; LAB 1_3.3_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 11:48:53 AM
; 
;
; Ket noi tin hieu tu mot port cua AVR den module ban phim ma tran , ket noi module BAR LED va LCD den 2 port khac cua AVR
; Viet chuong trinh con SCANKEY de quet ban phim ma tran va tra ve gia tri tu 0x0 den 0xF ung voi ma cua phim duoc nhan. 
; Neu khong co phim nao duoc nhan tra ve gia tri 0xFF. Gia tri tra ve chua trong R24
; Dung chuong trinh con nay, viet chuong trinh thuc hien viec quet phim va xuat gia tri doc duoc len bar led va LCD

; PORTA XUAT RA BARLED
; PORTC XUAT RA LCD

                .EQU KEYPAD = PINB
		.EQU KEYPAD_DDR = DDRB
		.EQU KEYPAD_SET = PORTB

		.EQU BLED = PORTA ; PORT DIEU KHIEN BARLED
		.EQU BLED_DDR = DDRA

		.EQU LCD4 = PORTC ; PORTC DIEU KHIEN LCD4
		.EQU LCD4_DDR = DDRC

		.EQU RS = 0 ; BIT RS
		.EQU RW = 1 ; BIT RW
		.EQU E = 2 ; BIT E

		.ORG 0
		RJMP MAIN
		.ORG 0X40
MAIN:	
		LDI R16, HIGH(RAMEND)
		OUT SPH, R16
		LDI R16, LOW(RAMEND)
		OUT SPL, R16

		LDI R16, 0X0F
		OUT KEYPAD_DDR, R16 ; PB0-PB3 LA NGO RA; PB4-PB7 LA NGO VAO

		LDI R16, 0XFF
		OUT BLED_DDR, R16 ; PORTA LA OUTPUT BARLED

		LDI R16, 0XFF
		OUT LCD4_DDR, R16 ; PORTC LA OUTPUT LCD4

		CBI LCD4, RS
		CBI LCD4, RW
		CBI LCD4, E	

;KHOI DONG LCD
		LDI R16, 250
		RCALL DELAY_US
		LDI R16, 250
		RCALL DELAY_US

		CBI LCD4, RS
		LDI R17, 0X30 
		RCALL OUT_LCD4 ; GHI 3H

		LDI R16, 42
		RCALL DELAY_US

		CBI LCD4, RS
		LDI R17, 0X30
		RCALL OUT_LCD4 ; GHI XONG 33H

		LDI R16, 2
		RCALL DELAY_US

		CBI LCD4, RS
		LDI R17, 0X32
		RCALL OUT_LCD40

		LDI R18, 0X28 ; FUNCTION SET GIAO TIEP 4 BIT 2 DONG FONT 5x8
		LDI R19, 0X01 ; CLEAR DISPLAY
		LDI R20, 0X0C ; DISPLAY ON, CON TRO OFF
		LDI R21, 0X06 ; ENTRY MODE SET: DICH PHAI CON TRO
		RCALL INIT_LCD4


START:	
		RCALL KEY_RD
		RJMP START

; ///CHUONG TRINH CON XAC DINH PHIM AN
; TRA VE R17=MA PHIM VA C=1 NEU CO PHIM NHAN
; TRA VE C=0 NEU KHONG CO PHIM NHAN
GET_KEYPAD:
		LDI R17, 4 ; SO LAN QUET COT
		LDI R20, 0XFE ; BAT DAU QUET COL0 VA ROW0
SCAN_COL:
		OUT KEYPAD_SET, R20 
		IN R19, KEYPAD
		IN R19, KEYPAD ; DOC LAI TRANG THAI HANG
		ANDI R19, 0XF0 ; CHE BIT CAO LAY MA HANG
		CPI R19, 0XF0 ; KIEM TRA CO PHIM AN KHONG?
		BRNE CHK_KEY ; CO PHIM AN
		LSL R20 
		INC R20 ; QUET COT KE TIEP
		DEC R17 ; GIAM SO LAN QUET COT
		BRNE SCAN_COL ; TIEP TUC QUET COT
		CLC ; KHONG CO PHIM AN CLEAR C
		RJMP EXIT
CHK_KEY:
		SUBI R17, 4 ; TINH VI TRI COT
		NEG  R17 ; BU 2 LAY SO DUONG
		SWAP R19 ; DAO SANG 4 BIT THAP LAY MA HANG
		LDI R20, 4 ; R20 DEM SO LAN QUET HANG
SCAN_ROW:
		ROR R19
		BRCC SET_FLG ; C=0 TIM VI TRI HANG CO PHIM NHAN
		INC R17
		INC R17
		INC R17
		INC R17
		DEC R20
		BRNE SCAN_ROW ; QUET HET 4 HANG
		CLC ; KHONG CO PHIM NHAN
		RJMP EXIT
SET_FLG:
		SEC ; CO PHIM NHAN C=1
		; PUSH R17 BAO TOAN MA PHIM
EXIT:	RET

;///CHUONG TRINH CON CHONG RUNG PHIM
KEY_RD:	
		LDI R18, 50
BACK1:	        RCALL GET_KEYPAD
		BRCC KEY_RD
		DEC R18
		BRNE BACK1 ; XAC NHAN DA NHAN SW

		;.....
		OUT BLED, R17
		PUSH R17
		
		; HIEN THI LCD

		LDI R16, 1
		RCALL DELAY_US
		CBI LCD4, RS ; DICH CHUYEN CON TRO
		LDI R17, 0X88
		RCALL OUT_LCD40
		
		POP R17
		RCALL BCD_ASCII
		SBI LCD4, RS
		RCALL OUT_LCD40
		;.....

		; PUSH R17
WAIT1:	        LDI R18, 50
BACK2:	        RCALL GET_KEYPAD
		BRCS WAIT1
		DEC R18
		BRNE BACK2 ; XAC NHAN DA NHA SW

		;.....
		LDI R17, 0XFF
		OUT BLED, R17
		
		;HIEN THI LCD
		LDI R16, 1
		RCALL DELAY_US
		CBI LCD4,RS ;DICH CHUYEN CON TRO
		LDI R17, 0X88
		RCALL OUT_LCD40
		
		LDI R17, 0X0F
		RCALL BCD_ASCII
		SBI LCD4, RS
		RCALL OUT_LCD40

		LDI R16, 10
		RCALL DELAY_US

		LDI R17, 0X0F
		RCALL BCD_ASCII
		SBI LCD4, RS
		RCALL OUT_LCD40
		;.....

		;POP R17
		RET

;.........................................		
; INIT_LCD KHOI DONG LCD GHI 4 BYTE MA LENH
; FUNCTION SET: R18 = 0X28 GIAO TIEP 4 BIT, 2 DONG FONT 5x8
; CLEAR DISPLAY: R19 = 0X01 XOA MAN HINH
; DISPLAY CONTROL: R20 = 0X0C MAN HINH ON, CON TRO OFF
; ENTRY MODE SET: R21 = 0X06 DICH PHAI CON TRO
; RS BIT0 = 0, RW BIT1 = 0
INIT_LCD4:
		CBI LCD4, RS
		MOV R17, R18 ; FUNCTION SET
		RCALL OUT_LCD40

		MOV R17, R19 
		RCALL OUT_LCD40

		LDI R16, 20 
		RCALL DELAY_US ; CHO 2ms

		MOV R17, R20
		RCALL OUT_LCD40
		 
		MOV R17, R21
		RCALL OUT_LCD40
		RET

;........................................
; OUT_LCD40 GHI 1BYTE MA LENH/DATA RA LCD4
; INPUT = R17 CHUA MA LENH/DATA, R16 = LOC LENH RS
OUT_LCD40:
		LDI R16, 1 ; CHO 100us
		RCALL DELAY_US

		IN R16, LCD4 
		ANDI R16, (1 << RS) ; LOC BIT RS
		PUSH R16
		PUSH R17
		ANDI R17, 0XF0
		OR R17, R16 ; GHEP LENH VA DATA XUAT LED4
		RCALL OUT_LCD4 ; GHI RA LCD

		LDI R16, 1 ; CHO 100us
		RCALL DELAY_US

		POP R17
		POP R16
		SWAP R17
		ANDI R17, 0XF0
		OR R17, R16
		RCALL OUT_LCD4
		RET

;................................
; OUT_LCD GHI MA LENH/DATA RA LCD
; INPUT R17 CHUA MA LENH/DATA
OUT_LCD4:
		OUT LCD4, R17 ; GHI LENH/DATA RA LCD
		SBI LCD4, E ; TAO XUNG CANH XUONG
		CBI LCD4, E
		RET

;................................
TABLE:	.DB "0","1","2","3","4","5","6","7","8","9"
		.DB "A","B","C","D","E","F"
; R17 LA OFFSET
; KET QUA LUU LAI R17
BCD_ASCII:
		LDI ZH, HIGH(TABLE << 1)
		LDI ZL, LOW(TABLE << 1)
		ADD ZL, R17
		CLR R16
		ADC ZH, R16
		LPM R17, Z
		RET

;..............................
; DELAY_US TAO THOI GIAN TRE = R16*100uF (FOSC=8MHz)
; INPUT R16 LA HE SO NHAN THOI GIAN TRE 1 DEN 255
DELAY_US:
		MOV R15, R16 ;1MC
		LDI R16, 200 ;1MC
L1:		MOV R14, R16 ;1MC NAP DATA CHO R14
L2:		NOP ;1MC
		DEC R14 ;1MC
		BRNE L2 ;2/1MC
		DEC R15 ;1MC
		BRNE L1 ;2/1MC
		RET ;4MC
