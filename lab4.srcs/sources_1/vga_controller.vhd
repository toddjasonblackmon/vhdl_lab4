----------------------------------------------------------------------------------
--
-- Author: Todd Blackmon
--
-- Description:
-- VGA display controller
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utility.all;

entity vga_controller is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           pixel : in RGB4;
           row : out STD_LOGIC_VECTOR (8 downto 0);
           col : out STD_LOGIC_VECTOR (9 downto 0);
           RED : out STD_LOGIC_VECTOR (3 downto 0);
           BLU : out STD_LOGIC_VECTOR (3 downto 0);
           GRN : out STD_LOGIC_VECTOR (3 downto 0);
           VSYNC : out STD_LOGIC;
           HSYNC : out STD_LOGIC);
end vga_controller;

architecture Behavioral of vga_controller is

begin


end Behavioral;
