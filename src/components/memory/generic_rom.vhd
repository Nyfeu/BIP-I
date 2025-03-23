
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

    -- (PROGRAMAS DE TESTE) ------------------------------------------------------------------------------

    -- Nesta seção estão os programas de teste para as funcionalidades e operações do BIP-1.
    -- Para selecionar um deles, basta comentar o anterior e remover os comentários do desejado.

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
        0 => x"3000",  
        1 => x"F000",  
        2 => x"F001",  
        3 => x"3001",  
        4 => x"F001",  
        5 => x"3FFF",  
        6 => x"1000",  
        7 => x"2000",  
        8 => x"A000",  
        9 => x"B04A", 
        10 => x"3001",  
        11 => x"F000", 
        12 => x"3002", 
        13 => x"F001", 
        14 => x"37D0", 
        15 => x"1001", 
        16 => x"37D0", 
        17 => x"4001", 
        18 => x"1002", 
        19 => x"37D0",
        20 => x"57D0",
        21 => x"A002",
        22 => x"B04A",
        23 => x"3001",
        24 => x"F000",
        25 => x"3003",
        26 => x"F001",
        27 => x"3FA0",
        28 => x"1003",
        29 => x"3FA0",
        30 => x"6003",
        31 => x"1004",
        32 => x"3000",
        33 => x"A004",
        34 => x"B04A",
        35 => x"3BB8",
        36 => x"7BB8",
        37 => x"A004",
        38 => x"B04A",
        39 => x"3001",
        40 => x"F000",
        41 => x"3004",
        42 => x"F001",
        43 => x"802F",
        44 => x"3000",
        45 => x"F000",
        46 => x"0000",
        47 => x"9000",
        48 => x"3001",
        49 => x"F000",
        50 => x"3005",
        51 => x"F001",
        52 => x"3064",
        53 => x"1005",
        54 => x"3032",
        55 => x"A005",
        56 => x"D03A",
        57 => x"804A",
        58 => x"30C8",
        59 => x"A005",
        60 => x"C03E",
        61 => x"804A",
        62 => x"3001",
        63 => x"F000",
        64 => x"3006",
        65 => x"F001",
        66 => x"E000",
        67 => x"1006",
        68 => x"2006",
        69 => x"A000",
        70 => x"B04A",
        71 => x"3001",
        72 => x"F000",
        73 => x"0000",
        74 => x"3000",
        75 => x"F000",
        76 => x"0000",
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

-- =======================================================================================================