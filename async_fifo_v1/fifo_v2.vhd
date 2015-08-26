library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ASYNC_FIFO is
    generic (
        DATA_WIDTH :integer := 8;
        ADDR_WIDTH :integer := 4
    );
    port (
        -- Reading port.
        Data_out                : out std_logic_vector (DATA_WIDTH-1 downto 0);
        Empty_out               : out std_logic;
        ReadEn_in               : in  std_logic;
        RClk_in                 : in  std_logic;
        -- Writing port.
        Data_in                 : in  std_logic_vector (DATA_WIDTH-1 downto 0);
        Full_out                : out std_logic;
        WriteEn_in              : in  std_logic;
        WClk_in                 : in  std_logic;
        -- Reset
        Reset_in                : in  std_logic
    );
end entity;

architecture rtl of ASYNC_FIFO is
    ----/Internal connections & variables------
    constant FIFO_DEPTH :integer := 2**ADDR_WIDTH;
    type RAM is array (integer range <>)of std_logic_vector (DATA_WIDTH-1 downto 0);
    signal Mem : RAM (0 to FIFO_DEPTH-1);
    
    signal pNextWordToWrite     :std_logic_vector (ADDR_WIDTH-1 downto 0);
    signal pNextWordToRead      :std_logic_vector (ADDR_WIDTH-1 downto 0);
    -- signal EqualAddresses       :std_logic;
    signal NextWriteAddressEn   :std_logic      := '0';
    signal NextReadAddressEn    :std_logic      := '0';
    -- signal Set_Status           :std_logic;
    -- signal Rst_Status           :std_logic;
    -- signal Status               :std_logic;
    -- signal PresetFull           :std_logic;
    -- signal PresetEmpty          :std_logic;
    signal empty                :std_logic;
    signal full                 :std_logic;
    
    component counter_4bit is
        generic (
            COUNTER_WIDTH :integer := 4
        );
        port(
            Clk            : in STD_LOGIC;
            Enable      : in  std_logic;
            Clear          : in STD_LOGIC;
            Dout           : out STD_LOGIC_VECTOR(COUNTER_WIDTH - 1 downto 0)
        );
    end component;
    
    component dpmem2clk is
        generic (
            DATA_WIDTH        :     integer   := 8;  -- Word Width
            ADDR_WIDTH        :     integer   := 4  -- Address width
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
            Reset              : in  std_logic -- Reset input
        );
    end component;
    
begin
    --------------Code--------------
    -- Data ports logic
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
    -- 'Next Addresses' enable logic:
    --NextWriteAddressEn <= WriteEn_in and (not full);
    --NextReadAddressEn  <= ReadEn_in  and (not empty);
           
    PROCESS( WriteEn_in , full )
    BEGIN
        IF ( full  = '1')  THEN
           NextWriteAddressEn <='0' ;
        elsif ( WriteEn_in = '1' ) THEN 
           NextWriteAddressEn <= '1' ; 
        END IF;
    END PROCESS;     
           
    PROCESS( ReadEn_in , empty )
    BEGIN
        IF ( empty  = '1')  THEN
           NextReadAddressEn <='0' ;
        elsif ( ReadEn_in = '1' ) THEN 
           NextReadAddressEn <= '1' ; 
        END IF;
    END PROCESS; 
    
    -- Address (4bit counters) logic:
    Counter_pWr : counter_4bit
    port map (
        Clk           => WClk_in,
        Enable        => NextWriteAddressEn,
        Clear         => Reset_in,
        Dout          => pNextWordToWrite
    );
       
    Counter_pRd : counter_4bit
    port map (
        Clk           => RClk_in,
        Enable        => NextReadAddressEn,
        Clear         => Reset_in,
        Dout          => pNextWordToRead
    );

    --'EqualAddresses' logic:
    -- EqualAddresses <= '1' when (pNextWordToWrite = pNextWordToRead) else '0';  
    
    -- Full
    FullProc : process (WClk_in)
    begin
        if(WClk_in'event and WClk_in='1') then
            if(pNextWordToRead = pNextWordToWrite) then
                full <= '1';
            else    
                full <= '0';
            end if;
        end if;
    end process FullProc;

    -- Empty
    EmptyProc : process (RClk_in)
    begin
        if(RClk_in'event and RClk_in='1') then
            if(pNextWordToWrite = pNextWordToRead) then
                Empty <= '1';
            else    
                Empty <= '0';
            end if;
        end if;
    end process EmptyProc;
    
    -- Bypass
    BypassProc : process (Data_in, WriteEn_in, ReadEn_in, Empty)
    begin
        if(Reset_in='1') then
            if(ReadEn_in='1' and WriteEn_in='1') then
                if Empty = '1' then
                    Data_out <= Data_in;
                end if;
            end if;
        end if;
    end process BypassProc;

end architecture;
