
-- Descrição de Hardware (VHDL) de um FULL_ADDER
--
--            ____				
--      a >--|    |--> sum      a | b | c_in | s | c_out 
--           | FA |            --------------------------
--      b >--|____|--> carry    0 | 0 |  0   | 0 |   0
--                              0 | 0 |  1   | 1 |   0
--                              0 | 1 |  0   | 1 |   0
--                              0 | 1 |  1   | 0 |   1
--                              1 | 0 |  0   | 1 |   0
--                              1 | 0 |  1   | 0 |   1
--                              1 | 1 |  0   | 0 |   1
--                              1 | 1 |  1   | 1 |   1
--                             --------------------------
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

library ieee;
use ieee.std_logic_1164.all;

entity full_adder is

    port (
        a, b           : in std_logic;
        carry_in       : in std_logic;
        sum, carry_out : out std_logic
    );

end full_adder;

architecture main of full_adder is 

    -- Sinais internos:

    signal x, y, z : std_logic;

    -- Componentes internos:

    component half_adder is

        port(
            a, b  : in  std_logic;
            sum   : out std_logic;
            carry : out std_logic
        );

    end component half_adder;

begin

        -- Instaciação nominal: (a [in], b [in], sum [out], carry [out])
        half_adder_1: half_adder port map (
            a     => a,
            b     => b,
            sum   => x,
            carry => y
        );

        -- Instanciação posicional: (a [in], b [in], sum [out], carry [out])
        half_adder_2: half_adder port map (
            x, carry_in, sum, z
        );

        -- Lógica
        carry_out <= y or z;

end architecture main;