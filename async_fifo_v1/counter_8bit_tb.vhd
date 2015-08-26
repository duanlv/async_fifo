LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity counter_8bit_tb is
end entity counter_8bit_tb;

ARCHITECTURE behavior OF counter_8bit_tb IS 
   --Inputs
   signal RST_I : std_logic := '0';
   signal CLK_I : std_logic := '0';
   signal EN_I : std_logic := '0';
    --Outputs
   signal DAT_O : STD_LOGIC_VECTOR(3 downto 0);
   -- Clock period definitions
   constant CLK_I_period : time := 2 ns;

   component counter_8bit is
    generic (
        COUNTER_WIDTH :integer := 8
    );
    port(
        Clk            : in STD_LOGIC;
        Enable         : in  std_logic;
        Clear          : in STD_LOGIC;
        Dout           : out STD_LOGIC_VECTOR(COUNTER_WIDTH - 1 downto 0)
    );
   end component counter_8bit;
BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: counter_8bit PORT MAP (
          Clk => CLK_I,
          Enable => EN_I,
          Clear => RST_I,
          Dout => DAT_O
        );

   -- Clock process definitions
   CLK_I_process :process
   begin
        CLK_I <= '1';
        wait for CLK_I_period/2;
        CLK_I <= '0';
        wait for CLK_I_period/2;
   end process;

   EN_I_proc : process
   begin
    EN_I <= '0';
    wait for 1 ns;
    EN_I <= '1';
    wait for 2 ns;
   end process;

   -- Stimulus process
   stim_proc: process
   begin        
        RST_I <= '1';
        wait for 10 ns;    
        RST_I <= '0';
        wait for 2 ns;  
        RST_I <= '1';
        wait for 8 ns;  
        RST_I <= '0';
        wait;
   end process;

END behavior;
