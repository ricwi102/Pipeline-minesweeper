library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity jump_stall is
  port ( clk            : in std_logic;
         IR1_in         : in std_logic_vector(31 downto 0);
         IR2_in         : in std_logic_vector(31 downto 0);
         IR1_out        : out std_logic_vector(31 downto 0);
         IR2_out        : out std_logic_vector(31 downto 0);
         PC_out         : out std_logic_vector(31 downto 0);
         PC_in          : in std_logic_vector(31 downto 0);
         PC2_in         : in std_logic_vector(31 downto 0);
         PM_in             : in std_logic_vector(31 downto 0)
         );
end jump_stall;

architecture Behavioral of jump_stall is

  signal register_used : std_logic := '0';
  signal stall_rom     : std_logic := '0';
  signal jump_rom      : std_logic_vector(1 downto 0) := "00";   
  signal Stall_JmpTaken : std_logic_vector(1 downto 0) := "00";  -- Stall = X0 , JmpTaken = 0X
                                                                
  
begin  -- Behoavioral

  process(clk)
  begin
    if rising_edge(clk) then
      if (IR2_in(25 downto 21) = IR1_in(15 downto 11)) or
        (IR2_in(25 downto 21) = IR1_in(20 downto 16)) then
        register_used <= '1';
      end if;

       with IR1_in(31 downto 26) select
         stall_rom <= '0' when "000000",
                      '0' when "000001",
                      '1' when others;  
                    
       with IR2_in(31 downto 26) select
         jump_rom <=  "10" when "000011",
                      "00" when others;
         
        
      end if;
    end if;
  end process;

-- Stall/JmpTaken
  
Stall_JmpTaken(1) <= '1' when (register_used and stall_rom and jump_rom(1)) else '0'; -- Stall
Stall_JmpTaken(0) <= '1' when ( or jump_rom(0)) else '0'; -- JmpTaken (Fixa klart efter att flaggorna blir klara)
                                                         

-- Muxarna
  
      with Stall_JmpTaken select
        PC_out <= (PC + 4) when "00",
                  PC2_in when "01",
                  PC when others;

      with Stall_JmpTaken select
        IR1_out <= PM_in when "00",
                   "000000" when "01",  -- NOP
                   IR1 when others;

      with Stall_JmpTaken select
        IR2_out <= IR1 when "00",
                   "000000" when others;

--

end Behavioral;
