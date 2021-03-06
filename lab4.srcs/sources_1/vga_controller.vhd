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
           pix_r : in std_logic_vector (3 downto 0);
           pix_g : in std_logic_vector (3 downto 0);
           pix_b : in std_logic_vector (3 downto 0);
           row : out STD_LOGIC_VECTOR (8 downto 0);
           col : out STD_LOGIC_VECTOR (9 downto 0);
           RED : out STD_LOGIC_VECTOR (3 downto 0);
           BLU : out STD_LOGIC_VECTOR (3 downto 0);
           GRN : out STD_LOGIC_VECTOR (3 downto 0);
           VSYNC : out STD_LOGIC;
           HSYNC : out STD_LOGIC);
end vga_controller;

architecture Behavioral of vga_controller is
    -- DIV 4 signals
    signal next_pixel : std_logic;
    signal div4 : unsigned (1 downto 0);
    
    -- Horizontal Sequencer
    signal disp_pixel : std_logic;  -- Next pixel is a display pixel.
    signal h_blank_count : unsigned (7 downto 0);
    signal h_blank_last, last_col : std_logic;
    signal i_col : unsigned (9 downto 0);       -- Internal version of col
    signal next_row : std_logic;                -- Pulses to increment rows.
    
    -- Horizontal Sequence Constants
    constant num_h_blank_pixels : unsigned (7 downto 0) := to_unsigned (160, 8);
    constant num_h_disp_pixels : unsigned (9 downto 0) := to_unsigned (640, 10);
    constant hsync_start : unsigned (7 downto 0) := to_unsigned(16, 8);
    constant hsync_stop : unsigned (7 downto 0) := to_unsigned(112, 8);

    -- Vertical Sequencer    
    signal disp_row : std_logic;    -- Next row has displayed pixels
    signal v_blank_count : unsigned (5 downto 0);
    signal v_blank_last, last_row : std_logic;
    signal i_row : unsigned (8 downto 0);       -- Internal version of row
 
    -- Vertical Sequence Constants
    constant num_v_blank_pixels : unsigned (5 downto 0) := to_unsigned (41, 6);
    constant num_v_disp_pixels : unsigned (8 downto 0) := to_unsigned (480, 9);
    constant vsync_start : unsigned (5 downto 0) := to_unsigned(10, 6);
    constant vsync_stop : unsigned (5 downto 0) := to_unsigned(12, 6);
 
begin

    -- DIV4
    process (clk, rst)
    begin
        if (rst = '1') then
            div4 <= "00";
        elsif (rising_edge(clk)) then
            div4 <= div4 + 1;
        end if;
    end process;

    -- Next_pixel is only high for the cycle where both are high.
    -- This will be one pulse in 4, so at a 25 MHz rate.    
    next_pixel <= div4(1) and div4(0);
  
    -- Horizontal Thresholds
    h_blank_last <= '1' when h_blank_count = (num_h_blank_pixels-1) else '0';
    last_col <= '1' when i_col = (num_h_disp_pixels-1) else '0';
 
    -- Horizontal Display Counters
    process (clk, rst)
    begin
        if (rst = '1') then
            h_blank_count <= (others => '0');
            i_col <= (others => '0');
            disp_pixel <= '0';                  -- We start on the front porch blanking period
            next_row <= '0';
        elsif (rising_edge(clk)) then
            next_row <= '0';    -- Default to no pulse.
            
            if (next_pixel = '1') then
                if (disp_pixel = '0') then                 -- Blanking Pixels
                    if (h_blank_last = '1') then
                        h_blank_count <= (others => '0');
                        disp_pixel <= '1';             -- Switch to displaying
                    else
                        h_blank_count <= h_blank_count + 1;
                    end if;
                else    -- Display Pixels
                    if (last_col = '1') then
                        i_col <= (others => '0');
                        disp_pixel <= '0';              -- Switch to blanking
                        next_row <= '1';
                    else
                        i_col <= i_col + 1;
                    end if;                    
                end if;
            end if;
        end if;
    end process;  
  
    -- Horizontal Thresholds
    v_blank_last <= '1' when v_blank_count = (num_v_blank_pixels-1) else '0';
    last_row <= '1' when i_row = (num_v_disp_pixels-1) else '0';
  
    -- Vertical Display Counters
    process (clk, rst)
    begin
        if (rst = '1') then
            v_blank_count <= (others => '0');
            i_row <= (others => '0');
            disp_row <= '0';                  -- We start on the front porch blanking period
        elsif (rising_edge(clk))then
            if (next_row = '1') then
                if (disp_row = '0') then                 -- Blanking Row
                    if (v_blank_last = '1') then
                        v_blank_count <= (others => '0');
                        disp_row <= '1';             -- Switch to displaying
                    else
                        v_blank_count <= v_blank_count + 1;
                    end if;
                else    -- Display Rows
                    if (last_row = '1') then
                        i_row <= (others => '0');
                        disp_row <= '0';              -- Switch to blanking
                    else
                        i_row <= i_row + 1;
                    end if;                    
                end if;
            end if;
        end if;
    end process;  
  
    -- HSYNC
    -- We trigger one before the start and stop count due to pipelining.
    process (clk, rst)
    begin
        if (rst = '1') then
            HSYNC <= '1';
        elsif (rising_edge(clk)) then
            if (next_pixel = '1') then
                if (h_blank_count = (hsync_start-1)) then
                    HSYNC <= '0';
                elsif (h_blank_count = (hsync_stop-1)) then
                    HSYNC <= '1';
                end if;
            end if;
        end if;
    end process;
  
    -- VSYNC
    -- We trigger one before the start and stop count due to pipelining.
    process (clk, rst)
    begin
        if (rst = '1') then
            VSYNC <= '1';
        elsif (rising_edge(clk)) then
            if (next_row = '1') then
                if (v_blank_count = (vsync_start-1)) then
                    VSYNC <= '0';
                elsif (v_blank_count = (vsync_stop-1)) then
                    VSYNC <= '1';
                end if;
            end if;
        end if;
    end process;
  
        
  
    RED <= pix_r when disp_pixel = '1' and disp_row = '1' else "0000";
    GRN <= pix_g when disp_pixel = '1' and disp_row = '1' else "0000";
    BLU <= pix_b when disp_pixel = '1' and disp_row = '1' else "0000";

    col <= std_logic_vector(i_col);
    row <= std_logic_vector(i_row);

end Behavioral;

-- Attempt the same as a FSM
architecture B2 of vga_controller is
    -- DIV 4 signals
    signal next_pixel : std_logic;
    signal div4 : unsigned (1 downto 0);
    
    -- Horizontal Sequencer
    type state_type is (FRONT_PORCH, SYNC, BACK_PORCH, DISPLAY);
    signal hstate, vstate : state_type;
    
    signal last_col : std_logic;
    signal i_col : unsigned (9 downto 0);       -- Internal version of col
    signal next_row : std_logic;                -- Pulses to increment rows.
    
    -- Horizontal Sequence Constants
    constant num_h_blank_pixels : unsigned (7 downto 0) := to_unsigned (160, 8);
    constant num_h_disp_pixels : unsigned (9 downto 0) := to_unsigned (640, 10);
    constant hsync_start : unsigned (7 downto 0) := to_unsigned(16, 8);
    constant hsync_stop : unsigned (7 downto 0) := to_unsigned(112, 8);
    
    -- Vertical Sequencer    
    signal last_row : std_logic;
    signal i_row : unsigned (8 downto 0);       -- Internal version of row
    
    -- Vertical Sequence Constants
    constant num_v_blank_pixels : unsigned (5 downto 0) := to_unsigned (41, 6);
    constant num_v_disp_pixels : unsigned (8 downto 0) := to_unsigned (480, 9);
    constant vsync_start : unsigned (5 downto 0) := to_unsigned(10, 6);
    constant vsync_stop : unsigned (5 downto 0) := to_unsigned(12, 6);

begin
    -- DIV4
    process (clk, rst)
    begin
        if (rst = '1') then
            div4 <= "00";
        elsif (rising_edge(clk)) then
            div4 <= div4 + 1;
        end if;
    end process;
    
    -- Next_pixel is only high for the cycle where both are high.
    -- This will be one pulse in 4, so at a 25 MHz rate.    
    next_pixel <= div4(1) and div4(0);
    
    -- Horizontal Thresholds
    last_col <= '1' when i_col = (num_h_disp_pixels-1) else '0';
    
    -- Horizontal Display Counters
    process (clk, rst)
    begin
        if (rst = '1') then
            i_col <= (others => '0');
            next_row <= '0';
            hstate <= FRONT_PORCH;
        elsif (rising_edge(clk)) then
            next_row <= '0';    -- Default to no pulse.
            
            if (next_pixel = '1') then
                i_col <= i_col + 1;

                case hstate is
                when FRONT_PORCH => 
                    if i_col = (hsync_start-1) then
                        hstate <= SYNC;
                    end if;
                when SYNC =>
                    if i_col = (hsync_stop-1) then
                        hstate <= BACK_PORCH;
                    end if;
                when BACK_PORCH => null;
                    if i_col = (num_h_blank_pixels-1) then
                        hstate <= DISPLAY;
                        i_col <= (others => '0');
                    end if;
                when DISPLAY => null;
                    if last_col = '1' then
                        i_col <= (others => '0');
                        hstate <= FRONT_PORCH;
                        next_row <= '1';
                    end if;
                end case;
                   
            end if;
        end if;
    end process;

    -- Vertical Thresholds
    last_row <= '1' when i_row = (num_v_disp_pixels-1) else '0';
    
    -- Vertical Display Counters
    process (clk, rst)
    begin
        if (rst = '1') then
            vstate <= FRONT_PORCH;
            i_row <= (others => '0');
        elsif (rising_edge(clk))then
            if (next_row = '1') then
                i_row <= i_row + 1;

                case vstate is
                when FRONT_PORCH => 
                    if i_row = (vsync_start-1) then
                        vstate <= SYNC;
                    end if;
                when SYNC =>
                    if i_row = (vsync_stop-1) then
                        vstate <= BACK_PORCH;
                    end if;
                when BACK_PORCH => null;
                    if i_row = (num_v_blank_pixels-1) then
                        vstate <= DISPLAY;
                        i_row <= (others => '0');
                    end if;
                when DISPLAY => null;
                    if last_row = '1' then
                        i_row <= (others => '0');
                        vstate <= FRONT_PORCH;
                    end if;
                end case;
                   
            end if;            
        end if;
    end process;  
        
    HSYNC <= '0' when hstate = SYNC else '1';
    VSYNC <= '0' when vstate = SYNC else '1';
    
    
    RED <= pix_r when hstate = DISPLAY and vstate = DISPLAY else "0000";
    GRN <= pix_g when hstate = DISPLAY and vstate = DISPLAY else "0000";
    BLU <= pix_b when hstate = DISPLAY and vstate = DISPLAY else "0000";
    
    col <= std_logic_vector(i_col) when hstate = DISPLAY else "0000000000";
    row <= std_logic_vector(i_row) when vstate = DISPLAY else "000000000";

end B2;

architecture MinFlops of vga_controller is

    -- DIV 4 signals
signal next_pixel : std_logic;
signal div4 : unsigned (1 downto 0);

-- Horizontal Sequencer
signal last_col : std_logic;
signal hdisplay : std_logic;
signal next_row : std_logic;                -- Pulses to increment rows.

signal i_col : unsigned (9 downto 0);       -- Internal version of col

-- Horizontal Sequence Constants
--   0 - 639 is display pixels
-- 640 - 655 is front porch
-- 656 - 751 is sync
-- 752 - 799 is back porch (and rollover) 
constant num_h_disp_pixels : unsigned (9 downto 0) := to_unsigned (640, 10);
constant num_h_total_pixels : unsigned (9 downto 0) := to_unsigned (800, 10);
constant hsync_start : unsigned (9 downto 0) := to_unsigned(656, 10);
constant hsync_stop : unsigned (9 downto 0) := to_unsigned(751, 10);

-- Vertical Sequencer    
signal last_row : std_logic;
signal vdisplay : std_logic;

signal i_row : unsigned (9 downto 0);       -- Internal version of row

-- Vertical Sequence Constants
--    0 - 479 is display rows
--  480 - 489 is front porch
--  490 - 491 is sync
--  492 - 520 is back porch
constant num_v_disp_pixels : unsigned (9 downto 0) := to_unsigned (480, 10);
constant num_v_total_pixels : unsigned (9 downto 0) := to_unsigned (521, 10);
constant vsync_start : unsigned (9 downto 0) := to_unsigned(490, 10);
constant vsync_stop : unsigned (9 downto 0) := to_unsigned(491, 10);

begin
-- DIV4
process (clk, rst)
begin
    if (rst = '1') then
        div4 <= "00";
    elsif (rising_edge(clk)) then
        div4 <= div4 + 1;
    end if;
end process;

-- Next_pixel is only high for the cycle where both are high.
-- This will be one pulse in 4, so at a 25 MHz rate.    
next_pixel <= div4(1) and div4(0);

-- Horizontal Thresholds
hdisplay <= '1' when i_col < num_h_disp_pixels else '0';
last_col <= '1' when i_col = (num_h_total_pixels-1) else '0';

-- Horizontal Display Counters
process (clk, rst)
begin
    if (rst = '1') then
        i_col <= num_h_disp_pixels; -- Start counter at front porch
    elsif (rising_edge(clk)) then
        if next_pixel = '1' then
            if last_col = '1' then
                i_col <= (others => '0');
            else
                i_col <= i_col + 1;
            end if;
            
        end if;
    end if;
end process;

next_row <= '1' when i_col = (num_h_disp_pixels-1) and next_pixel = '1' else '0';
    
-- Vertical Thresholds
vdisplay <= '1' when i_row < num_v_disp_pixels else '0';
last_row <= '1' when i_row = (num_v_total_pixels-1) else '0';

-- Veritcal Display Counter
process (clk, rst)
begin
    if (rst = '1') then
        i_row <= num_v_disp_pixels; -- Start counter at front porch
    elsif (rising_edge(clk)) then
        if next_row = '1' then
            if last_row = '1' then
                i_row <= (others => '0');
            else
                i_row <= i_row + 1;
            end if;
        end if;
    end if;
end process;

HSYNC <= '0' when i_col >= hsync_start and i_col <= hsync_stop else '1';
VSYNC <= '0' when i_row >= vsync_start and i_row <= vsync_stop else '1';


RED <= pix_r when hdisplay = '1' and vdisplay = '1' else "0000";
GRN <= pix_g when hdisplay = '1' and vdisplay = '1' else "0000";
BLU <= pix_b when hdisplay = '1' and vdisplay = '1' else "0000";

col <= std_logic_vector(i_col) when hdisplay = '1' else "0000000000";
row <= std_logic_vector(i_row(8 downto 0)) when vdisplay = '1' else "000000000";

end MinFlops;
