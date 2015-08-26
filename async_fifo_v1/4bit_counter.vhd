library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity counter_4bit is
    generic (
        COUNTER_WIDTH :integer := 4
    );
    port(
        Clk            : in STD_LOGIC;
        Enable         : in  std_logic;
        Clear          : in STD_LOGIC;
        Dout           : out STD_LOGIC_VECTOR(COUNTER_WIDTH - 1 downto 0)
    );
end counter_4bit;

architecture counter_4bit_arch of counter_4bit is
begin
    counting : process (Clk,Clear) is
    variable m : std_logic_vector (COUNTER_WIDTH-1 downto 0) := "0000";
    begin
        if (Clear='0') then
            m := "0000";
        elsif (rising_edge (Clk)) then
            if (Enable='1') then
                m := m + 1;
            end if;
        end if;
        Dout <= m;
    end process counting;
end counter_4bit_arch;