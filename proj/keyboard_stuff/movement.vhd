-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity movement is
  
  port (
    clk          : in std_logic;
    rst          : in std_logic;
    KeyPressedIn : in std_logic_vector(3 downto 0));

end movement;

architecture behavioral of movement is

  -- signals
  
  type curmov_type is (_LEFT,_RIGHT, _DOWN, _UP, _STAND);	-- declare cursor movement types
  signal curMovement            : curmov_type;			-- cursor movement
	
  signal curposX		: unsigned(5 downto 0);		-- cursor X position
  signal curposY		: unsigned(4 downto 0);		-- cursor Y position


begin 

  -- set cursor movement based on scan code
  with KeyPressedIn select
    curMovement <= _DOWN when "0011",	        -- down scancode (1B), so move cursor to next line
                   _UP when "0001",	        -- up scancode (1D), so move cursor backward
		   _LEFT when "0010",		-- left scancode (1C), so move cursor backward
		   _RIGHT when "0100",		-- right scancode (23), so move cursor backward
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

end behavioral;
