-- Descrição de Hardware (VHDL) de um Registrador Síncrono c/ Master-Reset
--
-- ->> Detector de bordas de descida
--
--                  __________
--           MR >--|          |
--          CLK >--| register |--> data_out (16 bits)
--                 |  n bits  |
--      data_in >--|__________|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Register |---------------------------------------------------------------------------

entity register_falling_edge is
    generic (
        n      : integer := 16                          -- Quantidade de bits
    );
    port (
        data_in   : in  std_logic_vector(n-1 downto 0); -- Dados de entrada
        MR        : in  std_logic;                      -- Sinal de master-reset
        CLK       : in  std_logic;                      -- Sinal de clock
        data_out  : out std_logic_vector(n-1 downto 0)  -- Dados de saída
    );
end entity register_falling_edge;

--| Lógica |------------------------------------------------------------------------------

architecture main of register_falling_edge is
begin

    process (CLK, MR)
    begin
        if MR = '0' then
            data_out <= (others => '0');
        elsif falling_edge(CLK) then
            data_out <= data_in;
        end if;
    end process;

end architecture main;
