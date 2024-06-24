-- Arquivo de testes (testbench) para a CPU (BIP I)

--| Libraries |----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Entidade |-----------------------------------------------------------------------------------------------------------

entity cpu_tb is
end entity cpu_tb;

--| Lógica - Testbench |-------------------------------------------------------------------------------------------------

architecture teste of cpu_tb is
  
  -- Definições básicas do processador:

  constant n        : integer := 16;                        -- Tamanho do Program Counter (PC) da CPU em bits
  constant f        : integer := 2000;                      -- Frequência de operação do Timer Interno (MHz)
  constant i_word   : integer := 16;                        -- Palavra de instrução em bits
  constant addr_rom : integer := 16;                        -- Bits de endereçamento da ROM
  
  -- Sinais sendo rastreados:

  signal enable_clk : std_logic := '1';                       -- Enable (ativo em HIGH)
  signal MR         : std_logic;                              -- Master-Reset (ativo em LOW)
  signal pc_count   : std_logic_vector(n-1 downto 0);         -- Program Count
  signal d_out      : std_logic_vector(n-1 downto 0);         -- Valor do ACC
  signal op_out     : std_logic_vector(3 downto 0);           -- Código de operação

  -- Declaração do componente CPU:

  component cpu is

    generic(
        n        : integer := n;
        f        : integer := f;
        addr_rom : integer := addr_rom;
        i_word   : integer := i_word
    );

    port(
        enable_clk  : in  std_logic;                           -- Habilita pulsos de clock
        MR          : in  std_logic;                           -- Master-Reset (ativo em LOW)
        pc_count    : out std_logic_vector(n-1 downto 0);      -- Program Count
        d_out       : out std_logic_vector(n-1 downto 0);      -- Valor do ACC
        op_out      : out std_logic_vector(3 downto 0)         -- Código de operação
    );

  end component cpu;

begin

    -- Instanciando o BIP (do tipo cpu) e declarando as portas:

    BIP: cpu port map (enable_clk, MR, pc_count, d_out, op_out);

    -- Testando o Program Counter (PC) do BIP:

    test: process
    begin

        MR <= '0';
        wait for 1 ns;
        MR <= '1';
        wait for 30 ns;
        enable_clk <= '0';

        wait;

    end process test;

end architecture teste;
