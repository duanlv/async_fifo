library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 

-------------------------------------------------------------------------------
-- Asynchronous Dual Port Memory
-------------------------------------------------------------------------------
entity dpmem2clk is
  
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
end dpmem2clk; 

architecture dpmem_arch of dpmem2clk is

  type DATA_ARRAY is array (integer range <>) of std_logic_vector(DATA_WIDTH -1 downto 0);  	-- Memory Type
  signal   data       :     DATA_ARRAY(0 to (2**ADDR_WIDTH) -1);  						-- Local data
  constant IDELOUTPUT :     std_logic := 'Z';  											-- IDEL state output
  
	procedure init_mem(signal memory_cell : inout DATA_ARRAY ) is
	begin
		for i in 0 to (2** ADDR_WIDTH) loop
		  memory_cell(i) <= (others => '0');
		end loop;
	end init_mem;
	
begin  -- dpmem_arch
  
  -- purpose: Read process
  -- type   : sequential
  -- inputs : Rclk
  -- outputs: 
  RdProc              :     process (Rclk, Ren, Reset)
  begin  -- process ReProc
	if Reset = '0' then
		Dataout                       <= (others => IDELOUTPUT); 
		init_mem (data);
    elsif Rclk'event and Rclk = '1' then   -- rising clock edge

      if Ren = '1' then
        Dataout                       <= data(conv_integer(Radd)); 
      else
        Dataout                       <= (others => IDELOUTPUT); 
      end if; 
      
    end if; 
  end process ReProc; 
  
  -- purpose: Write process
  -- type   : sequential
  -- inputs : Wclk
  -- outputs: 
  WrProc              :     process (Wclk, Wen, Reset)
  begin  -- process WrProc
    
    if Wclk'event and Wclk = '1' then   -- rising clock edge
      if Wen = '1' then
        data(conv_integer(Wadd))      <= Datain; 
      end if; 
    end if; 
  end process WrProc; 
  
end dpmem_arch; 

