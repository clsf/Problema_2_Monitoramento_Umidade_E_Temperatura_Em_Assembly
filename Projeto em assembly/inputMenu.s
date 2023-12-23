inputMenu:
    bl readBuffer

    @Verifica o valor da chave se for 1 vai para o menu de output
    GPIOGetData C4
    cmp r0, #1
    beq singleAnswer2

    @Verifica o valor do botão e soma caso seja pressionado
    GPIOGetData B0
    cmp r0, #0
    beq addCount

    @Verifica o valor do botão e subtrai caso seja pressionado
    GPIOGetData B2
    cmp r0, #0
    beq subCount

    @Verifica o valor do botão e confirma caso seja pressionado
    GPIOGetData B1
    cmp r0, #0
    beq confirm
    .ltorg

    @Continua o loop do inputMenu
    bl inputMenu

@Função reponsavél por fazer o debounce do botão cofirmação
confirm:
    nanoSleep time0, time150ms @Ignorar trepidação botão
    bl confirmLoop
@Fica em loop até que o botão seja solto
confirmLoop: 
    GPIOGetData B1
    cmp r0, #0 @botão ativa em nivel logico baixo 
    beq confirmLoop 
    nanoSleep time0, time150ms @Ignorar trepidação botão
    @Verifica a etapa do menu
    ldr r1, =mCount
    ldr r0, [r1]
    cmp r0, #0 @Primeira etapa se o valor ser zero(selecionou o sensor)
    beq nextSel
    @Se não for 0 selecionou o comando
    bl checkCont

@Incrementa o contador da etapa do menu e avanaça para proxima etapa
nextSel:
    add r0, r0, #1
    str r0, [r1]
    bl printInputMenu

@ Verifica se o comando selecionado é de monitoramento continuo
finishSel:
    ldr r1, =cCount
    ldr r1, [r1]

    cmp r1, #3
    beq tempContOn
    cmp r1, #4
    beq humContOn

    bl finishSel2

@ Ativa a variavel de controle (tempCont) para sinalizar que o monitoramento continuo foi ativado
tempContOn:
    ldr r0, =tempCont
    mov r1, #1
    str r1, [r0]

    @ Atualiza o sensor que está em continuo
    ldr r0, =sCount
    ldr r0, [r0]
    ldr r1, =sensorCont
    str r0, [r1]

    bl finishSel2

@ Ativa a variavel de controle (humCont) para sinalizar que o monitoramento continuo foi ativado
humContOn:
    ldr r0, =humCont
    mov r1, #1
    str r1, [r0]

    @ Atualiza o sensor que está em continuo
    ldr r0, =sCount
    ldr r0, [r0]
    ldr r1, =sensorCont
    str r0, [r1]

    bl finishSel2

@ Verifica se  o monitoramento continuo da temperatura está ativado
checkCont:
    ldr r0, =tempCont
    ldr r0, [r0]
    cmp r0, #0
    beq checkCont2
    @ Se estiver ativado verifica se o comando recebido é de desativação
    ldr r0, =cCount
    ldr r0, [r0]
    cmp r0, #0x05
    bne printContTempOn @ Se o comando não for de desativação, exibe a tela de monitoramento continuo ativado

    @ Verifica se o sensor ter o monitoramento continuo desativo é o mesmo que está ativo
    ldr r0, =sensorCont
    ldr r0, [r0]
    ldr r1, =sCount
    ldr r1, [r1]
    cmp r0, r1
    beq finishSel

    bl printContTempOn @ Se não, sinaliza que o monitoramento continuo está ativado

 @ Verifica se  o monitoramento continuo da umidade está ativado
checkCont2:
    ldr r0, =humCont
    ldr r0, [r0]
    cmp r0, #0
    beq finishSel
    @ Se estiver ativado verifica se o comando recebido é de desativação
    ldr r0, =cCount
    ldr r0, [r0]
    cmp r0, #0x06
    bne printContHumOn @ Se o comando for e desativação, envia o comando

    @ Verifica se o sensor ter o monitoramento continuo desativo é o mesmo que está ativo
    ldr r0, =sensorCont
    ldr r0, [r0]
    ldr r1, =sCount
    ldr r1, [r1]
    cmp r0, r1
    beq finishSel

    bl printContHumOn @ Se não, sinaliza que o monitoramento continuo está ativado

@ Exibe no LCD a sinalização que o monitoramento continuo da temperatura está ativado
printContTempOn:
    @ Reseta o contador da etapa do menu para 0
    mov r0, #0
    ldr r1, =mCount
    str r0, [r1]

    displayClear
    returnHome

    writeString msg19 lenMsg19
    setDDRAM
    writeString msg20 lenMsg20

    nanoSleep time2s, time0

    bl printInputMenu

@ Exibe no LCD a sinalização que o monitoramento continuo da umidade está ativado
printContHumOn:
    @ Reseta o contador da etapa do menu para 0
    mov r0, #0
    ldr r1, =mCount
    str r0, [r1]

    displayClear
    returnHome

    writeString msg21 lenMsg21
    setDDRAM
    writeString msg22 lenMsg22

    nanoSleep time2s, time0

    bl printInputMenu

@ Enviar o comando e o sensor para UART e reseta as as veriaveis de controle
finishSel2:
    @ Enviar para a UART o comando
    ldr r1, =cCount
    ldr r1, [r1]
    str r1, [r6]

    @ Enviar para a UART o sensor
    ldr r1, =sCount
    ldr r1, [r1]
    str r1, [r6]

    @ Reseta o contador da etapa do menu para 0
    mov r0, #0
    ldr r1, =mCount
    str r0, [r1]

    @ Reseta o contador do sensor para 15
    mov r0, #15
    ldr r1, =sCount
    str r0, [r1]

    @ Reseta o contador do comando para 1
    mov r0, #1
    ldr r1, =cCount
    str r0, [r1]
    
    bl loadingScreen

@ Tela de espera execução do comando na ESP
loadingScreen:
    displayClear
    returnHome
    writeString msg17 lenMsg17
    setDDRAM
    writeString msg18 lenMsg18

    nanoSleep time2s, time0 @ Tempo de espera da requisição

    bl printInputMenu

@ Função reponsavél por fazer o debounce do botão de adição
addCount:
    nanoSleep time0, time150ms @Ignorar trepidação botão
    bl loopAddCount
@Fica em loop até que o botão seja solto
loopAddCount:
    GPIOGetData B0
    cmp r0, #0
    beq loopAddCount
    nanoSleep time0, time150ms @Ignorar trepidação botão
    @Verificar se a etapa é de adicionar o sensor ou o comando
    ldr r0, =mCount
    ldr r0, [r0]
    cmp r0, #0
    beq addSensor
    bl addCommand

@Função responsavél por definir o valor limite da variavel do sensor 
addSensor:
    ldr r1, =sCount
    mov r2, #31
    bl addTarget

@Função responsavél por definir o valor limite da variavel do comando  
addCommand:
    ldr r1, =cCount
    mov r2, #6
    bl addTarget

@Função resposavél por somar a variavel do sensor ou comando dependendo da etapa
addTarget:
    ldr r0, [r1]
    cmp r0, r2
    beq limitAdd
    add r0, #1
    str r0, [r1]
    bl printInputMenu

@Caso esteja somando no valor limite reseta para o valor inicial
limitAdd:
    mov r0, #0
    str r0, [r1]
    bl printInputMenu

@ Função reponsavél por fazer o debounce do botão de subtração
subCount:
    nanoSleep time0, time150ms @Ignorar trepidação botão
    bl loopSubCount
@ Função reponsavél por fazer o debounce do botão de subtração
loopSubCount:
    GPIOGetData B2
    cmp r0, #0
    beq loopSubCount
    nanoSleep time0, time150ms @Ignorar trepidação botão

    @Verificar se a etapa é de sutrair o sensor ou o comando
    ldr r0, =mCount
    ldr r0, [r0]
    cmp r0, #0
    beq subSensor
    bl subCommand

@Função responsavél por definir o valor limite da variavel do sensor 
subSensor:
    ldr r1, =sCount
    mov r2, #31
    bl subTarget

@Função responsavél por definir o valor limite da variavel do comando  
subCommand:
    ldr r1, =cCount
    mov r2, #6
    bl subTarget

@Função resposavél por subtrair a variavel do sensor ou comando dependendo da etapa
subTarget:
    ldr r0, [r1]
    cmp r0, #0
    beq limitSub
    sub r0, #1
    str r0, [r1]
    bl printInputMenu

@Caso esteja subtraindo no valor limite reseta para o valor inicial
limitSub:
    mov r0, r2
    str r0, [r1]
    bl printInputMenu

@Função responsavél por printar a tela de entrada
printInputMenu:
    displayClear
    returnHome

    writeString sChar lenSChar

    getDigits sCount digit1 digit2
    writeData digit1
    writeData digit2

    @Verifica estapa do menu e printa o comando caso a etapa seja 1
    ldr r0, =mCount
    ldr r0, [r0]
    cmp r0, #1
    beq command
    bl inputMenu

@Função que printa a linha do comando 
command:
    setDDRAM

    writeString cChar lenCChar

    getDigits cCount digit1 digit2
    writeData digit1
    writeData digit2

    bl inputMenu

