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
    signal rst : std_logic;
    signal cursor_row : std_logic_vector (7 downto 0);
    signal cursor_col : std_logic_vector (7 downto 0);
    signal seg7_disp_value : std_logic_vector (31 downto 0);
    signal anode : std_logic_vector (7 downto 0);
begin

    -- We only show the lower 16 bits of the display controller for
    -- an XY format in hex.
    seg7_disp_value <= "0000000000000000" & cursor_col & cursor_row;

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

end Behavioral;
