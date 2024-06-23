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

  constant n : integer := 16;                               -- Tamanho do Program Counter (PC) da CPU em bits
  constant f : integer := 2000;                             -- Frequência de operação do Timer Interno (MHz)
  
  -- Sinais sendo rastreados:

  signal enable   : std_logic := '1';                       -- Enable (ativo em HIGH)
  signal MR       : std_logic;                              -- Master-Reset (ativo em LOW)
  signal pc_count : std_logic_vector(n-1 downto 0);         -- Program Count

  -- Declaração do componente CPU:

  component cpu is

    generic(
        n : integer := n;
        f : integer := f
    );

    port(
        enable    : in  std_logic;                          -- Enable (ativo em HIGH)
        MR        : in  std_logic;                          -- Master-Reset (ativo em LOW)
        pc_count  : out std_logic_vector(n-1 downto 0)      -- Program Count
    );

  end component cpu;

begin

    -- Instanciando o BIP (do tipo cpu) e declarando as portas:

    BIP: cpu port map (enable, MR, pc_count);

    -- Testando o Program Counter (PC) do BIP:

    test: process
    begin

        MR <= '0';
        wait for 1 ns;
        MR <= '1';
        wait for 7 ns;
        MR <= '0';
        wait for 1 ns;
        MR <= '1';
        wait for 30 ns;
        enable <= '0';

        wait;

    end process test;

end architecture teste;
