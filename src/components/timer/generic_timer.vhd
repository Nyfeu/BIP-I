-- Descrição de Hardware (VHDL) de um Timer de Freq. Genérica (MHz)
--
--             _________
--            |         |
--      en >--|  Timer  |--> clk
--            |_________|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| Timer |----------------------------------------------------------------------------------

entity generic_timer is

    generic(
        clk_freq : integer := 4
    );

    port(
        clk : out std_logic := '0';
        enable : in std_logic
    );

end entity generic_timer;

--| Lógica |----------------------------------------------------------------------------------

architecture main of generic_timer is
begin

    clock_generator : process
    begin
        
        while enable = '1' loop
            clk <= not clk;
            wait for (1000 ns / clk_freq);
        end loop;
        
        clk <= '0';

        wait;

    end process;

end architecture main;