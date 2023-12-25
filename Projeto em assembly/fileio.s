@ Various macros to perform file I/O

@ The fd parameter needs to be a register.
@ Uses R0, R1, R7.
@ Return code is in R0.

.include "unistd.s"

.equ O_RDONLY, 0 @valor da flag para abrir o arquivo somente como leitura
.equ O_WRONLY, 1 @valor da flag para abrir o arquivo somente como leitura
.equ O_CREAT, 0100
.equ S_RDWR, 0666 @valor da flag para abrir o arquivo como leitura e escrita

.macro openFile fileName, flags macro para abrir o arquivo com o as opções de leitura e escrita
	ldr r0, =\fileName @Nome do arquivo 
	mov r1, #\flags @flags sobre como abrir ele 
	mov r2, #S_RDWR @ RW access rights
	mov r7, #sys_open @chamada do SO responsável por abrir e criar o arquivo
	svc 0
.endm

.macro readFile fd, buffer, length @macro para ler um arquivo  
	mov r0, \fd @ file descriptor
	ldr r1, =\buffer @buffer do arquivo
	mov r2, #\length @tamanho do arquivo
	mov r7, #sys_read @chamada do SO responsável por ler um arquivo 
	svc 0
.endm

.macro writeFile fd, buffer, length @macro para escrever em um arquivo
	mov r0, \fd @ file descriptor 
	ldr r1, =\buffer @buffer do arquivo
	mov r2, \length @tamanho do arquivo 
	mov r7, #sys_write @chamda do SO responsavél por escrever em um arquivo
	svc 0
.endm

.macro flushClose fd @macro para fechar um arquivo q foi aberto
	@fsync syscall
	mov r0, \fd @ file descriptor 
	mov r7, #sys_fsync @Chamada do SO para sincronizar o estado do arquivo e armazena-lo
	svc 0
	@close syscall
	mov r0, \fd
	mov r7, #sys_close @Chamada do SO para fechar o descritor do arquivo
	svc 0
.endm
