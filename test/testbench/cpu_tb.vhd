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

  signal enable_clk  : std_logic := '1';                      -- Enable (ativo em HIGH)
  signal MR          : std_logic;                             -- Master-Reset (ativo em LOW)

  -- Definindo sinais dos portes de IO:

  signal in_port_1   : std_logic_vector(15 downto 0);         -- Porte de entrada 1 (16 bits)
  signal in_port_2   : std_logic_vector(15 downto 0);         -- Porte de entrada 2 (16 bits)
  signal in_port_3   : std_logic_vector(15 downto 0);         -- Porte de entrada 3 (16 bits)
  signal in_port_4   : std_logic_vector(15 downto 0);         -- Porte de entrada 4 (16 bits)
  signal out_port_1  : std_logic_vector(15 downto 0);         -- Porte de saída 1 (16 bits)
  signal out_port_2  : std_logic_vector(15 downto 0);         -- Porte de saída 2 (16 bits)
  signal out_port_3  : std_logic_vector(15 downto 0);         -- Porte de saída 3 (16 bits)
  signal out_port_4  : std_logic_vector(15 downto 0);         -- Porte de saída 4 (16 bits)

  -- Declaração do componente CPU:

  component cpu is

    port(
      enable_clk  : in  std_logic;                            -- Habilita pulsos de clock
      MR          : in  std_logic;                          -- Master-Reset (ativo em LOW)
      in_port_1   : in  std_logic_vector(15 downto 0);      -- Porte de entrada 1 (16 bits)
      in_port_2   : in  std_logic_vector(15 downto 0);      -- Porte de entrada 2 (16 bits)
      in_port_3   : in  std_logic_vector(15 downto 0);      -- Porte de entrada 3 (16 bits)
      in_port_4   : in  std_logic_vector(15 downto 0);      -- Porte de entrada 4 (16 bits)
      out_port_1  : out std_logic_vector(15 downto 0);      -- Porte de saída 1 (16 bits)
      out_port_2  : out std_logic_vector(15 downto 0);      -- Porte de saída 2 (16 bits)
      out_port_3  : out std_logic_vector(15 downto 0);      -- Porte de saída 3 (16 bits)
      out_port_4  : out std_logic_vector(15 downto 0)       -- Porte de saída 4 (16 bits)
    );

  end component cpu;

begin

    -- Instanciando o BIP (do tipo cpu) e declarando as portas:

    BIP: cpu 
      port map (
        enable_clk, 
        MR, in_port_1, 
        in_port_2, 
        in_port_3, 
        in_port_4, 
        out_port_1, 
        out_port_2, 
        out_port_3, 
        out_port_4
      );

    -- Inicializando portes de I/O:

    in_port_1 <= x"0000";
    in_port_2 <= x"0001";
    in_port_3 <= x"0000";
    in_port_4 <= x"0000";

    -- Testando o BIP (duração da execução de 100 ns):

    test: process
    begin

        MR <= '0';
        wait for 0.1 ns;
        MR <= '1';
        wait for 200 ns;
        enable_clk <= '0';

        wait;

    end process test;

end architecture teste;
