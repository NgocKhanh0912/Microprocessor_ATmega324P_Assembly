;
; LAB 4_1.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/7/2023 2:39:23 AM
; 
;
; lap trinh tao 1 xung tan so 1k Hz tren chan PC0 su dung ngat timer 1 overflow
; khi timer 1 tran, chuong trinh phuc vu ngat dao chan PC0 va dat lai gia tri cho thanh ghi dem

                   .ORG 0
		   RJMP MAIN
		   .ORG 0X001E
		   RJMP TIMER1_OVF ; INTERRUPTS TIMER1 OVERFLOW
		   .ORG 0X40 ; DUA CHUONG TRINH CHINH RA KHOI VUNG INTERRUPTS
MAIN:  
           LDI R16, HIGH(RAMEND)
           OUT SPH, R16
	   LDI R16, LOW(RAMEND)
	   OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO

	   LDI R16, 0X01
	   OUT DDRC, R16 ; PC0 OUTPUT 

	   LDI R17, HIGH(61536) ; 0.5MS = 4000 XUNG MOI XUNG 0.125US
	   STS TCNT1H, R17
	   LDI R17, LOW(61536) ; 65535 - 4000 + 1 = 61536
	   STS TCNT1L, R17

	   LDI R17, 0X00 
	   STS TCCR1A, R17 ; TIMER 1 MODE NOR
	   LDI R17, 0X01
	   STS TCCR1B, R17 ; MODE NOR, KHONG CHIA, START

           SEI ; CHO PHEP NGAT TOAN CUC
	   LDI R17, (1 << TOIE1) ; CHO PHEP NGAT KHI TIMER1 TRAN
	   STS TIMSK1, R17
START:     RJMP START

;-----------------------------------------------------------------------
TIMER1_OVF: 
           LDI R17, 0X00
	   STS TCCR1B, R17 ; DUNG TIMER1

	   LDI R17, HIGH(61536) 
	   STS TCNT1H, R17
	   LDI R17, LOW(61536) ; NAP TCNT1
	   STS TCNT1L, R17

	   IN R17, PORTC ; DOC PORTC
	   EOR R17, R16 ; DAO BIT CHAN PC0 VOI R16 = 0X01
	   OUT PORTC, R17

	   LDI R17, 0X01
	   STS TCCR1B, R17 ; MODE NOR KHONG CHIA START
	   RETI