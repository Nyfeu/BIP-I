
-- Descrição de Hardware (VHDL) de um FULL_SUBBER (4 bits)
--
--                    ____				
--      a (4bits) >--|    |--> dif (4 bits)
--      b (4bits) >--| FS |
--    b_in (1bit) >--|____|--> b_out (1 bit)
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

--| Libraries |---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Full Subber 4 bits |-------------------------------------

entity full_subber_4bit is 

    port (
        a, b  : in  std_logic_vector(3 downto 0);
        b_in  : in  std_logic;
        dif   : out std_logic_vector(3 downto 0);
        b_out : out std_logic
    );

end full_subber_4bit;

--| Lógica |------------------------------------------------

architecture main of full_subber_4bit is 

    signal b1, b2, b3 : std_logic;

    component full_subber is

        port (
            a, b, b_in : in std_logic;
            dif, b_out : out std_logic
        );

    end component full_subber;

begin 

    -- full_subber (a, b, b_in, dif, b_out)

    fa0: full_subber port map(a(0), b(0), b_in, dif(0), b1);

    fa1: full_subber port map(a(1), b(1), b1, dif(1), b2);

    fa2: full_subber port map(a(2), b(2), b2, dif(2), b3);

    fa3: full_subber port map(a(3), b(3), b3, dif(3), b_out);

    -- Composição de FS de 1 bit.

end architecture main;