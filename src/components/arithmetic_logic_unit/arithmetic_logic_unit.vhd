
-- ==========================================================================================================================
--
-- Descrição de Hardware (VHDL) de uma Unidade Aritmética (16 bits)
--
--    █████╗ ██╗     ██╗   ██╗
--   ██╔══██╗██║     ██║   ██║
--   ███████║██║     ██║   ██║
--   ██╔══██║██║     ██║   ██║
--   ██║  ██║███████╗╚██████╔╝
--   ╚═╝  ╚═╝╚══════╝ ╚═════╝ 
--
--  ->> AUTOR: André Solano F. R. Maiolini (19.02012-0)
--  ->> DATA: 25/06/2024
--
--  ->> Diagrama de bloco (entradas e saídas) ===============================================================================
--
--                  data_in_2   data_in_1
--                     |            |
--                     v            v
--                 _________    _________
--                 \        \  /        /
--                  \        \/        /                               ->> ZF: resultado igual a zero;
--                   \                /                                ->> GZ: resultado maior que zero;
--         OP_ULA --> \     ALU      / --> FLAGS (ZF, GZ)              ->> OP_ULA: seleção da operação.
--                     \            /
--                      \__________/
--                           |
--                           v
--                        data_out
--
--
-- ==========================================================================================================================

--| Libraries |--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| ALU |--------------------------------------------------------------------------------------------------------------------

entity arithmetic_logic_unit is
    generic (
        n : integer := 16                                   -- QTD de bits
    );
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

    signal result : std_logic_vector(n-1 downto 0);

    -- Sinais intermediários internos:

    signal zero : std_logic_vector(n-1 downto 0) := (others => '0');
    signal zero_flag : std_logic;
    signal greater_than_zero_flag : std_logic;

begin

    -- Seleção da Operação:

    OPERATIONS: process(data_in_1, data_in_2, op_ula)
    begin
        case op_ula is

            -- Adição
            when '0' => result <= std_logic_vector(unsigned(data_in_1) + unsigned(data_in_2));

            -- Subtração
            when '1' => result <= std_logic_vector(unsigned(data_in_1) - unsigned(data_in_2));

            -- Erro
            when others => result <= (others => '0');

        end case;
    end process OPERATIONS;

    -- Calcular as FLAGS:

    FLAGS_PROCESS: process(result)
    begin

        if result = zero then

            zero_flag <= '1';

        else

            zero_flag <= '0';

        end if;

        if op_ula = '0' then

            if unsigned(result) < unsigned(data_in_1) or unsigned(result) < unsigned(data_in_2) then

                greater_than_zero_flag <= '0';

            else
                
                greater_than_zero_flag <= '1';
                
            end if;

        else

            if unsigned(data_in_1) < unsigned(data_in_2) then

                greater_than_zero_flag <= '0';

            else

                greater_than_zero_flag <= '1';

            end if;
        
        end if;

    end process FLAGS_PROCESS;

    -- Atribuindo as FLAGS à saída da ALU:

    ZF <= zero_flag;
    GZ <= greater_than_zero_flag when zero_flag = '0' else '0';
    data_out <= result;
    
end architecture main;

-- ==========================================================================================================================