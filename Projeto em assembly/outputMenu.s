outputMenu:
    bl readBuffer

    @Verifica o valor da chave se for 0 vai para o menu de input
    GPIOGetData C4
    cmp r0, #0
    beq printInputMenu

    bl singleAnswer

@Verifica se o valor do byte1 é igual ao ultimo recebido 
singleAnswer:
    ldr r0, =byte1
    ldr r0, [r0]
    ldr r1, =firstSend
    ldr r1, [r1]
    cmp r0, r1
    beq outputMenu

@Caso o valor recebido seja diferente do anterior ele carrega o valores e determina qual mensagem será exibida
singleAnswer2:
    @Limpa LCD
    displayClear 
    @Função para retornar o ponteiro para linha de cima
    returnHome

    @Carrega os valores recebidos em byte1 e byte2
    ldr r0, =byte1
    ldr r0, [r0]
    ldr r1, =byte2
    ldr r1, [r1]

    @Compara a resposta recebida e envia para exibição das telas correspondentes
    cmp r0, #0x1F
    beq problemSensor
    cmp r0, #0x2F
    beq noSensor
    cmp r0, #0x3F
    beq noRequest
    cmp r0, #0x07
    beq sensorWorking
    cmp r1, #0x08
    beq humidity
    cmp r1, #0x09
    beq temperature
    cmp r0, #0x0A
    beq contTempOff
    cmp r0, #0x0B
    beq contHumOff

    @Exibe mensagem de aguardando requisição
    bl awaitReq

@Exibe mensagem de sensor com problema
problemSensor:
    writeString msg1 lenMsg1
    setDDRAM
    writeString msg2 lenMsg2
    bl finishSingleAnswer

@Exibe mensagem de sensor inexistente
noSensor:
    writeString msg3 lenMsg3
    setDDRAM
    writeString msg4 lenMsg4
    bl finishSingleAnswer

@Exibe mensagem de comando inexistente
noRequest:
    writeString msg5 lenMsg5
    setDDRAM
    writeString msg6 lenMsg6
    bl finishSingleAnswer

@Exibe mensagem de sensor funcionando
sensorWorking:
    writeString msg7 lenMsg7
    setDDRAM
    writeString msg8 lenMsg8
    bl finishSingleAnswer

@Exibe a medida de umidade
humidity:
    writeString msg9 lenMsg9

    getDigits byte1 digit1 digit2
    writeData digit1
    writeData digit2
    bl finishSingleAnswer

@Exibe a medida de temperatura
temperature:
    writeString msg10 lenMsg10

    getDigits byte1 digit1 digit2
    writeData digit1
    writeData digit2
    bl finishSingleAnswer

@Exibe a mensagem de temperatura contiua desligada
contTempOff:
    writeString msg11 lenMsg11
    setDDRAM
    writeString msg12 lenMsg12
    bl finishSingleAnswer

@Exibe a mensagem de umidade cotinua desligada
contHumOff:
    writeString msg13 lenMsg13
    setDDRAM
    writeString msg14 lenMsg14
    bl finishSingleAnswer

@Exibe a mensagem de espera de comando
awaitReq:
    writeString msg15 lenMsg15
    setDDRAM
    writeString msg16 lenMsg16
    bl finishSingleAnswer

@Função que salva o comando recebido para fazer a comparação posteriormente
finishSingleAnswer:
    ldr r0, =byte1
    ldr r0, [r0]
    ldr r1, =firstSend
    str r0, [r1]
    
    bl outputMenu
