
-- Descrição de Hardware (VHDL) de um FULL_ADDER (16 bits)
--
--                      ____				
--      a (16 bits) >--|    |--> sum (16 bits)
--      b (16 bits) >--| FA |
--        carry_int >--|____|--> carry_out
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

--| Libraries |---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Full Adder 16 bits |-------------------------------------

entity full_adder_16bit is 

    port (
        a, b      : in  std_logic_vector(15 downto 0);
        carry_in  : in  std_logic;
        sum       : out std_logic_vector(15 downto 0);
        carry_out : out std_logic
    );

end full_adder_16bit;

--| Lógica |------------------------------------------------

architecture main of full_adder_16bit is 

    signal c1, c2, c3 : std_logic;

    component full_adder_4bit is

        port (
            a, b      : in  std_logic_vector(3 downto 0);
            carry_in  : in  std_logic;
            sum       : out std_logic_vector(3 downto 0);
            carry_out : out std_logic
        );

    end component full_adder_4bit;

begin 

    -- full_adder (a, b, carry_in, sum, carry_out)

    fa0: full_adder_4bit port map(a(3 downto 0), b(3 downto 0), carry_in, sum(3 downto 0), c1);

    fa1: full_adder_4bit port map(a(7 downto 4), b(7 downto 4), c1, sum(7 downto 4), c2);

    fa2: full_adder_4bit port map(a(11 downto 8), b(11 downto 8), c2, sum(11 downto 8), c3);

    fa3: full_adder_4bit port map(a(15 downto 12), b(15 downto 12), c3, sum(15 downto 12), carry_out);

    -- Composição de FA de 4 bit.

end architecture main;