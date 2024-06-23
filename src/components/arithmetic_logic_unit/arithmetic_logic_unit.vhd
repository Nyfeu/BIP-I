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

    -- Sinais intermediários que entrarão no MUX
    signal sum : std_logic_vector(15 downto 0);
    signal dif : std_logic_vector(15 downto 0);

    component full_adder_16bit is
        port (
            a, b      : in  std_logic_vector(15 downto 0);  -- Dados de entrada
            carry_in  : in  std_logic;                      -- Carry in
            sum       : out std_logic_vector(15 downto 0);  -- Resultado
            carry_out : out std_logic                       -- Carry out
        );
    end component full_adder_16bit;

    component full_subber_16bit is
        port (
            a, b  : in  std_logic_vector(15 downto 0);      -- Dados de entrada
            b_in  : in  std_logic;                          -- Borrow in
            dif   : out std_logic_vector(15 downto 0);      -- Resultado
            b_out : out std_logic                           -- Borrow out
        );
    end component full_subber_16bit;

    component mux_16bit is
        port (
            data_in_1 : in  std_logic_vector(15 downto 0);  -- Dados de entrada 1
            data_in_2 : in  std_logic_vector(15 downto 0);  -- Dados de entrada 2
            sel       : in  std_logic;                      -- Sinal de habilitação
            data_out  : out std_logic_vector(15 downto 0)   -- Dados de saída
        );
      end component mux_16bit;

begin

    -- Instanciação dos componentes
    
    FA_16: full_adder_16bit port map(
        data_in_1, data_in_2, '0', sum, open
    );

    FS_16: full_subber_16bit port map(
        data_in_1, data_in_2, '0', dif, open
    );

    MUX: mux_16bit port map(
        sum, dif, op_ula, data_out
    );
    

end architecture main;