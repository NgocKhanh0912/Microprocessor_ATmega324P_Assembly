;
; LAB 1_3.1.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 11:46:38 AM
; 
;
; Ket noi mot PORT cua AVR vao J33 (Header dieu khien LCD) tren kit thi nghiem.
; Viet chuong trinh khoi dong LCD va xuat len LCD nhu sau. (XX l� so nhom)
; TN VXL-AVR
; NHOM: XX
; GIAO TIEP LCD 8 BIT (PHAN MO RONG, KIT THI NGHIEM CHI CHO PHEP GIAO TIEP LCD 4 BIT)


; PC0 NOI VOI RS, PC1 NOI VOI RW, PC2 NOI VOI E
; PB0:7 NOI VOI D0:7

         .EQU OUTPORT = PORTB
	 .EQU IOSETB = DDRB
	 .EQU CONT = PORTC
	 .EQU CONT_DR = DDRC
	 .EQU CONT_IN = PINC
	 .EQU RS = 0
	 .EQU RW = 1
	 .EQU E = 2
	 .EQU CR = 0X0D
	 .EQU NULL = 0X00
         .ORG 0
	 RJMP MAIN
	 .ORG 0X40
MAIN: 
         LDI R16, HIGH(RAMEND)
         OUT SPH, R16
         LDI R16, LOW(RAMEND)
	 OUT SPL, R16 ; dua stack len vung dia chi cao

	 LDI R16, 0X07
	 OUT CONT_DR, R16 ; PC0:2 LA OUTPUT
	 CBI CONT, RS ; RS = PC0 = 0
	 CBI CONT, RW ; RW = PC1 = 0 TRUY XUAT GHI
	 CBI CONT, E ; E = PC2 = 0 CAM LCD

	 LDI R16, 0XFF
	 OUT IOSETB, R16 ; PORTB LA OUTPORT
	 LDI R16, 250 
	 RCALL DELAY_US ; CTC DELAY 100US X R16 = 25MS
	 LDI R16, 250 
	 RCALL DELAY_US ; CTC DELAY 100US X R16 = 25MS , DELAY 50MS

	 CBI CONT, RS ; RS = 0 MODE GHI LENH
	 LDI R17, 0X30 ; MA LENH CO DINH 30 LAN 1
	 RCALL OUT_LCD ; CTC GHI RA LCD
	 LDI R16, 42
	 RCALL DELAY_US ; DELAY 4.2MS

	 CBI CONT, RS
	 LDI R17, 0X30 ; MA LENH CO DINH 30 LAN 2
	 RCALL OUT_LCD ; CTC GHI RA LCD
	 LDI R16, 2
	 RCALL DELAY_US ; DELAY 200US

	 CBI CONT, RS
	 LDI R17,0X30 ; MA LENH CO DINH 30 LAN 3
	 RCALL OUT_LCD ; CTC GHI RA LCD

	 LDI R18, 0X38 ; FUNCTION SET 2 DONG FONT 5X8
	 LDI R19, 0X01 ; CLEAR DISPLAY
	 LDI R20, 0X0C ; DISPLAY ON , CON TRO OFF
	 LDI R21, 0X06 ; ENTRY MODE SET DICH PHAI CON TRO, DDRAM TANG 1 DIA CHI, KHI NHAP KI TU MAN HINH KHONG DICH
	 RCALL INIT_LCD8 ; CTC KHOI DONG LCD 8BIT

START: 
           LDI R16, 1
           RCALL DELAY_US ; DELAY 100US
	   CBI CONT, RS ; GHI LENH
	   LDI R17, 0X01 ; XOA MAN HINH
	   RCALL OUT_LCD

	   LDI R16, 20 
	   RCALL DELAY_US ; DELAY 2MS SAU LENH CLEAR DISPLAY
	   CBI CONT, RS
	   LDI R17, 0X83 ; CON TRO BAT DAU O HANG 1 VI TRI SO 4
	   RCALL OUT_LCD

	   LDI ZH, HIGH(TAB<<1) ; Z TRO DAU BANG TRA KI TU
	   LDI ZL, LOW(TAB<<1)
LINE1: 
           LPM R17, Z+ ; LAY MA ASCII KY TU TU FLASH ROM
           CPI R17, CR ; KIEM TRA CO PHAI KY TU XUONG DONG HAY KHONG
	   BREQ DOWN ; NEU LA KI TU XUONG DONG, NHAY TOI DOWN
	   LDI R16, 1 ; DELAY 100US
	   RCALL DELAY_US

	   SBI CONT, RS ; RS = 1 GHI DATA HIEN THI RA LCD
	   RCALL OUT_LCD ; GHI MA ASCII RA LCD
	   RJMP LINE1
DOWN: 
           LDI R16, 1
           RCALL DELAY_US ; DELAY 100US
	   CBI CONT, RS ; RS = 0 GHI LENH
	   LDI R17, 0XC3 ; CON TRO BAT DAU O DONG 2 VI TRI SO 4
	   RCALL OUT_LCD
LINE2: 
           LPM R17, Z+
           CPI R17, NULL
	   BREQ WAIT
	   LDI R16, 1
	   RCALL DELAY_US
	   SBI CONT, RS
	   RCALL OUT_LCD
	   RJMP LINE2
WAIT: 
           LDI R16, 1
           RCALL DELAY_US
HERE:      RJMP HERE

;-------------------------------------------------------
; INIT_LCD8 KHOI DONG LCD GHI 4 BYTE MA LENH
; FUNCTION SET R18= 0X38 2 DONG FONT 5X8
; CLEAR DISPLAY R19 = 0X01 XOA MAN HINH
; DISPLAY ON/OFF CONTROL : R20 = 0X0C MAN HINH ON, CON TRO OFF
; ENTRY MODE SET l R20 = 0X06  DICH PHAI CON TRO, DIA CHI DDRAM TANG 1 KHI GHI DATA
;-------------------------------------------------------

INIT_LCD8:         LDI R16, 1 ; DELAY 100US
                   RCALL DELAY_US
		   CBI CONT, RS ; GHI LENH
		   MOV R17, R18 ; R18 = FUNCTION SET
		   RCALL OUT_LCD
		   LDI R16, 1
		   RCALL DELAY_US
		   MOV R17, R19 ; R19 = CLEAR DISPLAY
		   RCALL OUT_LCD
		   LDI R16, 20 ; CHO 2MS SAU LENH CLEAR DISPLAY
		   RCALL DELAY_US
		   CBI CONT, RS
		   MOV R17, R20 ; R20 = DISPLAY ON/OFF CONTROL
		   RCALL OUT_LCD
		   LDI R16, 1
		   RCALL DELAY_US
		   CBI CONT, RS
		   MOV R17, R21 ; R21 = ENTRY MODE SET
		   RCALL OUT_LCD
		   RET


;----------------------------------------------------
; OUT_LCD GHI MA LENH/DATA RA LCD
; INPUT: R17 CHUA MA LENH/DATA
;----------------------------------------------------

OUT_LCD:         OUT OUTPORT, R17 ; GHI LENH/DATA RA LCD
                 SBI CONT, E ; CHO PHEP LCD
		 CBI CONT, E 
		 RET


;---------------------------------------------------
; DELAY_US TAO TRE R16 X 100US ( FOSC = 8MHZ ) ( NEU FOSC = 1MHZ THI LDI R16,25 )
; INPUT R16 HE SO NHAN THOI GIAN TRE [1:255]
;---------------------------------------------------
DELAY_US:         MOV R15, R16
                  LDI R16, 200
L1:		  MOV R14, R16
L2:               DEC R14
                  NOP
		  BRNE L2
		  DEC R15
		  BRNE L1
		  RET


.ORG 0X0200
;--------------------------------------
TAB: .DB "TN VXL-AVR",0X0D,"NHOM: 03",0X00
