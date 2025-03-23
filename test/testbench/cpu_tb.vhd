-- ======================================================================================================================
--
-- Arquivo de testes (testbench) para a CPU (BIP I)    
--
--   ████████╗███████╗███████╗████████╗██████╗ ███████╗███╗   ██╗ ██████╗██╗  ██╗    ██████╗ ██╗██████╗        ██╗
--   ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔════╝██║  ██║    ██╔══██╗██║██╔══██╗      ███║
--      ██║   █████╗  ███████╗   ██║   ██████╔╝█████╗  ██╔██╗ ██║██║     ███████║    ██████╔╝██║██████╔╝█████╗╚██║
--      ██║   ██╔══╝  ╚════██║   ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║     ██╔══██║    ██╔══██╗██║██╔═══╝ ╚════╝ ██║
--      ██║   ███████╗███████║   ██║   ██████╔╝███████╗██║ ╚████║╚██████╗██║  ██║    ██████╔╝██║██║            ██║
--      ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝    ╚═════╝ ╚═╝╚═╝            ╚═╝
--                                                                                                             
-- ->> AUTOR: André Solano F. R. Maiolini (19.02012-0)
-- ->> DATA: 25/06/2024
--
-- ======================================================================================================================                                                                   

--| Testbench Code | ====================================================================================================

-- ; ================================================================
-- ; BIP I CPU INSTRUCTION SET TEST PROGRAM
-- ; ================================================================
-- ; Output Port Usage:
-- ; - out_port_1 (0000): Test status (0 = fail, 1 = pass)
-- ; - out_port_2 (0001): Current test step
-- ; ================================================================
-- 
-- ; Initialize outputs to 0
-- LDI 0
-- OUT 0000  ; Reset out_port_1
-- OUT 0001  ; Reset out_port_2
-- 
-- ; ----------------------------------------------------------------
-- ; TEST 1: LDI, STO, LD, OUT
-- ; ----------------------------------------------------------------
-- LDI 1
-- OUT 0001  ; Test step = 1
-- LDI 4095  ; Max 12-bit value (4095)
-- STO 0000  ; Store in memory[0000]
-- LD 0000   ; Load back into ACC
-- CMP 0000  ; Compare ACC with memory[0000]
-- JNE fail  ; Fail if mismatch
-- LDI 1
-- OUT 0000  ; Pass
-- 
-- ; ----------------------------------------------------------------
-- ; TEST 2: ADD and ADDI
-- ; ----------------------------------------------------------------
-- LDI 2
-- OUT 0001  ; Test step = 2
-- LDI 2000
-- STO 0001  ; Store 2000 in memory[0001]
-- LDI 2000
-- ADD 0001  ; ACC = 2000 + 2000 = 4000 (valid 16-bit)
-- STO 0002  ; Store 4000 in memory[0002]
-- LDI 2000
-- ADDI 2000 ; ACC = 2000 + 2000 = 4000
-- CMP 0002  ; Compare with memory[0002]
-- JNE fail
-- LDI 1
-- OUT 0000  ; Pass
-- 
-- ; ----------------------------------------------------------------
-- ; TEST 3: SUB and SUBI
-- ; ----------------------------------------------------------------
-- LDI 3
-- OUT 0001  ; Test step = 3
-- LDI 4000
-- STO 0003  ; Store 4000 in memory[0003]
-- LDI 4000
-- SUB 0003  ; ACC = 4000 - 4000 = 0
-- STO 0004  ; Store 0 in memory[0004]
-- LDI 0
-- CMP 0004  ; Compare ACC (0) with memory[0004]
-- JNE fail
-- LDI 3000
-- SUBI 3000 ; ACC = 0
-- CMP 0004  ; Compare with memory[0004] (0)
-- JNE fail
-- LDI 1
-- OUT 0000  ; Pass
-- 
-- ; ----------------------------------------------------------------
-- ; TEST 4: JUMP, NOP
-- ; ----------------------------------------------------------------
-- LDI 4
-- OUT 0001  ; Test step = 4
-- JUMP skip
-- fail:     ; Unreachable if JUMP works
--   LDI 0
--   OUT 0000
--   HLT 0
-- skip:
-- NOP       ; Verify no side effects
-- LDI 1
-- OUT 0000  ; Pass
-- 
-- ; ----------------------------------------------------------------
-- ; TEST 5: CMP, JNE, JL, JG
-- ; ----------------------------------------------------------------
-- LDI 5
-- OUT 0001  ; Test step = 5
-- LDI 100
-- STO 0005  ; memory[0005] = 100
-- LDI 50
-- CMP 0005  ; Compare 100 > 50
-- JG  greater  ; Jump if ACC < memory[0005]
-- JUMP fail
-- greater:
-- LDI 200
-- CMP 0005  ; Compare 100 < 200
-- JL  less:
-- JUMP fail
-- less:
-- LDI 1
-- OUT 0000  ; Pass
-- 
-- ; ----------------------------------------------------------------
-- ; TEST 6: IN, HLT
-- ; ----------------------------------------------------------------
-- LDI 6
-- OUT 0001  ; Test step = 6
-- IN 0000   ; Read input from port 0000 (simulate X=4095)
-- STO 0006  ; Store input
-- LD 0006   ; Load input back
-- CMP 0000  ; Compare with memory[0000] (4095)
-- JNE fail
-- LDI 1
-- OUT 0000  ; Pass
-- HLT 0     ; Halt
-- 
-- ; ================================================================
-- ; FAIL HANDLER
-- ; ================================================================
-- fail:
--   LDI 0
--   OUT 0000  ; Signal failure
--   HLT 0
--
-- ; ================================================================

--| Libraries | =========================================================================================================

library ieee;
use ieee.std_logic_1164.all;

--| Entidade | ==========================================================================================================

entity cpu_tb is
end entity cpu_tb;

--| Lógica - Testbench | ================================================================================================

architecture teste of cpu_tb is
  
  -- (Sinais sendo rastreados) ------------------------------------------------------------------------------------------

  signal enable_clk  : std_logic := '1';                                 -- Enable (ativo em HIGH)
  signal MR          : std_logic;                                        -- Master-Reset (ativo em LOW)

  -- (Definindo sinais dos portes de IO) --------------------------------------------------------------------------------

  signal in_port_1   : std_logic_vector(15 downto 0) := x"0000";         -- Porte de entrada 1 (16 bits)
  signal in_port_2   : std_logic_vector(15 downto 0) := x"0001";         -- Porte de entrada 2 (16 bits)
  signal in_port_3   : std_logic_vector(15 downto 0) := x"0000";         -- Porte de entrada 3 (16 bits)
  signal in_port_4   : std_logic_vector(15 downto 0) := x"0000";         -- Porte de entrada 4 (16 bits)
  signal out_port_1  : std_logic_vector(15 downto 0);                    -- Porte de saída 1 (16 bits)
  signal out_port_2  : std_logic_vector(15 downto 0);                    -- Porte de saída 2 (16 bits)
  signal out_port_3  : std_logic_vector(15 downto 0);                    -- Porte de saída 3 (16 bits)
  signal out_port_4  : std_logic_vector(15 downto 0);                    -- Porte de saída 4 (16 bits)

  -- Aqui também foram inicializados também os valores dos portes de entrada (in_port).

  -- (Declaração da CPU) ------------------------------------------------------------------------------------------------

  component cpu is

    port(
      enable_clk  : in  std_logic;                                       -- Habilita pulsos de clock
      MR          : in  std_logic;                                       -- Master-Reset (ativo em LOW)
      in_port_1   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 1 (16 bits)
      in_port_2   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 2 (16 bits)
      in_port_3   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 3 (16 bits)
      in_port_4   : in  std_logic_vector(15 downto 0);                   -- Porte de entrada 4 (16 bits)
      out_port_1  : out std_logic_vector(15 downto 0);                   -- Porte de saída 1 (16 bits)
      out_port_2  : out std_logic_vector(15 downto 0);                   -- Porte de saída 2 (16 bits)
      out_port_3  : out std_logic_vector(15 downto 0);                   -- Porte de saída 3 (16 bits)
      out_port_4  : out std_logic_vector(15 downto 0)                    -- Porte de saída 4 (16 bits)
    );

  end component cpu;

begin

    -- (Instanciando o BIP e declarando as portas) ----------------------------------------------------------------------

    BIP: cpu 
      port map (
        enable_clk, 
        MR, in_port_1, 
        in_port_2, 
        in_port_3, 
        in_port_4, 
        out_port_1, 
        out_port_2, 
        out_port_3, 
        out_port_4
      );

    -- Inicializando in_ports -------------------------------------------------------------------------------------------

    in_port_1 <= x"0FFF";

    -- Testando o BIP (duração da execução de 200 ns) -------------------------------------------------------------------

    test: process
    begin

        MR <= '0';                                                       -- Reseta os componentes internos
        wait for 0.1 ns;                                                 
        MR <= '1';                                                       -- Desabilita o Master-Reset
        wait for 200 ns;                                                 -- Executa por 200 ns
        enable_clk <= '0';                                               -- Desabilita a exeução

        wait;                                                            -- Finaliza exeução do BIP

    end process test;

    -- OBS.: o código a ser testado é gravado na memória de programa,
    --       no arquivo: "src > components > memory > generic_rom.vhd"

end architecture teste;

-- ======================================================================================================================