--------------------------------------------------------------------------------
-- KBD ENC

-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity KBD_ENC is
  port ( clk	                : in std_logic;			-- system clock (100 MHz)
	 rst		        : in std_logic;			-- reset signal
         PS2KeyboardCLK	        : in std_logic; 		-- USB keyboard PS2 clock
         PS2KeyboardData	: in std_logic;			-- USB keyboard PS2 data
         data			: out std_logic_vector(7 downto 0);		-- tile data
         addr			: out unsigned(10 downto 0);	-- tile address
         we			: out std_logic;		-- write enable
         KBsignal               : out std_logic(7 downto 0));   -- Vector for keyboard where every bit represents a key-signal
                                                               
end KBD_ENC;

-- architecture
architecture behavioral of KBD_ENC is
  signal PS2Clk			: std_logic;			-- Synchronized PS2 clock
  signal PS2Data		: std_logic;			-- Synchronized PS2 data
  signal PS2Clk_Q1, PS2Clk_Q2 	: std_logic;			-- PS2 clock one pulse flip flop
  signal PS2Clk_op 		: std_logic;			-- PS2 clock one pulse
  signal BC11                   : std_logic;                    -- BC11
	
  signal PS2Data_sr 		: std_logic_vector(10 downto 0);-- PS2 data shift register
	
  signal PS2BitCounter	        : unsigned(3 downto 0);		-- PS2 bit counter
  signal make_Q			: std_logic;			-- make one pulselse flip flop
  signal make_op		: std_logic;			-- make one pulse

  type state_type is (IDLE, MAKE, BREAK);			-- declare state types for PS2
  signal PS2state : state_type;					-- PS2 state

  signal ScanCode		: std_logic_vector(7 downto 0);	-- scan code
  signal TileIndex		: std_logic_vector(7 downto 0);	-- tile index

  type action_type is (FLAG, QUESTION, MINE);                   -- declare state types for actions
  signal action : action_type;                                  -- actions
  
  type curmov_type is (_LEFT,_RIGHT, _DOWN, _UP, _STAND);	-- declare cursor movement types
  signal curMovement : curmov_type;				-- cursor movement
	
  signal curposX		: unsigned(5 downto 0);		-- cursor X position
  signal curposY		: unsigned(4 downto 0);		-- cursor Y position
	
  type wr_type is (STANDBY, WRCHAR, WRCUR);			-- declare state types for write cycle
  signal WRstate : wr_type;					-- write cycle state

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
process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        PS2Data_sr(10 downto 0) <= "00000000000";
      else
        -- Change to one line ?
        if PS2Clk_op = '1' then
          PS2Data_sr(0) <= PS2Data_sr(1);
          PS2Data_sr(1) <= PS2Data_sr(2);
          PS2Data_sr(2) <= PS2Data_sr(3);
          PS2Data_sr(3) <= PS2Data_sr(4);
          PS2Data_sr(4) <= PS2Data_sr(5);
          PS2Data_sr(5) <= PS2Data_sr(6);
          PS2Data_sr(6) <= PS2Data_sr(7);
          PS2Data_sr(7) <= PS2Data_sr(8);
          PS2Data_sr(8) <= PS2Data_sr(9);
          PS2Data_sr(9) <= PS2Data_sr(10);
          PS2Data_sr(10) <= PS2Data;
        end if;
        
      end if;
    end if;
  end process;


  ScanCode <= PS2Data_sr(8 downto 1);
	
  -- PS2 bit counter
  -- The purpose of the PS2 bit counter is to tell the PS2 state machine when to change state

 process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        PS2BitCounter <= "0000";
      else
        
        if BC11 = '1' then
          PS2BitCounter <= "0000";         
        elsif PS2Clk_op = '1' then
          PS2BitCounter <= PS2BitCounter + 1;
        end if;
        
      end if;
    end if;
  end process;

 BC11 <= '1' when PS2BitCounter = "1011" else '0';   

	

  -- PS2 state
  -- Either MAKE or BREAK state is identified from the scancode
  -- Only single character scan codes are identified
  -- The behavior of multiple character scan codes is undefined

 process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        PS2state <= IDLE;    
      else
        
        if BC11 = '1' and not (ScanCode = X"F0") and PS2state = IDLE then
          PS2state <= MAKE;
        elsif BC11 = '1' and ScanCode = X"F0" and PS2state = IDLE then
          PS2state <= BREAK;
        elsif BC11 = '1' and PS2state = BREAK then
          PS2state <= IDLE;
        elsif PS2state = MAKE then
          PS2state <= IDLE;
        end if;
        
      end if;
    end if;
  end process; 
-- 
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          PS2state <= IDLE;    
        else
          if BC11 = '1' and ScanCode = x"76" and PS2state = IDLE then
           KBsignal(0) <= '1';
           PS2state <= MAKE/BREAK;
          elsif BC11 = '1' and ScanCode = X"1D" and PS2state = IDLE then
            KBsignal(1) <= '1';
          elsif BC11 = '1' and ScanCode = X"1C" and PS2state = IDLE then
            KBsignal(2) <= '1';
          elsif BC11 = '1' and ScanCode = X"1B" and PS2state = IDLE then
            KBsignal(3) <= '1';
          elsif BC11 = '1' and ScanCode = X"23" and PS2state = IDLE then
            KBsignal(4) <= '1';
          elsif BC11 = '1' and ScanCode = X"24" and PS2state = IDLE then
            KBsignal(5) <= '1';
          elsif BC11 = '1' and ScanCode = X"15" and PS2state = IDLE then
            KBsignal(6) <= '1';
          elsif BC11 = '1' and ScanCode = X"2D" and PS2state = IDLE then
            KBsignal(7) <= '1';

          else
            KBsignal <= "00000000";
            
          end if;
        end if;    
      end if;
    end process;      

	
	

  -- Scan Code -> Tile Index mapping
  with ScanCode select
    TileIndex <= x"00" when x"76",	-- ESC (reset)
                 x"01" when x"1D",      -- W (UP)
                 x"02" when x"1C",      -- A (LEFT)
                 x"03" when x"1B",      -- S (DOWN)
                 x"04" when x"23",      -- D (RIGHT)
		 x"05" when x"24",	-- E (flag)
		 x"06" when x"15",	-- Q (questionmark)
		 x"07" when x"2D",	-- R (röj/mine)
		 x"00" when others;
						 
						 
  -- set cursor movement based on scan code
  with ScanCode select
    curMovement <= _DOWN when x"1B",	        -- down scancode (1B), so move cursor to next line
                   _UP when x"1D",	        -- up scancode (1D), so move cursor backward
		   _LEFT when x"1C",		-- left scancode (1C), so move cursor backward
		   _RIGHT when x"23",		-- right scancode (23), so move cursor backward
                   _STAND when others;	        -- for all other scancodes, move cursor stand still


  -- curposX
  -- update cursor X position based on current cursor position (curposX and curposY) and cursor
  -- movement (curMovement)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        curposX <= (others => '0');
      elsif (WRstate = WRCHAR) then
        if (curMovement = _RIGHT) then
          if ((curposX < 19) and (curposX >= 0)) then 
            curposX <= curposX + 1;
          end if;
        elsif (curMovement = _LEFT) then
          if ((curposX < 20) and (curposX > 0)) then 
            curposX <= curposX - 1;
          end if;
        elsif (curMovement = _STAND) then
          curposX <= curPosX;
        end if;
      end if;
    end if;
  end process;


  -- curposY
  -- update cursor Y position based on current cursor position (curposX and curposY) and cursor
  -- movement (curMovement)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        curposY <= (others => '0');
      elsif (WRstate = WRCHAR) then
        if (curMovement = UP) then
            if ((curposY < 15) and (curposY > 0)) then
              curposY <= curposY - 1;
            end if;
          end if;
        elsif (curMovement = DOWN) then
            if ((curposY >= 0) and (curposY < 14)) then
              curposY <= curposY + 1;
            end if;
          end if;
        elsif (curMovement = STAND) then
          if (curposY = 14) then
            curposY <= curposY;
          end if;
        end if;
      end if;
    end if;
  end process;


  -- write state
  -- every write cycle begins with writing the character tile index at the current
  -- cursor position, then moving to the next cursor position and there write the
  -- cursor tile index
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        WRstate <= STANDBY;
      else
        case WRstate is
          when STANDBY =>
            if (PS2state = MAKE) then
              WRstate <= WRCHAR;
            else
              WRstate <= STANDBY;
            end if;
          when WRCHAR =>
            WRstate <= WRCUR;
          when WRCUR =>
            WRstate <= STANDBY;
          when others =>
            WRstate <= STANDBY;
        end case;
      end if;
    end if;
  end process;
	

  -- we will be enabled ('1') for two consecutive clock cycles during WRCHAR and WRCUR states
  -- and disabled ('0') otherwise at STANDBY state
  we <= '0' when (WRstate = STANDBY) else '1';


  -- memory address is a composite of curposY and curposX
  -- the "to_unsigned(20, 6)" is needed to generate a correct size of the resulting unsigned vector
  addr <= to_unsigned(20, 6)*curposY + curposX;

  
  -- data output is set to be x"1F" (cursor tile index) during WRCUR state, otherwise set as scan code tile index
  data <= x"1F" when (WRstate =  WRCUR) else TileIndex;

  
end behavioral;
