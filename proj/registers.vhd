library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Regs is
  port (
    clk, rst 			 : in std_logic;
    w_enable 			 : in std_logic; 
    out1, out2 			 : out std_logic_vector (31 downto 0);
    write_in 			 : in std_logic_vector (31 downto 0);      
    read_address1, read_address2 : in std_logic_vector (4 downto 0);
    write_address 		 : in std_logic_vector (4 downto 0);
    keyboard_in			 : in std_logic_vector (3 downto 0)
    );
end Regs;



architecture Behavioral of Regs is

  signal r0, r1, r2, r3 : std_logic_vector(31 downto 0) := (others => '0');  -- Register
  signal r4, r5, r6, r7 : std_logic_vector(31 downto 0) := (others => '0');
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
        when others => null;
      end case;
    end if;
  end if;
 end process;  

 out1 <= a2;
 out2 <= b2;

temp_a <= r0 when (read_address1 = "00000") else
          r1 when (read_address1 = "00001") else
          r2 when (read_address1 = "00010") else
          r3 when (read_address1 = "00011") else
          r4 when (read_address1 = "00100") else
          r5 when (read_address1 = "00101") else
          r6 when (read_address1 = "00110") else
          r7 when (read_address1 = "00111") else
          (others => '0');
           
 temp_b <= r0 when (read_address1 = "00000") else
           r1 when (read_address1 = "00001") else
           r2 when (read_address1 = "00010") else
           r3 when (read_address1 = "00011") else
           r4 when (read_address1 = "00100") else
           r5 when (read_address1 = "00101") else
           r6 when (read_address1 = "00110") else
           r7 when (read_address1 = "00111") else
           (others => '0');

               
               
  

end Behavioral;
