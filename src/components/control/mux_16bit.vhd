
-- Descrição de Hardware (VHDL) de um Mux 16 bits
--
--                  _____		
--       select >--|     |
--    data_in_1 >--| MUX |--> data_out
--    data_in_2 >--|_____|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| MUX |--------------------------------------------------------------------------------

entity mux_16bit is
    port (
        data_in_1   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 1
        data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 2
        sel         : in  std_logic;                      -- Sinal de seleção
        data_out    : out std_logic_vector(15 downto 0)   -- Dados de saída
    );
end entity mux_16bit;

--| Lógica |-----------------------------------------------------------------------------

architecture main of mux_16bit is
begin

    -- Seleciona data_in_1 ou data_in_2 => data_out
    data_out <= data_in_1 when sel = '0' else data_in_2;

end architecture main;