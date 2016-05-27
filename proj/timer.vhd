library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity timer is
  
  port (
    clk, rst : in std_logic;          -- 
    segments : out std_logic_vector(6 downto 0);
    pos : out std_logic_vector(3 downto 0);
		IR1_in : in std_logic_vector(31 downto 0)
    );
    
end timer;

architecture Behavioral of timer is
signal count  : std_logic_vector(17 downto 0) := (others => '0');
signal tenK_c1 : std_logic_vector(13 downto 0) := (others => '0');
signal tenK_c2 : std_logic_vector(13 downto 0) := (others => '0');
signal time_pulse : std_logic := '0';   -- sekunder aboo
signal lp : std_logic := '0';
signal first  : std_logic_vector(3 downto 0) := (others => '0');
signal second : std_logic_vector(3 downto 0) := (others => '0');
signal third  : std_logic_vector(3 downto 0) := (others => '0');
signal fourth : std_logic_vector(3 downto 0) := (others => '0');
signal v : std_logic_vector(3 downto 0) := (others => '0');
signal lp1, lp2, lp3, lp4 : std_logic := '0';
signal count_enable				:std_logic;
signal ce_last				:std_logic;
signal ce_op			:std_logic;
                                                        
  
begin 
  counter:process(clk) begin
     if rising_edge(clk) then
       if rst = '1' then
         count <= (others => '0');
       else
         count <= count + 1;
         case count(17 downto 16) is
           when "00" => pos <= "1110";
           when "01" => pos <= "1101";
           when "10" => pos <= "1011";
           when others => pos <= "0111";
         end case;
       end if;
     end if;
  end process;

  process (clk) begin
    if rising_edge(clk) then
      if rst = '1' or ce_op = '1' then
        tenK_c1 <= (others => '0');
      elsif(count_enable = '1') then
        tenK_c1 <= tenK_c1 + 1;
        if lp = '1' then
          tenK_c1 <= (others => '0');
        end if;       
      end if;
    end if;   
  end process;
  lp <= '1' when(tenK_c1 = 10000) else '0'; 

 process (clk) begin 
    if rising_edge(clk) then
      if rst = '1' or ce_op = '1' then
        tenK_c2 <= (others => '0');
      elsif(count_enable = '1') then
        if lp = '1' then
           tenK_c2 <= tenK_c2 + 1;
        end if;
        if time_pulse = '1' then
          tenK_c2 <= (others => '0');
        end if;       
      end if;
    end if;   
  end process;
  
time_pulse <= '1' when (tenK_c2 = 10000) else '0';
  
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  
 process (clk) begin 
    if rising_edge(clk) then
      if rst = '1' or ce_op = '1' then
        first <= (others => '0');
      else
        if time_pulse = '1'then
          first <= first + 1;
        end if;
        if lp1 = '1' then
          first <= (others => '0');
        end if;       
      end if;
    end if;   
  end process;
  lp1 <= '1' when (first = 10) else '0';
  
   process (clk) begin 
    if rising_edge(clk) then
      if rst = '1' or ce_op = '1' then
        second <= (others => '0');
      else
        if lp1 = '1' then
           second <= second + 1;
        end if;
        if lp2 = '1' then
           second <= (others => '0');
        end if;      
      end if;
    end if;   
  end process;
  lp2 <= '1' when (second = 10) else '0';

   process (clk) begin 
    if rising_edge(clk) then
      if rst = '1' or ce_op = '1' then
        third <= (others => '0');
      else
        if lp2 = '1' then
           third <= third + 1;
        end if;
        if lp3 = '1' then
           third <= (others => '0');
        end if;       
      end if;
    end if;   
  end process;
  lp3 <= '1' when (third = 10) else '0';

   process (clk) begin 
    if rising_edge(clk) then
      if rst = '1' or ce_op = '1' then
        fourth <= (others => '0');
      else
        if lp3 = '1' then
           fourth <= fourth + 1;
        end if;
         if lp4 = '1' then
             fourth <= (others => '0');
         end if;       
      end if;
    end if;   
  end process;
  lp4 <= '1' when (fourth = 10) else '0';

  process(clk) begin
     if rising_edge(clk) then 
       case v is
         when "0000" => segments <= "0000001";
         when "0001" => segments <= "1001111";
         when "0010" => segments <= "0010010";
         when "0011" => segments <= "0000110";
         when "0100" => segments <= "1001100";
         when "0101" => segments <= "0100100";
         when "0110" => segments <= "0100000";
         when "0111" => segments <= "0001111";
         when "1000" => segments <= "0000000";
         when "1001" => segments <= "0000100";
				 when others => segments <= "1111111";
       end case;
     end if;
  end process;
       

  with count(17 downto 16) select
     v <= first when "00",
          second when "01",	
          third when "10",
          fourth when others;



process(clk) begin
	if rising_edge(clk) then
		ce_last <= count_enable;
		if(IR1_in(31 downto 26) = "100011") then
			count_enable <= '1';
		elsif(IR1_in(31 downto 26) = "100100") then
			count_enable <= '0';
		end if;
	end if;
end process;
ce_op <= '1' when (ce_last = '0' and count_enable = '1') else '0';

 


end Behavioral;
                       
                          
