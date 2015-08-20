library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;
 
entity FIFO is
    generic (
		WIDTH 		: integer := 8;  							-- FIFO word width
		ADD_WIDTH 	: integer := 8  							-- Address width
	);

    port (
		-- Write FIFO.
		Data_in : in std_logic_vector(WIDTH - 1 downto 0);  	-- Input data
		WE : in std_logic;  									-- Write Enable
		W_Clk : in std_logic;  									-- Write Clock
		Full : buffer std_logic;  								-- Full Flag
		
		-- Read FIFO.
		Data_out : out std_logic_vector(WIDTH - 1 downto 0);  	-- Out put data
		R_Clk : in std_logic;  									-- Read Clock
		RE : in std_logic;  									-- Read Enable
		Empty : buffer std_logic; 								-- Empty Flag
		
		-- Reset FIFO.
		Reset : in std_logic									-- System global Reset
	);  	
end FIFO;

architecture FIFO_v1 of FIFO is
-- constant values
	constant MAX_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '1');
	constant MIN_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := (others => '0');
--	-- constant HALF_ADDR:std_logic_vector(ADD_WIDTH -1 downto 0) := '0' & (MAX_ADDR'range => '1');
-- 
--	signal Data_in_del : std_logic_vector(WIDTH - 1 downto 0);  -- delayed Data in
 
    signal r_add   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal w_add   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Write Address
--	signal d_add   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Diff Address
 
    signal ren_int : std_logic;  		-- internal read enable
    signal wen_int : std_logic;  		-- internal write enable
 
	component dpmem
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
	end component;
begin  -- FIFO_v1
-------------------------------------------------------------------------------
	memcore: dpmem 
		generic map (
				DATA => 8,
				ADDR => 8)
		port map (
				w_clk => W_Clk,
				w_wr => wen_int,		-- temporary
				w_addr => w_add			-- temporary
				w_din => Data_in
				r_clk => R_Clk			
				r_re => ren_int,		-- temporary
				r_addr => r_add			-- temporary
				r_dout => Data_out
				reset => Reset
				);

	wen_int <= '1' when (WE = '1' and ( Full = '0')) else '0';
	ren_int <= '1' when (RE = '1' and ( Empty = '0')) else '0';
 
	Wadd_cnt:
		process(W_Clk) 
			variable q1 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
		begin  -- process Wadd_cnt
		   -- activities triggered by asynchronous reset (active low)
			if W_Clk'event and W_Clk = '1'  then
				if WE = '1' and ( Full = '0') then
					q1 := q1 + 1;
				 else
					q1 := q1;
				end if;
			end if;
			w_add  <= q1;
	   end process Wadd_cnt;
	   
	Radd_cnt:
		process(R_clk)
			variable q2 : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Counter state
		begin
			if R_clk'event and R_clk = '1'  then
	 
			if RE = '1' and ( Empty = '0') then
				q2 := q2 + 1;
			 else
				q2 := q2;
			end if;
			R_add  <= q2;
		end process Radd_cnt;

	FULL	<=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) = MAX_ADDR) else '0';
	Empty   <=  '1'when (D_ADD(ADD_WIDTH - 1 downto 0) =  MIN_ADDR) else '0';
	
end FIFO_v1;
 