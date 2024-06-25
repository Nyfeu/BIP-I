
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

--| Libraries |------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| AND gate |-------------------------------------------------------------------------------

-- Definindo uma entidade para o AND gate

entity decoder is
  
  port (
    op_code       : in  std_logic_vector(3 downto 0);  -- Lê o código da operação em exec
    clk           : in  std_logic;                     -- Recebe o clock interno da CPU
    sel_ula_src   : out std_logic;                     -- Seleciona operando para a ULA
    WR_RAM        : out std_logic;                     -- Sinal de escrita na RAM
    WR_PC         : out std_logic;                     -- Sinal de incremento do PC
    WR_ACC        : out std_logic;                     -- Sinal de escrita no ACC
    sel_acc_src_1 : out std_logic;                     -- Seleção do input do ACC (MSB)
    sel_acc_src_0 : out std_logic;                     -- Seleção do input do ACC (LSB)
    op_ula        : out std_logic;                     -- Seleciona operação da ULA
    WR_IR         : out std_logic;                     -- Sinal de escrita no IR
    LOAD          : out std_logic                      -- Sinal de carga para o PC (JMP)
  );

end decoder;

--| Architecture |---------------------------------------------------------------------------

-- Definindo a lógica do AND gate

architecture main of decoder is

  -- Sinais internos para a lógica combinacional:
  
  signal u, v, w, x, y : std_logic;

begin

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
  WR_ACC <= v or w;

  -- SelAccSrc1
  sel_acc_src_1 <= not(op_code(3)) and op_code(2);

  -- SelAccSrc0
  sel_acc_src_0 <= (((not(op_code(3)) and not(op_code(2))) and op_code(1)) and op_code(0));

  -- op_ula
  x <= not(op_code(3)) and not(op_code(2));
  y <= not(op_code(1)) and not(op_code(3));
  op_ula <= x or y;

  -- WR_IR
  WR_IR <= not(clk);

  -- LOAD
  LOAD <= ((op_code(3) and op_code(2)) and not(op_code(1))) or 
          ((op_code(3) and not(op_code(1))) and not(op_code(0))) or
          (((op_code(3) and not(op_code(2))) and op_code(1)) and op_code(0));

end architecture main;

-------------------------------------------------------------------------------------------