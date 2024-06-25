
-- Descrição de Hardware (VHDL) de um FULL_ADDER (4 bits)
--
--                    ____				
--      a (4bits) >--|    |--> sum (4 bits)
--      b (4bits) >--| FA |
--      carry_int >--|____|--> carry_out
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

--| Libraries |---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Full Adder 4 bits |-------------------------------------

entity full_adder_4bit is 

    port (
        a, b      : in  std_logic_vector(3 downto 0);
        carry_in  : in  std_logic;
        sum       : out std_logic_vector(3 downto 0);
        carry_out : out std_logic
    );

end full_adder_4bit;

--| Lógica |------------------------------------------------

architecture main of full_adder_4bit is 

    signal c1, c2, c3 : std_logic;

    component full_adder is

        port(
            a, b           : in std_logic;
            carry_in       : in std_logic;
            sum, carry_out : out std_logic
        );

    end component full_adder;

begin 

    -- full_adder (a, b, carry_in, sum, carry_out)

    fa0: full_adder port map(a(0), b(0), carry_in, sum(0), c1);

    fa1: full_adder port map(a(1), b(1), c1, sum(1), c2);

    fa2: full_adder port map(a(2), b(2), c2, sum(2), c3);

    fa3: full_adder port map(a(3), b(3), c3, sum(3), carry_out);

    -- É uma composição de FA de 1 bit.

end architecture main;