library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Regs is
  port (
    out1, out2 : out std_logic_vector (31 downto 0);
    write_in : in std_logic_vector (31 downto 0);
    r1_enable, r1_enable : in std_logic;
    w_enable : in std_logic;
    read_address1, read_address2 : in std_logic_vector (4 downto 0);
    write_address : in std_logic_vector (4 downto 0)
    );
end Regs;



architecture Behavioral of Regs is

  signal r0, r1, r2, r3 : std_logic_vector(31 downto 0);  -- Register
  signal r4, r5, r6, r7 : std_logic_vector(31 downto 0); 

  
begin  -- Behavioral

  if (r1_enable = '1') then     
    out1 <= r0 when (read_address1 = "00000") else
            r1 when (read_address1 = "00001") else
            r2 when (read_address1 = "00010") else
            r3 when (read_address1 = "00011") else
            r4 when (read_address1 = "00100") else
            r5 when (read_address1 = "00101") else
            r6 when (read_address1 = "00110") else
            r7 when (read_address1 = "00111") else
            (others => '0') when others;
  else
    out1 <= (others => '0');
  end if;


  if (r2_enable = '1') then     
    out2 <= r0 when (read_address1 = "00000") else
            r1 when (read_address1 = "00001") else
            r2 when (read_address1 = "00010") else
            r3 when (read_address1 = "00011") else
            r4 when (read_address1 = "00100") else
            r5 when (read_address1 = "00101") else
            r6 when (read_address1 = "00110") else
            r7 when (read_address1 = "00111") else
            (others => '0') when others;
  else
    out2 <= (others => '0');
  end if;

  
           


               
               
  

end Behavioral;
