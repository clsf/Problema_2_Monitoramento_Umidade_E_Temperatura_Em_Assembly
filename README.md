# Problema_2_Monitoramento_Umidade_E_Temperatura_Em_Assembly
Problema 2 da disciplina de Sistemas Digitais - Monitoramento de Temperatura e Humidade em Assembly

## Sumário
- [Introdução](#introdução)
  - [Como Executar](#como-executar)
  - [Subtópicos](#subtópicos)
- [Desenvolvimento](#desenvolvimento)
  - [Subtópicos](#subtópicos)
- [Conclusão](#conclusão)

## Introdução
Nesta seção, abordaremos informações essenciais sobre o projeto, incluindo uma visão geral do desenvolvimento na plataforma Orange, módulos responsáveis e referências ao projeto de Paulo.

- **Projeto na Orange:** Descreva brevemente o projeto na plataforma Orange, destacando os principais módulos e suas responsabilidades.

- **Projeto de Paulo:** Forneça um link para o projeto de Paulo, permitindo que os usuários acessem mais informações relevantes.

## Equipe de Desenvolvimento
- **Tutor:** [Nome do Tutor]

## Recursos Utilizados
Liste os recursos, ferramentas e tecnologias que foram utilizados durante o desenvolvimento do projeto.

## Como Executar
Forneça instruções claras sobre como executar o projeto. Isso pode incluir requisitos de sistema, instalação de dependências e passos específicos para a execução do código.

## Desenvolvimento - Módulos em Assembly da Orange
Nesta seção, detalharemos os módulos desenvolvidos em Assembly para a plataforma Orange.

### Módulo GPIOMEM
Explique a funcionalidade do módulo GPIOMEM, detalhando seu papel no projeto.

### Módulo LCD
Como interface de visualização foi utilizado um display LCD da marca HITACHI, modelo HD44780U (LCD-II). Esse display tem uma resolução 16x2 o que indica que ele pode exibir 2 linhas com 16 caracteres.

<div align="center">
  <img src="/img/display.png" alt="HD44780U (LCD-II)">
   <p>
      Diagrama de Estados do Receiver.
    </p>
</div>

#### Pinos

O display possui ao todo 14 pinos, porém para solução foi necessário fazer o manuseio somente dos seguintes pinos:
- RS: Seleciona o registrador de instrução caso esteja em 0 ou o registrador de dados caso esteja em 1.
- R/W: Seleciona a operação de escrita caso esteja em 0 ou a operação de leitura caso esteja em 1.
- E: Inicia uma operação de leitura ou escrita de dados quando em 1.
- D7, D6, D5, D4: Usado para transferência e recepção de dados.

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
  <img src="/img/tempo_do_eneable.png" alt="Waveform do Tempo da Operação de Escrita">
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

Em condições de alimentação ideais a inicialização do display já é feita automaticamente porem como a chance de falha em alcansar essas condições se faz necessario a implementação da inicialização. A inicialização se dá de acordo com o fluxograma a seguir.

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

Texto aqui

#### Conversão de Decimal para ASCII

Texto aqui

### Módulo UART
Este módulo foi projetado para realizar a configuração e uso da UART em uma Orange Pi PC Plus. A UART (Universal asynchronous Receiver/Transmitter) é um protocolo essencial para a comunicação serial entre dispositivos e foi dita para transmissões de palavras de 8 bits, com 1 bit de start, sem bit de paridade e com a velociadade de transmissão de aproxiamdamente 9600 bps. 


#### Modo de operação
O modo de operação UART utilizado é o 16550.Este modo contém buffers no formato FIFO tanto para o transmitter como para o receiver, que servem para armazenar os dados que são recebidos dando a possibilidade do programador que estiver utilizando este modo escolha em que momento os dados serão lidos.

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
    

### Mains
Discuta os diversos módulos mains desenvolvidos, abordando suas funcionalidades específicas e importância no projeto.

## Conclusão
Nesta seção, resuma o que foi alcançado durante o desenvolvimento. Utilize vídeos e imagens para destacar visualmente o progresso e os resultados do projeto.





