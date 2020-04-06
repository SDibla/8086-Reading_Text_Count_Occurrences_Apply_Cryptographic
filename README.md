# 8086-Reading-text-Count-occurrences-Apply-Cryptographic
8086 Assembly code for read in input a short text of 4 lines, each of these lines long from 20 to 50 characters. Count number of occurrences of the letters and apply a cryptographic algorithm (Caesar cipher).

# Reading

The program reads the lines with the instruction INT 21H and stores them in

first_line DB 50 DUP(?)

second_line DB 50 DUP(?)

third_line DB 50 DUP(?)

fourth_line DB 50 DUP(?)

# End of Reading

Reading stops when one of these conditions is satisfied:

•	 After at least 20 characters, an ENTER has been read.

•	 50 characters have been read without any ENTER, after the first 20 characters.

The ENTER character corresponds to 13 in ASCII table (if we read an ENTER in the first 20 characters, the reading must continue).

# Number of occurrences

For each line, the program must count how many times a certain character appears.

consider only letters, a...z, A...Z, discerning upper and lower case. For each line, output the most frequent character (appearing MAX times), print the list of characters appearing at least MAX/2 times. After each character printed, print also the number of occurrences.

# Cryptographic algorithm

I print the text using Caesar cipher, only applied to a...z, A...Z characters.

Given parameter k, the Caesar cipher transforms the letter in a+k, considering the following pattern: a...zA...Za...zA...Z etc. (Non-alphabetic characters stay the same).

I chose k = 1 for the first row, 2 for the second, 3 for the third, 4 for the fourth.

Example with k = 3: piZza -> slcCd.
