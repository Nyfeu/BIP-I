-- ===============================================================================================================================================
--
--          ██████╗ ██╗██████╗       ██╗
--          ██╔══██╗██║██╔══██╗     ███║           Descrição de Hardware (VHDL)
--          ██████╔╝██║██████╔╝████╗╚██║           Unidade Central de Processamento (CPU)
--          ██╔══██╗██║██╔═══╝ ╚═══╝ ██║           
--          ██████╔╝██║██║           ██║           ->> AUTOR: André Solano F. R. Maiolini (19.02012-0)
--          ╚═════╝ ╚═╝╚═╝           ╚═╝           ->> DATA: 25/06/2024
--
-- ============+=================================================================================================================================
--   Descrição |
-- ------------+
-- 
--  Este código VHDL descreve a arquitetura de uma Unidade Central de Processamento (CPU) simplificada.
--  A CPU é capaz de executar instruções básicas armazenadas na memória ROM, utilizando um acumulador (ACC)
--  e uma Unidade Lógica e Aritmética (ALU) para operações aritméticas e lógicas. Utliza arquitetura de 
--  barramentos de Harvard.
--
-- ===================+===========================================================================================================================
--  Entradas / Saídas |
-- -------------------+
--
--  enable_clk  : Habilita pulsos de clock, ou seja, inicia a execução;
--  MR          : Master-Reset (ativo em LOW);
--  in_port_1   : Porte de entrada 1 (16 bits);
--  in_port_2   : Porte de entrada 2 (16 bits);
--  in_port_3   : Porte de entrada 3 (16 bits);
--  in_port_4   : Porte de entrada 4 (16 bits);
--  out_port_1  : Porte de saída 1 (16 bits);
--  out_port_2  : Porte de saída 2 (16 bits);
--  out_port_3  : Porte de saída 3 (16 bits);
--  out_port_4  : Porte de saída 4 (16 bits).
--
-- =====================+=========================================================================================================================
--  Diagrama de Blocos  |
-- ---------------------+                     Arquitetura de barramentos Harvard                   ____________________________
--                                                                                                /                           /\
--                  +--------+             +-----+   addr   +-----+   addr   +-----+             /         BIP I            _/ /\
--            MR >--|        |             |     | <------- |     | -------> |     |            /        (Harvard)         / \/
--    enable_clk >--|  CPU   |   ==>       | ROM |   inst   | CPU |   data   | RAM |           /                           /\
--                  |        |             |     | -------> |     | <------> |     |          /___________________________/ /
--                  +--------+             +-----+          +-----+          +-----+          \___________________________\/
--                                                                                             \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
--
-- ===============================================================================================================================================
--

--| Libraries |===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| CPU |=========================================================================================================================================

entity cpu is

    -- (PORTAS CPU - entradas de controle básicas ) ===========================================================================================

    port(
        enable_clk  : in  std_logic;                                       -- Habilita pulsos de clock
        MR          : in  std_logic;                                       -- Master-Reset (ativo em LOW)
        in_port_1   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 1 (16 bits)
        in_port_2   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 2 (16 bits)
        in_port_3   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 3 (16 bits)
        in_port_4   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 4 (16 bits)
        out_port_1  : out std_logic_vector(15 downto 0);                   -- Porte de saída 1 (16 bits)
        out_port_2  : out std_logic_vector(15 downto 0);                   -- Porte de saída 2 (16 bits)
        out_port_3  : out std_logic_vector(15 downto 0);                   -- Porte de saída 3 (16 bits)
        out_port_4  : out std_logic_vector(15 downto 0)                    -- Porte de saída 4 (16 bits)
    );

    -- O sinal "enable_clk" é responsável por habilitar o TIMER interno da CPU, dessa forma,
    -- inicia os pulsos de CLOCK do processador - em outras palavras, começa a execução.

    -- MR (Master-Reset) serve para resetar a contagem do Program Counter (PC), assim como
    -- resetar os valores armazenados em registradores e afins.

    -- Tem-se também 4 portas para entrada de dados e outras 4 para saída. Dessa forma,
    -- será feito o endereçamento por meio de 2 bits, num dispositivo dedicado "io_device".
    -- É delegada a esse dispositivo a responsabilidade de encaminhar para o Acumulador (ACC)
    -- o valor correto de INPUT, assim como registrar o OUTPUT em sua respectiva porta.

end entity cpu;

--| Architecture |================================================================================================================================

architecture main of cpu is

    -- Define os valores genéricos (CONSTANTES) ==================================================================================================

    -- Alguns componentes foram criados usando valores genéricos. Caso necessário, podem ser usadas
    -- as seguintes constantes para definir os valores específicos necessários.

    constant n             : integer := 16;                                -- Tamanho em bits do PC
    constant f             : integer := 2000;                              -- freq. do clock [MHz]
    constant addr_rom      : integer := 16;                                -- Bits de endereçamento da ROM
    constant i_word        : integer := 16;                                -- Tamanho da palavra de instrução

    -- (SINAIS INTERNOS) =========================================================================================================================

    -- Para que possa ser feita a comunicação adequada entre os diversos componentes que integram
    -- a CPU, é necessário que sejam definidos sinais internos.

    signal CLOCK           : std_logic;                                    -- Clock interno da CPU (recebe o clock do TIMER)
    signal PC_out          : std_logic_vector(n - 1 downto 0);             -- Valor de saída do contador (valor do PC)
    signal ROM_out         : std_logic_vector(i_word-1 downto 0);          -- Define a instrução que será carregada no IR
    signal IR_out          : std_logic_vector(i_word-1 downto 0);          -- Instrução lida da saída do IR
    signal OP_CODE         : std_logic_vector(3 downto 0);                 -- Código de operação (4 MSBs do IR_out)
    signal OPERAND         : std_logic_vector(11 downto 0);                -- Operando 12 bits (12 LSBs do IR_out)
    signal EX_SINAL        : std_logic_vector(15 downto 0);                -- Operando extendido (16 bits)
    signal ACC_in          : std_logic_vector(15 downto 0);                -- Valor da entrada do acumulador
    signal ACC_out         : std_logic_vector(15 downto 0);                -- Valor da saída do acumulador
    signal RAM_data        : std_logic_vector(15 downto 0);                -- Valor lido da RAM
    signal ALU_out         : std_logic_vector(15 downto 0);                -- Resultado lido da ALU
    signal ALU_in          : std_logic_vector(15 downto 0);                -- Entrada da ALU
    signal OE              : std_logic := '1';                             -- Habilita output da memória (sempre habilitado)
    signal ME              : std_logic := '1';                             -- Habilita memória (sempre habilitado)
    signal load_val        : std_logic_vector(n - 1 downto 0);             -- Valor a ser carregado no PC
    signal ZF_in           : std_logic;                                    -- Zero flag (ZF_in) lida da ALU
    signal GZ_in           : std_logic;                                    -- Greater than Zero flag (GZ_in) lida da ALU
    signal input_data      : std_logic_vector(15 downto 0);                -- Valor recebido do dispositivo de I/O
    signal io_addr         : std_logic_vector(1 downto 0);                 -- Endereçamento do porte de I/O

    -- (CONTROL BUS) =============================================================================================================================

    -- Além dos sinais internos, tem-se os sinais de controle decodificados a partir das instruções
    -- em execução (de acordo com o valor registrado pelo IR). Esses sinais são responsáveis por
    -- controlar os diversos componentes. Selecionando entradas e saídas, habilitando operações de escrita
    -- e leitura, bem como selecionando as operações a serem executadas.

    signal SelUlaSrc       : std_logic;                                    -- Sinal de seleção da fonte para a ALU
    signal OP_ULA          : std_logic;                                    -- Sinal de seleção de operação da ALU
    signal WR_RAM          : std_logic;                                    -- Sinal de escrita na memória de dados (RAM)
    signal WR_PC           : std_logic;                                    -- Sinal de incremento do PC
    signal WR_IR           : std_logic;                                    -- Sinal de escrita do IR
    signal WR_ACC          : std_logic;                                    -- Sinal de escrita no ACC
    signal SelAccSrc1      : std_logic;                                    -- Seleciona dados para o ACC (MSB)
    signal SelACCSrc0      : std_logic;                                    -- Seleciona dados para o ACC (LSB)
    signal PC_load         : std_logic := '0';                             -- Sinal de carregamento (ativo em HIGH)
    signal RD_io           : std_logic;                                    -- Habilita leitura dos portes de INPUT
    signal WR_io           : std_logic;                                    -- Habilita escrita nos portes de OUTPUT

    -- (COMPONENTES INTERNOS) ====================================================================================================================

    -- Para que os componentes possam ser utilizados para integrar a CPU, é necessário definí-los,
    -- de forma que, possa-se criar instâncias de cada componente (uma ou múltiplas vezes).

        -- [TIMER] -------------------------------------------------------------------------------------------------------------------------------

        component generic_timer is
            generic(
                clk_freq : integer := f                                    -- Define a frequência do TIMER
            );
            port(
                clk : out std_logic := '0';                                -- Será responsável por fornecer o CLOCK 
                enable : in std_logic                                      -- Habilita os pulsos do TIMER
            );
        end component generic_timer;

        -- [CONTADOR] ----------------------------------------------------------------------------------------------------------------------------

        component generic_counter is
            generic(
                n : integer := n                                           -- Define a largura de bits do contador
            );
            port (
                clk      : in  std_logic;                                  -- Sincroniza o contador
                MR       : in  std_logic;                                  -- Master-Reset reinicia a contagem
                en       : in  std_logic;                                  -- Habilita a contagem
                load     : in  std_logic;                                  -- Sinal de carregamento (ativo em HIGH)
                load_val : in  std_logic_vector(n - 1 downto 0);           -- Valor a ser carregado
                count    : out std_logic_vector(n - 1 downto 0)            -- Valor atual do contador
            );
        end component generic_counter;

        -- [MEMÓRIA DE PROGRAMA] -----------------------------------------------------------------------------------------------------------------

        -- Para a aplicação foi adotada uma memória de somente leitura (ROM - Read Only Memória), pois,
        -- as operações feitas se restringem a leitura. Isso significa que o código gravado na memória, será
        -- alterado a uma razão muito mais baixa que a taxa de leitura da mesma.

        component generic_rom is
            generic (
                n      : integer := addr_rom;                              -- Quantidade de bits de endereçamento
                word   : integer := i_word                                 -- Tamanho da palavra de memória
            );
            port (
                CS       : in std_logic;                                   -- Chip Selection (CS) ativo em LOW
                OE       : in std_logic;                                   -- Output Enable (OE) ativo em LOW
                address  : in std_logic_vector(n-1 downto 0);              -- Barramento de endereço
                data_out : out std_logic_vector(word-1 downto 0)           -- Saída de dados
            );
        end component generic_rom;

        -- [REGISTRADORES] -----------------------------------------------------------------------------------------------------------------------

        -- Registrador de 16 bits detector de borda de descida com enable:

        component register_rising_edge_enable is
            port (
                data_in   : in  std_logic_vector(15 downto 0);             -- Dados de entrada
                enable    : in  std_logic;                                 -- Sinal de habilitação
                MR        : in  std_logic;                                 -- Sinal de master-reset
                CLK       : in  std_logic;                                 -- Sinal de clock
                data_out  : out std_logic_vector(15 downto 0)              -- Dados de saída
            );
        end component register_rising_edge_enable;

        -- Registrador de 16 bits detector de borda de descida sem enable:

        component register_falling_edge is
            port (
                data_in   : in  std_logic_vector(15 downto 0);             -- Dados de entrada
                MR        : in  std_logic;                                 -- Sinal de master-reset
                CLK       : in  std_logic;                                 -- Sinal de clock
                data_out  : out std_logic_vector(15 downto 0)              -- Dados de saída
            );
        end component register_falling_edge;

        -- [DECODIFICADOR DE INSTRUÇÔES (unidade de controle)] ===================================================================================

        component decoder is
            port (
                op_code       : in  std_logic_vector;                      -- Lê o código da operação em execução
                clk           : in  std_logic;                             -- Recebe o clock interno da CPU
                ZF            : in  std_logic;                             -- Zero Flag
                GZ            : in  std_logic;                             -- Flag "Greater than Zero"
                MR            : in  std_logic;                             -- Master-Reset para o registrador de status  
                sel_ula_src   : out std_logic;                             -- Seleciona o operando para a ULA
                WR_RAM        : out std_logic;                             -- Sinal de escrita na RAM
                WR_PC         : out std_logic;                             -- Sinal de incremento do PC
                WR_ACC        : out std_logic;                             -- Sinal de escrita no ACC
                sel_acc_src_1 : out std_logic;                             -- Seleção do input do ACC (MSB)
                sel_acc_src_0 : out std_logic;                             -- Seleção do input do ACC (LSB)
                op_ula        : out std_logic;                             -- Seleciona operação da ULA
                WR_IR         : out std_logic;                             -- Sinal de escrita no IR
                PC_load          : out std_logic;                          -- Sinal de carga para o PC (JMP)
                RD_io       : out std_logic;                               -- Sinal para leitura do dispositivo de I/O
                WR_io      : out std_logic                                 -- Sinal para escrita no dispositivo de I/O
            );
        end component decoder;

        -- [MEMÓRIA DE DADOS] --------------------------------------------------------------------------------------------------------------------

        -- Random Access Memory: podem ser realizadas tanto operações de leitura quanto escrita,
        -- além disso, o custo para acessar qualquer célula da memória é constante, independentemente,
        -- do endereço - por isso o nome: "acesso randômico".

        component generic_ram is
            generic(
                n    : integer := 12;                                      -- Quantidade de bits de endereçamento
                word : integer := 16                                       -- Tamanho da palavra de memória
            );
            port (
                we      : in  std_logic;                                   -- Habilita escrita (ativo em LOW)
                oe      : in  std_logic;                                   -- Habilita output
                ME      : in  std_logic;                                   -- Habilita memória
                addr    : in  std_logic_vector(n-1 downto 0);              -- Endereçamento (n bits)
                data_in : in  std_logic_vector(word-1 downto 0);           -- Palavra de entrada (word bits)
                data_out: out std_logic_vector(word-1 downto 0)            -- Palavra de saída (word bits)
            ); 
        end component generic_ram;

        -- [MULTIPLEXADORES] ---------------------------------------------------------------------------------------------------------------------

        -- MUX 2 selects e 16 bits:

        component mux_2_16bit is
            port (
                data_in_1   : in  std_logic_vector(15 downto 0);           -- Dados de entrada 1
                data_in_2   : in  std_logic_vector(15 downto 0);           -- Dados de entrada 2
                data_in_3   : in  std_logic_vector(15 downto 0);           -- Dados de entrada 3
                data_in_4   : in  std_logic_vector(15 downto 0);           -- Dados de entrada 4
                sel_1       : in  std_logic;                               -- Sinal de seleção 1
                sel_0       : in  std_logic;                               -- Sinal de seleção 2
                data_out    : out std_logic_vector(15 downto 0)            -- Dados de saída
            );
        end component mux_2_16bit;

        -- MUX 1 select e 16 bits:

        component mux_16bit is
            port (
                data_in_1   : in  std_logic_vector(15 downto 0);           -- Dados de entrada 1
                data_in_2   : in  std_logic_vector(15 downto 0);           -- Dados de entrada 2
                sel         : in  std_logic;                               -- Sinal de seleção
                data_out    : out std_logic_vector(15 downto 0)            -- Dados de saída
            );
        end component mux_16bit;

        -- [ALU] ---------------------------------------------------------------------------------------------------------------------------------

        -- Unidade Lógica e Aritmética (ALU): responsável por realizar diferentes operações aritméticas,
        -- assim como por gerar flags (status) que tornam possíveis os pulos (jumps) condicionais.

        component arithmetic_logic_unit is
            port (
                data_in_1, data_in_2 : in  std_logic_vector(15 downto 0);  -- Dados de entrada
                op_ula               : in  std_logic;                      -- Sinal de operação
                data_out             : out std_logic_vector(15 downto 0);  -- Dados de saída
                ZF                   : out std_logic;                      -- Zero Flag
                GZ                   : out std_logic                       -- Greater than Zero (flag)
            );
          end component arithmetic_logic_unit;

        -- [I/O DEVICE] --------------------------------------------------------------------------------------------------------------------------

        -- O dispositivo de I/O é responsável por encapsular a lógica de escrita e leitura dos diferentes
        -- portes da CPU. Esses portes devem ser considerados na "pinagem" da CPU, conforme definido na própria
        -- entidade. São usados 2 bits de enderaçamento e o tamanho da palavra lida segue o padrão da CPU.

        -- Além disso, esse dispositivo deverá receber o sinal MR (Master-Reset) para que se possa resetar os
        -- registradores de OUTPUT - necessários para que o sinal seja definido adequadamente.

        -- Também sincroniza os sinais de INPUT através do CLOCK recebido da CPU.

        -- Definindo o dispositivo de I/O (interface):

        component io_device is
            port (
                MR            : in  std_logic;                             -- Master-Reset
                clk           : in  std_logic;                             -- Clock interno da CPU
                data_out      : in  std_logic_vector(n-1 downto 0);        -- Dados de saída do I/O (output)
                data_in       : out std_logic_vector(n-1 downto 0);        -- Dados de entrada do I/O (input)
                enable_read   : in  std_logic;                             -- Habilita leitura do I/O
                enable_write  : in  std_logic;                             -- Habilita escrita do I/O
                address       : in  std_logic_vector(1 downto 0);          -- Endereço do I/O
                in_port_1     : in  std_logic_vector(n-1 downto 0);        -- Porte de entrada 1
                in_port_2     : in  std_logic_vector(n-1 downto 0);        -- Porte de entrada 2
                in_port_3     : in  std_logic_vector(n-1 downto 0);        -- Porte de entrada 3
                in_port_4     : in  std_logic_vector(n-1 downto 0);        -- Porte de entrada 4
                out_port_1    : out std_logic_vector(n-1 downto 0);        -- Porte de saída 1
                out_port_2    : out std_logic_vector(n-1 downto 0);        -- Porte de saída 2
                out_port_3    : out std_logic_vector(n-1 downto 0);        -- Porte de saída 3
                out_port_4    : out std_logic_vector(n-1 downto 0)         -- Porte de saída 4
            );
        end component io_device;

begin

    -- (LIGANDO OS COMPONENTES INTERNOS) =========================================================================================================

    -- Instância do relógio interno da CPU: [TIMER]

    TIMER: generic_timer 
        port map(
            CLOCK,                                                         -- Recebe, a partir do TIMER o CLOCK interno
            enable_clk                                                     -- Sinal para habilitar o TIMER da CPU
        );

    -- Instância do circuito contador para o [Program Counter] (PC):

    load_val <= EX_SINAL;

    PC_counter: generic_counter
        port map(
            CLOCK,                                                         -- Atribui o clock interno da CPU
            MR,                                                            -- Sinal de Master-Reset
            WR_PC,                                                         -- Incrementa a contagem do PC
            PC_load,                                                       -- Utilizado para sobrescrever o PC
            load_val,                                                      -- Valor a ser carregado (possivelmente de um JMP)
            PC_out                                                         -- Direciona o valor do PC para PC_out
        );

    -- Instância da [MEMÓRIA DE PROGRAMA]: ROM

    ROM: generic_rom
        port map(
            not(ME),                                                       -- Seleciona a memória ROM (Chip Select) - ativo em LOW
            not(OE),                                                       -- Habilita a leitura da memória de programa
            PC_out,                                                        -- Endereça a memória a partir do PC
            ROM_out                                                        -- Obtém instrução a partir do endereço
        );

    -- Instância de um registrador: IR [INSTRUCTION REGISTER]

    IR: register_falling_edge
        port map(
            ROM_out,                                                       -- Recebe instrução a partir do sinal da memória de programa
            MR,                                                            -- Master Reset para o registrador
            WR_IR,                                                         -- Habilita a escrita no Instruction Register (IR)
            IR_out                                                         -- Saída do dado gravado no IR
        );

    -- Lendo o OP_CODE e OPERAND:

    OP_CODE <= IR_out(15 downto 12);                                       -- Seleciona os 4 MSBs da instrução em execução
    OPERAND <= IR_out(11 downto 0);                                        -- Seleciona os demais bits da instrução em execução

    -- Extensão de sinal do operando:

    EX_SINAL <= x"0" & OPERAND;                                            -- Extende o sinal para 16 bits - adicionando zeros aos MSBs

    -- Instanciando o [DECODIFICADOR DE INSTRUÇÔES]:

    DECR: decoder port map(
        OP_CODE,                                                           -- Lê o código da operação em exec
        CLOCK,                                                             -- Recebe o clock interno da CPU
        ZF_in,                                                             -- Zero Flag
        GZ_in,                                                             -- Flag "Greater than Zero"
        MR,                                                                -- Master-Reset para o registrador de status
        SelUlaSrc,                                                         -- Seleciona operando para a ULA
        WR_RAM,                                                            -- Sinal de escrita na RAM
        WR_PC,                                                             -- Sinal de incremento do PC
        WR_ACC,                                                            -- Sinal de escrita no ACC
        SelAccSrc1,                                                        -- Seleção do input do ACC (MSB)
        SelAccSrc0,                                                        -- Seleção do input do ACC (LSB)
        OP_ULA,                                                            -- Seleciona operação da ULA
        WR_IR,                                                             -- Sinal de escrita no IR
        PC_load,                                                           -- Sinal de carga para o PC (JMP)
        RD_io,                                                             -- Sinal para leitura do dispositivo de I/O
        WR_io                                                              -- Sinal para escrita no dispositivo de I/O
    );                        

    -- Instância da [MEMÓRIA DE DADOS]: RAM

    RAM: generic_ram 
        port map(
            not(WR_RAM),                                                   -- Habilita escrita (ativo em LOW)
            oe,                                                            -- Habilita output
            ME,                                                            -- Habilita memória
            OPERAND,                                                       -- Endereçamento (n bits)
            ACC_out,                                                       -- Palavra de entrada (word bits)
            RAM_data                                                       -- Palavra de saída (word bits)
        );           

    -- Instância de um registrador: [ACC] (Acumulador)

    ACC: register_rising_edge_enable
        port map(
            ACC_in,                                                        -- Recebe instrução a partir do sinal da memória de programa
            WR_ACC,                                                        -- Habilita a escrita no Instruction Register (IR)
            MR,                                                            -- Master Reset ativo em LOW para o registrador
            CLOCK,                                                         -- Sincroniza o registrador com o clock interno da CPU
            ACC_out                                                        -- Saída do dado gravado no IR
        );

    -- [MUX] entrada do ACC (Acumulador):

    MUX_ACC: mux_2_16bit 
        port map(
            RAM_data,                                                      -- Dados de entrada 1 (RAM_data)
            EX_SINAL,                                                      -- Dados de entrada 2 (EX_SINAL)
            ALU_out,                                                       -- Dados de entrada 3 (ALU_out)
            input_data,                                                    -- Dados de entrada 4 (INPUT)
            SelAccSrc1,                                                    -- Sinal de seleção 1 (MSB)
            SelAccSrc0,                                                    -- Sinal de seleção 2 (LSB)
            ACC_in                                                         -- Dados de saída
        );

    -- [MUX] entrada da ALU:

    MUX_ALU: mux_16bit
        port map(
            RAM_data,                                                      -- Dados de entrada 1
            EX_SINAL,                                                      -- Dados de entrada 2
            SelUlaSrc,                                                     -- Sinal de seleção
            ALU_in                                                         -- Dados de saída
        );

    -- [ALU] - Unidade Lógica e Aritmética:

    ALU: arithmetic_logic_unit 
        port map(
            ACC_out,                                                       -- Recebe dado do acumulador
            ALU_in,                                                        -- Recebe dado do MUX_ALU
            not(OP_ULA),                                                   -- Sinal de operação
            ALU_out,                                                       -- Dados de saída
            ZF_in,                                                         -- Zero flag (ZF_in)
            GZ_in                                                          -- Greater than Zero (GZ_in)
        );

    -- Instanciando [DISPOSITIVO DE I/O]:

    io_addr <= OPERAND(1 downto 0);

    IO: io_device 
        port map(
            MR,                                                            -- Master-Reset
            CLOCK,                                                         -- Clock interno da CPU
            ACC_out,                                                       -- Dados de saída do I/O (output)
            input_data,                                                    -- Dados de entrada do I/O (input)
            RD_io,                                                         -- Habilita leitura do I/O
            WR_io,                                                         -- Habilita escrita do I/O
            io_addr,                                                       -- Endereço do I/O
            in_port_1,                                                     -- Porte de entrada 1
            in_port_2,                                                     -- Porte de entrada 2
            in_port_3,                                                     -- Porte de entrada 3
            in_port_4,                                                     -- Porte de entrada 4
            out_port_1,                                                    -- Porte de saída 1
            out_port_2,                                                    -- Porte de saída 2
            out_port_3,                                                    -- Porte de saída 3
            out_port_4                                                     -- Porte de saída 4
        );

end architecture main;

-- ===============================================================================================================================================