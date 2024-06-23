-- Descrição de Hardware (VHDL) de um Contador Genérico de n bits
--
--                  __________
--          clk >--|          |
--                 | Contador |--> count (n bits) 
--           MR >--|__________|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| Contador |--------------------------------------------------------------------------------

entity generic_counter is
    generic(n : integer := 4); -- quantidade de bits do contador
    port (
        clk    : in  std_logic;
        MR     : in  std_logic;
        count  : out std_logic_vector(n - 1 downto 0)
    );
end entity generic_counter;

--| Lógica |----------------------------------------------------------------------------------

architecture main of generic_counter is

    signal count_temp : unsigned(n-1 downto 0);

begin

    contagem : process(clk, MR) 
    begin

        if MR = '0' then

            count_temp <= (others => '0');

        elsif falling_edge(clk) then

            count_temp <= count_temp + 1;

        end if;

    end process contagem;

    count <= std_logic_vector(count_temp);

end architecture main;