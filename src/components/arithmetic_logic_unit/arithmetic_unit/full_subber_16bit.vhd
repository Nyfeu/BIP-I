
-- Descrição de Hardware (VHDL) de um FULL_SUBBER (16 bits)
--
--                      ____				
--      a (16 bits) >--|    |--> dif (16 bits)
--      b (16 bits) >--| FS |
--             b_in >--|____|--> b_out
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

--| Libraries |---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Full Adder 16 bits |-------------------------------------

entity full_subber_16bit is 

    port (
        a, b  : in  std_logic_vector(15 downto 0);
        b_in  : in  std_logic;
        dif   : out std_logic_vector(15 downto 0);
        b_out : out std_logic
    );

end full_subber_16bit;

--| Lógica |------------------------------------------------

architecture main of full_subber_16bit is 

    signal b1, b2, b3 : std_logic;

    component full_subber_4bit is

        port (
            a, b      : in  std_logic_vector(3 downto 0);
            b_in  : in  std_logic;
            dif       : out std_logic_vector(3 downto 0);
            b_out : out std_logic
        );

    end component full_subber_4bit;

begin 

    -- full_subber (a, b, b_in, dif, b_out)

    fa0: full_subber_4bit port map(a(3 downto 0), b(3 downto 0), b_in, dif(3 downto 0), b1);

    fa1: full_subber_4bit port map(a(7 downto 4), b(7 downto 4), b1, dif(7 downto 4), b2);

    fa2: full_subber_4bit port map(a(11 downto 8), b(11 downto 8), b2, dif(11 downto 8), b3);

    fa3: full_subber_4bit port map(a(15 downto 12), b(15 downto 12), b3, dif(15 downto 12), b_out);

    -- Composição de FS de 4 bit.

end architecture main;