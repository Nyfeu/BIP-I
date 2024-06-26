
-- =======================================================================================================
--
--  Descrição de Hardware (VHDL) do decodificador de instruções
--   
--  ->> AUTOR: André Solano F. R. Maiolini
--  ->> DATA: 21/06/2024
--   
--   ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗██████╗ 
--   ██╔══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝██╔══██╗
--   ██║  ██║█████╗  ██║     ██║   ██║██║  ██║█████╗  ██████╔╝
--   ██║  ██║██╔══╝  ██║     ██║   ██║██║  ██║██╔══╝  ██╔══██╗
--   ██████╔╝███████╗╚██████╗╚██████╔╝██████╔╝███████╗██║  ██║
--   ╚═════╝ ╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
--                                                         
--   ->> Diagrama de bloco (entradas e saídas) ===========================================================
--
--                          _____				
--                         |     |
--      op_code (4bits) >--| DEC |--> control_signals
--                         |_____|
--
--
-- =======================================================================================================

--| Libraries |-------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--| DECODER |---------------------------------------------------------------------------------------------

entity decoder is
  
  -- Aqui são definidos todos os sinais de entrada necessários para decodificar e controlar
  -- as diferentes operações definidas pela ISA (Instruction Set Architecture) do BIP-I.

  port (
    op_code       : in  std_logic_vector(3 downto 0);  -- Lê o código da operação em execução
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
    PC_load       : out std_logic;                     -- Sinal de carga para o PC (JMP)
    RD_io         : out std_logic;                     -- Sinal para leitura do dispositivo de I/O
    WR_io         : out std_logic                      -- Sinal para escrita no dispositivo de I/O
  );

end decoder;

--| Architecture |----------------------------------------------------------------------------------------

architecture main of decoder is

  -- Sinais internos para a lógica combinacional ---------------------------------------------------------
  
  signal u, v, w, x, y              : std_logic;

  -- Sinais de flag (STATUS) -----------------------------------------------------------------------------

  -- O decodificador contêm um registrador de status, que armazena o valor da 
  -- última atualização das flags: GZ e ZF.

  -- O sinal "enable_FLAG" é responsável por atualizar o registrador.

  -- Por sua vez, flag_out é o sinal de saída do registrador que é divido em: ZF_out e GZ_out.

  signal enable_FLAG                : std_logic;
  signal flag_in                    : std_logic_vector(1 downto 0);
  signal flag_out                   : std_logic_vector(1 downto 0);
  signal ZF_out, GZ_out             : std_logic;

  -- Definindo registrador de status (FLAGS) -------------------------------------------------------------

  component register_rising_edge_enable is
    generic (
      n : integer := 2                                 -- Define os bits: GZ e ZF
    );
    port (
      data_in   : in  std_logic_vector(1 downto 0);    -- Dados de entrada
      enable    : in  std_logic;                       -- Sinal de habilitação
      MR        : in  std_logic;                       -- Sinal de master-reset
      CLK       : in  std_logic;                       -- Sinal de clock
      data_out  : out std_logic_vector(1 downto 0)     -- Dados de saída
    );
  end component register_rising_edge_enable;

begin

  -- Instanciando o [STATUS REGISTER] --------------------------------------------------------------------

  flag_in <= (ZF & GZ);                                -- Concatena as flags

  FLAG_REG: register_rising_edge_enable
    port map(
      flag_in,                                         -- Armazena as flags no registrador
      enable_FLAG,                                     -- Habilita o registrador
      MR,                                              -- Master-Reset
      clk,                                             -- CLOCK interno da CPU
      flag_out                                         -- Último valor atualizado
    );

  -- É importante ressaltar que o FLAG_REG é atualizado somente quando é feita uma operação
  -- de comparação, adição ou subtração. A diferença é que a operação de comparação não realiza
  -- a escrita do resultado no acumulador (ACC).

  -- [SINAIS DE CONTROLE] ================================================================================

  -- (SelUlaSrc) -----------------------------------------------------------------------------------------

  -- Seleciona se a entrada da ALU (ou ULA) será o operando da instrução ou um dado
  -- armazenado na memória de dados.

  sel_ula_src <= (not(op_code(3)) and op_code(2)) and op_code(0);
   
  -- (WR_RAM) -------------------------------------------------------------------------------------------- 

  -- Habilita a escrita num endereço da memória de dadoos.

  u <= (not(op_code(3)) and not(op_code(2))) and not(op_code(1));
  WR_RAM <= u and op_code(0);

  -- (WR_PC) ---------------------------------------------------------------------------------------------

  -- Habilita o incremento do Program Counter (PC).

  WR_PC <= ((op_code(3) or op_code(2)) or op_code(1)) or op_code(0);

  -- (WR_ACC) --------------------------------------------------------------------------------------------

  -- Habilita a escrita de um valor no acumulador (ACC).

  v <= (not(op_code(3)) and op_code(2));
  w <= (op_code(1) and not(op_code(3)));
  WR_ACC <= v or w or ((op_code(2) and op_code(1)) and not(op_code(0)));

  -- (SelAccSrc1) ----------------------------------------------------------------------------------------

  -- Bit mais significativo (MSB) na seleção da entrada do acumulador (ACC)

  sel_acc_src_1 <= (not(op_code(3)) and op_code(2)) or ((op_code(2) and op_code(1)) and not(op_code(0)));

  -- (SelAccSrc0) ----------------------------------------------------------------------------------------

  -- Bit menos significativo (LSB) na seleção da entrada do acumulador (ACC)

  sel_acc_src_0 <= (((not(op_code(3)) and not(op_code(2))) and op_code(1)) and op_code(0)) or 
                   (((op_code(3) and op_code(2)) and op_code(1)) and not(op_code(0)));

  -- A seleção da entrada do ACC pode ser: operando, dado armazenado na memória,
  -- resultado obtido da ALU ou algum dado lido pelo dispositivo de I/O.

  -- (op_ula) --------------------------------------------------------------------------------------------

  -- Seleciona a operação a ser executada pela unidade lógica e aritmérica (ALU).

  x <= not(op_code(3)) and not(op_code(2));
  y <= not(op_code(1)) and not(op_code(3));
  op_ula <= x or y;

  -- (WR_IR) ---------------------------------------------------------------------------------------------

  -- Habilita escrita no Instruction Register (IR).

  WR_IR <= not(clk);

  -- (PC_load) -------------------------------------------------------------------------------------------

  -- Habilita o carregamento de um valor no contador de programa (PC). Ou seja, permite operações
  -- de salto (jump) - sejam condicionais ou incondicionais.

  -- Para o caso das operações condicionais, além da decodificação da operação, é necessário que 
  -- o critério das flags GZ e ZF sejam atendidos para que o sinal seja emitido.

  PC_load <= '1' when ((op_code = "1000") or ((op_code = "1011") 
             and (ZF_out = '0')) or (op_code = "1100" and (GZ_out = '1')) 
             or (op_code = "1100" and (GZ_out = '0'))) else '0';

  -- (enable_flag) ---------------------------------------------------------------------------------------

  -- Permite a atualização do registrador de status/flags.

  enable_flag <= ((not(op_code(3)) and op_code(2)) or (((op_code(3) and not(op_code(2))) 
                 and op_code(1)) and not(op_code(0))));

  -- Lembrando que essa atualização é permitida somente por operações aritméticas e de comparação.

  -- (Lendo flags do registrador) ------------------------------------------------------------------------

  ZF_out <= flag_out(1);
  GZ_out <= flag_out(0);

  -- (RD_io) ---------------------------------------------------------------------------------------------

  -- Habilita a leitura dos portes de entrada (INPUT) para o dispositivo de I/O.

  RD_io <= (((op_code(3) and op_code(2)) and op_code(1)) and not(op_code(0)));

  -- (WR_io) ---------------------------------------------------------------------------------------------

  -- Habilita a escrita nos registradores dos portes de saída (OUTPUT) para o dispositivo de I/O.

  WR_io <= (((op_code(3) and op_code(2)) and op_code(1)) and op_code(0));

end architecture main;

----------------------------------------------------------------------------------------------------------