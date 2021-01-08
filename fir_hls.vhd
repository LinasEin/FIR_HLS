-- ----------------------------------------------------------------------------
-- LegUp High-Level Synthesis Tool Version 8.1 (http://www.legupcomputing.com)
-- Copyright (c) 2015-2020 LegUp Computing Inc. All Rights Reserved.
-- For technical issues, please contact: support@legupcomputing.com
-- For general inquiries, please contact: info@legupcomputing.com
-- Date: Sat Dec  5 14:04:39 2020
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


library work;
use work.legup_types_pkg.all;
entity FIRFilterStreaming_top_vhdl is
port (
	                     i_clk	:	in	std_logic;
	                   i_reset	:	in	std_logic;
	                   i_start	:	in	std_logic;
	                  o_finish	:	out	std_logic;
	              i_input_fifo	:	in	std_logic_vector(31 downto 0);
	        o_input_fifo_ready	:	out	std_logic;
	        i_input_fifo_valid	:	in	std_logic;
	             o_output_fifo	:	out	std_logic_vector(31 downto 0);
	       i_output_fifo_ready	:	in	std_logic;
	       o_output_fifo_valid	:	out	std_logic
);
end FIRFilterStreaming_top_vhdl;

architecture behavior of FIRFilterStreaming_top_vhdl is

component FIRFilterStreaming_top
port (
	                         clk	:	in	std_logic;
	                       reset	:	in	std_logic;
	                       start	:	in	std_logic;
	                      finish	:	out	std_logic;
	 input_fifo_data_from_source	:	in	std_logic_vector(31 downto 0);
	  input_fifo_ready_to_source	:	out	std_logic;
	input_fifo_valid_from_source	:	in	std_logic;
	    output_fifo_data_to_sink	:	out	std_logic_vector(31 downto 0);
	 output_fifo_ready_from_sink	:	in	std_logic;
	   output_fifo_valid_to_sink	:	out	std_logic
);
end component;

begin


FIRFilterStreaming_top_inst : FIRFilterStreaming_top
port map (
	                       clk	=>	i_clk,
	                     reset	=>	i_reset,
	                     start	=>	i_start,
	                    finish	=>	o_finish,
	input_fifo_data_from_source	=>	i_input_fifo(31 downto 0),
	input_fifo_ready_to_source	=>	o_input_fifo_ready,
	input_fifo_valid_from_source	=>	i_input_fifo_valid,
	  output_fifo_data_to_sink	=>	o_output_fifo(31 downto 0),
	output_fifo_ready_from_sink	=>	i_output_fifo_ready,
	 output_fifo_valid_to_sink	=>	o_output_fifo_valid
);


end behavior;
