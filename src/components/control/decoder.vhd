
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

  -- Sinais de flag (STATUS) -----------------------------------------------------------------------------

  -- O decodificador contêm um registrador de status, que armazena o valor da 
  -- última atualização das flags: GZ e ZF.

  -- O sinal "enable_FLAG" é responsável por atualizar o registrador.

  -- Por sua vez, flag_out é o sinal de saída do registrador que é divido em: ZF_out e GZ_out.

  signal enable_FLAG                : std_logic;
  signal SelAccSrc                  : std_logic_vector(1 downto 0);
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

  -- Definição do tipo record para agrupar os sinais de controle
  type ControlSignals is record
      sel_ula_src : std_logic;
      op_ula      : std_logic;
      WR_RAM      : std_logic;
      WR_PC       : std_logic;
      WR_ACC      : std_logic;
      SelAccSrc   : std_logic_vector(1 downto 0);
  end record;

  -- Declaração do sinal do tipo record
  signal ctrl : ControlSignals;

begin

  -- ENABLE_FLAG UPDATE -----------------------------------------------------------------------------------
  
    -- Verififca se é um operação aritmética ou de comparação
  
    enable_flag <= '1' when (op_code = "1010" or op_code = "0000" or op_code = "0001" or op_code = "0010") else '0';

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
    
    process(op_code)
    begin
        
          -- Valor padrão para evitar inferência de latch
          ctrl <= ('0', '0', '0', '0', '0', "00");
      
          case op_code is
              when "0000" => ctrl <= ('0', '1', '0', '0', '0', "00");
              when "0001" => ctrl <= ('0', '1', '1', '1', '0', "00");
              when "0010" => ctrl <= ('0', '1', '0', '1', '1', "00");
              when "0011" => ctrl <= ('0', '1', '0', '1', '1', "01");
              when "0100" => ctrl <= ('0', '1', '0', '1', '1', "10");
              when "0101" => ctrl <= ('1', '1', '0', '1', '1', "10");
              when "0110" => ctrl <= ('0', '0', '0', '1', '1', "10");
              when "0111" => ctrl <= ('1', '0', '0', '1', '1', "10");
              when "1000" => ctrl <= ('0', '0', '0', '1', '0', "00");
              when "1001" => ctrl <= ('0', '0', '0', '1', '0', "00");
              when "1010" => ctrl <= ('0', '0', '0', '1', '0', "00");
              when "1011" => ctrl <= ('0', '0', '0', '1', '0', "00");
              when "1100" => ctrl <= ('0', '0', '0', '1', '0', "00");
              when "1101" => ctrl <= ('0', '0', '0', '1', '0', "00");
              when "1110" => ctrl <= ('0', '0', '0', '1', '1', "11");
              when "1111" => ctrl <= ('0', '0', '0', '1', '0', "00");
              when others => ctrl <= ('0', '0', '0', '0', '0', "00");
          end case;
          
    end process;
    
    -- Atribuir os sinais individuais a partir do record
    
    sel_ula_src <= ctrl.sel_ula_src;
    op_ula      <= ctrl.op_ula;
    WR_RAM      <= ctrl.WR_RAM;
    WR_PC       <= ctrl.WR_PC;
    WR_ACC      <= ctrl.WR_ACC;
    SelAccSrc   <= ctrl.SelAccSrc;
    
    -- (WR_IR) --------------------------------------------------------------------------------------------
    
    WR_IR <= not(clk);
    
    -- (SelAccSrc) -----------------------------------------------------------------------------------------
    
    sel_acc_src_1 <= SelAccSrc(1);
    sel_acc_src_0 <= SelAccSrc(0);
    
    -- (Verificando salto) ---------------------------------------------------------------------------------
    
    ZF_out <= flag_out(1);
    GZ_out <= flag_out(0);
    
    PC_load <= '1' when 
                   (op_code = "1000") or                                          -- JUMP (Incondicional)
                   ((op_code = "1011") and (ZF_out = '0')) or                     -- JNE (Jump if Not Equal)
                   ((op_code = "1100") and (GZ_out = '1')) or                     -- JL (Jump if Lesser)
                   ((op_code = "1101") and (GZ_out = '0') and (ZF_out = '0'))     -- JG (Jump if Greater)
                   else '0';
         
    -- (RD_io) ---------------------------------------------------------------------------------------------

    -- Habilita a leitura dos portes de entrada (INPUT) para o dispositivo de I/O.  
    
    RD_io <= '1' when op_code = "1110" else '0';
    
    -- (WR_io) ---------------------------------------------------------------------------------------------

    -- Habilita a escrita nos registradores dos portes de saída (OUTPUT) para o dispositivo de I/O.

    WR_io <= '1' when op_code = "1111" else '0';    

end architecture main;


----------------------------------------------------------------------------------------------------------