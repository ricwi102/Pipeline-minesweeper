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
    signal rx1,rx2, reader : std_logic;         -- vippor p� insignalen
    signal sp : std_logic;              -- skiftpuls
    signal lp : std_logic;         -- laddpuls
    signal pos : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal bitcounter : std_logic_vector(3 downto 0) :="0000";
    signal clockcounter : STD_LOGIC_VECTOR(15 downto 0) :="0000000000000000";
begin
  -- rst �r tryckknappen i mitten under displayen
  -- *****************************
  -- *  synkroniseringsvippor    *
  -- *****************************

  process(clk) begin
     if rising_edge(clk) then
       if rst = '1' then
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
 -- Styrenhet. Denna producerar tv� styrsignaler, b�da enpulsade:
      --Skiftpulsen sp, som kommer mitt i (ungef�r) varje bit.
      --Laddpulsen lp, som kommer efter den sista skiftpulsen
           
  
  process(clk) begin
    if rising_edge(clk) then
      
      if rst = '1' then
        reader <= '0';
        sp <= '0';
        lp <= '0';
      else
        if rx1 = '0' and rx2 = '1' then
          reader <= '1';
        end if;
          
        if bitcounter = 10 and clockcounter = 500 and reader = '1' then
          lp <= '1';
          reader <= '0';
        else
          lp <='0';
        end if;
          
        if clockcounter = 434 then 
          sp <= '1';
        else
          sp <= '0';
        end if;
        
      end if;
    end if;
  end process;

  process(clk) begin
   if rising_edge(clk) then
     
     if rst='1' then
       clockcounter <= "0000000000000000";
       bitcounter <= "0000";
     else

       if reader = '0' then
         clockcounter <= "0000000000000000";
         bitcounter <= "0000";
       end if;
       
       if reader = '1'  then 
         clockcounter <= clockcounter + 1;
       end if;

       
       if clockcounter = 868 then
         clockcounter <="0000000000000000" ;
       end if;

       
       if clockcounter = 434 then
         bitcounter <= bitcounter + 1;
       end if;

       
     end if;
   end if;
  end process;

  
  
  -- *****************************
  -- * 10 bit skiftregister      *
  -- *****************************
  --Skiftregister. De 10 bitarna i varje siffra skiftas in i skiftregistret.
  process(clk) begin
    if rising_edge(clk) then
      if rst='1' then
        sreg(9 downto 0) <= "0000000000";
      else
        if sp = '1' then
          sreg(0)<=sreg(1);                --Shiftar s�nder.
          sreg(1)<=sreg(2);
          sreg(2)<=sreg(3);
          sreg(3)<=sreg(4);
          sreg(4)<=sreg(5);
          sreg(5)<=sreg(6);
          sreg(6)<=sreg(7);
          sreg(7)<=sreg(8);
          sreg(8)<=sreg(9);
          sreg(9)<=rx2;
        end if;    
      end if;
    end if;
  end process;

  -- *****************************
  -- * 2  bit register           *R�TT
  -- *****************************
  process(clk) begin 
    if rising_edge(clk) then
      if rst = '1' then
        pos <= "00";
      else
        if lp = '1' then
          case pos is
            when "00" => pos <= "01";
            when "01" => pos <= "10";
            when "10" => pos <= "11";
            when others => pos <= "00";
          end case;
        end if;
      end if;
    end if;
  end process;

  -- *****************************
  -- * 16 bit register           *
  -- *****************************
  --   ----------

  -- *****************************
  -- * Multiplexad display       *
  -- *****************************
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        tal(15 downto 0) <= "0000000000000000";
      else
        if lp = '1' then
          if pos = "00" then
            tal(3 downto 0) <= sreg(4 downto 1);
          elsif pos = "01" then
            tal(7 downto 4) <= sreg(4 downto 1);
          elsif pos = "10" then
            tal(11 downto 8) <= sreg(4 downto 1);
          elsif pos = "11" then
            tal(15 downto 12) <= sreg(4 downto 1);
          end if;
        end if;
      end if;
    end if;
  end process;
  
  led: leddriver port map (clk, rst, seg, an, tal);
end Behavioral;