-- ==============================================================================================================================================
--
--  Descrição de Hardware (VHDL) do dispositivo de I/O (INPUT/OUTPUT)
--   
--  ->> AUTOR: André Solano F. R. Maiolini
--  ->> DATA: 25/06/2024
--
--   ██╗    ██╗ ██████╗     ██████╗ ███████╗██╗   ██╗██╗ ██████╗███████╗
--   ██║   ██╔╝██╔═══██╗    ██╔══██╗██╔════╝██║   ██║██║██╔════╝██╔════╝
--   ██║  ██╔╝ ██║   ██║    ██║  ██║█████╗  ██║   ██║██║██║     █████╗  
--   ██║ ██╔╝  ██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══╝  
--   ██║██╔╝   ╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ ██║╚██████╗███████╗
--   ╚═╝╚═╝     ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝
--      
-- ==============================================================================================================================================                                                             

--| Libraries |----------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--| DEVICE |-------------------------------------------------------------------------------------------------------------------------------------

entity io_device is

    generic (
        n    : integer := 16;                                           -- Tamanho da palavra
        addr : integer := 2                                             -- Quatro portes
    );

    port (
        MR            : in  std_logic;                                  -- Master-Reset
        clk           : in  std_logic;                                  -- Clock interno da CPU
        data_out      : in  std_logic_vector(n-1 downto 0);             -- Dados de saída do I/O (output)
        data_in       : out std_logic_vector(n-1 downto 0);             -- Dados de entrada do I/O (input)
        enable_read   : in  std_logic;                                  -- Habilita leitura do I/O
        enable_write  : in  std_logic;                                  -- Habilita escrita do I/O
        address       : in  std_logic_vector(addr-1 downto 0);          -- Endereço do I/O
        in_port_1     : in  std_logic_vector(n-1 downto 0);             -- Porte de entrada 1
        in_port_2     : in  std_logic_vector(n-1 downto 0);             -- Porte de entrada 2
        in_port_3     : in  std_logic_vector(n-1 downto 0);             -- Porte de entrada 3
        in_port_4     : in  std_logic_vector(n-1 downto 0);             -- Porte de entrada 4
        out_port_1    : out std_logic_vector(n-1 downto 0);             -- Porte de saída 1
        out_port_2    : out std_logic_vector(n-1 downto 0);             -- Porte de saída 2
        out_port_3    : out std_logic_vector(n-1 downto 0);             -- Porte de saída 3
        out_port_4    : out std_logic_vector(n-1 downto 0)              -- Porte de saída 4
    );

end entity io_device;

--| Lógica |--------------------------------------------------------------------------------------------------------------------------------------

architecture main of io_device is

    -- Registrador de 16 bits detector de borda de descida com enable:

    component register_falling_edge_enable is
        port (
            data_in   : in  std_logic_vector(15 downto 0);             -- Dados de entrada
            enable    : in  std_logic;                                 -- Sinal de habilitação
            MR        : in  std_logic;                                 -- Sinal de master-reset
            CLK       : in  std_logic;                                 -- Sinal de clock
            data_out  : out std_logic_vector(15 downto 0)              -- Dados de saída
        );
    end component register_falling_edge_enable;

    -- Sinais internos:

    signal enable_in_1, enable_in_2, enable_in_3, enable_in_4     : std_logic;
    signal enable_out_1, enable_out_2, enable_out_3, enable_out_4 : std_logic;

begin

    -- Instânciando os registradores de cada porte:

    reg_out_1:register_falling_edge_enable 
        port map (
            data_out,
            enable_out_1,
            MR,
            clk,
            out_port_1
        );
    
    reg_out_2:register_falling_edge_enable 
        port map (
            data_out,
            enable_out_2,
            MR,
            clk,
            out_port_2
        );

    reg_out_3:register_falling_edge_enable 
        port map (
            data_out,
            enable_out_3,
            MR,
            clk,
            out_port_3
        );

    reg_out_4:register_falling_edge_enable 
        port map (
            data_out,
            enable_out_4,
            MR,
            clk,
            out_port_4
        );

    -- Definindo os sinais de enable_out:

    process (enable_write, address)
    begin
        enable_out_1 <= '1' when (rising_edge(enable_write) and address = "00") else '0';
        enable_out_2 <= '1' when (rising_edge(enable_write) and address = "01") else '0';
        enable_out_3 <= '1' when (rising_edge(enable_write) and address = "10") else '0';
        enable_out_4 <= '1' when (rising_edge(enable_write) and address = "11") else '0';
    end process;

    -- Processo para seleção do INPUT

    INPUT_PROCESS: process (enable_read)
    begin

        if rising_edge(enable_read) then

            case address is

                when "00" => data_in <= in_port_1;
                when "01" => data_in <= in_port_2;
                when "10" => data_in <= in_port_3;
                when "11" => data_in <= in_port_4;
                when others => data_in <= (others => '0');

            end case;

        end if;

    end process INPUT_PROCESS;

end architecture main;

--------------------------------------------------------------------------------------------------------------------------------------------------