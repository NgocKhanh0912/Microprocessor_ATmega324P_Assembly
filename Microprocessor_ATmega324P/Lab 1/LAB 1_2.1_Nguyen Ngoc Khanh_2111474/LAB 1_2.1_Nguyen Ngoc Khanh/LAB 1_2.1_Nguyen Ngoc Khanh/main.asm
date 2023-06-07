;
; LAB 1_2.1_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 12:39:30 AM
;
;
; Ket noi PA0 vao mot kenh do tren khoi TEST STATION va do dang xung tren oscilloscope
;
; chan PA0 LA OUTPUT

           .ORG 0
	   LDI R16, 0X01
	   OUT DDRA, R16 ; KHAI BAO PA0 OUTPUT
START:
           SBI PORTA, PINA0 ; PORTA XUAT TIN HIEU MUC 1
           CBI PORTA, PINA0 ; PORTA XUAT TIN HIEU MUC 0
           RJMP START
