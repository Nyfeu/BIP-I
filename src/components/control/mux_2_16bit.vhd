
-- Descrição de Hardware (VHDL) de um Mux 16 bits com 2 selects
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

entity mux_2_16bit is
    port (
        data_in_1   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 1
        data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 2
        data_in_3   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 3
        data_in_4   : in  std_logic_vector(15 downto 0);  -- Dados de entrada 4
        sel_1       : in  std_logic;                      -- Sinal de seleção 1
        sel_0       : in  std_logic;                      -- Sinal de seleção 2
        data_out    : out std_logic_vector(15 downto 0)   -- Dados de saída
    );
end entity mux_2_16bit;

--| Lógica |-----------------------------------------------------------------------------

architecture main of mux_2_16bit is
begin

    -- Seleciona data_in_1 ou data_in_2 => data_out
    data_out <= data_in_1 when (sel_1 = '0' and sel_0 = '0') else 
                data_in_2 when (sel_1 = '0' and sel_0 = '1') else
                data_in_3 when (sel_1 = '1' and sel_0 = '0') else
                data_in_4;

end architecture main;