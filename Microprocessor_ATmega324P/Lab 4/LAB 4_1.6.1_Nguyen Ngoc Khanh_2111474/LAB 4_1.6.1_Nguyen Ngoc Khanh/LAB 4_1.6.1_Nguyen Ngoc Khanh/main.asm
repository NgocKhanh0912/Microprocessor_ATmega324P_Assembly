;
; LAB 4_1.6.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/7/2023 2:49:54 AM
; 
;
; ket noi cac tin hieu can thiet de dieu khien led ma tran
; quet led ma tran su dung timer interrupt
; hien thi chu 'A' len led ma tran


; PB0:7 LA D0:D7
; PA0 LA SCK (CLK + LATCH)
; PA1 LA SDA (DSI)

;-----------------------------------------------
             
                           .EQU OUTPORT = PORTB
			   .EQU IOSETB = DDRB
			   .EQU SCK = 0
			   .EQU SDA = 1
			   .EQU SHIFT = PORTA
			   .EQU SHIFT_DR = DDRA
			   .ORG 0
			   RJMP MAIN
			   .ORG 0X001A
		           RJMP COMPARE_MATCH ; INTERRUPTS SO SANH KENH 1A
			   .ORG 0X40 ; DUA CHUONG TRINH CHINH THOAT RA KHOI VUNG INTERRUPTS
MAIN: 
          LDI R16, HIGH(RAMEND)
          OUT SPH, R16
	  LDI R16, LOW(RAMEND)
	  OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

	  LDI R16, 0X03
	  OUT SHIFT_DR, R16 ; KHAI BAO PA01 LA OUTPUT
	  CBI SHIFT, SCK ; SCK = 0
	  CBI SHIFT, SDA ; SDA = 0

	  LDI R16, 0XFF 
	  OUT IOSETB, R16 ; PORTB OUTPUT

	  LDI R16, 0
	  OUT OUTPORT, R16 ; TAT TOAN BO DEN
START: 
           LDI ZH, HIGH(TAB) ; TRO DIA CHI BANG TRA
           LDI ZL, LOW(TAB)
	   CLC ; QUAY QUA C, C=0
	   ROL R30 ; QUAY TRAI ZL QUA C
	   ROL R31 ; QUAY TRAI ZH QUA C TAO DIA CHI NEN TRUY XUAT BO NHO CHUONG TRINH
	   LDI R19, 8 ; 8 LAN QUET
	   LDI R18, 0X01 ; MA QUET COT 0
LOOP: 
           CLR R16
           OUT OUTPORT, R16 ; XOA TAT CA CAC COT
	   LPM R17, Z+ ; LAY MA FONT KI TU, TANG DIA CHI CON TRO
	   RCALL SHO_8
	   OUT OUTPORT, R18 ; XUAT MA QUET COT
	   SEI ; CHO PHEP NGAT TOAN CUC
	   LDI R21, (1 << OCIE1A) ; CHO PHEP NGAT KHI TIMER1 TRAN
	   STS TIMSK1, R21
	   RCALL DELAY_2MS
	   CLC
	   ROL R18 ; QUAY TRAI TAO MA QUET COT TIEP THEO
	   DEC R19
	   BRNE LOOP
	   RJMP START 

;-----------------------------------------------
; SHO_8 DICH TRAI BIT DATA TRONG R17 RA SDA
; INPUT: R17
; OUTPUT SDA NOI TIEP MSB TRUOC
; PHAI DICH VA XUAT 9 LAN MOI DUNG VI TRI

SHO_8: 
                 LDI R16, 9 ; DEM 9 LAN DICH
SH_LOOP: 
                 ROL R17 ; QUAY TRAI QUA C BYTE THAP C = B7, B0 = C
                 BRCC BIT_0 ; C = 0 NHAY DEN BIT_0
		 SBI SHIFT, SDA ; BIT7 = 1 = SDA
		 RJMP NEXT
BIT_0:
                 CBI SHIFT, SDA ; BIT7 = 0 = SDA
NEXT:
                 SBI SHIFT, SCK ; TAO XUNG CK
                 CBI SHIFT, SCK
	         DEC R16 ; DEM 
	         BRNE SH_LOOP
	         RET

;--------------------------------------------------

COMPARE_MATCH: 
            LDI R22,1
	    RETI

;-----------------------------------------------
DELAY_2MS:
            LDI R21, HIGH(1999) ;  2ms = 2000 XUNG , MOI XUNG 1US
	    STS OCR1AH, R21
	    LDI R21, LOW(1999) ; 2000 - 1 XUNG, DOI NGAT
	    STS OCR1AL, R21

	    LDI R21, 0X00 
	    STS TCCR1A, R21 ; TIMER 1
	    LDI R21, 0X0A
	    STS TCCR1B, R21 ; MODE CTC CHIA 8 START
HERE:
            CPI R22, 1 ; DOI THUC HIEN CTRINH NGAT ROI MOI QUAY TRO LAI CTCHINH
	    BREQ BACK
	    RJMP HERE
BACK:	  
            LDI R21, 0X00
	    STS TCCR1B, R21 ; DUNG TIMER1
 	    CLR R22
            RET

;-----------------------------------------------------
TAB: .DB 0X00,0X7E,0X11,0X11,0X11,0X7E,0X00,0X00 ; MA QUET LED CHU 'A'
