-- Descrição de Hardware (VHDL) de uma Random Access Memory (RAM)
--
--                    _________
--        data_in >--|         |
--           addr >--|   RAM   |--> data_out
--       ME (LOW) >--|         |
--             OE >--|         |
--             WE >--|_________|
--                
-- 
-- Requisitos
-- > Random Access Memory: acesso a qualquer posição diretamente da memória
-- > Read/Write Memory: qualquer célula da memória pode ser lida e/ou escrita
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 23/06/2024

--| Libraries |-----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| RAM |-----------------------------------------------------------------------------------------

entity generic_ram is

    generic(
        n    : integer := 8;    -- Quantidade de bits de endereçamento
        word : integer := 16    -- Tamanho da palavra de memória
    );

    port (
        we      : in  std_logic;                             -- Habilita escrita (ativo em LOW)
        oe      : in  std_logic;                             -- Habilita output
        ME      : in  std_logic;                             -- Habilita memória
        addr    : in  std_logic_vector(n-1 downto 0);        -- Endereçamento (n bits)
        data_in : in  std_logic_vector(word-1 downto 0);     -- Palavra de entrada (word bits)
        data_out: out std_logic_vector(word-1 downto 0)      -- Palavra de saída (word bits)
    );

end entity generic_ram;

--| Lógica |---------------------------------------------------------------------------------------

architecture main of generic_ram is

    type ram_type is array (0 to (2**n)-1) of std_logic_vector(word-1 downto 0);
    signal ram_block : ram_type;

begin

    process (we, oe, ME, addr)
    begin

        if ME = '1' then

            if we = '0' then    -- Operação de escrita (WR)
                
                ram_block(to_integer(unsigned(addr))) <= data_in;

            end if;

            if oe = '1' then    -- Operação de leitura (RD)

                data_out <= ram_block(to_integer(unsigned(addr)));

            else

                data_out <= (others => 'Z'); -- Alta impedância quando não está lendo

            end if;
        
        else 

            data_out <= (others => 'Z');     -- Alta impedância quando a memória está desabilitada

        end if;
    
    end process;

end architecture main;
