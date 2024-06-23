-- Arquivo de testes (testbench) para a ALU 16 bits

--| Libraries |----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| Entidade |-----------------------------------------------------------------------------

entity arithmetic_logic_unit_tb is
end entity arithmetic_logic_unit_tb;

--| Lógica - Testbench |-------------------------------------------------------------------

architecture teste of arithmetic_logic_unit_tb is
  
  signal data_in_1 : std_logic_vector(15 downto 0);
  signal data_in_2 : std_logic_vector(15 downto 0);
  signal op_ula    : std_logic;
  signal data_out  : std_logic_vector(15 downto 0);

  component arithmetic_logic_unit is
    port (
        data_in_1, data_in_2   : in  std_logic_vector(15 downto 0);  -- Dados de entrada
        op_ula                 : in  std_logic;                      -- Sinal de operação
        data_out               : out std_logic_vector(15 downto 0)   -- Dados de saída
    );
  end component arithmetic_logic_unit;

begin

    ALU: arithmetic_logic_unit port map (
        data_in_1, data_in_2, op_ula, data_out
    );

    process
    begin

        -- Quando op_ula = 0 => soma;
        -- Quando op_ula = 1 => subtrai;

        -- Test 1: Soma, data_in_1 = 0x000A, data_in_2 = 0x0005, op_ula = 0
        data_in_1 <= x"000A";
        data_in_2 <= x"0005";
        op_ula <= '0';
        wait for 1 ns;
        -- Esperado: data_out = 0x000F

        -- Test 2: Subtrai, data_in_1 = 0x000A, data_in_2 = 0x0005, op_ula = 1
        data_in_1 <= x"000A";
        data_in_2 <= x"0005";
        op_ula <= '1';
        wait for 1 ns;
        -- Esperado: data_out = 0x0005

        -- Test 3: Soma, data_in_1 = 0xFFFF, data_in_2 = 0x0001, op_ula = 0
        data_in_1 <= x"FFFF";
        data_in_2 <= x"0001";
        op_ula <= '0';
        wait for 1 ns;
        -- Esperado: data_out = 0x0000 (overflow)

        -- Test 4: Subtrai, data_in_1 = 0x0000, data_in_2 = 0x0001, op_ula = 1
        data_in_1 <= x"0000";
        data_in_2 <= x"0001";
        op_ula <= '1';
        wait for 1 ns;
        -- Esperado: data_out = 0xFFFF (underflow)

        -- Test 5: Soma, data_in_1 = 0x1234, data_in_2 = 0x5678, op_ula = 0
        data_in_1 <= x"1234";
        data_in_2 <= x"5678";
        op_ula <= '0';
        wait for 1 ns;
        -- Esperado: data_out = 0x68AC

        -- Test 6: Subtrai, data_in_1 = 0x5678, data_in_2 = 0x1234, op_ula = 1
        data_in_1 <= x"5678";
        data_in_2 <= x"1234";
        op_ula <= '1';
        wait for 1 ns;
        -- Esperado: data_out = 0x4444

        wait;

    end process;

end architecture teste;
