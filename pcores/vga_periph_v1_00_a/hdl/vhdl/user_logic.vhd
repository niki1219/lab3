------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Tue Mar 26 09:27:14 2019 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_NUM_REG                    -- Number of software accessible registers
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Resetn                -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    RES_TYPE             : natural := 1;
    TEXT_MEM_DATA_WIDTH  : natural := 6;
    GRAPH_MEM_DATA_WIDTH : natural := 32
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_NUM_REG                      : integer              := 1;
    C_SLV_DWIDTH                   : integer              := 32
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
	 clk_i          : in  std_logic;
    reset_n_i      : in  std_logic;
    -- vga
	direct_mode_i     : in std_logic;
	display_mode_i : in std_logic_vector( 1 downto 0);
    vga_hsync_o    : out std_logic;
    vga_vsync_o    : out std_logic;
    blank_o        : out std_logic;
    pix_clock_o    : out std_logic;
    psave_o        : out std_logic;
    sync_o         : out std_logic;
    red_o          : out std_logic_vector(7 downto 0);
    green_o        : out std_logic_vector(7 downto 0);
    blue_o         : out std_logic_vector(7 downto 0)
	 
	 LED_Data : out std_logic_vector(7 downto 0);
	 DIP_Data : in std_logic_vector(7 downto 0);
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Resetn                  : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
    Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Resetn : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic

	  signal message_lenght      : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
  signal graphics_lenght     : std_logic_vector(GRAPH_MEM_ADDR_WIDTH-1 downto 0);
  
  signal direct_mode         : std_logic;
  --
  signal font_size           : std_logic_vector(3 downto 0);
  signal show_frame          : std_logic;
  signal display_mode        : std_logic_vector(1 downto 0);  -- 01 - text mode, 10 - graphics mode, 11 - text & graphics
  signal foreground_color    : std_logic_vector(23 downto 0);
  signal background_color    : std_logic_vector(23 downto 0);
  signal frame_color         : std_logic_vector(23 downto 0);

  signal char_we             : std_logic;
  signal char_address        : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
  signal offset              : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
  signal offset_next 		  : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
  signal char_value          : std_logic_vector(5 downto 0);

  signal pixel_address       : std_logic_vector(GRAPH_MEM_ADDR_WIDTH-1 downto 0);
  signal pixel_value         : std_logic_vector(GRAPH_MEM_DATA_WIDTH-1 downto 0);
  signal pixel_we            : std_logic;
  signal add					  : std_logic_vector(9 downto 0);
  
    signal counter  			  : std_logic_vector(10 downto 0);
  signal counter_s  			  : std_logic_vector(10 downto 0);


  signal pix_clock_s         : std_logic;
  signal vga_rst_n_s         : std_logic;
  signal pix_clock_n         : std_logic;
   
  signal dir_red             : std_logic_vector(7 downto 0);
  signal dir_green           : std_logic_vector(7 downto 0);
  signal dir_blue            : std_logic_vector(7 downto 0);
  signal dir_pixel_column    : std_logic_vector(10 downto 0);
  signal dir_pixel_row       : std_logic_vector(10 downto 0);
  
  signal sec_cnt             : std_logic_vector(24 downto 0);
  signal sec_cnt_next 		  : std_logic_vector(24 downto 0);

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg_write_sel              : std_logic_vector(0 to 0);
  signal slv_reg_read_sel               : std_logic_vector(0 to 0);
  signal slv_ip2bus_data                : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

begin

  --USER logic implementation added here
	LED_Data <= slv_reg0(7 downto 0);
	
	  dir_red <= x"ff" when dir_pixel_column < 80 else
				 x"ff" when dir_pixel_column < 160 else
				 x"00" when dir_pixel_column < 240 else
				 x"00" when dir_pixel_column < 320 else
				 x"ff" when dir_pixel_column < 400 else
				 x"ff" when dir_pixel_column < 480 else
				 x"00" when dir_pixel_column < 560 else
				 x"00";

	dir_green <= x"ff" when dir_pixel_column < 80 else
					x"ff" when dir_pixel_column < 160 else
					x"ff" when dir_pixel_column < 240 else
					x"ff" when dir_pixel_column < 320 else
					x"00" when dir_pixel_column < 400 else
					x"00" when dir_pixel_column < 480 else
					x"00" when dir_pixel_column < 560 else
					x"00";
				 
	dir_blue <= x"ff" when dir_pixel_column < 80 else
				  x"00" when dir_pixel_column < 160 else
				  x"ff" when dir_pixel_column < 240 else
				  x"00" when dir_pixel_column < 320 else
				  x"ff" when dir_pixel_column < 400 else
				  x"00" when dir_pixel_column < 480 else
				  x"ff" when dir_pixel_column < 560 else
				  x"00";
 
  -- koristeci signale realizovati logiku koja pise po TXT_MEM
  --char_address
  --char_value
  --char_we
  
  char_we <= '1';
  
  process(pix_clock_s)begin
		if( rising_edge(pix_clock_s) )then
			sec_cnt <= sec_cnt_next;
			offset <= offset_next;
			
			if(char_address = "00010010110000") then
				char_address <= "00000000000000";
			else
				char_address <= char_address + '1';
			end if;
		end if;
  end process;
  
  char_value <= "000000" when char_address ="00000001111000" + offset else
					"000001" when char_address = "00000001111001" + offset else
					"000010" when char_address = "00000001111010" + offset else
					"000011" when char_address = "00000001111011" + offset else
					"100000";
					
	sec_cnt_next <= sec_cnt + 1 when sec_cnt < 01000000 else (others => '0');
	offset_next <= offset when sec_cnt < 01000000 else
						offset + 1 when offset < 1100 else (others => '0');
  
  -- koristeci signale realizovati logiku koja pise po GRAPH_MEM
  --pixel_address
  --pixel_value
  --pixel_we
  
	pixel_we<='1';
	process(pix_clock_n) begin
	if(rising_edge(pix_clock_n)) then
		if(pixel_address="1001011000000000000") then
			pixel_address<=(others=>'0');
			counter_s<=counter_s+1;
			if(counter_s = "00000100100") then  
				add<=add+1;
				if(add="0000010100") then
					add<=(others=>'0');
				end if;
				counter_s<=(others=>'0');
			end if;
		else
			pixel_address<=pixel_address+1;
		end if;
	end if;
	end process;
	
  pixel_value<=x"FFFFFFFF" when pixel_address=(x"00064"+add) else
					x"FFFFFFFF" when pixel_address=(x"00078"+add) else
					x"FFFFFFFF" when pixel_address=(x"0008C"+add) else
					x"FFFFFFFF" when pixel_address=(x"000A0"+add) else
					x"FFFFFFFF" when pixel_address=(x"000B4"+add) else
					x"FFFFFFFF" when pixel_address=(x"000C8"+add) else
					x"FFFFFFFF" when pixel_address=(x"000DC"+add) else
					x"FFFFFFFF" when pixel_address=(x"000F0"+add) else
					x"FFFFFFFF" when pixel_address=(x"00104"+add) else
					x"FFFFFFFF" when pixel_address=(x"00118"+add) else
					x"FFFFFFFF" when pixel_address=(x"0012C"+add) else
					x"FFFFFFFF" when pixel_address=(x"00140"+add) else
					x"FFFFFFFF" when pixel_address=(x"00154"+add) else
					x"FFFFFFFF" when pixel_address=(x"00168"+add) else
					x"FFFFFFFF" when pixel_address=(x"0017C"+add) else
					x"FFFFFFFF" when pixel_address=(x"00190"+add) else
					x"FFFFFFFF" when pixel_address=(x"001A4"+add) else
					x"FFFFFFFF" when pixel_address=(x"001B8"+add) else
					x"FFFFFFFF" when pixel_address=(x"001CC"+add) else
					x"FFFFFFFF" when pixel_address=(x"001E0"+add) else
					x"FFFFFFFF" when pixel_address=(x"001F4"+add) else
					x"FFFFFFFF" when pixel_address=(x"00208"+add) else
					x"FFFFFFFF" when pixel_address=(x"0021C"+add) else
					x"FFFFFFFF" when pixel_address=(x"00230"+add) else
					x"FFFFFFFF" when pixel_address=(x"00244"+add) else
					x"FFFFFFFF" when pixel_address=(x"00258"+add) else
					x"00000000";
  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(0 downto 0);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 downto 0);
  slv_write_ack     <= Bus2IP_WrCE(0);
  slv_read_ack      <= Bus2IP_RdCE(0);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Resetn = '0' then
        slv_reg0 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "1" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0 ) is
  begin

    case slv_reg_read_sel is
      when "1" => slv_ip2bus_data <= slv_reg0;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
	IP2Bus_Data(31 downto 8) <= (others=>'0'); 
	IP2Bus_Data(7 downto 0) <= DIP_Data(7 downto 0);

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

end IMP;
