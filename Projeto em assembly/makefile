all:
	as -o main.o main.s
	ld -o main main.o
	sudo ./main
	
fifo:
	as -o testeFIFO.o testeFIFO.s
	ld -o testeFIFO testeFIFO.o
	sudo ./testeFIFO

uart:
	as -o uartT.o uartT.s
	ld -o uartT uartT.o
	sudo ./uartT