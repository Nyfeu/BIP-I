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
        d_out       : out std_logic_vector(n-1 downto 0);      -- Valor do ACC
        op_out      : out std_logic_vector(3 downto 0)         -- Código de operação
    );

end entity cpu;

--| Lógica |--------------------------------------------------------------------------------------------------------

architecture main of cpu is

    -- Definindo sinais internos à CPU:

    signal internal_clk : std_logic;                                  -- Clock interno da CPU (recebe o clock do TIMER)
    signal inst_data    : std_logic_vector(i_word-1 downto 0);        -- Define a instrução que será carregada no IR
    signal instruction  : std_logic_vector(i_word-1 downto 0);        -- Instrução lida da saída do IR
    signal op_code      : std_logic_vector(3 downto 0);               -- Código de operação
    signal operand      : std_logic_vector(11 downto 0);              -- Operando 12 bits
    signal operand_ex   : std_logic_vector(15 downto 0);              -- Operando extendido (16 bits)
    signal acc_in       : std_logic_vector(15 downto 0);              -- Valor da entrada do acumulador
    signal acc_out      : std_logic_vector(15 downto 0);              -- Valor da saída do acumulador
    signal ram_data     : std_logic_vector(15 downto 0);              -- Valor lido da RAM
    signal alu_out      : std_logic_vector(15 downto 0);              -- Resultado lido da ALU
    signal alu_src      : std_logic_vector(15 downto 0);              -- Entrada da ALU

    -- Definindo sinais de controle:

    signal SelUlaSrc    : std_logic;                                  -- Sinal de seleção da fonte para a ALU
    signal OP_ULA       : std_logic;                                  -- Sinal de seleção de operação da ALU
    signal WR_RAM       : std_logic;                                  -- Sinal de escrita na memória de dados (RAM)
    signal WR_PC        : std_logic;                                  -- Sinal de incremento do PC (modificar)
    signal WR_IR        : std_logic := '1';                           -- Sinal de controle WR_IR
    signal WR_ACC       : std_logic;                                  -- Sinal de escrita no acumulador (ACC)
    signal SelAccSrc1   : std_logic;                                  -- Seleciona dados para o ACC (MSB)
    signal SelACCSrc0   : std_logic;                                  -- Seleciona dados para o ACC (LSB)

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
                data_in   : in  std_logic_vector(15 downto 0);         -- Dados de entrada
                enable    : in  std_logic;                             -- Sinal de habilitação
                MR        : in  std_logic;                             -- Sinal de master-reset
                CLK       : in  std_logic;                             -- Sinal de clock
                data_out  : out std_logic_vector(15 downto 0)          -- Dados de saída
            );
        end component register_sync_16bit;

        -- Decodificador de instruções

        component decoder is
            port (
                op_code       : in  std_logic_vector(3 downto 0);      -- Entrada do código de operação
                sel_ula_src   : out std_logic;                         -- Restante dos sinais de controle
                WR_RAM        : out std_logic;
                WR_PC         : out std_logic;
                WR_ACC        : out std_logic;
                sel_acc_src_1 : out std_logic;
                sel_acc_src_0 : out std_logic;
                op_ula        : out std_logic
            );
        end component decoder;

        -- Random Access Memory:

        component generic_ram is
            generic(
                n    : integer := 12;    -- Quantidade de bits de endereçamento
                word : integer := 16     -- Tamanho da palavra de memória
            );
            port (
                we      : in  std_logic;                             -- Habilita escrita (ativo em LOW)
                oe      : in  std_logic;                             -- Habilita output
                ME      : in  std_logic;                             -- Habilita memória
                addr    : in  std_logic_vector(n-1 downto 0);        -- Endereçamento (n bits)
                data_in : in  std_logic_vector(word-1 downto 0);     -- Palavra de entrada (word bits)
                data_out: out std_logic_vector(word-1 downto 0)      -- Palavra de saída (word bits)
            ); 
        end component generic_ram;

        -- MUX 2 selects e 16 bits:

        component mux_2_16bit is
            port (
                data_in_1   : in  std_logic_vector(15 downto 0);     -- Dados de entrada 1
                data_in_2   : in  std_logic_vector(15 downto 0);     -- Dados de entrada 2
                data_in_3   : in  std_logic_vector(15 downto 0);     -- Dados de entrada 3
                data_in_4   : in  std_logic_vector(15 downto 0);     -- Dados de entrada 4
                sel_1       : in  std_logic;                         -- Sinal de seleção 1
                sel_0       : in  std_logic;                         -- Sinal de seleção 2
                data_out    : out std_logic_vector(15 downto 0)      -- Dados de saída
            );
        end component mux_2_16bit;

        -- MUX 1 select e 16 bits:

        component mux_16bit is
            port (
                data_in_1   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 1
                data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 2
                sel         : in  std_logic;                      -- Sinal de seleção
                data_out    : out std_logic_vector(15 downto 0)   -- Dados de saída
            );
        end component mux_16bit;

        -- Unidade Lógica e Aritmética (ALU):

        component arithmetic_logic_unit is
            port (
                data_in_1, data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada
                op_ula                 : in  std_logic;                      -- Sinal de operação
                data_out               : out std_logic_vector(15 downto 0)   -- Dados de saída
            );
          end component arithmetic_logic_unit;

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

    -- Instância da memória de programa: ROM

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
    op_out <= op_code; 

    -- Instanciando o decodificador de instruções:

    DECR: decoder port map(
        op_code, SelUlaSrc, WR_RAM, WR_PC, WR_ACC, SelAccSrc1, SelAccSrc0, OP_ULA
    );

    -- Instância da memória de dados: RAM

    RAM: generic_ram 
        port map(
            not(WR_RAM),
            '1',
            '1',
            operand,
            acc_out,
            ram_data
        );

    -- Instância de um registrador: ACC (Acumulador)

    ACC: register_sync_16bit
        port map(
            acc_in,                          -- Recebe instrução a partir do sinal da memória de programa
            WR_ACC,                          -- Habilita a escrita no Instruction Register (IR)
            MR,                              -- Master Reset ativo em LOW para o registrador
            internal_clk,                    -- Sincroniza o registrador com o clock interno da CPU
            acc_out                          -- Saída do dado gravado no IR
        );

    -- MUX entrada do ACC (Acumulador):

    MUX_ACC: mux_2_16bit 
        port map(
            ram_data,                        -- Dados de entrada 1 (ram_data)
            operand_ex,                      -- Dados de entrada 2 (operand_ex)
            alu_out,                         -- Dados de entrada 3 (alu_out)
            x"0000",                         -- Dados de entrada 4 (não usada)
            SelAccSrc1,                      -- Sinal de seleção 1 (MSB)
            SelAccSrc0,                      -- Sinal de seleção 2 (LSB)
            acc_in                           -- Dados de saída
        );

    -- MUX entrada da ALU:

    MUX_ALU: mux_16bit
        port map(
            ram_data,                        -- Dados de entrada 1
            operand_ex,                      -- Dados de entrada 2
            SelUlaSrc,                       -- Sinal de seleção
            alu_src                          -- Dados de saída
        );

    -- ALU - Unidade Lógica e Aritmética:

    ALU: arithmetic_logic_unit 
        port map(
            acc_out,                         -- Recebe dado do acumulador
            alu_src,                         -- Recebe dado do MUX_ALU
            OP_ULA,                          -- Sinal de operação
            alu_out                          -- Dados de saída
        );

    -- Jogando valor do ACC para a saída:

    d_out <= acc_out;

end architecture main;

--------------------------------------------------------------------------------------------------------------------