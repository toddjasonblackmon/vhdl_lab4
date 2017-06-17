----------------------------------------------------------------------------------
--
-- Author: Todd Blackmon
--
-- Description:
-- Lab 4 top level displays a green & blue checkerboard pattern using VGA while
-- adding a movable red cursor block. The 7 segment controller provides another
-- view of the location of the cursor.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utility.all;
use work.all;

entity lab4_top is
    generic (debounce_limit: natural := 5000000);
    Port ( CLK100MHZ : in STD_LOGIC;
           SW : in STD_LOGIC;
           BTNU : in STD_LOGIC;
           BTNL : in STD_LOGIC;
           BTND : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           VGA_R : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_HS : out STD_LOGIC;
           VGA_VS : out STD_LOGIC;
           AN : out STD_LOGIC_VECTOR (7 downto 0);
           SEG7_CATH : out STD_LOGIC_VECTOR (7 downto 0));
end lab4_top;

architecture Behavioral of lab4_top is
    signal clk : std_logic;
    signal rst : std_logic;
    signal cursor_row : std_logic_vector (3 downto 0);
    signal cursor_col : std_logic_vector (4 downto 0);
    signal seg7_disp_value : std_logic_vector (31 downto 0);
    signal anode : std_logic_vector (7 downto 0);
    signal up, down, left, right : std_logic;
    signal rst_s1 : std_logic;
    
    signal pix_r, pix_g, pix_b : std_logic_vector (3 downto 0);
    signal row : std_logic_vector (8 downto 0);
    signal col : std_logic_vector (9 downto 0);
begin
    -- Internal signal rename
    clk <= CLK100MHZ;

    -- Async enable reset, synchronous disable
    -- Purpose is to ensure that all flops come out 
    -- of reset on same clock.
    process (clk, SW)
    begin
        if (SW = '1') then
            rst_s1 <= '1';
            rst <= '1';
        elsif (rising_edge(clk)) then
            rst_s1 <= '0';
            rst <= rst_s1;
        end if;
    end process; 

    -- Button debounce
    dbnc_u : entity debounce
        generic map (debounce_limit => debounce_limit) 
        port map (clk => clk, rst => rst, btn => BTNU, pulse => up);
        
    dbnc_d : entity debounce
        generic map (debounce_limit => debounce_limit)
        port map (clk => clk, rst => rst, btn => BTND, pulse => down);
        
    dbnc_l : entity debounce
        generic map (debounce_limit => debounce_limit)
        port map (clk => clk, rst => rst, btn => BTNL, pulse => left);
        
    dbnc_r : entity debounce
        generic map (debounce_limit => debounce_limit) 
        port map (clk => clk, rst => rst, btn => BTNR, pulse => right);

    -- This block handles cursor location adjustment
    c_adj : entity cursor_adjust port map (
        clk => clk,
        rst => rst,
        up => up,
        down => down,
        left => left,
        right => right,
        col => cursor_col,
        row => cursor_row
    );

    -- The seg7_disp_value upper bits are unused.
    -- The third byte is the cursor column.
    -- The last byte is the cursor row.
    seg7_disp_value(31 downto 16) <= X"0000";
    seg7_disp_value(15 downto 8) <= "000" & std_logic_vector(cursor_col);
    seg7_disp_value(7 downto 0) <= "0000" & std_logic_vector(cursor_row);

    -- The 7 segment controller displays the cursor position
    s7_ctrl : entity seg7_controller port map (
        clk => CLK100MHZ,
        rst => rst,
        display_value => seg7_disp_value, 
        an => anode,
        cath => SEG7_CATH
    );

    -- Force the upper 4 anode lines to be alway inactive high
    AN <= "1111" & anode(3 downto 0);

    -- Pixel generator
    process (row, col, cursor_col, cursor_row)
    begin
        pix_r <= "0000";
        pix_g <= "0000";
        pix_b <= "0000";
    
        -- The cursor is given priority
        -- The cursor position is in grid units, so some slicing is needed.
        if ((row(8 downto 5) = cursor_row) and 
            (col(9 downto 5) = cursor_col)) then
            pix_r <= "1111";
            
        -- Otherwise do a 32-pixel green-blue checkerboard pattern.            
        elsif ((row(5) xor col(5)) = '1') then
            pix_b <= "1111";
        else
            pix_g <= "1111";
        end if;
    end process;

    -- VGA controller
    vga : entity vga_controller port map (
        clk => CLK100MHZ,
        rst => rst,
        pix_r => pix_r, pix_g => pix_g, pix_b => pix_b,
        row => row, col => col,
        RED => VGA_R, GRN => VGA_G, BLU => VGA_B,
        VSYNC => VGA_VS, HSYNC => VGA_HS);

end Behavioral;
