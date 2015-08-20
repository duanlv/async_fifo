library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dpmem is
	generic (
		DATA 		: integer := 8;
		ADDR 		: integer := 8
	);
	port (
		-- Writing port.
		w_clk   : in  std_logic;
		w_wr    : in  std_logic;
		w_addr  : in  std_logic_vector(ADDR-1 downto 0);
		w_din   : in  std_logic_vector(DATA-1 downto 0);

		-- Reading port.
		r_clk   : in  std_logic;
		r_re    : in  std_logic;
		r_addr  : in  std_logic_vector(ADDR-1 downto 0);
		r_dout  : out std_logic_vector(DATA-1 downto 0)
		
		-- Reset signal.
		reset	: in std_logic;
	);
end dpmem;

architecture dpmem_rtl_v1 of dpmem is
	type data_array is array (integer range <>) of std_logic_vector(DATA -1 downto 0);
    signal data : data_array(0 to (2** ADDR) );  -- local data.

	procedure init_mem(signal memory_cell : inout data_array ) is
	begin
		for i in 0 to (2** ADDR) loop
		  memory_cell(i) <= (others => '0');
		end loop;
	end init_mem;
begin
	-- Reset.
--	process(reset)	  
--	begin
--		if reset='0' then
--			init_mem (data);
--		end if;
--	end process;
	
	-- Writing port.
	process(w_clk)	  
	begin
		--if(w_clk'event and w_clk='1') then
		if(rising_edge(clk)) then
			if(w_wr='1') then
				mem(conv_integer(w_addr)) <= w_din;
			end if;
		end if;
	end process;
 
	-- Reading port.
	process(r_clk)
	begin
		--if(r_clk'event and r_clk='1') then
		if(rising_edge(clk)) then
			if(r_re='1') then
				r_dout <= mem(conv_integer(r_addr));
			else
				r_dout <= (OTHERS => '1');    -- Default value
			end if;
		end if;
	end process;
end dpmem_rtl_v1;

-- architecture dpmem_rtl_v2 of dpmem is
-- 
-- begin
-- --	    --Addreses (Gray counters) logic:
-- --    GrayCounter_pWr : GrayCounter
-- --    port map (
-- --        GrayCount_out => pNextWordToWrite,
-- --        Enable_in     => NextWriteAddressEn,
-- --        Clear_in      => Clear_in,
-- --        clk           => WClk
-- --    );
-- --       
-- --    GrayCounter_pRd : GrayCounter
-- --    port map (
-- --        GrayCount_out => pNextWordToRead,
-- --        Enable_in     => NextReadAddressEn,
-- --        Clear_in      => Clear_in,
-- --        clk           => RClk
-- --    );
-- --
-- end dpmem_rtl_v2;
