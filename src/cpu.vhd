--| Libraries |----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| CPU |----------------------------------------------------------------------------------------------------------

entity cpu is

    -- Define genericamente os valores que serão fornecidos pelo arquivo de testes:

    generic(
        n        : integer := 16;                              -- Tamanho em bits do PC
        f        : integer := 2000;                            -- MHz (freq. clock)
        addr_rom : integer := 16;                              -- Bits de endereçamento ROM (instruções)
        i_word   : integer := 16                               -- Tamanho da palavra de instrução
    );

    -- Define as portas da CPU - entradas, saídas e tipos básicos:

    port(
        enable_clk  : in  std_logic;                           -- Habilita pulsos de clock
        MR          : in  std_logic;                           -- Master-Reset (ativo em LOW)
        pc_count    : out std_logic_vector(n-1 downto 0);      -- Program Counter (PC)
        d_out       : out std_logic_vector(i_word-1 downto 0); -- Leitura do IR
        op_out      : out std_logic_vector(3 downto 0)         -- Código de operação
    );

end entity cpu;

--| Lógica |--------------------------------------------------------------------------------------------------------

architecture main of cpu is

    -- Definindo sinais internos à CPU:

    signal internal_clk : std_logic;                            -- Clock interno da CPU (recebe o clock do TIMER)
    signal inst_data    : std_logic_vector(i_word-1 downto 0);  -- Define a instrução que será carregada no IR
    signal WR_IR        : std_logic := '1';                     -- Sinal de controle WR_IR
    signal instruction  : std_logic_vector(i_word-1 downto 0);  -- Instrução lida da saída do IR
    signal op_code      : std_logic_vector(3 downto 0);         -- Código de operação
    signal operand      : std_logic_vector(11 downto 0);        -- Operando 12 bits
    signal operand_ex   : std_logic_vector(15 downto 0);        -- Operando extendido (16 bits)

    -- Definindo os componentes internos da CPU:

        -- Temporizador genérico:

        component generic_timer is
            generic(
                clk_freq : integer := f      -- Define a frequência do temporizador
            );
            port(
                clk : out std_logic := '0';
                enable : in std_logic
            );
        end component generic_timer;

        -- Contador genérico:

        component generic_counter is
            generic(
                n : integer := n                          -- Define a largura de bits do contador
            );
            port (
                clk    : in  std_logic;
                MR     : in  std_logic;
                count  : out std_logic_vector(n - 1 downto 0)
            );
        end component generic_counter;

        -- Read Only Memory:

        component generic_rom is
            generic (
                n      : integer := addr_rom;   -- Quantidade de bits de endereçamento
                word   : integer := i_word      -- Tamanho da palavra de memória
            );
            port (
                cs       : in std_logic;                               -- Chip Selection (CS) ativo em LOW
                oe       : in std_logic;                               -- Output Enable (OE) ativo em LOW
                address  : in std_logic_vector(n-1 downto 0);          -- Barramento de endereço
                data_out : out std_logic_vector(word-1 downto 0)       -- Saída de dados
            );
        end component generic_rom;

        -- Registrador de 16 bits:

        component register_sync_16bit is
            port (
                data_in   : in  std_logic_vector(15 downto 0);  -- Dados de entrada
                enable    : in  std_logic;                      -- Sinal de habilitação
                MR        : in  std_logic;                      -- Sinal de master-reset
                CLK       : in  std_logic;                      -- Sinal de clock
                data_out  : out std_logic_vector(15 downto 0)   -- Dados de saída
            );
        end component register_sync_16bit;

begin

    -- Instância o relógio interno da CPU: TIMER

    TIMER: generic_timer 
        port map(
            internal_clk,                    -- Recebe, a partir do TIMER o internal_clock
            enable_clk                       -- Sinal para habilitar o TIMER interno da CPU
        );

    -- Instância o circuito Program Counter: PC_counter

    PC_counter: generic_counter
        port map(
            internal_clk,                    -- Atribui o clock interno da CPU para o contador
            MR,                              -- Sinal de Master-Reset do PC_counter
            pc_count                         -- Direciona o valor do PC para pc_count
        );

    -- Instância a memória de programa: ROM

    ROM: generic_rom
        port map(
            '0',                             -- Seleciona a memória ROM (Chip Select) - ativo em LOW
            '0',                             -- Habilita a leitura da memória de programa
            pc_count,                        -- Endereça a memória a partir do PC
            inst_data                        -- Obtém instrução a partir do endereço
        );

    -- Instância de um registrador: IR (Instruction Register)

    IR: register_sync_16bit
        port map(
            inst_data,                       -- Recebe instrução a partir do sinal da memória de programa
            WR_IR,                           -- Habilita a escrita no Instruction Register (IR)
            MR,                              -- Master Reset ativo em LOW para o registrador
            internal_clk,                    -- Sincroniza o registrador com o clock interno da CPU
            instruction                      -- Saída do dado gravado no IR
        );

    -- Lendo o op_code e operand:

    op_code <= instruction(15 downto 12);
    operand <= instruction(11 downto 0);

    -- Extensão de sinal do operando:

    operand_ex <= x"0" & operand;
    d_out <= operand_ex;   
    op_out <= op_code; 

end architecture main;

--------------------------------------------------------------------------------------------------------------------