.include "fileio.s"

@ Definição das contantes
.equ pagelen, 4096
.equ PROT_READ, 1
.equ PROT_WRITE, 2
.equ MAP_SHARED, 1

@ Macro para mapear a memória dos registradores do GPIO
.macro mapMem
    openFile devmem, S_RDWR @ abre /dev/mem
    movs r4, r0 @ move o conteúdo de r0(descrior de arquivo) para r4
    @ checa se deu erro e printa a mensagem se erro se necessário
    BPL 1f @ número positivo significa que o arquivo foi aberto
    MOV R1, #1 @ stdout(standard output)
    LDR R2, =memOpnsz @ mensagem de erro
    LDR R2, [R2]
    writeFile R1, memOpnErr, R2 @ printa o erro
    B _end


@ Configura a chamada ao serviço mmap2 do kernel Linux.
1: ldr r5, =gpioaddr @ endereço desejado / 4096
    ldr r5, [r5] @ carrega o endereço
    mov r1, #pagelen @ tamanho da memoria desejado

@ mem protection options
mov r2, #(PROT_READ + PROT_WRITE)
mov r3, #MAP_SHARED @ opções do compartilhamento de memoria
mov r0, #0 @ o kernel linux deve escolher um endereço virtual para a memória mapeada.
mov r7, #sys_mmap2 @ move o número de serviço de mmap2 para r7
svc 0 @ chama o serviço
mov r8, r0 @ salva o valor retornado pela chamada do sistema
add r8, #0x800
@ checa se deu erro e printa a mensagem se erro se necessario
BPL 2f @ número positivo significa que a chamada mmap2 deu certo
MOV R1, #1 @ stdout(standard output)
LDR R2, =memMapsz @ mensagem de erro
LDR R2, [R2]
writeFile R1, memMapErr, R2 @ printa o erro
B _end

2:
.endm

@Macro para mapear a memória dos registradores do UART
.macro mapMemUART
    openFile devmem, S_RDWR @ abre /dev/mem
    movs r4, r0 @ move o conteúdo de r0(descrior de arquivo) para r4
    @ checa se deu erro e printa a mensagem se erro se necessário
    BPL 1f @ número positivo significa que o arquivo foi aberto
    MOV R1, #1 @ stdout(standard output)
    LDR R2, =memOpnsz @ mensagem de erro
    LDR R2, [R2]
    writeFile R1, memOpnErr, R2 @ printa o erro
    B _end


@ Configura a chamada ao serviço mmap2 do kernel Linux.
1: ldr r5, =uartaddr @ endereço desejado / 4096
    ldr r5, [r5] @ carrega o endereço
    mov r1, #pagelen @ tamanho da memoria desejado

@ mem protection options
mov r2, #(PROT_READ + PROT_WRITE)
mov r3, #MAP_SHARED @ opções do compartilhamento de memoria
mov r0, #0 @ o kernel linux deve escolher um endereço virtual para a memória mapeada.
mov r7, #sys_mmap2 @ move o número de serviço de mmap2 para r7
svc 0 @ chama o serviço
mov r6, r0 @ salva o valor retornado pela chamada do sistema
add r6, #0xC00
@ checa se deu erro e printa a mensagem se erro se necessario
BPL 2f @ número positivo significa que a chamada mmap2 deu certo
MOV R1, #1 @ stdout(standard output)
LDR R2, =memMapsz @ mensagem de erro
LDR R2, [R2]
writeFile R1, memMapErr, R2 @ printa o erro
B _end

2:
.endm

@ Macro nanoSleep pausa por 0.1 segundo
@ Chama o ponto de entrada do nanosleep do Linux, que é a função 162.
@ Passa a referencia para um timespec em r0 e r1
@ O primeiro é o tempo de entrada para pausar em segundos e nanossegundos.
@ O segundo é o tempo que resta para pausar se for interrompido (que ignoramos)
.macro nanoSleep sec nanosec
    ldr r0, =\sec
    ldr r1, =\nanosec
    mov r7, #sys_nanosleep
    svc 0
.endm

.macro GPIOUART pin
    ldr r2, =\pin @ offset do registrador selecionado
    ldr r3, =\pin @ offset do registrador selecionado
    BL funcGPIOUART
.endm

funcGPIOUART:
    ldr r2, [r2] @ carrega o valor
    ldr r1, [r8, r2] @ endereço do registrador
    add r3, #4 @ carrega a quantidade de deslocamento da tabela
    ldr r3, [r3] @ carrega o valor do deslocamento amt
    mov r0, #0b111 @ mascara para limpar 3 bits
    lsl r0, r3 @ desloca para posição
    bic r1, r0 @ limpa os 3 bits
    mov r0, #0b11 @ 1 bit para deslocar para posição
    lsl r0, r3 @ deslocamento pela quantidade da tabela
    orr r1, r0 @ liga o bit
    str r1, [r8, r2] @ atualiza o valor do registrador associado aos pinos GPIO.
    BX LR

.macro GPIODirectionOut pin
    ldr r2, =\pin @ offset do registrador selecionado
    ldr r3, =\pin @ offset do registrador selecionado
    BL funcGPIODirectionOut
.endm

funcGPIODirectionOut:
    ldr r2, [r2] @ carrega o valor
    ldr r1, [r8, r2] @ endereço do registrador
    add r3, #4 @ carrega a quantidade de deslocamento da tabela
    ldr r3, [r3] @ carrega o valor do deslocamento amt
    mov r0, #0b111 @ mascara para limpar 3 bits
    lsl r0, r3 @ desloca para posição
    bic r1, r0 @ limpa os 3 bits
    mov r0, #1 @ 1 bit para deslocar para posição
    lsl r0, r3 @ deslocamento pela quantidade da tabela
    orr r1, r0 @ liga o bit
    str r1, [r8, r2] @ atualiza o valor do registrador associado aos pinos GPIO.
    BX LR

.macro GPIODirectionIn pin
    ldr r2, =\pin @ offset do registrador selecionado
    ldr r3, =\pin @ offset do registrador selecionado
    BL funcGPIODirectionIn
.endm

funcGPIODirectionIn:
    ldr r2, [r2] @ carrega o valor
    ldr r1, [r8, r2] @ endereço do registrador
    add r3, #4 @ carrega a quantidade de deslocamento da tabela
    ldr r3, [r3] @ carrega o valor do deslocamento amt
    mov r0, #0b111 @ mascara para limpar 3 bits
    lsl r0, r3 @ desloca para posição
    bic r1, r0 @ limpa os 3 bits
    str r1, [r8, r2] @ atualiza o valor do registrador associado aos pinos GPIO.
    BX LR

.macro GPIOTurnOn pin
    LDR R0, =\pin @ carrega o endereco de ~pin~
    BL funcGPIOTurnOn
.endm

funcGPIOTurnOn:
	LDR R2, [R0, #8] @ offset do pino no registrador de dados
    LDR R1, [R0, #12] @ offset do registrador de dados do pino
    LDR R5, [R8, R1] @ endereco base + registrador de dados
    MOV R4, #1 @ move 1 para R4
    LSL R4, R2 @ desloca o bit para a posicao do pino no registrador de dados
    ORR R3, R5, R4 @ insere 1 na posicao anteriomente deslocada
    STR R3, [R8, R1] @ armazena o novo valor do registrador de dados na memoria
    BX LR

.macro GPIOTurnOff pin
    LDR R0, =\pin @ carrega o endereco de ~pin~
    BL funcGPIOTurnOff
.endm

funcGPIOTurnOff:
    LDR R1, [R0, #12] @ offset do registrador de dados do pino
	LDR R2, [R0, #8] @ offset do pino no registrador de dados
    LDR R5, [R8, R1] @ endereco base + offset do registrador de dados
    MOV R4, #1 @ move 1 para R4
    LSL R4, R2@ desloca para R4 R4 R2 vezes
    BIC R3, R5, R4 @ insere 1 na posicao anteriomente deslocada
    STR R3, [R8, R1] @ armazena o novo valor do registrador de dados na memoria
    BX LR

.macro GPIOGetData pin
    LDR R0, =\pin @ carrega o endereco de ~pin~
    BL funcGPIOGetData
.endm

funcGPIOGetData:
	LDR R2, [R0, #8] @ offset do pino no registrador de dados
    LDR R1, [R0, #12] @ offset do registrador de dados do pino
    LDR R5, [R8, R1] @ endereco base + registrador de dados
    MOV R4, #1 @ move 1 para R4
    LSL R4, R2 @ desloca o bit para a posicao do pino no registrador de dados
    AND R3, R5, R4 @ insere 1 na posicao anteriomente deslocada
    LSR R0, R3, R2 @ desloca o bit para a posição menos significativa
    BX LR

.data
msg1: .ascii "Sensor"
msg2: .ascii "com problema"
lenMsg1: .word 6
lenMsg2: .word 12

msg3: .ascii "Sensor"
msg4: .ascii "inexistente"
lenMsg3: .word 6
lenMsg4: .word 11

msg5: .ascii "Requisição"
msg6: .ascii "inexistente"
lenMsg5: .word 10
lenMsg6: .word 11

msg7: .ascii "Sensor"
msg8: .ascii "funcionando"
lenMsg7: .word 6
lenMsg8: .word 11

msg9: .ascii "Umidade: "
lenMsg9: .word 9

msg10: .ascii "Temperatura: "
lenMsg10: .word 13

msg11: .ascii "Temperatura"
msg12: .ascii "continua off"
lenMsg11: .word 11
lenMsg12: .word 12

msg13: .ascii "Umidade"
msg14: .ascii "continua off"
lenMsg13: .word 7
lenMsg14: .word 12

msg15: .ascii "Aguardando"
msg16: .ascii "Requisicao"
lenMsg15: .word 10
lenMsg16: .word 10

msg17: .ascii "Comando em"
msg18: .ascii "Execucao"
lenMsg17: .word 10
lenMsg18: .word 8

msg19: .ascii "Temperatura"
msg20: .ascii "Continua On"
lenMsg19: .word 11
lenMsg20: .word 11

msg21: .ascii "Umidade"
msg22: .ascii "Continua On"
lenMsg21: .word 7
lenMsg22: .word 11

sChar: .ascii "Sensor: "
lenSChar: .word 8
cChar: .ascii "Comando: "
lenCChar: .word 9

saltarLinha: .ascii "\n"    @ Usado no debug
saltar2Linhas: .ascii "\n\n"

byte1: .word 0  @ Buffer do primeiro byte recebido
byte2: .word 0 @ Buffer do segundo byete recebido
tempCont: .word 0 @ Variavel de controle de temperatura continua
humCont: .word 0 @ Variavel de controle de umidade continua
sensorCont: .word 0 @ Variavel que armazena qual sensor está em continuo
firstSend: .word 0  @ Ultima resposta exibida na tela
mCount: .word 0 @ contador de telas do menu
sCount: .word 15 @ contador do menu sensor
cCount: .word 1 @ contador do menu comando

digit1: .word 0 @ primeiro digito apos a separacao
digit2: .word 0 @ segundo digito apos a separacao

time2s: .word 2 
time150ms: .word 150000000 
time0: .word 0
time1ms: .word 1000000
time5ms: .word 5000000 
time15ms: .word 15000000 
time150us: .word 150000 
devmem: .asciz "/dev/mem"
memOpnErr: .asciz "Failed to open /dev/mem\n"
memOpnsz: .word .-memOpnErr
memMapErr: .asciz "Failed to map memory\n"
memMapsz: .word .-memMapErr

.align 4 @ Alinha os dados na memória em uma fronteira de 4 bytes

@ endereço de memoria dos registradores do gpio / 4096
gpioaddr: .word 0x1C20 @ 800
uartaddr: .word 0x1C28 @ C00

/*
    ordem das palavras dos endereços dos registradores
    Offset do Registrador de Função
    Offeset do pino no Registrador de Função
    Offset do pino no Registrador de Dados
    Offset do Registrador de Dados
 */

RS:
    .word 0x0
    .word 0x8
    .word 0x2
    .word 0x10

E:
    .word 0x8
    .word 0x8
    .word 0x12
    .word 0x10

D4:
    .word 0xDC
    .word 0x0
    .word 0x8
    .word 0xE8

D5:
    .word 0xDC
    .word 0x4
    .word 0x9
    .word 0xE8

D6:
    .word 0xD8
    .word 0x18
    .word 0x6
    .word 0xE8

D7:
    .word 0xD8
    .word 0x1C
    .word 0x7
    .word 0xE8

@ PA07
B0: 
    .word 0x00
    .word 28
    .word 7
    .word 0x10

@ PA10
B1:
    .word 0x4
    .word 0x8
    .word 0xA
    .word 0x10

@ PA20
B2: 
	.word 0x8
	.word 0x10
	.word 0x14
	.word 0x10

@ PA03
C4:
    .word 0x00
    .word 0xC
    .word 0x3
    .word 0x10

@ PA13 UART3_TX
TX: 
    .word 0x04
    .word 0x14
    .word 0xD
    .word 0x10

@ PA14 UART3_RX
RX: 
    .word 0x04
    .word 0x18
    .word 0xE
    .word 0x10

.text
