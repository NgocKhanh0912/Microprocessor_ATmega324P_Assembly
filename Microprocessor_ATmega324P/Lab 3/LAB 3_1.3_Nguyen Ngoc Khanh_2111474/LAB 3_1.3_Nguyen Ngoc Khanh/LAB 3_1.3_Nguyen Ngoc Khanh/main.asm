;
; LAB 3_1.3_Nguyen Ngoc Khanh.asm
;
; Created: 5/6/2023 3:53:57 PM
; 
;
; ket noi cac tin hieu MOSI, SCK cua port SPI tu avr den tin hieu SDI va CLK cua khoi thanh ghi dich
; ket noi 2 chan port khac vao tin hieu nCLR va LATCH
; ket noi ngo ra cua thanh ghi dich vao bar led
; ket noi cac tin hieu UART
; Viet chuong trinh ghi nhan 1 gia tri tu UART va xuat ra bar led su dung SPI

; SS NOI VAO LATCH
; MOSI NOI VOI DSI
; SCK NOI VOI CLK
; PA0 NOI VOI nCLR

                .DEF DATA_UART_REC = R20
		.DEF DATA_SPI_TRANS = R21
		.DEF DATA_SPI_REC = R22   
		.DEF DATA_SHIFT = R23
		.EQU CLEAR = 3        
		.EQU SHCP = 2
		.EQU STCP = 1
		.EQU DS = 0

		.EQU SS = 4
		.EQU MOSI = 5
		.EQU MISO = 6
		.EQU SCK = 7
		.ORG 0X00
		RJMP MAIN
		.ORG 0X40 ; DUA CHUONG TRINH CHINH RA KHOI VUNG INTERRUPTS
MAIN:	
		RCALL USART_INIT

		SBI DDRA, 0 ; PA0 OUTPUT
		SBI PORTA, 0 ; PA0 BAN DAU = 1

		LDI R16, (1<<SS)|(1<<SCK)|(1<<MOSI) ; KHAI BAO CAC OUTPUT SPI
		OUT DDRB, R16
		LDI R16, (1<<SPE0)|(1<<MSTR0)|(1<<SPR00) ; SPI MASTER
		OUT SPCR0, R16
		SBI PORTB, SS ; DUNG TRUYEN SPI
START:

		RCALL USART_REC
		MOV DATA_SPI_TRANS, DATA_UART_REC

		RCALL SPI_TRANS_REC

		CBI PORTB, SS
		SBI PORTB, SS
		
		RJMP START

;----------------------------------------------------------------------------------
USART_INIT:
		LDI R16, (1<<TXEN0|1<<RXEN0) ; CHO PHEP BO THU/PHAT
		STS UCSR0B, R16

		LDI R16, (1<<UCSZ01)|(1<<UCSZ00) ; 8 BIT DATA/KHONG KT CHAN LE/1 STOP BIT
		STS UCSR0C, R16

		LDI R16, 0
		STS UBRR0H, R16
		LDI R16, 51 ; BAUD RATE = 9600 UNG VOI FOSC =8MHZ
		STS UBRR0L, R16
		
		RET

;--------------------------------------------------------------------------
USART_REC:
		LDS R17, UCSR0A
		SBRS R17, RXC0
		RJMP USART_REC
		LDS DATA_UART_REC, UDR0 ; NAP DU LIEU TU UDR0 VAO R16
		RET

SPI_TRANS_REC:
		OUT SPDR0, DATA_SPI_TRANS ; GHI DARA RA SPI
WAIT_SPI:
		IN R16, SPSR0 ; DOC CO SPIF0
		SBRS R16, SPIF0 ; CO SPIEF0 = 1 TRUYEN SPI XONG
		RJMP WAIT_SPI ; CHO CO SPIF0 = 1
		//IN DATA_SPI_REC, SPDR0 ; DOC DATA TU SPI
		RET
