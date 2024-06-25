-- Descrição de Hardware (VHDL) de uma Unidade Aritmética (16 bits)
--
--
--                  data_in_2   data_in_1
--                     |            |
--                     v            v
--                 _________    _________
--                 \        \  /        /
--                  \        \/        /
--                   \                /
--         OP_ULA --> \     ALU      / --> FLAGS (ZF, GZ)
--                     \            /
--                      \__________/
--                           |
--                           v
--                        data_out
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 25/06/2024

--| Libraries |--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| ALU |--------------------------------------------------------------------------------------------------------------------

entity arithmetic_logic_unit is
    port (
        data_in_1, data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada
        op_ula                 : in  std_logic;                      -- Sinal de operação
        data_out               : out std_logic_vector(15 downto 0);  -- Dados de saída
        ZF                     : out std_logic;                      -- Zero Flag
        GZ                     : out std_logic                       -- Greater than Zero (flag)
    );
end entity arithmetic_logic_unit;

--| Lógica |-----------------------------------------------------------------------------------------------------------------

architecture main of arithmetic_logic_unit is

    -- Sinais intermediários que entrarão no MUX:

    signal sum : std_logic_vector(15 downto 0);
    signal dif : std_logic_vector(15 downto 0);

    -- Sinais intermediários internos:

    signal zero_flag : std_logic;
    signal greater_than_zero_flag : std_logic;

    -- Definindo o somador completo de 16 bits:

    component full_adder_16bit is
        port (
            a, b      : in  std_logic_vector(15 downto 0);           -- Dados de entrada
            carry_in  : in  std_logic;                               -- Carry in
            sum       : out std_logic_vector(15 downto 0);           -- Resultado
            carry_out : out std_logic                                -- Carry out
        );
    end component full_adder_16bit;

    -- Definindo o subtrator completo de 16 bits:

    component full_subber_16bit is
        port (
            a, b  : in  std_logic_vector(15 downto 0);               -- Dados de entrada
            b_in  : in  std_logic;                                   -- Borrow in
            dif   : out std_logic_vector(15 downto 0);               -- Resultado
            b_out : out std_logic                                    -- Borrow out
        );
    end component full_subber_16bit;

    -- Definindo um mux de 16 bits:

    component mux_16bit is
        port (
            data_in_1 : in  std_logic_vector(15 downto 0);           -- Dados de entrada 1
            data_in_2 : in  std_logic_vector(15 downto 0);           -- Dados de entrada 2
            sel       : in  std_logic;                               -- Sinal de habilitação
            data_out  : out std_logic_vector(15 downto 0)            -- Dados de saída
        );
      end component mux_16bit;

begin

    -- Instanciação dos componentes:
    
    FA_16: full_adder_16bit port map(
        data_in_1, data_in_2, '0', sum, open
    );

    FS_16: full_subber_16bit port map(
        data_in_1, data_in_2, '0', dif, open
    );

    MUX: mux_16bit port map(
        sum, dif, op_ula, data_out
    );

    -- Calcular as FLAGS:

    FLAGS_PROCESS: process(data_out)
    begin

        zero_flag <= '1' when (data_out = (x"0000")) else '0';
        
        if (op_ula = '0') then

            greater_than_zero_flag <= '0' when (data_out < data_in_1 or data_out < data_in_2) else
                                      '1' when (data_out /= x"0000") else '0';

        else

            greater_than_zero_flag <= '0' when data_in_1 < data_in_2 else '1';

        end if;

    end process FLAGS_PROCESS;

    -- Atribuindo as FLAGS à saída da ALU:

    ZF <= zero_flag;
    GZ <= greater_than_zero_flag;
    
end architecture main;

-----------------------------------------------------------------------------------------------------------------------------