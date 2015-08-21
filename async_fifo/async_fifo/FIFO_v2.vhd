library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity FIFO is
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
end entity;

architecture rtl of FIFO is
    ----/Internal connections & variables------
    constant FIFO_DEPTH :integer := 2**ADDR_WIDTH;
    type RAM is array (integer range <>)of std_logic_vector (DATA_WIDTH-1 downto 0);
    signal Mem : RAM (0 to FIFO_DEPTH-1);
    
    signal pNextWordToWrite     :std_logic_vector (ADDR_WIDTH-1 downto 0);
    signal pNextWordToRead      :std_logic_vector (ADDR_WIDTH-1 downto 0);
    signal EqualAddresses       :std_logic;
    signal NextWriteAddressEn   :std_logic;
    signal NextReadAddressEn    :std_logic;
    signal Set_Status           :std_logic;
    signal Rst_Status           :std_logic;
    signal Status               :std_logic;
    signal PresetFull           :std_logic;
    signal PresetEmpty          :std_logic;
    signal empty,full           :std_logic;
    
    component GrayCounter is
		generic (
			COUNTER_WIDTH :integer := 4
		);
		port (
			GrayCount_out 	:out std_logic_vector (COUNTER_WIDTH-1 downto 0);
			Enable_in     	:in  std_logic;  --Count enable.
			Reset      		:in  std_logic;  --Count reset.
			clk_in          :in  std_logic
		);
    end component;
	
	component dpmem2clk is
		generic (
			ADDR_WIDTH        :     integer   := 4;  -- Address width
			DATA_WIDTH        :     integer   := 8  -- Word Width
		);

		port (
			Wclk              : in  std_logic;  -- write clock
			Wen               : in  std_logic;  -- Write Enable
			Wadd              : in  std_logic_vector(ADDR_WIDTH -1 downto 0);  -- Write Address
			Datain            : in  std_logic_vector(DATA_WIDTH -1 downto 0);  -- Input Data
			Rclk              : in  std_logic;  -- Read clock
			Ren               : in  std_logic;  -- Read Enable
			Radd              : in  std_logic_vector(ADDR_WIDTH -1 downto 0);  -- Read Address
			Dataout           : out std_logic_vector(DATA_WIDTH -1 downto 0);  -- Output data
			Reset			  : in  std_logic -- Reset input
		);
	end component;
	
begin

    --------------Code--------------
    --Data ports logic
	--------------------------------
	memcore : dpmem2clk 
	port map (
		Wclk => WClk_in,
		Wen => NextWriteAddressEn,
		Wadd => pNextWordToWrite,
		Datain => Data_in,
		Rclk => RClk_in,
		Ren => NextReadAddressEn,
		Radd => pNextWordToRead,
		Dataout => Data_out,
		Reset => Reset_in
	);
    -- FIFO addresses support logic: 
    --'Next Addresses' enable logic:
    NextWriteAddressEn <= WriteEn_in and (not full);
    NextReadAddressEn  <= ReadEn_in  and (not empty);
           
    --Address (Gray counters) logic:
    GrayCounter_pWr : GrayCounter
    port map (
        GrayCount_out => pNextWordToWrite,
        Enable_in     => NextWriteAddressEn,
        Reset   	  => Reset_in,
        clk_in	      => WClk_in
    );
       
    GrayCounter_pRd : GrayCounter
    port map (
        GrayCount_out => pNextWordToRead,
        Enable_in     => NextReadAddressEn,
        Reset      	  => Reset_in,
        clk_in        => RClk_in
    );

    --'EqualAddresses' logic:
    EqualAddresses <= '1' when (pNextWordToWrite = pNextWordToRead) else '0';

    --'Quadrant selectors' logic:
    process (pNextWordToWrite, pNextWordToRead)
        variable set_status_bit0 :std_logic;
        variable set_status_bit1 :std_logic;
        variable rst_status_bit0 :std_logic;
        variable rst_status_bit1 :std_logic;
    begin
        set_status_bit0 := pNextWordToWrite(ADDR_WIDTH-2) xnor pNextWordToRead(ADDR_WIDTH-1);
        set_status_bit1 := pNextWordToWrite(ADDR_WIDTH-1) xor  pNextWordToRead(ADDR_WIDTH-2);
        Set_Status <= set_status_bit0 and set_status_bit1;
        
        rst_status_bit0 := pNextWordToWrite(ADDR_WIDTH-2) xor  pNextWordToRead(ADDR_WIDTH-1);
        rst_status_bit1 := pNextWordToWrite(ADDR_WIDTH-1) xnor pNextWordToRead(ADDR_WIDTH-2);
        Rst_Status      <= rst_status_bit0 and rst_status_bit1;
    end process;
    
    --'Status' latch logic:
    process (Set_Status, Rst_Status, Reset_in) begin--D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status = '1' or Reset_in = '1') then
            Status <= '0';  --Going 'Empty'.
        elsif (Set_Status = '1') then
            Status <= '1';  --Going 'Full'.
        end if;
    end process;
    
    --'Full' logic for the writing port:
    PresetFull <= Status and EqualAddresses;  --'Full' FIFO.
    
    process (WClk_in, PresetFull) begin --D Flip-Flop w/ Asynchronous Pre-set.
        if (PresetFull = '1') then
            full <= '1';
        elsif (rising_edge(WClk_in)) then
            full <= '0';
        end if;
    end process;
    Full_out <= full;
    
    --'Empty' logic for the reading port:
    PresetEmpty <= not Status and EqualAddresses;  --'Empty' Fifo.
    
    process (RClk_in, PresetEmpty) begin --D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty = '1') then
            empty <= '1';
        elsif (rising_edge(RClk_in)) then
            empty <= '0';
        end if;
    end process;
    
    Empty_out <= Empty;
end architecture;