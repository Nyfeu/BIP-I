-- Descrição de Hardware (VHDL) de uma Unidade Lógica e Aritmética (16 bits)
--
--                  __________
--    data_in_1 >--|          |
--    data_in_2 >--|   ALU    |--> data_out 
--       op_ula >--|__________|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| ALU |------------------------------------------------------------------------------------

entity arithmetic_logic_unit is
    port (
        data_in_1, data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada
        op_ula                 : in  std_logic;                      -- Sinal de operação
        data_out               : out std_logic_vector(15 downto 0)   -- Dados de saída
    );
end entity arithmetic_logic_unit;

--| Lógica |----------------------------------------------------------------------------------

architecture main of arithmetic_logic_unit is

    -- Definindo a unidade aritmética:

    component arithmetic_unit is
        port (
            data_in_1, data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada
            op_ula                 : in  std_logic;                      -- Sinal de operação
            data_out               : out std_logic_vector(15 downto 0)   -- Dados de saída
        );
    end component arithmetic_unit;

begin

    AU: arithmetic_unit port map(
        data_in_1, data_in_2, op_ula, data_out
    );

end architecture main;