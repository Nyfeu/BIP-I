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
    constant memory : memory_type := (
        0 => x"3000",
        1 => x"1001",
        2 => x"3001",
        3 => x"1002",
        4 => x"2001",
        5 => x"4002",
        6 => x"1002",
        7 => x"2002",
        8 => x"4001",
        9 => x"1001",
        10 => x"2001",
        11 => x"4002",
        12 => x"1002",
        13 => x"2002",
        14 => x"4001",
        15 => x"1001",
        16 => x"2001",
        17 => x"4002",
        18 => x"1002",
        19 => x"2002",
        20 => x"4001",
        21 => x"1001",
        22 => x"2001",
        23 => x"4002",
        24 => x"1002",
        25 => x"2002",
        26 => x"4001",
        27 => x"1001",
        28 => x"2001",
        29 => x"4002",
        30 => x"1002",
        31 => x"2002",
        32 => x"4001",
        33 => x"1001",
        34 => x"2001",
        35 => x"4002",
        36 => x"1002",
        37 => x"2002",
        38 => x"4001",
        39 => x"1001",
        40 => x"2001",
        41 => x"4002",
        42 => x"1002",
        43 => x"2002",
        44 => x"4001",
        45 => x"1001",
        46 => x"2001",
        47 => x"4002",
        48 => x"1002",
        49 => x"2002",
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
