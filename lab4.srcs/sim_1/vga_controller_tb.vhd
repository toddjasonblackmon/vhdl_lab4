----------------------------------------------------------------------------------
--
-- Author: Todd Blackmon
--
-- Description:
-- Testbench module for the vga_controller module.
--
----------------------------------------------------------------------------------


library IEEE;
library utility;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.all;
use work.utility.all;
use std.textio.all;

entity vga_controller_tb is
end vga_controller_tb;

architecture testbench of vga_controller_tb is

    signal clk : STD_LOGIC;
    signal rst : STD_LOGIC;
    signal pix_r : std_logic_vector (3 downto 0);
    signal pix_g : std_logic_vector (3 downto 0);
    signal pix_b : std_logic_vector (3 downto 0);
    signal row : STD_LOGIC_VECTOR (8 downto 0);
    signal col : STD_LOGIC_VECTOR (9 downto 0);
    signal RED : STD_LOGIC_VECTOR (3 downto 0);
    signal BLU : STD_LOGIC_VECTOR (3 downto 0);
    signal GRN : STD_LOGIC_VECTOR (3 downto 0);
    signal VSYNC : STD_LOGIC;
    signal HSYNC : STD_LOGIC;
    
    signal sim_run : STD_LOGIC := '1';
begin

    process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        
        if (sim_run = '0') then
            wait;
        end if;
        
    end process;

    process
        file data_fp : text open read_mode is "vga_tb.dat";
        file file_RESULTS : text; 
        variable sample : line;
        variable t : time;
        variable pix_r_var, pix_g_var, pix_b_var : bit_vector (3 downto 0);
        constant dummy : bit := '1';
    begin
        while not endfile (data_fp) loop
            readline (data_fp, sample);
            read (sample, t);
            read (sample, pix_r_var);
            read (sample, pix_g_var);
            read (sample, pix_b_var);
            
            wait for t;
            pix_r <= to_stdlogicvector(pix_r_var);
            pix_g <= to_stdlogicvector(pix_g_var);
            pix_b <= to_stdlogicvector(pix_b_var);
            wait for 10 ns;
        end loop;
        sim_run <= '0';
        report "Simulation successful"; 
        wait;
   end process;
    
    CUT: entity vga_controller
        port map (clk, rst, pix_r, pix_g, pix_b,
                  row, col, RED, BLU, GRN, 
                  VSYNC, HSYNC);

end testbench;
