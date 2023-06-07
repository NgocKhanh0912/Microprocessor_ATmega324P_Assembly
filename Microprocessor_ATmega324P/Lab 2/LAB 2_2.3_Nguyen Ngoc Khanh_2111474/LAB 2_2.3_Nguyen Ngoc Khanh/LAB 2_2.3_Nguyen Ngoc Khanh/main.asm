;
; LAB 2_2.3_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 1:49:30 PM
; 
;
; ket noi cac tin hieu can thiet de dieu khien led ma tran
; hien thi chu 'A' tren led ma tran
; quet led su dung timer de tao delay

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
			   .ORG 0X40 ; DUA CHUONG TRINH RA KHOI VUNG INTERRUPTS
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
	   RCALL DELAY1MS
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
; DUNG TIMER0 DELAY 1MS
DELAY1MS:      LDI R22, 0X00 
	       OUT TCCR0A, R22 ; TIMER 0 MODE NOR
	       LDI R22, 0X00
	       OUT TCCR0B, R22 ; MODE NOR STOP
               LDI R22, -125
               OUT TCNT0, R22 ; NAP GIA TRI BAN DAU
               LDI R22, 0X03 ; RUN, CHIA 64
               OUT TCCR0B, R22
WAIT:     IN R22, TIFR0 ; KIEM TRA CO BAO TRAN
          SBRS R22, TOV0
	  RJMP WAIT ; NEU CHUA TRAN, NHAY LAI WAIT
	  OUT TIFR0, R22 ; XOA CO BAO TRAN
	  LDI R22, 0X00 ; STOP
	  OUT TCCR0B, R22
	  RET
;-----------------------------------------------------
TAB: .DB 0X00,0X7E,0X11,0X11,0X11,0X7E,0X00,0X00 ; ma quet cot cua chu 'A'
