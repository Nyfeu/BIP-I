-- =============================================================================================================================================
--
--                                                                                 ____________________________
--                                                                                /                           /\
--     Descrição de Hardware (VHDL)                                              /         BIP I            _/ /\
--     Unidade Central de Processamento (CPU)                                   /        (Harvard)         / \/
--                                                                             /                           /\
--     ->> AUTOR: André Solano F. R. Maiolini (19.02012-0)                    /___________________________/ /
--     ->> DATA: 24/06/2024                                                   \___________________________\/
--                                                                             \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
--
-- ============+================================================================================================================================
--   Descrição |
-- ------------+
-- 
--  Este código VHDL descreve a arquitetura de uma Unidade Central de Processamento (CPU) simplificada.
--  A CPU é capaz de executar instruções básicas armazenadas na memória ROM, utilizando um acumulador (ACC)
--  e uma Unidade Lógica e Aritmética (ALU) para operações aritméticas e lógicas. Utliza arquitetura de 
--  barramentos de Harvard.
--
-- ==========+==================================================================================================================================
--  Entradas |
-- ----------+
--
--  enable_clk : Habilita pulsos de clock, ou seja, inicia a execução;
--  MR         : Master-Reset (ativo em LOW).
--
-- =====================+========================================================================================================================
--  Diagrama de Blocos  |
-- ---------------------+                          Arquitetura de barramentos Harvard
-- 
--                  +--------+                  +-----+   addr   +-----+   addr   +-----+
--            MR >--|        |                  |     | <------- |     | -------> |     |
--    enable_clk >--|  CPU   |        ==>       | ROM |   inst   | CPU |   data   | RAM |
--                  |        |                  |     | -------> |     | <------> |     |
--                  +--------+                  +-----+          +-----+          +-----+
-- 
--
-- ==============================================================================================================================================
--

--| Libraries |----------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| CPU |----------------------------------------------------------------------------------------------------------------------------------------

entity cpu is

    -- Define as portas da CPU - entradas de controle básicas:

    port(
        enable_clk  : in  std_logic;                                       -- Habilita pulsos de clock
        MR          : in  std_logic                                        -- Master-Reset (ativo em LOW)
    );

end entity cpu;

--| Lógica |--------------------------------------------------------------------------------------------------------------------------------------

architecture main of cpu is

    -- Define os valores genéricos que serão fornecidos aos componentes:

    constant n        : integer := 16;                                     -- Tamanho em bits do PC
    constant f        : integer := 2000;                                   -- freq. do clock [MHz]
    constant addr_rom : integer := 16;                                     -- Bits de endereçamento da ROM
    constant i_word   : integer := 16;                                     -- Tamanho da palavra de instrução

    -- Definindo sinais internos à CPU:

    signal CLOCK        : std_logic;                                       -- Clock interno da CPU (recebe o clock do TIMER)
    signal PC_out       : std_logic_vector(n - 1 downto 0);                -- Valor de saída do contador (valor do PC)
    signal ROM_out      : std_logic_vector(i_word-1 downto 0);             -- Define a instrução que será carregada no IR
    signal IR_out       : std_logic_vector(i_word-1 downto 0);             -- Instrução lida da saída do IR
    signal OP_CODE      : std_logic_vector(3 downto 0);                    -- Código de operação (4 MSBs do IR_out)
    signal OPERAND      : std_logic_vector(11 downto 0);                   -- Operando 12 bits (12 LSBs do IR_out)
    signal EX_SINAL     : std_logic_vector(15 downto 0);                   -- Operando extendido (16 bits)
    signal ACC_in       : std_logic_vector(15 downto 0);                   -- Valor da entrada do acumulador
    signal ACC_out      : std_logic_vector(15 downto 0);                   -- Valor da saída do acumulador
    signal RAM_data     : std_logic_vector(15 downto 0);                   -- Valor lido da RAM
    signal ALU_out      : std_logic_vector(15 downto 0);                   -- Resultado lido da ALU
    signal ALU_in       : std_logic_vector(15 downto 0);                   -- Entrada da ALU
    signal OE           : std_logic := '1';                                -- Habilita output da memória (sempre habilitado)
    signal ME           : std_logic := '1';                                -- Habilita memória (sempre habilitado)
    signal PC_load      : std_logic := '0';                                -- Sinal de carregamento (ativo em HIGH)
    signal load_val     : std_logic_vector(n - 1 downto 0);                -- Valor a ser carregado no PC
    signal ZF           : std_logic;                                       -- Zero flag (ZF)

    -- Definindo sinais de controle:

    signal SelUlaSrc    : std_logic;                                       -- Sinal de seleção da fonte para a ALU
    signal OP_ULA       : std_logic;                                       -- Sinal de seleção de operação da ALU
    signal WR_RAM       : std_logic;                                       -- Sinal de escrita na memória de dados (RAM)
    signal WR_PC        : std_logic;                                       -- Sinal de incremento do PC
    signal WR_IR        : std_logic;                                       -- Sinal de escrita do IR
    signal WR_ACC       : std_logic;                                       -- Sinal de escrita no ACC
    signal SelAccSrc1   : std_logic;                                       -- Seleciona dados para o ACC (MSB)
    signal SelACCSrc0   : std_logic;                                       -- Seleciona dados para o ACC (LSB)

    -- Definindo os componentes internos da CPU:

        -- Temporizador genérico:

        component generic_timer is
            generic(
                clk_freq : integer := f                                    -- Define a frequência do temporizador
            );
            port(
                clk : out std_logic := '0';
                enable : in std_logic
            );
        end component generic_timer;

        -- Contador genérico:

        component generic_counter is
            generic(
                n : integer := n                                           -- Define a largura de bits do contador
            );
            port (
                clk      : in  std_logic;
                MR       : in  std_logic;
                en       : in  std_logic;
                load     : in  std_logic;                                  -- Sinal de carregamento (ativo em HIGH)
                load_val : in  std_logic_vector(n - 1 downto 0);           -- Valor a ser carregado
                count    : out std_logic_vector(n - 1 downto 0)
            );
        end component generic_counter;

        -- Read Only Memory (memória de programa):

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

        -- Decodificador de instruções (unidade de controle)

        component decoder is
            port (
                OP_CODE       : in  std_logic_vector(3 downto 0);          -- Entrada do código de operação
                clk           : in  std_logic;                             -- Entrada do clock para o WR_IR
                sel_ula_src   : out std_logic;                             -- Restante dos sinais de controle
                WR_RAM        : out std_logic;
                WR_PC         : out std_logic;
                WR_ACC        : out std_logic;
                sel_acc_src_1 : out std_logic;
                sel_acc_src_0 : out std_logic;
                op_ula        : out std_logic;
                WR_IR         : out std_logic;                             -- Sinal de escrita no IR
                LOAD          : out std_logic                              -- Sinal de carga para o PC (JMP)
            );
        end component decoder;

        -- Random Access Memory (memória de dados):

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

        -- Unidade Lógica e Aritmética (ALU):

        component arithmetic_logic_unit is
            port (
                data_in_1, data_in_2 : in  std_logic_vector(15 downto 0);  -- Dados de entrada
                op_ula               : in  std_logic;                      -- Sinal de operação
                data_out             : out std_logic_vector(15 downto 0);  -- Dados de saída
                ZF                   : out std_logic                       -- Zero Flag
            );
          end component arithmetic_logic_unit;

begin

    -- Instância do relógio interno da CPU: TIMER

    TIMER: generic_timer 
        port map(
            CLOCK,                                                         -- Recebe, a partir do TIMER o CLOCK interno
            enable_clk                                                     -- Sinal para habilitar o TIMER da CPU
        );

    -- Instância do circuito contador para o Program Counter (PC):

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

    -- Instância da memória de programa: ROM

    ROM: generic_rom
        port map(
            not(ME),                                                       -- Seleciona a memória ROM (Chip Select) - ativo em LOW
            not(OE),                                                       -- Habilita a leitura da memória de programa
            PC_out,                                                        -- Endereça a memória a partir do PC
            ROM_out                                                        -- Obtém instrução a partir do endereço
        );

    -- Instância de um registrador: IR (Instruction Register)

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

    -- Instanciando o decodificador de instruções:

    DECR: decoder port map(
        OP_CODE, CLOCK, SelUlaSrc, WR_RAM, WR_PC, WR_ACC, SelAccSrc1, SelAccSrc0, OP_ULA, WR_IR, PC_load
    );

    -- Instância da memória de dados: RAM

    RAM: generic_ram 
        port map(
            not(WR_RAM),
            oe,
            ME,
            OPERAND,
            ACC_out,
            RAM_data
        );

    -- Instância de um registrador: ACC (Acumulador)

    ACC: register_rising_edge_enable
        port map(
            ACC_in,                                                        -- Recebe instrução a partir do sinal da memória de programa
            WR_ACC,                                                        -- Habilita a escrita no Instruction Register (IR)
            MR,                                                            -- Master Reset ativo em LOW para o registrador
            CLOCK,                                                         -- Sincroniza o registrador com o clock interno da CPU
            ACC_out                                                        -- Saída do dado gravado no IR
        );

    -- MUX entrada do ACC (Acumulador):

    MUX_ACC: mux_2_16bit 
        port map(
            RAM_data,                                                      -- Dados de entrada 1 (RAM_data)
            EX_SINAL,                                                      -- Dados de entrada 2 (EX_SINAL)
            ALU_out,                                                       -- Dados de entrada 3 (ALU_out)
            x"0000",                                                       -- Dados de entrada 4 (não usada)
            SelAccSrc1,                                                    -- Sinal de seleção 1 (MSB)
            SelAccSrc0,                                                    -- Sinal de seleção 2 (LSB)
            ACC_in                                                         -- Dados de saída
        );

    -- MUX entrada da ALU:

    MUX_ALU: mux_16bit
        port map(
            RAM_data,                                                      -- Dados de entrada 1
            EX_SINAL,                                                      -- Dados de entrada 2
            SelUlaSrc,                                                     -- Sinal de seleção
            ALU_in                                                         -- Dados de saída
        );

    -- ALU - Unidade Lógica e Aritmética:

    ALU: arithmetic_logic_unit 
        port map(
            ACC_out,                                                       -- Recebe dado do acumulador
            ALU_in,                                                        -- Recebe dado do MUX_ALU
            not(OP_ULA),                                                   -- Sinal de operação
            ALU_out,                                                       -- Dados de saída
            ZF                                                             -- Zero flag (ZF)
        );

end architecture main;

--------------------------------------------------------------------------------------------------------------------------------------------------