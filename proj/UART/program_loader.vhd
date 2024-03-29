library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity program_loader is
    Port (clk,rst, rx 	: in  STD_LOGIC;											--System clock, reset and input
          instr_out			: out STD_LOGIC_VECTOR(31 downto 0);	--output
	  			PM_count_out  : out std_logic_vector(9 downto 0);		--Andress pointer in pm
	  			we_out				: out std_logic;
					running_out		: out std_logic												--Program_loader is running
	  			);          
end program_loader;

architecture Behavioral of program_loader is
  signal PM_count 	: std_logic_vector(9 downto 0) := (others => '0');   
  signal instr_int	: std_logic_vector(31 downto 0) := (others => '0');
  signal we					: std_logic := '0';
  signal reading 		: std_logic := '0';	
	signal running 		: std_logic := '0';	
	signal run_last 	: std_logic;
	signal run_op			: std_logic;	
	signal rx1, rx2		: std_logic;
	signal sp, lp			: std_logic;
	signal pulsecount : std_logic_vector(9 downto 0);
	signal sreg				: std_logic_vector(9 downto 0);
	signal pos, last_pos	: std_logic_vector(1 downto 0);	
	signal pos_op			: std_logic;


  signal shiftcount : std_logic_vector(3 downto 0) := (others => '0');


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
  -- * 2 bit räknare             *
  -- *****************************

   two_bit_reg : process(clk) begin
     if rising_edge(clk) then 
      if rst='1' then
         pos <= "00";
      elsif lp = '1' then 
         pos <= pos + 1;
      end if;
			last_pos <= pos;
    end if;
  end process;  
	pos_op <= '1' when (pos = "00" and last_pos = "11") else '0';
	

  -- *****************************
  -- * 32 bit register           *
  -- *****************************


  hexbit_reg : process(clk) begin
    if rising_edge(clk) then 
      if rst='1' then
         instr_int <= (others => '0');
      elsif lp = '1' then 
         case pos is
           when "00" => instr_int(31 downto 24) <= sreg(8 downto 1);
           when "01" => instr_int(23 downto 16) <= sreg(8 downto 1);
           when "10" => instr_int(15 downto 8) <= sreg(8 downto 1);
           when "11" => instr_int(7 downto 0) <= sreg(8 downto 1);
           when others => null;
         end case;
      end if;
    end if;
  end process;




  instr_shift : process(clk) begin
    if rising_edge(clk) then
      if (rst = '1' or run_op = '1') then
 	 			PM_count <= (others => '0');	 		
      else			
       	if(we = '1') then	   			
          PM_count <= PM_count + 1;
        end if;  
      end if;
    end if;
  end process;
	we <= '1' when (pos_op = '1' and running = '1') else '0';


	running_count : process(clk) begin
		if rising_edge(clk)	then
			if (rst = '1') then
				running <= '0';
				run_last <= '0';
			else			
				run_last <= running;
				if (instr_int = x"ffff_ffff") then					
					running <= '0';
				elsif (instr_int = x"ffff_fffe") then
					running <= '1';				
				end if;
			end if;
		end if;
	end process;
	run_op <= '1' when (running = '0' and run_last = '0') else '0';



	running_out <= running;
  instr_out <= instr_int;
  we_out <= we;
	PM_count_out <= PM_count;



end Behavioral;

