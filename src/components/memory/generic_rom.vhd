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

    constant memory : memory_type := (
        0 => x"3000",
        1 => x"1000",
        2 => x"3001",
        3 => x"1001",
        4 => x"4000",
        5 => x"1000",
        6 => x"4001",
        7 => x"1001",
        8 => x"4000",
        9 => x"1000",
        10 => x"4001",
        11 => x"1001",
        12 => x"4000",
        13 => x"1000",
        14 => x"4001",
        15 => x"1001",
        16 => x"4000",
        17 => x"1000",
        18 => x"4001",
        19 => x"1001",
        20 => x"4000",
        21 => x"1000",
        22 => x"4001",
        23 => x"1001",
        24 => x"4000",
        25 => x"1000",
        26 => x"4001",
        27 => x"1001",
        28 => x"4000",
        29 => x"1000",
        30 => x"4001",
        31 => x"1001",
        32 => x"4000",
        33 => x"1000",
        34 => x"4001",
        35 => x"1001",
        36 => x"4000",
        37 => x"1000",
        38 => x"4001",
        39 => x"1001",
        40 => x"4000",
        41 => x"1000",
        42 => x"4001",
        43 => x"1001",
        44 => x"4000",
        45 => x"1000",
        46 => x"4001",
        47 => x"1001",
        48 => x"4000",
        49 => x"1000",
        others => x"0000"
    );

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
