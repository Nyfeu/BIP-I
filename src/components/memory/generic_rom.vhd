-- Descrição de Hardware (VHDL) de uma Read Only Memory (ROM)
--
--                    _________
--           addr >--|         |--> data_out
--       CS (LOW) >--|   ROM   |
--       OE (LOW) >--|_________|
--                
-- 
-- Requisitos
-- > Read Only Memory: somente leitura.
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |-----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| ROM |-----------------------------------------------------------------------------------------

entity generic_rom is

    generic (
        n      : integer := 8;                                 -- Quantidade de bits de endereçamento
        word   : integer := 16                                 -- Tamanho da palavra de memória
    );

    port (
        cs       : in std_logic;                               -- Chip Selection (CS) ativo em LOW
        oe       : in std_logic;                               -- Output Enable (OE) ativo em LOW
        address  : in std_logic_vector(n-1 downto 0);          -- Barramento de endereço
        data_out : out std_logic_vector(word-1 downto 0)       -- Saída de dados
    );
    
end entity generic_rom;

--| Lógica |--------------------------------------------------------------------------------------

architecture main of generic_rom is

    type memory_type is array (0 to 2**n - 1) of std_logic_vector(word-1 downto 0);

    -- Gravação do código a ser executado pela CPU:

    -- Teste: "Pulos condicionais"
    
    -- constant memory : memory_type := (
    --     0 => x"3007",  -- Define ACC = 7
    --     1 => x"1007",  -- valor do (0x007) = 7
    --     2 => x"9000",  -- NOP
    --     3 => x"300E",  -- Define ACC = 14
    --     4 => x"A007",  -- Compara ACC com 7
    --     5 => x"B00F",  -- Caso ACC ≠ 7 - ou seja, 7 ≠ 14 (✓)
    --     6 => x"800A",  -- Caso ACC = 7 - ou seja, 7 = 14 (x) - finaliza (PC_out = A)
    --     15 => x"D012", -- Caso ACC < 7 - ou seja, 7 > 14 (x) - finaliza (PC_out = 12) 
    --     16 => x"C01B", -- Caso ACC > 7 - ou seja, 7 < 14 (✓)
    --     27 => x"C02B", -- Caso ACC > 7 - ou seja, 7 < 14 (✓) - finaliza (PC_out = 2B)
    --     28 => x"D02C", -- Caso ACC < 7 - ou seja, 7 > 14 (x) - finaliza (PC_out = 2C)
    --     others => x"0000"
    -- );

    -- Teste: "Sequência de Fibonacci"

    constant memory : memory_type := (
        0 => x"E000",
        1 => x"1000",
        2 => x"F003",
        3 => x"E001",
        4 => x"1001",
        5 => x"F003",
        6 => x"9000",
        7 => x"4000",
        8 => x"1000",
        9 => x"F003",
        10 => x"4001",
        11 => x"1001",
        12 => x"F003",
        13 => x"8005",
        others => x"0000"
    );

    -- Teste: "I/O"

    -- constant memory : memory_type := (
    --     0 => x"E000",
    --     1 => x"F000",
    --     2 => x"E001",
    --     3 => x"F001",
    --     4 => x"E002",
    --     5 => x"F002",
    --     6 => x"E003",
    --     7 => x"F003",
    --     others => x"0000"
    -- );

begin

    process (address, cs, oe)
    begin

        if cs = '0' then      -- CS ativo (nível lógico LOW)

            if oe = '0' then  -- OE ativo (nível lógico LOW)

                data_out <= memory(to_integer(unsigned(address)));

            else

                data_out <= (others => 'Z');  -- Alta impedância quando OE não está ativo

            end if;

        else

            data_out <= (others => 'Z');      -- Alta impedância quando CS não está ativo
            
        end if;

    end process;

end architecture main;
