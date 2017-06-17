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
use ieee.std_logic_textio.all;

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
        variable pix_r_var, pix_g_var, pix_b_var : std_logic_vector (3 downto 0);
        variable RED_var, GRN_var, BLU_var : std_logic_vector (3 downto 0);
        variable HSYNC_var, VSYNC_var : std_logic;
        variable out_valid : std_logic;
        variable rst_var : std_logic;
        variable col_var, row_var : integer;
        constant dummy : bit := '1';
    begin
        while not endfile (data_fp) loop
            readline (data_fp, sample);
            read (sample, t);
            read (sample, rst_var);
            read (sample, pix_r_var);
            read (sample, pix_g_var);
            read (sample, pix_b_var);
            read (sample, out_valid);
            if (out_valid = '1') then
                read (sample, HSYNC_var);
                read (sample, VSYNC_var);
                read (sample, RED_var);
                read (sample, GRN_var);
                read (sample, BLU_var);
                read (sample, col_var);
                read (sample, row_var);
            end if;
            
            wait for t;
            
            -- Drive inputs
            rst <= rst_var;
            pix_r <= pix_r_var;
            pix_g <= pix_g_var;
            pix_b <= pix_b_var;
            
            if (out_valid = '1') then   
                assert HSYNC = HSYNC_var report "HSYNC output does not match" severity Error;
                assert HSYNC = HSYNC_var report "VSYNC output does not match" severity Error;         
                assert RED = RED_var report "Red output does not match" severity Error;
                assert GRN = GRN_var report "Green output does not match" severity Error;
                assert BLU = BLU_var report "Blue output does not match" severity Error;
                assert to_integer(unsigned(col)) = col_var report "column output does not match" severity Error;
                assert to_integer(unsigned(row)) = row_var report "row output does not match" severity Error;
            end if;
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
