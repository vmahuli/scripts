#!/usr/bin/env python3

'''
This script takes 2 numbers as input and prints
the fibonacci series between these two numbers.

Author: Vinay Mahuli
'''

import sys

def parse_input(start_num, end_num):
    # Generate fibonacci series till the last number, but print only numbers between start and end number

    # initialise first 2 numbers
    n,m=0,1

    # Display results
    print ("\nFibbonacci series between {} and {}:\n".format(start_num, end_num))
    while m < end_num:
        # Display between 2 numbers
        if m > start_num:
            print(m)
        n,m = m,n+m

def error_num():
    # Error Message
    print("You need to enter positive numbers!!")
    sys.exit(1)

def main():
    #input 2 numbers
    try:
        start_num=input("Enter start number:")
        start_num=int(start_num)
    except ValueError as ve1:
        error_num()

    try:
        end_num=input("Enter End number:")
        end_num=int(end_num)
    except ValueError as ve2:
        error_num()

    parse_input(start_num, end_num)

# Handle keyboard interrupts Ctrl+C and Ctrl+D
if __name__ == "__main__":
   try:
      main()
   except (KeyboardInterrupt,EOFError) as e:
      # do nothing here
      pass
