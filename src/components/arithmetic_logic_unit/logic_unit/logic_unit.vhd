-- Descrição de Hardware (VHDL) de uma Unidade Lógica (16 bits)
--
--                  _________
--    data_in_1 >--|         |
--    data_in_2 >--|   LU    |--> flag
--       op_ula >--|_________|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| LU |-------------------------------------------------------------------------------------

entity logic_unit is
    port (
        data_in_1, data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada
        op_ula                 : in  std_logic;                      -- Sinal de operação
        flag                   : out std_logic;                      -- Flag de saída
    );
end entity logic_unit;

--| Lógica |----------------------------------------------------------------------------------

architecture main of arithmetic_unit is



begin

    

end architecture main;