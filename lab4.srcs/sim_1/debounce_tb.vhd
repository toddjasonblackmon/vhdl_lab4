----------------------------------------------------------------------------------
--
-- Author: Todd Blackmon
--
-- Description:
-- Basic testbench to check the debounce circuit.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity debounce_tb is
end debounce_tb;

architecture Testbench of debounce_tb is

signal clk : std_logic;
signal rst : std_logic;
signal btn : std_logic;
signal pulse : std_logic;
signal clk_count : natural := 0;

begin

    rst <= '0', '1' after 20 ns, '0' after 95 ns;
    
    process
    begin
        if (rst = '0') then
            clk_count <= clk_count + 1;
        end if;
        
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;

    process
    begin
        btn <= '0';
        wait for 100 ns;
        btn <= '1';
        wait for 20 ns;
        btn <= '0';
        wait for 20 ns;
        btn <= '1';
        wait for 200 us;
        btn <= '0';
        wait;
    end process;

    dut : entity work.debounce
    generic map (debounce_limit => 10000) 
    port map (
        clk => clk,
        rst => rst,
        btn => btn,
        pulse => pulse
    );


end Testbench;
