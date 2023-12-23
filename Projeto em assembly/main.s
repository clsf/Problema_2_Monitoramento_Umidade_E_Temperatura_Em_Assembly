.include "gpiomem.s"
.include "uart.s"
.include "lcd.s"
.include "outputMenu.s"
.include "inputMenu.s"
.include "debug.s"

.global _start

_start:
    mapMem @ Salva o endereço base do GPIO no reg r8

    GPIODirectionIn B0
    GPIODirectionIn B1
    GPIODirectionIn B2
    GPIODirectionIn C4

    GPIODirectionOut RS
    GPIODirectionOut E
    GPIODirectionOut D4
    GPIODirectionOut D5
    GPIODirectionOut D6
    GPIODirectionOut D7
    .ltorg
    initialization @ Inicialização do LCD
    displayOn
    modeSet

    mapMemUART @ Salva o endereço base da UARt no reg r6

    GPIOUART TX @ Muda o pin 13 para o modo UART TX
    GPIOUART RX @ Muda o pin 14 para o modo UART RX

    bl initUART @ Inicializa a UART

@ Primeira exibição na tela
keyStatus:
    GPIOGetData C4
    cmp r0, #0
    beq printInputMenu
    bl singleAnswer

readBuffer:
    @ Verifica se o buffer da UART está pronto para a leitura
    push {lr}
    mov r1, #1
    ldr r0, [r6, #0x0014] @ Carrega o registrador DR
    and r0, r0, r1
    cmp r0, #0
    beq backMenu

    @ Ler os dados da UART
    bl dataReceiver 
    mov r2, r0
    
    cmp r2, #0
    beq backMenu

    bl dataReceiver
    mov r3, r0

    @ Salva os dados lidos na memoria
    ldr r0, =byte1
    str r2, [r0]

    ldr r0, =byte2
    str r3, [r0]

    @ Chama a função que exibe no terminal os bytes recebidos
    printDebug
    ldr r0, =byte1
    ldr r2, [r0]
    ldr r0, =byte2
    ldr r3, [r0]

    @ Verifica se a temperatura continua foi desativada
    cmp r2, #0x0A
    beq tempContOff

    @ Verifica se a humidade continua foi desativada
    cmp r2, #0x0B
    beq humContOff

    @ Verifica se foi recebido o comando sensor inexistente
    cmp r2, #0x2F
    beq nullSensor

    @ Verifica se o monitoramento continuo da temperatura ou humidade esta ativado
    @ Nesses casos ele nao precisa limpar o buffer pois não há lixo
    ldr r0, =tempCont
    ldr r0, [r0]
    cmp r0, #1
    beq backMenu

    ldr r0, =humCont
    ldr r0, [r0]
    cmp r0, #1
    beq backMenu

    bl clearBuffer

@ Altera o controlador de temperatura continua para 0
tempContOff:
    ldr r0, =tempCont
    mov r1, #0
    str r1, [r0]
    bl clearBuffer

@ Altera o controlador de humidade continua para 0
humContOff:
    ldr r0, =humCont
    mov r1, #0
    str r1, [r0]
    bl clearBuffer

@ Desativa o controlador da temperatura continuo e humidade
@ Caso tenha cido ativdo pora um sensor inexistente
nullSensor:
    ldr r0, =tempCont
    mov r1, #0
    str r1, [r0]

    ldr r0, =humCont
    mov r1, #0
    str r1, [r0]

    bl backMenu

@ Remove o lixo do buffer da UART
clearBuffer:
    bl dataReceiver
    bl dataReceiver

    bl backMenu

@ Retorna parao  local a onde a função readBuffer foi chamada
backMenu:
    pop {PC}

_end:
    mov r0, #0
    mov r7, #1
    svc 0
    