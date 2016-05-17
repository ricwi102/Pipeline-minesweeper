library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity jump_stall is
  port ( clk,rst        : in std_logic;
         IR1_in_js      : in std_logic_vector(31 downto 0);
         IR2_in_js      : in std_logic_vector(31 downto 0);
         IR1_out_js     : out std_logic_vector(31 downto 0);
         IR2_out_js     : out std_logic_vector(31 downto 0);

         PC_out         : out std_logic_vector(31 downto 0);
         PM_in          : in std_logic_vector(31 downto 0);
         z_flag_in      : in std_logic
         );
end jump_stall;

architecture Behavioral of jump_stall is
  
  signal extend	        : std_logic_vector(31 downto 0) := (others => '0');
  signal PC		: std_logic_vector(31 downto 0) := (others => '0');
  signal PC1		: std_logic_vector(31 downto 0) := (others => '0');
  signal PC2		: std_logic_vector(31 downto 0) := (others => '0');
  
  signal stall_rom     	: std_logic_vector(30 downto 0) := b"0001_0111_1111_1111_1111_1111_1000_000";
  signal IR1_internal   : std_logic_vector(31 downto 0) := (others => '0');
  signal IR2_internal   : std_logic_vector(31 downto 0) := (others => '0');
  alias command_ir1	: std_logic_vector(5 downto 0) is IR1_internal(31 downto 26);
  alias command_ir2 	: std_logic_vector(5 downto 0) is IR2_internal(31 downto 26);

  signal  mux_signal 	: std_logic_vector(1 downto 0) := "00";
  
  signal mem_acc, reg_acc : std_logic := '0';    -- command at IR2 = load word
  alias send_stall 	  : std_logic is mux_signal(1);
  
  signal j, z_flag_j 	: std_logic := '0';
  signal dir_jump	: std_logic := '0';
  alias take_jump 	: std_logic is mux_signal(0);

 
  
begin  -- Behoavioral

  IR1_internal <= IR1_in_js;
  IR2_internal <= IR2_in_js;

  -- STALL LOGIC --

  mem_acc <= '1' when (command_ir2 = "000011") else '0';

  reg_acc <= '1' when ((IR2_internal(25 downto 21) = IR1_internal(20 downto 16) or
                       (IR2_internal(25 downto 21) = IR1_internal(15 downto 11)))) else '0';

  send_stall <= '1' when (mem_acc = '1' and reg_acc = '1' and
                          stall_rom(conv_integer(IR1_internal(31 downto 26))) = '1') else '0';  
  
  
  -- JUMP LOGIC --

  dir_jump <= '1' when (command_ir1 = "011001" or command_ir1 = "011011" or 
			command_ir1 = "011101") else '0';

  j <= '1' when (command_ir2 = "011001" or command_ir2 = "011010") else '0';
  
  z_flag_j <= '1' when ((z_flag_in = '1' and conv_integer(command_ir2) >= 27 and conv_integer(command_ir2) <= 28) 
												or (z_flag_in = '0' and conv_integer(command_ir2) >= 29 and conv_integer(command_ir2) <= 30))
              else '0';
  
  take_jump <= '1' when (j = '1' or z_flag_j = '1') else '0';



  
  process(clk)
    begin
      if(rising_edge(clk)) then
        if(rst = '1') then
          PC <= (others => '0');
          PC1 <= (others => '0');
          PC2 <= (others => '0');
        else
	  if (dir_jump = '1') then    
 	    PC2 <= extend;
	  else
	    PC2 <= extend + PC1;
	  end if;

          PC1 <= PC;
          if (mux_signal = "00") then
            PC <= PC + 1;
          elsif (mux_signal = "01") then
            PC <= PC2;	  
          else
            PC <= PC;
          end if;
        end if;
      end if;
    end process;
  PC_out <= PC;
          

  extend(24 downto 0) <= IR1_internal(24 downto 0);
  extend(31 downto 25) <= (others => IR1_internal(25));  


  -- MUX --  
  IR1_out_js <= PM_in              when (mux_signal = "00") else
                (others => '0')    when (mux_signal = "01") else
                IR1_internal;


  IR2_out_js <= IR1_internal when (send_stall = '0') else (others => '0');



end Behavioral;
