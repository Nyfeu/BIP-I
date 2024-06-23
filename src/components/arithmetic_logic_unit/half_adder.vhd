
-- Descrição de Hardware (VHDL) de um HALF_ADDER
--
--            ____				
--      a >--|    |--> sum      a | b | s | c 
--           | HA |            ---------------
--      b >--|____|--> carry    0 | 0 | 0 | 0
--                              0 | 1 | 1 | 0
--                              1 | 0 | 1 | 0
--                              1 | 1 | 0 | 1
--                             ---------------
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

--| Libraries |-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Half Adder |------------------------------------------------------

entity half_adder is

    port(
        a, b  : in  std_logic;
        sum   : out std_logic;
        carry : out std_logic
    );

end half_adder;

--| Architecture |----------------------------------------------------

architecture main of half_adder is
begin 

    sum <= a xor b;
    carry <= a and b;

end architecture main;