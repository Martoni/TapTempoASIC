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
    component rstgen is
    port (
        -- clock input
        clk_i : in std_logic;
        -- rst output
        rst_o : out std_logic
    );
    end component rstgen;

    -- TimePulse generation
    signal tp : std_logic;
    component timepulse is
    port(
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- timepulse output
        tp_o : out std_logic
    );
    end component timepulse;

    -- Synchronize btn_i to avoid metastability
    signal btn_old : std_logic;
    signal btn_s : std_logic;

    -- debounce
    signal btn_d : std_logic;
    component debounce is
    port (
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- inputs
        tp_i : in std_logic;
        btn_i: in std_logic;
        -- outputs
        btn_o : out std_logic
    );
    end component debounce;

    -- count tap period
    signal btn_per : std_logic_vector(BTN_PER_SIZE -1 downto 0);
    signal btn_per_valid : std_logic;
    component percount is
    port(
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- time plulse
        tp_i : in std_logic;
        -- input button
        btn_i : in std_logic;
        -- output period
        btn_per_o : out std_logic_vector(BTN_PER_SIZE-1 downto 0);
        btn_per_valid : out std_logic);
    end component percount;

    -- convert period in bpm
    signal bpm : std_logic_vector(BPM_SIZE - 1 downto 0);
    signal bpm_valid : std_logic;
    component per2bpm is
        port(
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- inputs
        btn_per_i : in std_logic_vector(BTN_PER_SIZE-1 downto 0);
        btn_per_valid : in std_logic;
        -- outputs
        bpm_o : out std_logic_vector(BPM_SIZE-1 downto 0);
        bpm_valid : out std_logic
    );
    end component per2bpm;

    -- output pwm
    component pwmgen is
    generic(BPM_MAX : natural := 250);
    port (
        -- clock and reset
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- timepulse
        tp_i : in std_logic;
        -- input value
        bpm_i : in std_logic_vector(BPM_SIZE-1 downto 0);
        bpm_valid : in std_logic;
        -- output
        pwm_o : out std_logic);
    end component pwmgen;


begin

    -- generate reset internally
    rstgen_connect : rstgen
    port map (
        clk_i => clk_i,
        rst_o => rst);

    -- TimePulse generation
    timepulse_connect : timepulse
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
    debounce_connect : debounce
    port map (
        clk_i => clk_i,
        rst_i => rst,
        tp_i => tp,
        btn_i => btn_s,
        btn_o => btn_d);


    -- count tap period
    percount_connect : percount
    port map (
        clk_i => clk_i,
        rst_i => rst,
        tp_i => tp,
        btn_i => btn_d,
        btn_per_o => btn_per,
        btn_per_valid => btn_per_valid);

    -- convert period in bpm
    per2bpm_connect : per2bpm
    port map (
        clk_i => clk_i,
        rst_i => rst,
        btn_per_i => btn_per,
        btn_per_valid => btn_per_valid,
        bpm_o => bpm,
        bpm_valid => bpm_valid);


    -- generate pwm
    pwmgen_connect : pwmgen
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
