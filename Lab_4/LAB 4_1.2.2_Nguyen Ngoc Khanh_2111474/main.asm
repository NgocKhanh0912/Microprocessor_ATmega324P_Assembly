;
; LAB 4_1.2.2_Nguyen Ngoc Khanh.asm
;
; Created: 5/7/2023 2:41:11 AM
; 
;
; cau hinh timer de tao ra ngat COMPARE_MATCH sau moi 1ms
; trong ngat su dung 1 so dem de dem so lan xay ra ngta va dieu khien chan PC0 de tao ra xung co tan so 100Hz
; moi lan xay ra ngat cong so dem len 1, neu so dem bang 5 thi dao bit PC0 va reset so dem ve 0

                   .ORG 0
		   RJMP MAIN
		   .ORG 0X001A
		   RJMP COMPARE_MATCH ; INTERRUPTS SO SANH KENH 1A
		   .ORG 0X40 ; DUA CHUONG TRINH CHINH RA KHOI VUNG INTERRUPTS
MAIN:  
           LDI R16, HIGH(RAMEND)
           OUT SPH, R16
	   LDI R16, LOW(RAMEND)
	   OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

	   LDI R16, 0X01
	   OUT DDRC, R16 ; PC0 OUTPUT 

	   LDI R18 , 0 ; BIEN DEM SO LAN NGAT

	   LDI R17, HIGH(39999) ; 100Hz = 0.01s , 5ms = 40000 xung , moi xung 0.125us
	   STS OCR1AH, R17
	   LDI R17, LOW(39999) ; 40000 - 1 XUNG DOI NGAT
	   STS OCR1AL, R17

	   LDI R17, 0X00 
	   STS TCCR1A, R17 ; TIMER 1
	   LDI R17, 0X09
	   STS TCCR1B, R17 ; MODE CTC KHONG CHIA START

           SEI ; CHO PHEP NGAT TOAN CUC
	   LDI R17, (1 << OCIE1A) ; CHO PHEP NGAT KHI TIMER1 TRAN
	   STS TIMSK1, R17
START:     RJMP START

;-----------------------------------------------------------------------
COMPARE_MATCH: 
           INC R18
	   CPI R18, 6
	   BREQ CHANGE
           LDI R17, 0X00
	   STS TCCR1B, R17 ; DUNG TIMER1

	   LDI R17, HIGH(7999) 
	   STS OCR1AH, R17
	   LDI R17, LOW(7999) ; NAP OCR1A = 1MS
	   STS OCR1AL, R17

	   LDI R17, 0X09
	   STS TCCR1B, R17 ; MODE CTC KHONG CHIA START
	   RETI
CHANGE:	   
           IN R17, PORTC ; DOC PORTC
	   EOR R17, R16 ; DAO BIT CHAN PC0 VOI R16 = 0X01
	   OUT PORTC, R17
	   CLR R18
	   LDI R17, 0X00

	   STS TCCR1B, R17 ; DUNG TIMER1

	   LDI R17, HIGH(1) 
	   STS OCR1AH, R17
	   LDI R17, LOW(1) ; NAP OCR1A DE TAO NGAT TIEP THEO
	   STS OCR1AL, R17

	   LDI R17, 0X09
	   STS TCCR1B, R17 ; MODE CTC KHONG CHIA START
           RETI

