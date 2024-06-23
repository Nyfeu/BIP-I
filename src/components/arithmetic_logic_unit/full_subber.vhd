
-- Descrição de Hardware (VHDL) de um FULL_SUBBER
--
--            ____				
--      a >--|    |--> dif
--      b >--| FS |
--   b_in >--|____|--> b_out
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 22/06/2024

library ieee;
use ieee.std_logic_1164.all;

entity full_subber is

    port (
        a, b, b_in : in std_logic;
        dif, b_out : out std_logic
    );

end full_subber;

architecture main of full_subber is 

    -- Sinais internos:

    signal x, y, z : std_logic;

    -- Componentes internos:

    component half_subber is

        port(
            a, b   : in  std_logic;
            dif    : out std_logic;
            borrow : out std_logic
        );
    
    end component half_subber;

begin

        -- Instanciação posicional: (a [in], b [in], dif [out], borrow [out])
        hb1: half_subber port map (
            a, b, x, y
        );

        -- Instanciação posicional: (a [in], b [in], dif [out], borrow [out])
        hb2: half_subber port map (
            x, b_in, dif, z
        );

        -- Lógica
        b_out <= y or z;

end architecture main;