-- The TapTempo Project
-- Created on    : 28/11/2020
-- Author        : Fabien Marteau <mail@fabienm.eu>
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.taptempo_pkg.all;

Entity taptempo is
    port(
        clk_i : in std_logic;
        btn_i : in std_logic;
        pwm_o : out std_logic);
end entity taptempo;

architecture taptempo_1 of taptempo is

    -- generate reset internally
    signal rst : std_logic;

    -- TimePulse generation
    signal tp : std_logic;

    -- Synchronize btn_i to avoid metastability
    signal btn_old : std_logic;
    signal btn_s : std_logic;

    -- debounce
    signal btn_d : std_logic;

    -- count tap period
    signal btn_per : std_logic_vector(BTN_PER_SIZE -1 downto 0);
    signal btn_per_valid : std_logic;

    -- convert period in bpm
    signal bpm : std_logic_vector(BPM_SIZE - 1 downto 0);
    signal bpm_valid : std_logic;

begin

    -- generate reset internally
    rstgen_connect : entity work.rstgen
    port map (
        clk_i => clk_i,
        rst_o => rst);

    -- TimePulse generation
    timepulse_connect : entity work.timepulse
    port map (
        clk_i => clk_i,
        rst_i => rst,
        tp_o => tp);

    -- Synchronize btn
    btn_sync_p : process(clk_i, rst)
    begin
        if (rst = '1') then
            btn_old <= '0';
            btn_s <= '0';
        elsif rising_edge(clk_i) then
            btn_s <= btn_old;
            btn_old <= btn_i;
        end if;
    end process btn_sync_p;

    -- debounce
    debounce_connect : entity work.debounce
    port map (
        clk_i => clk_i,
        rst_i => rst,
        tp_i => tp,
        btn_i => btn_s,
        btn_o => btn_d);


    -- count tap period
    percount_connect : entity work.percount
    port map (
        clk_i => clk_i,
        rst_i => rst,
        tp_i => tp,
        btn_i => btn_d,
        btn_per_o => btn_per,
        btn_per_valid => btn_per_valid);

    -- convert period in bpm
    per2bpm_connect : entity work.per2bpm
    port map (
        clk_i => clk_i,
        rst_i => rst,
        btn_per_i => btn_per,
        btn_per_valid => btn_per_valid,
        bpm_o => bpm,
        bpm_valid => bpm_valid);


    -- generate pwm
    pwmgen_connect : entity work.pwmgen
    port map (
        clk_i => clk_i,
        rst_i => rst,
        tp_i => tp,
        bpm_i => bpm,
        bpm_valid => bpm_valid,
--        pwm_o => open);
        pwm_o => pwm_o);

--    pwm_o <= btn_d;

end architecture taptempo_1;
