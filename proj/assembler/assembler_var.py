#!/usr/bin/env python
# -*- coding: utf-8 -*- 



import math

from sys import argv


jump_instr = ('JMP', 'JMPR', 'BEQ', 'BEQR', 'BNE', 'BNER', 'BGR', 'BGRR', 'BNG', 'BNGR')	
two_arg_instr = ('MOVE', 'CMP', 'BTST')

def main(): #main start
	if (len(argv) == 3):
		f = open(argv[1], 'r')
		output_file = open(argv[2], 'wb')
	elif (len(argv) == 2):
		f = open(argv[1], 'r')
		output_file = open('test_out.o', 'wb')
	else:
		return
		


	commands = {'NOP'   : 0, 
							'HALT'  : 1, 
							'MOVE'  : 2, 
							'LOAD'  : 3,
							'GSTORE': 4,
							'STORE' : 5, 
							'ADD' 	: 6,
							'SUB' 	: 8,
							'MULT' 	: 11,
							'AND' 	: 13,
							'OR' 		: 15,
							'LSR' 	: 17,
							'LSL' 	: 19,
							'CMP' 	: 21,
							'BTST' 	: 23,
							'JMP' 	: 25,
							'JMPR' 	: 26,
							'BEQ' 	: 27,
							'BEQR' 	: 28,
							'BNE' 	: 29,
							'BNER' 	: 30,
							'BGR' 	: 31,
							'BGRR' 	: 32,
							'BNG' 	: 33,
							'BNGR' 	: 34}
	
	contains_const = (2, 3, 4, 5, 6, 8, 9, 11, 13, 15, 21, 23, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34)
	variables = dict()

	

	def write_line(s):#{
		temp = s[0].upper()
		instr_num = 0		
		instr_list = [0, 0, 0, 0]

		if (temp in ('ADD', 'MULT', 'AND', 'OR')):
			instr_num = determine_instr(s, commands[temp], 3)
		elif (temp in ('CMP', 'BTST')):
			instr_num = determine_instr(s, commands[temp], 2)
		elif (temp == "SUB"):
			instr_num = determine_instr_sub(s, commands[temp])
		else:
			instr_num = instr_num + commands[temp]

		const = False
		if (instr_num in contains_const):
			const = True

		store = False
		if (temp in ('STORE', 'GSTORE', 'CMP', 'BTST')):
			store = True

		instr_list[0] = instr_num * 4

		if not(temp in ('NOP', 'HALT')):		
			expected = get_expected(temp)

			args_i = conv_list(s[1:], expected, variables)		
			list_to_add = args_func(expected, args_i, const, store)

			for i in range(4):
				instr_list[i] += list_to_add[i]

		#print(instr_list)
		output_file.write(bytearray(instr_list))
		#}



	output_file.write(bytearray([255, 255, 255, 254]))
	

	temp_row_storage = []
	pos = 0;

	while(True):
		s = f.readline()
		if (s == ''):
			break
		s = s[0:s.find(';')]		

		if (s.find(':') != -1):
			variables[s[:s.find(':')]] = pos
		else:			
			s = s.split()

			if (len(s) >= 1):
				pos += 1
				for i in range(len(s) - 1):
					if (s[i+1].find(',') != -1):
						s[i+1] = s[i+1][:-1]
				
				temp_row_storage.append(s)


	for i in range(len(temp_row_storage)):
		write_line(temp_row_storage[i])
	
	output_file.write(bytearray([255, 255, 255, 255]))
#main end


def determine_instr(args_s, base_value, const_pos):
	if (args_s[const_pos][0] == 'R'):
		return base_value + 1
	return base_value

def determine_instr_sub(args_s, base_value):
	if (args_s[2][0] != 'R'):
		return base_value + 1
	elif (args_s[3][0] == 'R'):
		return base_value + 2
	return base_value

def get_expected(arg_name):
	if (arg_name in jump_instr):
		return 1
	elif (arg_name in two_arg_instr):
		return 2
	else:
		return 3


def conv_neg(num, limit):  # negative number
	return limit + num	

def args_func(expected, args_i, const = True, store = False):
	current_pos = 25
	diff = expected;
	r_list = [0, 0, 0, 0];
	if (store):
		current_pos -= 5	
	
	shorter_loop = 0
	if (const):
		shorter_loop = -1	
			
	for i in range(len(args_i) + shorter_loop): # for start // Regs loop
		temp_list = nums_to_add(current_pos, 5, args_i[i])
		for j in range(len(temp_list)):
			r_list[get_list_index(current_pos) + j] += temp_list[j]
		current_pos -= 5	
		diff -= 1
	# for end	

	for i in range(diff + shorter_loop): # behöver fixas för noll-reg
		current_pos -= 5	
		
	if (const):
		temp_list = nums_to_add(current_pos, current_pos + 1, args_i[-1])
		for i in range(len(temp_list)):		
				r_list[get_list_index(current_pos) + i] += temp_list[i]


	return r_list



def get_list_index(pos):
	return 3 - (pos // 8)


			
def nums_to_add(pos, size, num):
	if (num < 0):
		num = conv_neg(num, pow(2, size + 1))

	bits_written = (pos % 8) + 1
	diff = bits_written - size
	if (diff >= 0):
		return [num * pow(2, diff)]
	else:		
		diff = abs(diff);
		return [num // pow(2, diff)] + nums_to_add(pos - bits_written, size - bits_written, num % pow(2, diff))	



def conv_list(args_s, size, variables):
	r_args = [0 for i in range(size)]
	const_early = 0;

	for i in range(len(args_s)): # for start
		temp_arg = args_s[i]
		if (temp_arg in variables):
			r_args[i + const_early] = variables[temp_arg]
		elif (temp_arg[0] == 'R'):
			temp_arg = temp_arg[1:]
			r_args[i + const_early] = int(temp_arg)
		else:
			r_args[len(args_s) - 1] = int(temp_arg);
			const_early = -1
	# for end
	return r_args

if __name__ == "__main__":
    main()












		
