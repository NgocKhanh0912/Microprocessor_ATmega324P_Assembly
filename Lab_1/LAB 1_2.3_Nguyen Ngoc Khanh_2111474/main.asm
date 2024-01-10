;
; LAB 1_2.3_Nguyen Ngoc Khanh.asm
;
; Created: 5/4/2023 11:44:08 AM
; 
;
; Ket noi cac tin hieu can thiet tu 1 port cua AVR den cac tin hieu dieu khien thanh ghi dich tren header J13. Ket noi ngo ra cua thanh ghi dich den Bar LED.
; Viet chuong trinh tao hieu ung LED sang dan tu trai qua phai, sau do tat dan tu trai qua phai sau moi khoang thoi gian 500ms.
; PORT A NOI VOI THANH GHI DICH


                .ORG 0
		RJMP MAIN
		.ORG 0X40
MAIN:    
                LDI R16, HIGH(RAMEND)
                OUT SPH, R16
		LDI R16, LOW(RAMEND)
		OUT SPL, R16 ; DUA STACK LEN VUNG DIA CHI CAO
		LDI R16, 0X07
		OUT DDRA, R16 ; 3 BIT DIEU KHIEN CUA PORT A NOI VOI THANH GHI DICH : PA0 = DS, PA1 = SHCP CK DICH, PA2 = STCP CK XUAT OUTPUT
START:  
                LDI R17, 0XFF   ; R17 CHUA CAC BIT DICH DE DIEU KHIEN LED
                CLC ; C BAN DAU = 0
                RCALL SHIFT_OUT
		RJMP START

 ;-----------------------------------------------------------
 ; SHIFT_OUT DICH DATA NOI TIEP XUAT RA MSB TRUOC
 ; INPUT : R17 CHUA DATA CAN DICH
 ; OUTPUT : R17 VAN BAO TOAN NOI DUNG BAN DAU

 SHIFT_OUT: 
            LDI R16, 8 ; R16 DEM SO BIT CAN DICH
 SH_O: 
            ROL R17 ; QUAY TRAI R17 QUA C
            BRCC BIT_0 ; C = 0 XUAT BIT 0
	    SBI PORTA, 0 ; C = 1 XUAT BIT 1
	    RCALL DL500MS
	    RJMP SH_CK
BIT_0: 
            CBI PORTA, 0
            RCALL DL500MS
SH_CK: 
            SBI PORTA, 1 ; TAO XUNG CK DICH
            CBI PORTA, 1 
	    SBI PORTA, 2
	    CBI PORTA, 2 ; TAO XUNG CK XUAT
	    DEC R16
	    BRNE SH_O
	    ROL R17 ; PHUC HOI R17
	    RET
DL500MS: 
            LDI R21,250 ; FOSC = 1MHZ DA LAP TRINH
LP2: 
            LDI R20,250
LP1: 
            NOP
            NOP 
	    NOP
	    NOP
	    NOP
            DEC R20
	    BRNE LP1
	    DEC R21
	    BRNE LP2
	    RET
