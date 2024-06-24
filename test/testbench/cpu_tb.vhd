-- Arquivo de testes (testbench) para a CPU (BIP I)

--| Libraries |----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Entidade |-----------------------------------------------------------------------------------------------------------

entity cpu_tb is
end entity cpu_tb;

--| Lógica - Testbench |-------------------------------------------------------------------------------------------------

architecture teste of cpu_tb is
  
  -- Sinais sendo rastreados:

  signal enable_clk : std_logic := '1';                       -- Enable (ativo em HIGH)
  signal MR         : std_logic;                              -- Master-Reset (ativo em LOW)

  -- Declaração do componente CPU:

  component cpu is

    port(
      enable_clk  : in  std_logic;                           -- Habilita pulsos de clock
      MR          : in  std_logic                            -- Master-Reset (ativo em LOW)
    );

  end component cpu;

begin

    -- Instanciando o BIP (do tipo cpu) e declarando as portas:

    BIP: cpu port map (enable_clk, MR);

    -- Testando o BIP (duração da execução de 100 ns):

    test: process
    begin

        MR <= '0';
        wait for 0.1 ns;
        MR <= '1';
        wait for 100 ns;
        enable_clk <= '0';

        wait;

    end process test;

end architecture teste;
