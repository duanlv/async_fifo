library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo is
generic (RAMsize: integer :=4);
port (  data_in: in std_logic_vector (7 downto 0);  
    clk,nrst: in std_logic;
    readReq: in std_logic;  
        writeReq: in std_logic; 
        data_out: out std_logic_vector(7 downto 0); 
        empty: out std_logic;  
        full: out std_logic;
    error: out std_logic);
end fifo;

architecture Behavioral of fifo is
type memory_type is array (0 to RAMsize-1) of std_logic_vector(7 downto 0);
signal memory : memory_type :=(others => (others => '0')); 

begin
  process(clk,nrst)
  variable read_ptr, write_ptr : std_logic_vector(7 downto 0) :="00000000";  -- read and write pointers
  variable isempty , isfull : std_logic :='0';
  begin
  if nrst='0' then
    memory <= (others => (others => '0'));
    empty <='1';
    full <='0';
    data_out <= "00000000";
    read_ptr := "00000000";
    write_ptr := "00000000";
    isempty :='1';
    isfull :='0';
    error <='0';
  elsif clk'event and clk='1' then
    if readReq='0' and writeReq='0' then
      error <='0';
    end if;
    if readReq='1' then
      if isempty='1' then
        error <= '1';
      else
        data_out <= memory(conv_integer(read_ptr));
        isfull :='0';
        full <='0';
        error <='0';
        if read_ptr=conv_std_logic_vector(RAMsize-1,8) then
          read_ptr := "00000000";
        else
          read_ptr := read_ptr + '1';
        end if;
        if read_ptr=write_ptr then
          isempty:='1';
          empty <='1';
        end if;
      end if;
    end if;
    if writeReq='1' then
      if isfull='1' then
        error <='1';
      else
        memory(conv_integer(write_ptr)) <= data_in;
        error <='0';
        isempty :='0';
        empty <='0';
        if write_ptr=conv_std_logic_vector(RAMsize-1,8) then
          write_ptr := "00000000";
        else
          write_ptr := write_ptr + '1';
        end if;
        if write_ptr=read_ptr then
          isfull :='1';
          full <='1';
        end if;
      end if;
    end if;
  end if;
  end process;

end Behavioral;





------ test bench:



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo_tb is end fifo_tb;
architecture fifo_tb of fifo_tb is
component fifo is
generic (RAMsize: integer );
port (  data_in: in std_logic_vector (7 downto 0);  
    clk,nrst: in std_logic;
    readReq: in std_logic;  
        writeReq: in std_logic; 
        data_out: out std_logic_vector(7 downto 0); 
        empty: out std_logic;  
        full: out std_logic;
    error: out std_logic);
end component;
signal data_in_t:  std_logic_vector (7 downto 0);  
signal clk_t,nrst_t: std_logic :='0';
signal readReq_t: std_logic;  
signal writeReq_t: std_logic; 
signal data_out_t: std_logic_vector(7 downto 0); 
signal empty_t: std_logic;  
signal full_t: std_logic;
signal error_t: std_logic;

begin
  u1: fifo generic map (4) port map (data_in_t,clk_t,nrst_t,readReq_t,writeReq_t,data_out_t,empty_t,full_t,error_t);
  nrst_t <= '0' , '1' after 15 ns;
  clk_t <= not clk_t after 2 ns;
  readReq_t <= '1' after 21 ns , '0' after 23 ns, '1' after 41 ns, '0' after 45 ns , '1' after 53 ns;
  writeReq_t <= '1' after 28 ns, '0' after 31 ns , '1' after 33 ns , '0' after 35 ns, '1' after 37 ns, '1' after 45 ns, '0' after 47 ns , '1' after 49 ns, '0' after 51 ns;
  data_in_t <= "11111111" after 29 ns, "11111110" after 33 ns , "11111100" after 37 ns, "11111000" after 45 ns, "11110000" after 49 ns;

end fifo_tb;