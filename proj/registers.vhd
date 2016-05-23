library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Regs is
  port (
    clk, rst 			 	 							: in std_logic;
    w_enable 			 	 							: in std_logic; 
    out1, out2 			 							: out std_logic_vector (31 downto 0);
    write_in 			 								: in std_logic_vector (31 downto 0);      
    read_address1, read_address2 	: in std_logic_vector (4 downto 0);
    write_address 		 						: in std_logic_vector (4 downto 0);
    make_op_in			 							: in std_logic;
    keyboard_in			 							: in std_logic_vector (3 downto 0);
		x_pos_out											: out std_logic_vector(4 downto 0);
		y_pos_out											: out std_logic_vector(3 downto 0);
    r10_test			 								: out std_logic_vector(31 downto 0)	
    );
end Regs;



architecture Behavioral of Regs is

  signal r0, r1, r2, r3  	: std_logic_vector(31 downto 0) := (others => '0');  -- Register
  signal r4, r5, r6, r7 	: std_logic_vector(31 downto 0) := (others => '0');
  signal r8, r9, r10, r11 	: std_logic_vector(31 downto 0) := (others => '0');
	signal r12, r13, r14, r15 	: std_logic_vector(31 downto 0) := (others => '0');
  signal a2, b2, temp_a, temp_b : std_logic_vector(31 downto 0) := (others => '0');
  

  
begin  -- Behavioral
 process (clk) begin
  if rising_edge(clk) then                    
     a2 <= temp_a;    
     b2 <= temp_b;
    
    if(w_enable = '1') then
      case write_address is
        when "00000" => r0 <= write_in;
        when "00001" => r1 <= write_in;
        when "00010" => r2 <= write_in;
        when "00011" => r3 <= write_in;
        when "00100" => r4 <= write_in;
        when "00101" => r5 <= write_in;
        when "00110" => r6 <= write_in;
        when "00111" => r7 <= write_in;
				when "01000" => r8 <= write_in;			-- marker X_pos reserved
        when "01001" => r9 <= write_in;     -- marker Y_pos reserved
        --when "01010" => r10 <= write_in;    --Keyboard reserved
        when "01011" => r11 <= write_in;
				when "01100" => r12 <= write_in;
        when "01101" => r13 <= write_in;
				when "01110" => r14 <= write_in;			-- marker X_pos reserved
        when "01111" => r15 <= write_in;
        when others => null;
      end case;
    end if;
  end if;
 end process;  

 out1 <= a2;
 out2 <= b2;

 r10_test <= r2;

temp_a <= r0 when (read_address1 = "00000") else
          r1 when (read_address1 = "00001") else
          r2 when (read_address1 = "00010") else
          r3 when (read_address1 = "00011") else
          r4 when (read_address1 = "00100") else
          r5 when (read_address1 = "00101") else
          r6 when (read_address1 = "00110") else
          r7 when (read_address1 = "00111") else
	        r8 when (read_address1 = "01000") else
          r9 when (read_address1 = "01001") else
          r10 when (read_address1 = "01010") else
          r11 when (read_address1 = "01011") else
					r12 when (read_address1 = "01100") else
          r13 when (read_address1 = "01101") else
          r14 when (read_address1 = "01110") else
          r15 when (read_address1 = "01111") else
          (others => '0');
           
 temp_b <= r0 when (read_address2 = "00000") else
           r1 when (read_address2 = "00001") else
           r2 when (read_address2 = "00010") else
           r3 when (read_address2 = "00011") else
           r4 when (read_address2 = "00100") else
           r5 when (read_address2 = "00101") else
           r6 when (read_address2 = "00110") else
           r7 when (read_address2 = "00111") else
	   			 r8 when (read_address2 = "01000") else
           r9 when (read_address2 = "01001") else
           r10 when (read_address2 = "01010") else
           r11 when (read_address2 = "01011") else
					 r12 when (read_address2 = "01100") else
           r13 when (read_address2 = "01101") else
           r14 when (read_address2 = "01110") else
           r15 when (read_address2 = "01111") else
           (others => '0');

               
	
 x_pos_out <= r8(4 downto 0);
 y_pos_out <= r9(3 downto 0);
 --Read keyboard data
process(clk)
begin               
  if rising_edge(clk) then   
		if (make_op_in = '1') then
			r10(3 downto 0) <= keyboard_in;
			r10(31 downto 4) <= (others => '0');  
		elsif(write_address = "01010" and w_enable = '1') then
			r10 <= write_in;		
    end if;
  end if;
end process;


end Behavioral;
