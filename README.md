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

Este projeto tem como foco o desenvolvimento de programas utilizando a linguagem Assembly, aplicando conceitos fundamentais de arquitetura de computadores. A principal ênfase recai sobre a programação em Assembly para um processador com arquitetura ARM, compreendendo o conjunto de instruções específico e sua aplicação conforme as demandas do sistema.

Ao concluir este trabalho, espera-se que o/a discente alcance os seguintes objetivos:

- Adquirir proficiência na programação em Assembly para processadores ARM.
- Compreender e aplicar o conjunto de instruções da arquitetura ARM de acordo com as necessidades do sistema.
- Avaliar o desempenho de um código Assembly, analisando medidas relacionadas ao comportamento da execução no sistema.

O problema a ser abordado consiste no desenvolvimento de uma Interface Homem-Máquina (IHM) que apresente as informações de um sensor em um display LCD. Essa interface visa substituir uma versão anterior implementada em linguagem C, mantendo os mesmos requisitos. O protótipo da interface será integrado a um computador de placa única (SBC).

O desenvolvimento no SBC Orange Pi apresenta algumas restrições como: o código deve ser escrito em assembly e deve ser utilizado somente a interface disponibilizada (botões, chaves e LCD).

<div align="center">
  <img src="/img/fluxoHardware.drawio.png" alt="Fluxograma do hardware">
   <p>
    Fluxograma do hardware
    </p>
</div>

- **Projeto na Orange:** Este projeto foi desenvolvido utilizando a linguagem Assembly para realizar a comunicação eficiente com periféricos, além de processar e tratar os dados provenientes da ASP (Arquitetura de Sistema Percebido) por meio do protocolo de comunicação UART.

- **Projeto na ASP:** 

## Recursos Utilizados


## Como Executar


## Desenvolvimento - Módulos em Assembly da Orange
Nesta seção, detalharemos os módulos desenvolvidos em Assembly para a plataforma Orange. <- Fazer

### Módulo GPIOMEM
#### Módulos auxiliares
#### unistd
O unistd é responsável por definir as constantes para os números de chamadas do sistema que serão utilizadas no programa. Essas constantes são associadas aos serviços do kernel do sistema operacional que podem ser invocados pelo programa.
As quais são:
- sys_restart_syscall (0): Esta chamada do sistema reinicia a execução de uma chamada anterior que foi interrompida.
- sys_exit (1): Causa a terminação normal do processo. O valor retornado pelo processo é passado como argumento.
- sys_fork (2): Cria um novo processo filho, duplicando o processo chamador.
- sys_read (3): Lê dados de um descritor de arquivo (por exemplo, um arquivo, dispositivo ou soquete).
- sys_write (4): Escreve dados em um descritor de arquivo.
- sys_open (5): Abre ou cria um arquivo e retorna um descritor de arquivo para o mesmo.
- sys_close (6): Fecha um descritor de arquivo.
- sys_creat (8): Cria um novo arquivo.
- sys_link (9): Cria um novo nome (link) para um arquivo existente.
- sys_unlink (10): Remove um nome (link) para um arquivo. Se o link for o último, o arquivo é excluído.
- sys_execve (11): Executa um programa a partir de um arquivo executável.
- sys_nanosleep (162): Pausa a execução do programa pelo tempo especificado em nanossegundos.
- sys_mmap2 (192): Mapeia arquivos ou dispositivos na memória.
  
Essas constantes são usadas para identificar qual chamada do sistema deve ser feita quando o programa precisa interagir com o kernel do sistema operacional para realizar operações específicas, como ler ou escrever em arquivos, criar processos, entre outras.

#### fileio
Esse módulo é responsável por definir os macros que encapsulam as chamadas do sistema relacionadas a operações de entrada e saída de arquivos. O código utiliza as constantes das chamadas do sistema definidas no unistd.
Foram desenvolvivas quatro macros para gerenciar essas operações:
- <b>openFile:</b> Macro responsável por abrir um arquivo em modo de leitura e escrita, utiliza a chamada do sistema sys_open.
- <b>redFile:</b> Usa a chamada de sistema sys_read para ler um arquivo já aberto.
- <b>writeFile</b> Usa a chamada de sistema sys_write para escrever em um arquivo já aberto.
- <b>flushClose</b> Utiliza duas chamadas de sistema, a sys_fsync para sincronizar e armaenar o estado do arquivo aberto e a sys_close para fechá-lo.

### Módulo LCD
Como interface de visualização foi utilizado um display LCD da marca HITACHI, modelo HD44780U (LCD-II). Esse display tem uma resolução 16x2 o que indica que ele pode exibir 2 linhas com 16 caracteres.

<div align="center">
  <img src="/img/display.png" alt="HD44780U (LCD-II)" width="300">
   <p>
      HD44780U (LCD-II)
    </p>
</div>

#### Pinos

O display possui ao todo 14 pinos, porém para solução foi necessário fazer o manuseio somente dos seguintes pinos:
- **RS:** Seleciona o registrador de instrução caso esteja em 0 ou o registrador de dados caso esteja em 1.
- **R/W:** Seleciona a operação de escrita caso esteja em 0 ou a operação de leitura caso esteja em 1.
- **E:** Inicia uma operação de leitura ou escrita de dados quando em 1.
- **D7, D6, D5, D4:** Usado para transferência e recepção de dados.

Obs. No kit de desenvolvimento utilizado o pino R/W está ligado diretamente ao GND, logo só é possível fazer operações de escrita.

#### Instruções

A comunicação com o display é feita através de instruções enviadas ao mesmo utilizando os pinos citados anteriormente. Para solução foram utilizados as seguintes instruções:

| Instruction        | RS | R/W | DB7 | DB6 | DB5 | DB4 | DB3 | DB2 | DB1 | DB0 | Description        |
|--------------------|----|-----|-----|-----|-----|-----|-----|-----|-----|-----|--------------------|
| Function set       | 0  | 0   | 0   | 0   | 1   | DL  | N   | F   | -   | -   | Define o comprimento dos dados da interface (DL), número de linhas de exibição(N) e fonte de caracteres (F).       |
| Display on/off     | 0  | 0   | 0   | 0   | 0   | 0   | 1   | D   | C   | B   | Liga/desliga toda a exibição (D), cursor ligado/desligado (C) e piscando da posição do cursor.    |
| Entry mode set     | 0  | 0   | 0   | 0   | 0   | 0   | 0   | 1   | I/D | S   | Define a direção do movimento do cursor e especifica a mudança de exibição. Essas operações são executadas durante a gravação e leitura de dados.         |
| Write data         | 1  | 0   | -   | -   | -   | -   | -   | -   | -   | -   | Grava dados em DDRAM ou CGRAM.         |
| Set DDRAM address  | 0  | 0   | 1   | ADD | ADD | ADD | ADD | ADD | ADD | ADD | Define o endereço DDRAM. Os dados DRAM são enviados e recebidos após esta configuração.  |
| Clear display      | 0  | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 1   | Limpa todo o display e define o endereço DDRAM como 0 no contador de endereços.      |
| Return home        | 0  | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 1   | -   | Define o endereço DDRAM como 0 no contador de endereços. Também retorna a exibição de ser deslocada para a posição original. O conteúdo da DDRAM permanece inalterado.        |

#### Tempo do Enable

Após colocar todos os pinos utilizados nas instruções com os sinais referentes a instrução a ser tomada é necessário colocar em alto a entrada E (enable) do display. Para isso deve seguir os devidos intervalos de tempo informados pelo fabricante.

<div align="center">
  <img src="/img/tempo_do_eneable.png" alt="Waveform do Tempo da Operação de Escrita" width="400">
   <p>
      Waveform do Tempo da Operação de Escrita. Fonte: <a href="https://www.sparkfun.com/datasheets/LCD/HD44780.pdf">Datasheet</a>
    </p>
</div>

<div align="center">
  <img src="/img/tempo_do_eneable_tabela.png" alt="Tempo da Operação de Escrita">
   <p>
      Tempo da Operação de Escrita. Fonte: <a href="https://www.sparkfun.com/datasheets/LCD/HD44780.pdf">Datasheet</a>
    </p>
</div>

Ao observar as imagens é possivel perceber que para que a instrução seja executada corretamente o pino E deve ser habiltiado no minimo 60 ns (Adress set-up time) depois da ultima instrução. Além disso ele tem que permancer habilitado por no minimo 450 ns (Enable pulse width). Por fim deve ser desabilitado por no minimo 20 ns (Address hold time).

#### Inicialização

Em condições de alimentação ideais a inicialização do display já é feita automaticamente porem como a chance de falha em alcançar essas condições se faz necessario a implementação da inicialização. A inicialização se dá de acordo com o fluxograma a seguir.

<div align="center">
  <img src="/img/inicializacao_do_display.png" alt="Processo de Inicialização do Display">
   <p>
      Processo de Inicialização do Display. Fonte: <a href="https://www.sparkfun.com/datasheets/LCD/HD44780.pdf">Datasheet</a>
    </p>
</div>

É possivel observar que no processo a cima é usada a função *Function set* para definir o modo de operação de 4 bits, esse modo é utilizado porque no kit de desenvolvimento, como já falado, são utilizados apenas 4 pinos de dados, então faz-se necessario realizar essa mudança. Desse modo os dados das intruções antes passadas atraves de 8 pinos de dados em um envio somente, agora passam a ser passadas ao longo de 2 envios, sendo o primeiros os 4 dados mais significativos e os 4 ultimos, os menos significativos.

#### Implementação

As instruções citadas anteriormente foram implementadas utilizando as funções *GPIOTurnOff* e *GPIOTurnOn* do modulo *gpiomen.s* para colocar em alto ou em baixo os pinos utilizados. Alem delas também foi utilizado a função *nanoSleep* para espera dos devidos tempos tanto para o *Eneble* quanto para o processo de inicialização.

#### Exibição de Strings

Para exibição de uma string já inserida na memoria (.data) diretamente no display, foi necessario fazer um algoritmo que faz uso da instrução wiriteData para escrever caracter a caracter da string no display.

O algortimo é composto por diversas partes, e segue o fluxo presente na imagem abaixo

<div align="center">
  <img src="/img/writeString.png" alt="Fluxograma da função writeString" width="150">
   <p>
      Fluxograma da função writeString
    </p>
</div>

- **writeString:** É uma macro que é chamada quando se deseja exibir uma string no display. Ela é reponsavel por iniciar o procedimento de exibição. Para tal, ela salva a string no registrador R1 e também o tamanho da mesma no registrador R2. Além disso ela inicializa o contador (R0) que guarda o index do caracter a ser escrito no display.

- **funcWriteString:** Salva o link para o local de chamada da função.

- **loopWriteString:** Nessa label, cada caracter da string é percorrido e exibido, incrementando-se o valor de R0 até que ele seja igual ao tamanho da string. Ao final é usado o link salvo em *funcWriteString* para retornar ao local de chamada.

- **slice:** Divide o o código ASCII do caracter em 2 partes de 4 bits

- **funcWriteData:** Altera o estado lógico de cada um dos pinos de dado do LCD (D7, D6, D5, D4) para o estado correspondete ao conjunto de 4 bits recebido. Essa função é usada duas vezes, uma para os 4 bits mais significativos do código ASCII e outra para os 4 bits menos significativos.

Dentro da *funcWriteData* é preciso alterar o estado lógico de cada um dos 4 pinos de dado, para isso faz-se uso de uma função auxiliar *selPin*. Ela verifica qual pino terá seu estado lógico alterado e para qual estado lógico será alterado de acordo com o bit correspondente do conjunto. O fluxo da função pode ser visto na imagme abaixo, no qual **R11** corresponde ao index do bit e **R12** corresponde ao valor contido no bit, retornado pela função *getBit*.

<div align="center">
  <img src="/img/selPin.png" alt="Fluxograma da função writeString">
   <p>
      Fluxograma da função selPin
    </p>
</div>

#### Conversão de Decimal para ASCII

Os valores de temperatura e umidade retornados pela ESP vem em decimal, por conta disso se faz necessario converter esse valor para o equivalente ASCII dele. No entanto no caso de valores contendo dezenas e unidades, se faz necessario, alem dessa conversão, o fatiamento desses dois números, para que seja possivel exibi-lo no display. Para isso foi feita a função *getDigits* que recebe como entrada um valor em decimal, entre 0 e 99, e retorna o equivalente ao ASCII do número das dezenas e da unidade.

Para a divisão em dois números e conversão para ASCII foi utilizada a seguinte logica:
- Divide-se o número por 10 e obtem-se o número das dezenas
- Multiplica-se o número das dezenas por 10 e se subtrai esse valor do número original e se obtem o valor das unidades.
- Por fim soma-se a cada um desses valores 48. Desse modo obtem-se o equivalente ASCCI de cada digito do número.

### Módulo UART
Este módulo foi projetado para realizar a configuração e uso da UART em uma Orange Pi PC Plus. A UART (Universal asynchronous Receiver/Transmitter) é um protocolo essencial para a comunicação serial entre dispositivos e foi feita para transmissões de palavras de 8 bits, com 1 bit de start, sem bit de paridade e com a velociadade de transmissão de aproxiamdamente 9600 bps. 


#### Modo de operação
O modo de operação UART utilizado é o 16550. Este modo contém buffers no formato FIFO tanto para o transmitter como para o receiver, que servem para armazenar os dados que são recebidos dando a possibilidade do programador que estiver utilizando este modo escolha em que momento os dados serão lidos.

#### Escolha de pinos e endereçamento
A orange Pi pc plus, possui diversos pinos que podem servir para UART, os pinos escolhidos foram o PA13 e PA14, que são podem ser utilizados como UART3.Sendo assim as escolhas de endereços e configurações tiveram como base UART3.

<div align="center">
  <img src="/img/imagem_gpioo.png" alt="Gpioo Pinos">
   <p>
      Orange Pi PC Plus Pinout Fonte: <a href="http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/details/Orange-Pi-PC-Plus.html">Orange pi pc plus</a>
    </p>
</div>

Além disso, para obter o endereço base do CCU, endereço base para acessar os registradores da seção "inicializando a UART",foi feita uma subtração com o endereço já obtido do PIOO, já que assim já estariamos com o endereço do CCU com a operação: 

<div align="center">
  <img src="/img/Formula_endereco.png" alt="Formula Endereço">
    <p>
    Fórmula endereço do CCU
    </p>
</div> 

Já que o endereço de memória do PIOO está 0x800 posições a frente do CCU 

<div align="center">
  <img src="/img/endereco_CCU.png" alt="Endereço CCU">
   <p>
       Endereço do CCU e PIOO Fonte:<a href="https://drive.google.com/file/d/1AV0gV4J4V9BVFAox6bcfLu2wDwzlYGHt/view">Datasheet Pag:84</a>
    </p>
</div>

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

        <div align="center">
          <img src="/img/Enderecos_iguais.png" alt="Endereços iguais">
          <p>
          Endereços Iguais Fonte:<a href="https://drive.google.com/file/d/1AV0gV4J4V9BVFAox6bcfLu2wDwzlYGHt/view">Datasheet Pag:466</a>
        </p>
      </div>

        - Para saber qual valor irá ser colocado no divisor é necessário realizar esta operação:
        <div align="center">
          <img src="/img/Formula_divisor.png" alt="Formula">
          <p>
          Fórmula Divisor
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

  Para realizar o envio de dados a única operação necessária é armazenar um valor no endereço de memória correspondente ao transmitter da uart, por este motivo não foi necessária a criação de uma função especifica para isso.    

### Orquestração das funcionalidades
A coordenação e execução das funcionalidades essenciais são centralizadas em três módulos principais: main, inputMenu e outputMenu. Conforme ilustrado no diagrama, a main desempenha um papel crucial no mapeamento, inicialização e leitura do buffer, enquanto o inputMenu encarrega-se da leitura das solicitações do usuário. Por sua vez, o outputMenu é responsável por gerar e apresentar as respostas correspondentes a essas solicitações. Essa divisão de responsabilidades entre os módulos constitui a base para o funcionamento coordenado e eficiente do sistema.

<div align="center">
  <img src="/img/mains.drawio.png" alt="Fluxograma da main inputmenu e outputmenu">
   <p>
    Fluxograma da main inputmenu e outputmenu
    </p>
</div>

#### Main
Responsável por orquestrar o funcionamento integral do programa, o módulo `main` desempenha um papel crucial na inicialização do sistema, configuração de GPIO, controle do LCD e gerenciamento da comunicação UART. Além disso, direciona o fluxo para os módulos `inputMenu` e `outputMenu` conforme necessário.

Na prática, a função principal (`main`) concentra-se no mapeamento dos botões do LCD e UART, juntamente com a inicialização da LCD e UART. Após essa fase inicial, a `main` verifica a chave para determinar se deve direcionar o usuário para a tela de entrada (`inputMenu`) ou de saída (`outputMenu`). Também incorpora o `readBuffer`, monitorando continuamente a chegada de dados do `dataReceiver`. Essa monitorização avalia se os dados recebidos indicam a necessidade de desativar a medição contínua de temperatura ou umidade.

<div align="center">
  <img src="/img/readBuffer.drawio.png" alt="Fluxograma do readBuffer">
   <p>
    Fluxograma do readBuffer
    </p>
</div>

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

<div align="center">
  <img src="/img/confirm.drawio.png" alt="Fluxograma da função confirm">
   <p>
    Fluxograma da função confirm
    </p>
</div>

#### OutputMenu Module

O módulo `OutputMenu` desempenha a função de exibir os resultados das solicitações. Ele monitora a chave para alternar a tela para o `InputMenu`. A seguir, são detalhadas as funções deste módulo:

- **singleAnswer:** Verifica se o valor na variável `byte1` é igual ao último valor recebido. Se for, retorna ao `outputMenu` para verificar se o usuário optou por mudar de tela. Caso contrário, avança para o `singleAnswer2`.

- **singleAnswer2:** Carrega os valores recebidos em `byte1` e `byte2` e compara para identificar o tipo de resposta, como sensor com problema, sensor inexistente, sem resposta, sensor funcionando, umidade, temperatura e continuo desligado de temperatura ou umidade. Se não se enquadrar em nenhuma dessas categorias, exibe uma mensagem indicando que está aguardando requisição. A cada exibição da mensagem, chama a função `finishSingleAnswer`.

- **finishSingleAnswer:** Responsável por salvar o comando recebido e realizar comparações posteriores.


## Conclusão






