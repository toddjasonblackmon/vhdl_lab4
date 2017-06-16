----------------------------------------------------------------------------------
--
-- Author: Todd Blackmon
--
-- Description:
-- Button debounce module
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    generic (debounce_limit: natural := 10000000);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           btn : in STD_LOGIC;
           pulse : out STD_LOGIC);
end debounce;

architecture Behavioral of debounce is
    signal debounce_count : unsigned (23 downto 0);
    signal btn_cur : std_logic;
    signal btn_s, btn_s2 : std_logic;
    signal btn_diff : std_logic;
begin

    -- Double flop for asynchronous input
    -- No need for reset.
    process (clk)
    begin
        if (rising_edge (clk)) then
            btn_s <= btn;
            btn_s2 <= btn_s;
        end if;
    end process;
    
    -- Is the sensed state different from the current state?
    btn_diff <= btn_s2 xor btn_cur;

    process (clk, rst)
    begin
        if (rst = '1') then
            pulse <= '0';
            btn_cur <= '0';
            debounce_count <= (others => '0');
        elsif (rising_edge(clk)) then
            pulse <= '0';   -- Always default to no pulse.
        
            -- If the value is different from current
            if (btn_diff = '1') then
                -- If we hit the limit, change the state.
                if (debounce_count = debounce_limit) then
                    pulse <= btn_s2;    -- Only actually pulses on press.
                    btn_cur <= btn_s2;  -- Change state
                    debounce_count <= (others => '0');
                else
                    debounce_count <= debounce_count + 1;
                end if;
            else -- The button is different from current, reset timer.
                debounce_count <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;
