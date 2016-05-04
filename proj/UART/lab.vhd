library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab is
    Port ( clk,rst, rx : in  STD_LOGIC;
           seg: out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0));
end lab;

architecture Behavioral of lab is
    component leddriver
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           value : in  STD_LOGIC_VECTOR (15 downto 0));
    end component;
    signal sreg : STD_LOGIC_VECTOR(9 downto 0) := B"0_00000000_0";  -- 10 bit skiftregister
    signal tal : STD_LOGIC_VECTOR(15 downto 0) := X"0000";  
    signal rx1,rx2 : std_logic;         -- vippor på insignalen
    signal sp : std_logic;              -- skiftpuls
    signal lp : std_logic;         -- laddpuls
    signal pos : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal pulsecount : std_logic_vector(10 downto 0) := "00000000000";  -- antal klockpulser
    signal shiftcount : std_logic_vector(3 downto 0) := "0000";  -- antal skiftningar
    signal reading : std_logic := '0';
begin
  -- rst är tryckknappen i mitten under displayen
  -- *****************************
  -- *  synkroniseringsvippor    *
  -- *****************************
  synch1 : process(clk) begin
     if rising_edge(clk) then 
      if rst='1' then
         rx1 <= '0';
         rx2 <= '0';
      else
        rx1 <= rx;
        rx2 <= rx1;
      end if;
    end if;
  end process;

  
  -- *****************************
  -- *       styrenhet           *
  -- *****************************

  pulse_c : process(clk) begin
    if rising_edge(clk) then
      if reading = '1' then
        if pulsecount = 868 then
          pulsecount <= (others => '0');
        else
          pulsecount <= pulsecount + 1;
        end if;
      else
        pulsecount <= (others => '0');
      end if;
    end if;
  end process;           
            
  styr : process(clk) begin
     if rising_edge(clk) then
       if reading = '1' then
         if pulsecount = 434 then          
             shiftcount <= shiftcount + 1;             
         elsif (shiftcount = 10) then                 
               shiftcount <= (others => '0');
               reading <= '0';                       
         end if;       
       elsif reading = '0' and rx1 = '0' and rx2 = '1' then
         reading <= '1';
       end if;
     end if;
   end process;
     sp <= '1' when (pulsecount = 434) else '0';
     lp <= '1' when (shiftcount = 10) else '0';
     
     
           
  -- *****************************
  -- * 10 bit skiftregister      *
  -- *****************************
  skiftr : process(clk) begin 
     if rising_edge(clk) then 
       if sp = '1' then
         sreg <= rx2 & sreg(9 downto 1);         
        end if;
      end if;
  end process;          

  -- *****************************
  -- * 2  bit register           *
  -- *****************************

   two_bit_reg : process(clk) begin
     if rising_edge(clk) then 
      if rst='1' then
         pos <= "00";
      elsif lp = '1' then 
         pos <= pos + 1;
      end if;
    end if;
  end process;  

  -- *****************************
  -- * 16 bit register           *
  -- *****************************


  hexbit_reg : process(clk) begin
    if rising_edge(clk) then 
      if rst='1' then
         tal <= (others => '0');
      elsif lp = '1' then 
         case pos is
           when "00" => tal(3 downto 0) <= sreg(4 downto 1);
           when "01" => tal(7 downto 4) <= sreg(4 downto 1);
           when "10" => tal(11 downto 8) <= sreg(4 downto 1);
           when "11" => tal(15 downto 12) <= sreg(4 downto 1);
           when others => null;
         end case;
      end if;
    end if;
  end process;
  






  
  -- *****************************
  -- * Multiplexad display       *
  -- *****************************
  led: leddriver port map (clk, rst, seg, an, tal);
end Behavioral;

