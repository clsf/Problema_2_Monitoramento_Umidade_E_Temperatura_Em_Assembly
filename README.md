# Problema_2_Monitoramento_Umidade_E_Temperatura_Em_Assembly
Problema 2 da disciplina de Sistemas Digitais - Monitoramento de Temperatura e Humidade em Assembly

## Equipe de Desenvolvimento
- Antonio
- Cláudia
- Luis
- Nirvan

## Tutor
- Thiago Jesus

## Sumário
- [Introdução](#introdução)
- [Recursos Utilizados](#recursos-utlizados)
- [Como Executar](#como-executar)
- [Desenvolvimento](#desenvolvimento)
  - [Módulo GPIOMEM](#módulo-gpiomem)
  - [Módulo LCD](#módulo-lcd)
  - [Módulo UART](#módulo-uart)
  - [Orquestração das Funcionalidades](#orquestração-das-funcionalidades)
- [Conclusão](#conclusão)

## Introdução
Nesta seção, abordaremos informações essenciais sobre o projeto, incluindo uma visão geral do desenvolvimento na plataforma Orange, módulos responsáveis e referências ao projeto de Paulo.

- **Projeto na Orange:** Descreva brevemente o projeto na plataforma Orange, destacando os principais módulos e suas responsabilidades.

- **Projeto de Paulo:** Forneça um link para o projeto de Paulo, permitindo que os usuários acessem mais informações relevantes.

## Recursos Utilizados
Liste os recursos, ferramentas e tecnologias que foram utilizados durante o desenvolvimento do projeto.

## Como Executar
Forneça instruções claras sobre como executar o projeto. Isso pode incluir requisitos de sistema, instalação de dependências e passos específicos para a execução do código.

## Desenvolvimento - Módulos em Assembly da Orange
Nesta seção, detalharemos os módulos desenvolvidos em Assembly para a plataforma Orange.

### Módulo GPIOMEM
Explique a funcionalidade do módulo GPIOMEM, detalhando seu papel no projeto.

### Módulo LCD
Descreva as características e a função do módulo LCD, destacando sua contribuição para o projeto.

### Módulo UART
Este módulo foi projetado para realizar a configuração e uso da UART em uma Orange Pi PC Plus. A UART (Universal asynchronous Receiver/Transmitter) é um protocolo essencial para a comunicação serial entre dispositivos e foi dita para transmissões de palavras de 8 bits, com 1 bit de start, sem bit de paridade e com a velociadade de transmissão de aproxiamdamente 9600 bps. 

#### Modo de operação
O modo de operação UART utilizado é o 16550. Este modo contém buffers no formato FIFO tanto para o transmitter como para o receiver, que servem para armazenar os dados que são recebidos dando a possibilidade do programador que estiver utilizando este modo escolha em que momento os dados serão lidos.

#### Escolha de pinos
A orange Pi pc plus, possui diversos pinos que podem servir para UART, os pinos escolhidos foram o PA13 e PA14, que são podem ser utilizados como UART3.Sendo assim as escolhas de endereços e configurações tiveram como base UART3.(imagem Gpioo?)

##### Funções implementadas 
  1. initUART: 
    - Inicializando a UART 
      - È desabilitado duas vezes em sequência o reset da UART3 através do registrador BUS_SOFT_RST_REG4 
      - Habilita o PLL_PERIPH0 como fonte de clock de 600MHz através do registrador PLL_PERIPH0_CTRL_REG 
      - Seleciona o PLL_PERIPH0 como fonte de clock através do registrador APB2_CFG_REG 
      - Habilita o UART3_GATING que para ativar o clock no barramento através do registrador BUS_CLK_GATING_REG3  
    - Configurando a UART3 
      - È habilitado o FIFO através do registrador UART_FCR
      - Devido ao fato dos registradores que representam a parte alta e parte baixa do divisor do baud rate possuirem o mesmo endereço de memória que outros registradores que tem funções diferentes, é necessário que seja ativado o DLAB, que está no registrador UART_LCR, para que os endereços de memoria que serão utilizados tenham a função esperada de divisor  
        - Para saber qual valor irá ser colocado no divisor é necessário realizar esta operação:
        <div align="center">
          <img src="/img/Formula_divisor.png" alt="Formula">
          <p>
          Formula Divisor
          </p>
      </div>

       - Este número em binário é 111101000010.01, desta maneira é possivel saber o valor da parte baixa do divisor(01000010) e a parte alta(1111)

      - È registrado o valor 01000010 no DLL(divisor latch low) através do registrador UART_DLL 

      - É registrado o valor 1111 no DLH(divisor latch hig) através do registrador UART_DLH 

      - È desativado o DLAB no registrador UART_LCR para que os endereços de memória voltem a ter suas funções anteriores 

      - Configura-se o tamanho da palavra como 8 bits e desativa o bit de paridade através do registrado UART_LCR 
  2. dataReceiver:
    - Após ser chamada, a função verifica se existe algum dado pronto para ser lido no buffer do receiver através do registrador UART_LSR verificando o bit DR(data ready)
    - Caso tenha algum dado para ser lido é lido o endereço de memória correspondente ao receiver e o dado é obtido  

  Para realizar o envio de dados a única operação necessária é armazenar um valor no endereço de memória correspondente ao transmitter da uart, por este motivo não foi necessária a criação de uma função especifica para isso 
    

### Orquestração das funcionalidades
A coordenação e execução das funcionalidades essenciais são centralizadas em três módulos principais: main, inputMenu e outputMenu. Conforme ilustrado no diagrama, a main desempenha um papel crucial no mapeamento, inicialização e leitura do buffer, enquanto o inputMenu encarrega-se da leitura das solicitações do usuário. Por sua vez, o outputMenu é responsável por gerar e apresentar as respostas correspondentes a essas solicitações. Essa divisão de responsabilidades entre os módulos constitui a base para o funcionamento coordenado e eficiente do sistema.

#### Main
Responsável por orquestrar o funcionamento integral do programa, o módulo `main` desempenha um papel crucial na inicialização do sistema, configuração de GPIO, controle do LCD e gerenciamento da comunicação UART. Além disso, direciona o fluxo para os módulos `inputMenu` e `outputMenu` conforme necessário.

Na prática, a função principal (`main`) concentra-se no mapeamento dos botões do LCD e UART, juntamente com a inicialização da LCD e UART. Após essa fase inicial, a `main` verifica a chave para determinar se deve direcionar o usuário para a tela de entrada (`inputMenu`) ou de saída (`outputMenu`). Também incorpora o `readBuffer`, monitorando continuamente a chegada de dados do `dataReceiver`. Essa monitorização avalia se os dados recebidos indicam a necessidade de desativar a medição contínua de temperatura ou umidade.

##### Fluxo de Execução

1. **Mapeamento e Inicialização:**
   Este módulo realiza o mapeamento dos botões do LCD e UART, a direção dos pinos da GPIO e define o TX e RX da UART. A inicialização é feita para a LCD e UART.

2. **Verificação da Chave (`keyStatus`):**
   Após a fase de inicialização, a aplicação verifica uma chave determinante para decidir a rota subsequente do fluxo de execução. Essa decisão, orientada pela chave, é fundamental, direcionando o programa para a tela de entrada (`inputMenu`) ou para a tela de saída (`outputMenu`), adaptando-se dinamicamente às necessidades do usuário.

3. **Leitura do Buffer (`readBuffer`):**
   Mantém uma etiqueta de `readBuffer` para verificar se há dados vindos do `dataReceiver`, especialmente para desativar a medição contínua de temperatura ou umidade.

#### InputMenu Module

O módulo `InputMenu` desempenha um papel crucial no gerenciamento das interações do usuário e na coleta de dados de entrada. Ele lida com a leitura de entrada por meio de três botões: B0 (Incrementa), B1 (Confirma) e B2 (Decrementa), que são responsáveis pela seleção do sensor e do comando. Para lidar com o ruído ao pressionar o botão, são utilizados módulos de debounce, incluindo `confirm` (para o botão de confirmação), `addCount` (para incrementar) e `subCount` (para decrementar). Abaixo estão detalhados os métodos do `InputMenu`:

- **InputMenu:** Verifica se o usuário mudou para a tela através da chave, direcionando para o `outputMenu` se aplicável. Confere se B0 foi pressionado, chamando o método `addCount`. Em seguida, verifica se o botão B2 foi pressionado, redirecionando para o `subCount`. Por fim, verifica se B1 foi pressionado, direcionando para o `confirm`. Se nada for modificado, permanece em looping neste método.

- **confirm e confirmLoop:** Utilizado para ignorar ruídos do botão. Após isso, verifica em qual etapa está: selecionando sensor ou comando. Se a variável `mCount` estiver igual a 0, ainda está na etapa de seleção do sensor e avança para a seleção do comando (`nextSel`). Se já estiver selecionando o comando, segue para o método `checkCont`.

- **nextSel:** Incrementa o contador de etapa e vai para o método `printInputMenu`.

- **checkCont:** Verifica se a temperatura contínua de algum sensor está ativada. Em caso afirmativo, verifica se o comando solicitado pelo usuário é de desativação. Se sim, o fluxo segue para o `finishSel`; caso contrário, chama o método `printContTempOn`, exibindo no display que a temperatura contínua está ativada. Se a temperatura contínua estiver desativada, segue para o `checkCont2`.

- **checkCont2:** Semelhante ao `checkCont`, mas verifica se o comando de umidade contínua de algum sensor está ativado. Se estiver e o comando não for de desativar, exibe uma mensagem informando que o comando de umidade contínua está ativado. Se não estiver, segue para o `finishSel`.

- **finishSel:** Responsável por verificar se o comando é de ativação da temperatura ou umidade contínua. Se for, chama o `tempContOn` ou `humContOn`. Caso contrário, segue para o `finishSel2`.

- **tempContOn:** Ativa a variável de controle responsável por comunicar que a temperatura contínua está ativada e chama o `finishSel2`.

- **humContOn:** Ativa a variável de controle responsável por comunicar que a umidade contínua está ativada e chama o `finishSel2`.

- **finishSel2:** Encaminha para a UART o comando e o sensor, apresenta a etapa do menu, além do contador dos sensores e comando. Em seguida, segue para o método `loadingScreen`.

- **loadingScreen:** Método responsável por exibir na tela que o comando está em execução. Em seguida, retorna para a tela `printInputMenu`.

- **addCount e loopAddCount:** Utilizado para ignorar ruídos do botão. Após isso, verifica se a etapa é de incrementar o sensor ou o comando. Se for sensor, chama `addSensor`; caso contrário, chama `addCommand`.

- **addSensor e addCommand:** Responsável por definir o valor limite das variáveis do sensor e comando.

- **addTarget:** Função responsável por somar a variável do sensor ou comando, dependendo da etapa. Caso esteja no limite, chama o método `limitAdd`, que reinicia a variável e chama `printInputMenu`.

- **subCount e loopSubCount:** Utilizado para ignorar ruídos do botão. Após isso, verifica se a etapa é de decrementar o sensor ou o comando. Se for sensor, chama `subSensor`; caso contrário, chama `subCommand`.

- **subSensor e subCommand:** Responsável por definir o valor limite das variáveis do sensor e comando.

- **subTarget:** Função responsável por subtrair a variável do sensor ou comando, dependendo da etapa. Caso esteja no limite, chama o método `limitSub`, que reinicia a variável e chama `printInputMenu`.

- **printInputMenu:** Exibe a tela de entrada e, se estiver na fase de comando, chama o método `command`, que escreverá a linha de comando no LCD, retornando para o `inputMenu`.

#### OutputMenu Module

O módulo `OutputMenu` desempenha a função de exibir os resultados das solicitações. Ele monitora a chave para alternar a tela para o `InputMenu`. A seguir, são detalhadas as funções deste módulo:

- **singleAnswer:** Verifica se o valor na variável `byte1` é igual ao último valor recebido. Se for, retorna ao `outputMenu` para verificar se o usuário optou por mudar de tela. Caso contrário, avança para o `singleAnswer2`.

- **singleAnswer2:** Carrega os valores recebidos em `byte1` e `byte2` e compara para identificar o tipo de resposta, como sensor com problema, sensor inexistente, sem resposta, sensor funcionando, umidade, temperatura e continuo desligado de temperatura ou umidade. Se não se enquadrar em nenhuma dessas categorias, exibe uma mensagem indicando que está aguardando requisição. A cada exibição da mensagem, chama a função `finishSingleAnswer`.

- **finishSingleAnswer:** Responsável por salvar o comando recebido e realizar comparações posteriores.


## Conclusão
Nesta seção, resuma o que foi alcançado durante o desenvolvimento. Utilize vídeos e imagens para destacar visualmente o progresso e os resultados do projeto.





