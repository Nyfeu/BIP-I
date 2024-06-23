--| Libraries |------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| CPU |------------------------------------------------------------------------------------

entity cpu is

    -- Define genericamente os valores que serão fornecidos pelo arquivo de testes:

    generic(
        n : integer := 16;                                -- Tamanho em bits do PC
        f : integer := 2000                               -- MHz (freq. clock)
    );

    -- Define as portas da CPU - entradas, saídas e tipos básicos:

    port(
        enable    : in  std_logic;                        -- Enable (ativo em HIGH)
        MR        : in  std_logic;                        -- Master-Reset (ativo em LOW)
        pc_count  : out std_logic_vector(n-1 downto 0)    -- Program Counter (PC)
    );

end entity cpu;

--| Lógica |----------------------------------------------------------------------------------

architecture main of cpu is

    -- Definindo sinais internos à CPU:

    signal internal_clk : std_logic;         -- Clock interno da CPU (recebe o clock do TIMER)

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
                n : integer := n             -- Define a largura de bits do contador
            );
            port (
                clk    : in  std_logic;
                MR     : in  std_logic;
                count  : out std_logic_vector(n - 1 downto 0)
            );
        end component generic_counter;

begin

    -- Instância o relógio interno da CPU: TIMER

    TIMER: generic_timer 
        port map(
            internal_clk,                    -- Recebe, a partir do TIMER o internal_clock
            enable                           -- Sinal para habilitar o TIMER interno da CPU
        );

    -- Instância o circuito Program Counter: PC_counter

    PC_counter: generic_counter
        port map(
            internal_clk,                    -- Atribui o clock interno da CPU para o contador
            MR,                              -- Sinal de Master-Reset do PC_counter
            pc_count                         -- Direciona o valor do PC para pc_count
        );

end architecture main;

----------------------------------------------------------------------------------------------