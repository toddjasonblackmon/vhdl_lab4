----------------------------------------------------------------------------------
--
-- Author: Todd Blackmon
--
-- Description:
-- This entity handles adjustment of the cursor position due to button presses.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cursor_adjust is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           up : in STD_LOGIC;
           down : in STD_LOGIC;
           left : in STD_LOGIC;
           right : in STD_LOGIC;
           col : out STD_LOGIC_VECTOR (4 downto 0);
           row : out STD_LOGIC_VECTOR (3 downto 0));
end cursor_adjust;

architecture Behavioral of cursor_adjust is
    -- Limits of the edge of the screen.
    constant max_row : unsigned (3 downto 0) := "1110";  -- 0x0E
    constant max_col : unsigned (4 downto 0) := "10011"; -- 0x13
    -- Internal state of the row and col
    signal i_row : unsigned (3 downto 0);
    signal i_col : unsigned (4 downto 0);
    
begin
    process (clk, rst)
    begin
        if (rst = '1') then
            i_col <= (others => '0');
            i_row <= (others => '0');
        elsif (rising_edge(clk)) then
            if (up = '1') then
                if (i_row = "0000") then
                    i_row <= max_row;
                else
                    i_row <= i_row - 1;
                end if;
            end if;
            
            if (down = '1') then
                if (i_row = max_row) then
                    i_row <= (others => '0');
                else
                    i_row <= i_row + 1;
                end if;
            end if;
            
            if (left = '1') then
                if (i_col = "00000") then
                    i_col <= max_col;                    
                else
                    i_col <= i_col - 1;
                end if;
            end if;
            
            if (right = '1') then
                if (i_col = max_col) then
                    i_col <= (others => '0');
                else
                    i_col <= i_col + 1;
                end if;
            end if;
        end if;
           
    end process;

    col <= std_logic_vector(i_col);
    row <= std_logic_vector(i_row);

end Behavioral;
