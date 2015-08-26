library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity counter_8bit is
    generic (
        COUNTER_WIDTH :integer := 8
    );
    port(
        Clk            : in STD_LOGIC;
        Enable         : in  std_logic;
        Clear          : in STD_LOGIC;
        Dout           : out STD_LOGIC_VECTOR(COUNTER_WIDTH - 1 downto 0)
    );
end counter_8bit;

architecture counter_8bit_arch of counter_8bit is
begin
    counting : process (Clk,Clear) is
    variable m : std_logic_vector (COUNTER_WIDTH-1 downto 0) := "0000";
    begin
        if (Clear='0') then
            m := (others =>''0');
        elsif (rising_edge (Clk)) then
            if (Enable='1') then
                m := m + 1;
            end if;
        end if;
        Dout <= m;
    end process counting;
end counter_8bit_arch;