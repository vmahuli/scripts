#!/usr/bin/env python3

'''
This script takes 2 lists as input and combines the elements
seperately and then adds the 2 numbers which we get from the
list.

Author: Vinay Mahuli
'''

import sys

# Initialise input lists
list1 = []
list2 = []

# Define functions
def parse_input(list):
        # Take input as list
        list = input("Enter list elements separated by space: ").split()
        print("The input list is {}".format(list))

        # Reverse it
        list.reverse()
        print("Reversing this list {}".format(list))

        # Convert list to string (concatinate)
        listToStr = ' '.join(map(str, list))

        # Convert it to int and remove spaces inbetween
        Num=int(listToStr.replace(" ", ""))

        # Return number
        return Num

def error_string():
        # Error Message
        print("You need to enter numbers with spaces!!")
        sys.exit(1)

def main():
  # Handle exceptions (handle comma seperated inputs)
  try:
    # Pass first list to parse
    OneNum = parse_input(list1)
  except ValueError as ve1:
    error_string()

  # Handle exceptions (handle comma seperated inputs)
  try:
    # Pass second list to parse
    SecNum = parse_input(list2)
  except ValueError as ve2:
    error_string()

  # Add two numbers
  result = OneNum + SecNum

  # Display result on to the console
  print ("================================")
  print ("Final Sum is {}".format(result))
  print ("================================")

  print ("Seperating and reversing ==> {}".format(result))

  seperate = [int(x) for x in str(result)]
  seperate.reverse()
  print ("================================")
  print ("The reverted list is {}".format(seperate))
  print ("================================")

# Handle keyboard interrupts Ctrl+C and Ctrl+D
if __name__ == "__main__":
   try:
      main()
   except (KeyboardInterrupt,EOFError) as e:
      # do nothing here
      pass
