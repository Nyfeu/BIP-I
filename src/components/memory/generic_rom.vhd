
-- =======================================================================================================
--
--  Descrição de Hardware (VHDL) de uma Read Only Memory (ROM) - "Memória de Programa"
--
--  ->> AUTOR: André Solano F. R. Maiolini
--  ->> DATA: 23/06/2024
--
--   ██████╗  ██████╗ ███╗   ███╗
--   ██╔══██╗██╔═══██╗████╗ ████║
--   ██████╔╝██║   ██║██╔████╔██║
--   ██╔══██╗██║   ██║██║╚██╔╝██║
--   ██║  ██║╚██████╔╝██║ ╚═╝ ██║
--   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝
--
--  ->> Diagrama de bloco (entradas e saídas) ============================================================
--
--                    _________
--           addr >--|         |--> data_out
--       CS (LOW) >--|   ROM   |
--       OE (LOW) >--|_________|
--                
-- =======================================================================================================

--| Libraries |-------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| ROM |-------------------------------------------------------------------------------------------------

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

--| Lógica |----------------------------------------------------------------------------------------------

architecture main of generic_rom is

    -- (PROGRAMA DE TESTE) ------------------------------------------------------------------------------

    -- Nesta seção estão os programas de teste para as funcionalidades e operações do BIP-1.

    type memory_type is array (0 to 2**n - 1) of std_logic_vector(word-1 downto 0);

    -- Gravação do código a ser executado pela CPU:

    -- Teste: "Cálculo de 5! (fatorial de 5)"

    constant memory : memory_type := (                                                                                                                                                            
        0  => x"3001",   -- 0 : 3001                                                                                                                                                              
        1  => x"1000",   -- 1 : 1000
        2  => x"3005",   -- 2 : 3005
        3  => x"1001",   -- 3 : 1001
        4  => x"3000",   -- 4 : 3000
        5  => x"1006",   -- 5 : 1006
        6  => x"2001",   -- 6 : 2001
        7  => x"A006",   -- 7 : A006
        8  => x"B00A",   -- 8 : B00A
        9  => x"8022",   -- 9 : 8022
        10 => x"2001",   -- A : 2001
        11 => x"1002",   -- B : 1002
        12 => x"2000",   -- C : 2000
        13 => x"1003",   -- D : 1003
        14 => x"8015",   -- E : 8015
        15 => x"2004",   -- F : 2004
        16 => x"1000",   -- 10 : 1000
        17 => x"2001",   -- 11 : 2001
        18 => x"7001",   -- 12 : 7001
        19 => x"1001",   -- 13 : 1001
        20 => x"8006",   -- 14 : 8006
        21 => x"3000",   -- 15 : 3000
        22 => x"1004",   -- 16 : 1004
        23 => x"3000",   -- 17 : 3000
        24 => x"1005",   -- 18 : 1005
        25 => x"2004",   -- 19 : 2004
        26 => x"4003",   -- 1A : 4003
        27 => x"1004",   -- 1B : 1004
        28 => x"2002",   -- 1C : 2002
        29 => x"7001",   -- 1D : 7001
        30 => x"1002",   -- 1E : 1002
        31 => x"A005",   -- 1F : A005
        32 => x"B019",   -- 20 : B019
        33 => x"800F",   -- 21 : 800F
        34 => x"2000",   -- 22 : 2000
        35 => x"0000",   -- 23 : 0000
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

-- =======================================================================================================