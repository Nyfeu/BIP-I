
-- Descrição de Hardware (VHDL) de uma porta AND de duas entradas
--
--                          _____				
--                         |     |
--      op_code (4bits) >--| DEC |--> control_signals
--                         |_____|
--
--
-- AUTOR: André Solano F. R. Maiolini
-- DATA: 21/06/2024

--| Libraries |-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| AND gate |---------------------------------------------------------

-- Definindo uma entidade para o AND gate

entity decoder is
  
  port (
    op_code       : in  std_logic_vector(3 downto 0);
    sel_ula_src   : out std_logic;
    WR_RAM        : out std_logic;
    WR_PC         : out std_logic;
    WR_ACC        : out std_logic;
    sel_acc_src_1 : out std_logic;
    sel_acc_src_0 : out std_logic;
    op_ula        : out std_logic
  );

end decoder;

--| Architecture |-----------------------------------------------------

-- Definindo a lógica do AND gate

architecture main of decoder is

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

end architecture main;

---------------------------------------------------------------------