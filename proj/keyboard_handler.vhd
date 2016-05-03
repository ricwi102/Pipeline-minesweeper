library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

entity keyboard_handler is
  port (
    clk                 : in std_logic;
    rst                 : in std_logic;
    PS2KeyboardCLK      : in std_logic;
    PS2KeyboardData     : in std_logic;
    KeyPressedOut       : out std_logic_vector(3 downto 0)
    );
end keyboard_handler;


architecture behavioral of keyboard_handler is
  signal KeyPressed             : std_logic_vector(3 downto 0);
  
  signal PS2Clk			: std_logic;			-- Synchronized PS2 clock
  signal PS2Data		: std_logic;			-- Synchronized PS2 data
  signal PS2Clk_Q1, PS2Clk_Q2 	: std_logic;			-- PS2 clock one pulse flip flop
  signal PS2Clk_op 		: std_logic;			-- PS2 clock one pulse 
	
  signal PS2Data_sr 		: std_logic_vector(10 downto 0);-- PS2 data shift register
	
  signal PS2BitCounter	        : unsigned(3 downto 0);		-- PS2 bit counter
  signal BC11                   : std_logic;                    -- signal for ps2 state
  signal make_Q			: std_logic;			-- make one pulselse flip flop
  signal make_op		: std_logic;			-- make one pulse
  
  
  type state_type is (IDLE, MAKE, BREAK);			-- declare state types for PS2
  signal PS2state : state_type;					-- PS2 state

  signal ScanCode		: std_logic_vector(7 downto 0);	-- scan code

  
 begin

   -- Synchronize PS2-KBD signals
  process(clk)
  begin 
    if rising_edge(clk) then
      PS2Clk <= PS2KeyboardCLK;
      PS2Data <= PS2KeyboardData;
    end if;
  end process;

    -- Generate one cycle pulse from PS2 clock, negative edge
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        PS2Clk_Q1 <= '1';
        PS2Clk_Q2 <= '0';
      else
        PS2Clk_Q1 <= PS2Clk;
        PS2Clk_Q2 <= not PS2Clk_Q1;
      end if;
    end if;
  end process;
	
  PS2Clk_op <= (not PS2Clk_Q1) and (not PS2Clk_Q2);


  -- PS2 data shift register
  process (clk)
  begin
      if rising_edge(clk) then
        if (PS2clk_op = '1') then
           PS2Data_sr(10 downto 0) <= PS2Data & PS2Data_sr(10 downto 1); 
        end if;       
      end if;
  end process;

  ScanCode <= PS2Data_sr(8 downto 1);


  -- PS2 bit counter
  -- The purpose of the PS2 bit counter is to tell the PS2 state machine when to change state
  PS2_bit_counter: process (clk)
  begin 
    if rising_edge(clk) then
      if (BC11 = '1') then
        PS2BitCounter <= (others => '0');
      elsif (PS2CLK_op = '1') then
        PS2BitCounter <= PS2BitCounter + 1;
      end if;      
    end if;    
  end process;
  BC11 <= '1' when (PS2BitCounter = 11) else '0';

  -- PS2 state
  -- Either MAKE or BREAK state is identified from the scancode
  -- Only single character scan codes are identified
  -- The behavior of multiple character scan codes is undefined
  ps2_state: process (clk)
  begin
    if rising_edge(clk) then
      if (PS2state = IDLE and BC11 = '1') then
        if (ScanCode = x"F0") then       
          PS2state <= BREAK;
        else
          PS2state <= MAKE;
        end if; 
      elsif (PS2state = MAKE or BC11 = '1') then
        PS2state <= IDLE;    
      else
        PS2state <= PS2state;
      end if;
    end if;
  end process ps2_state;

  
  KeyPressed <= "0001" when ScanCode = x"1D" else  --W
                "0010" when ScanCode = x"1C" else  --A
                "0011" when ScanCode = x"1B" else  --S
                "0100" when ScanCode = x"23" else  --D
                "0101" when ScanCode = x"15" else  --Q
                "0110" when ScanCode = x"24" else  --E
                "0111" when ScanCode = x"2D" else  --R
                "1000" when ScanCode = x"76" else  --ESC
                "0000";
  KeyPressedOut <= KeyPressed;

 end behavioral ; 
