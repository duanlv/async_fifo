library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ASYNC_FIFO_TB is
end entity ASYNC_FIFO_TB;
    
architecture RTL of ASYNC_FIFO_TB is
  component ASYNC_FIFO is
    generic (
        DATA_WIDTH :integer := 8;
        ADDR_WIDTH :integer := 4
    );
    port (
        -- Reading port.
        Data_out     		: out std_logic_vector (DATA_WIDTH-1 downto 0);
        Empty_out   		: out std_logic;
        ReadEn_in   		: in  std_logic;
        RClk_in		        : in  std_logic;
        -- Writing port.
        Data_in      		: in  std_logic_vector (DATA_WIDTH-1 downto 0);
        Full_out    		: out std_logic;
        WriteEn_in  		: in  std_logic;
        WClk_in		        : in  std_logic;
		-- Reset
        Reset_in	       	: in  std_logic
    );
  end component ASYNC_FIFO;

  CONSTANT DAT_WIDTH        	: INTEGER   := 8;
  CONSTANT ADD_WIDTH        	: INTEGER   := 4;
  
  signal MASTER_RST     : std_logic   := '1';

  signal WR_CLK         : std_logic   := '0';
  signal WR_EN          : std_logic   := '0';
  signal DATA_IN        : std_logic_vector(DAT_WIDTH - 1 downto 0);

  signal RD_CLK         : std_logic   := '0';
  signal RD_EN          : std_logic   := '0';
  signal DATA_OUT       : std_logic_vector(DAT_WIDTH-1 downto 0);

  signal FULL           : std_logic   := '0';
  signal EMPTY          : std_logic   := '1';
--  signal DATA_OUT_COUNT : std_logic_vector(DATA_WIDTH-1 downto 0);

begin
  ASYNC_FIFO_INST_1 : ASYNC_FIFO generic map (
		DATA_WIDTH => DAT_WIDTH,
		ADDR_WIDTH => ADD_WIDTH
    	)
	port map(	
	-- Reading port.
        Data_out       		=> DATA_OUT,
        Empty_out          	=> EMPTY,
        ReadEn_in          	=> RD_EN,
        RClk_in         	=> RD_CLK,
        -- Writing port.
        Data_in        		=> DATA_IN,
        Full_out           	=> FULL,
        WriteEn_in          	=> WR_EN,
        WClk_in         	=> WR_CLK,
		-- Reset
        Reset_in 		=> MASTER_RST
		
    );

  process
  begin
	  while True loop
		  WR_CLK <= '0';
		  wait for 5 ns;
		  WR_CLK <= '1';
		  wait for 5 ns;
	  end loop;
	  wait;
  end process;

  process
  begin
	  while True loop
		  RD_CLK <= '0';
		  wait for 5 ns;
		  RD_CLK <= '1';
		  wait for 5 ns;
	  end loop;
	  wait;
  end process;

  process
  begin
	  MASTER_RST <= '1';
    wait for 100 ns;
    MASTER_RST <= '0';
	  wait for 10 ns;
    MASTER_RST <= '1';
    wait for 100 ns;
	  wait;
  end process;

  process
  begin
	  wait for 200 ns;
	  -- assert EMPTY = '1' report "Fail should be empty";
	  wait until rising_edge(WR_CLK);
    Data_in <= "01111111";
    WR_EN <= '1';
    wait until rising_edge(WR_CLK);
    WR_EN <= '0';
    wait until rising_edge(WR_CLK);
    Data_in <= "00001111";
    WR_EN <= '1';
    wait until rising_edge(WR_CLK);
    WR_EN <= '0';
	  wait until rising_edge(WR_CLK);
	  wait until rising_edge(WR_CLK);

	  wait until rising_edge(WR_CLK);
	  wait until rising_edge(WR_CLK);
    Data_in <= "11110000";
    WR_EN <= '1';
    wait until rising_edge(WR_CLK);
    WR_EN <= '0';
	  wait until rising_edge(WR_CLK);
	  assert EMPTY = '0' report "Fail should not be empty";
	  -- assert DATA_OUT_COUNT = "000000000001" report "Fail should not be empty";
	  wait;
  end process;

  process
  begin
    Data_out <= "00000000";
    wait for 300 ns;
    -- assert EMPTY = '1' report "Fail should be empty";
    wait until rising_edge(RD_CLK);
    RD_EN <= '1';
    wait until rising_edge(RD_CLK);
    wait until rising_edge(RD_CLK);
    RD_EN <= '0';
    wait until rising_edge(RD_CLK);
    wait until rising_edge(RD_CLK);
    RD_EN <= '1';
    wait until rising_edge(RD_CLK);
    
    wait until rising_edge(RD_CLK);
    wait until rising_edge(RD_CLK);
    wait until rising_edge(RD_CLK);
    --assert EMPTY = '0' report "Fail should not be empty";
    ---- assert DATA_OUT_COUNT = "000000000001" report "Fail should not be empty";
    --wait;
  end process;

end RTL;
