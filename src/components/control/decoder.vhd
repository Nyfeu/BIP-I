
-- Descrição de Hardware (VHDL) de um decodificador de instruções
--
--                          _____				
--                         |     |
--      op_code (4bits) >--| DEC |--> control_signals
--                         |_____|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 21/06/2024

--| Libraries |-------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| DECODER |---------------------------------------------------------------------------------------------

entity decoder is
  
  port (
    op_code       : in  std_logic_vector(3 downto 0);  -- Lê o código da operação em exec
    clk           : in  std_logic;                     -- Recebe o clock interno da CPU
    ZF            : in  std_logic;                     -- Zero Flag
    GZ            : in  std_logic;                     -- Flag "Greater than Zero"
    MR            : in  std_logic;                     -- Master-Reset para o registrador de status       
    sel_ula_src   : out std_logic;                     -- Seleciona operando para a ULA
    WR_RAM        : out std_logic;                     -- Sinal de escrita na RAM
    WR_PC         : out std_logic;                     -- Sinal de incremento do PC
    WR_ACC        : out std_logic;                     -- Sinal de escrita no ACC
    sel_acc_src_1 : out std_logic;                     -- Seleção do input do ACC (MSB)
    sel_acc_src_0 : out std_logic;                     -- Seleção do input do ACC (LSB)
    op_ula        : out std_logic;                     -- Seleciona operação da ULA
    WR_IR         : out std_logic;                     -- Sinal de escrita no IR
    LOAD          : out std_logic;                     -- Sinal de carga para o PC (JMP)
    read_io       : out std_logic;                     -- Sinal para leitura do dispositivo de I/O
    write_io      : out std_logic                      -- Sinal para escrita no dispositivo de I/O
  );

end decoder;

--| Architecture |----------------------------------------------------------------------------------------

architecture main of decoder is

  -- Sinais internos para a lógica combinacional:
  
  signal u, v, w, x, y, enable_FLAG : std_logic;
  signal flag_out                   : std_logic_vector(1 downto 0);
  signal ZF_out, GZ_out             : std_logic;

  -- Definindo registrador de status (FLAGS):

  component register_rising_edge_enable is
    generic (
      n : integer := 2
    );
    port (
      data_in   : in  std_logic_vector(1 downto 0);   -- Dados de entrada
      enable    : in  std_logic;                       -- Sinal de habilitação
      MR        : in  std_logic;                       -- Sinal de master-reset
      CLK       : in  std_logic;                       -- Sinal de clock
      data_out  : out std_logic_vector(1 downto 0)    -- Dados de saída
    );
  end component register_rising_edge_enable;

begin

  -- Status (FLAGS) register:

  FLAG_REG: register_rising_edge_enable
    port map(
      (ZF & GZ),
      enable_FLAG,
      MR,
      clk,
      flag_out
    );

  -- SelUlaSrc
  sel_ula_src <= (not(op_code(3)) and op_code(2)) and op_code(0);
   
  -- WR_RAM
  u <= (not(op_code(3)) and not(op_code(2))) and not(op_code(1));
  WR_RAM <= u and op_code(0);

  -- WR_PC
  WR_PC <= ((op_code(3) or op_code(2)) or op_code(1)) or op_code(0);

  -- WR_ACC
  v <= (not(op_code(3)) and op_code(2));
  w <= (op_code(1) and not(op_code(3)));
  WR_ACC <= v or w or ((op_code(2) and op_code(1)) and not(op_code(0)));

  -- SelAccSrc1
  sel_acc_src_1 <= (not(op_code(3)) and op_code(2)) or ((op_code(2) and op_code(1)) and not(op_code(0)));

  -- SelAccSrc0
  sel_acc_src_0 <= (((not(op_code(3)) and not(op_code(2))) and op_code(1)) and op_code(0)) or 
                   (((op_code(3) and op_code(2)) and op_code(1)) and not(op_code(0)));

  -- op_ula
  x <= not(op_code(3)) and not(op_code(2));
  y <= not(op_code(1)) and not(op_code(3));
  op_ula <= x or y;

  -- WR_IR
  WR_IR <= not(clk);

  -- LOAD
  LOAD <= '1' when ((op_code = "1000") or ((op_code = "1011") and (ZF_out = '0')) or (op_code = "1100" and (GZ_out = '1')) or (op_code = "1100" and (GZ_out = '0'))) else '0';

  -- enable_flag
  enable_flag <= ((not(op_code(3)) and op_code(2)) or (((op_code(3) and not(op_code(2))) and op_code(1)) and not(op_code(0))));

  -- Lendo flags do registrador:
  ZF_out <= flag_out(1);
  GZ_out <= flag_out(0);

  -- read_io
  read_io <= (((op_code(3) and op_code(2)) and op_code(1)) and not(op_code(0)));

  -- write_io
  write_io <= (((op_code(3) and op_code(2)) and op_code(1)) and op_code(0));

end architecture main;

--------------------------------------------------------------------------------------------------------