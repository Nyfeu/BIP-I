
-- Descrição de Hardware (VHDL) de um half_subber
--
--            ____				
--      a >--|    |--> dif       a | b | d | b_out 
--           | HS |             -------------------
--      b >--|____|--> borrow    0 | 0 | 0 | 0
--                               0 | 1 | 1 | 1
--                               1 | 0 | 1 | 0
--                               1 | 1 | 0 | 0
--                              -------------------
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

--| Libraries |-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Half Adder |------------------------------------------------------

entity half_subber is

    port(
        a, b   : in  std_logic;
        dif    : out std_logic;
        borrow : out std_logic
    );

end half_subber;

--| Architecture |----------------------------------------------------

architecture main of half_subber is
begin 

    dif <= a xor b;
    borrow <= not(a) and b;

end architecture main;