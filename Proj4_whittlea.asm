TITLE Project 4     (Proj4_whittlea.asm)

; Author: Abigail Whittle
; Last Modified: 2/24/2023
; OSU email address: whittlea@oregonstate.edu
; Course number/section:   CS271 Section 406
; Project Number: 4               Due Date: 2/26
; Description: Program that takes in user input and outputs the specified number of primes.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

UPPER_BOUND = 200
LOWER_BOUND = 1

.data

	; (insert variable definitions here)

    welcome  byte "Prime Numbers Programmed by Abigail Whittle", 0
    instr1    byte "Enter the number of primes you would like to see.", 0
    instr2   byte "I'll accept orders for up to 200 primes.", 0
    prompt   byte "Enter the number of primes to display [1..200]: ", 0
	error    byte "No primes for you! Number out of range. Try again.", 0
	goodbye  byte "Results certified by Abigail Whittle. Goodbye.", 0
	tabStr   byte "   ", 0
    
	num      dword ?
    outNum   dword 1
	divisor  dword 0

.code
main PROC

	; (insert executable instructions here)

	; Call procedures
    call introduction				; Print welcome message and instructions
    call getUserData				; Get number of primes to print
    call showPrimes					; Print primes
    call farewell					; Print goodbye message

    Invoke ExitProcess,0			; exit to operating system
main ENDP

; (insert additional procedures here)

;---------------------------------------------------------------------------
; Name: introduction
; 
; Description: Displays the welcome message and program instructions to the 
; user.
;
; Preconditions: None.
;
; Postconditions: None.
;
; Receives: None.
;
; Returns: None. Does not alter any parameters, but edx is changed
;---------------------------------------------------------------------------

introduction PROC
    mov edx, offset welcome 		; Print welcome message
    call WriteString
    call Crlf
    call Crlf

    mov edx, offset instr1 			; Print instructions
    call WriteString
    call Crlf

    mov edx, offset instr2			; Print instructions
    call WriteString
    call Crlf
    call Crlf

    ret								; Go back to main
introduction ENDP

;---------------------------------------------------------------------------
; Name: getUserData
; 
; Description: Prompts the user to input a number and validates the input. 
; If the input is not within the specified bounds, the user is prompted to 
; re-enter the number. 
;
; Preconditions: None.
;
; Postconditions: Num is within the bounds of [1,200]
;
; Receives: None.
;
; Returns: Returns the user input as a DWORD value in the `eax` register. 
; Does not alter any parameters or global variables. Registers eax and 
; edx are changed
;---------------------------------------------------------------------------

getUserData PROC
	; Loop until number is valid
	getNum:
		mov edx, offset prompt		; Print prompt
		call WriteString
		call ReadDec				; Read in number
		mov num, eax

		call validate				; Validate number
		cmp eax, 1
		je invalid
		mov eax, num

		ret 						; Go back to main

	; If the number is invalid
	invalid:
		mov edx, offset error		; Print error message
		call WriteString
		call Crlf
		jmp getNum					; Go back to getNum
		ret
getUserData ENDP

;---------------------------------------------------------------------------
; Name: validate
; 
; Description: Checks if a given number is within the specified bounds.
;
; Preconditions: There is a numerical value inside of num
;
; Postconditions: Either 0 (successful) or 1 (unsuccessful) in the eax register
;
; Receives: A DWORD value containing the number to be validated, in the `eax` register.
;
; Returns: Returns a boolean value indicating whether the number is within the 
; specified bounds or not. Returns TRUE in the `eax` register if the number is 
; within bounds, and FALSE otherwise. Does not alter any parameters or global 
; variables. Register eax is changed
;---------------------------------------------------------------------------

validate PROC
    cmp eax, LOWER_BOUND			; Check if number is in range
    jl invalidInput
    cmp eax, UPPER_BOUND
    jg invalidInput

    mov eax, 0						; Return true if in range and return to getUserData
    ret

	invalidInput:
		mov eax, 1					; Return false if not in range and return to getUserData
		ret
validate ENDP

;---------------------------------------------------------------------------
; Name: showPrimes
; 
; Description: Displays the specified number of prime numbers.
; Uses a counting loop to keep track of the number of primes displayed, and 
; generates candidate primes within the counting loop, which are passed to 
; isPrime for evaluation.
;
; Preconditions: Num is within the bounds and outNum = 1
;
; Postconditions: A num value of primes has been outputted
;
; Receives: A DWORD value specifying the number of primes to be displayed, 
; in the `eax` register and the number of primes that has already been out-
; putted on a line
;
; Returns: outNum the number of primes that has been printed on the line 
; Registers eax, ebx, ecx, and edx are changed
;---------------------------------------------------------------------------

showPrimes PROC
    mov ecx, eax					; Move number of primes to ecx
    mov ebx, 2						; Start at 2 for the prime

	; Loop  until ecx is 0
	printPrime:
		mov eax, ebx				; Move the current prime to eax
		call isPrime
		cmp eax, 0
		jne nextNum					; If not prime, go to the next number
		
		dec ecx						; Decrement number of primes left to print
		mov eax, ebx
		call WriteDec				; Print prime
		
		cmp outNum, 10				; Check if 10 primes have been printed	
		je nextRow
		inc outNum
		mov edx, offset tabStr		; If not 10, print tab
		call WriteString
		jmp nextNum

	nextRow:
		call Crlf					; If 10, print new line and reset counter
		mov outNum, 1

	nextNum:
		inc ecx						; Balance previous ecx decrement
		inc ebx						; Increment the current prime number
		loop printPrime 			; Loop until all primes are printed
		call Crlf
		ret							; Go back to main
showPrimes ENDP

;---------------------------------------------------------------------------
; Name: isPrime
;
; Description: Determines whether the specified value is prime or not, by 
; checking whether it is evenly divisible by any integer between 2 and itself - 1.
; 
; Preconditions: Eax is within the program bounds
; 
; Postconditions: 0 for prime, 1 for not prime
;
; Receives: The value to be checked, in the `eax` register.
; 
; Returns: A boolean value indicating whether the value is prime (0) or not 
; prime (1), in the `eax` register. Does not alter any other parameters or global 
; variables. Registers eax, ebx, ecx, and edx are changed
;---------------------------------------------------------------------------

isPrime PROC
	push ecx						; Save ecx & ebx
	push ebx
    mov ecx, eax					; Move number to check to ecx
	mov divisor, 2					; Start divisor at 2

	; Loop until divisor is greater than or equal to the number
	divideNum:
		cmp divisor, ecx			; Check if divisor is greater than the number
		jge primeNum
		mov edx, 0					; Clear edx
		mov eax, ecx				; Move number to eax
		div divisor
		cmp edx, 0					; Check if number is divisible by divisor
		je notPrime
		inc divisor					; If not, increment divisor and check again
		jmp divideNum

	primeNum:
		mov eax, 0					; Return true and return to showPrimes
		pop ebx
		pop ecx
		ret

	notPrime:
		mov eax, 1					; Return false and return to showPrimes
		pop ebx
		pop ecx
		ret
isPrime ENDP

;---------------------------------------------------------------------------
; Name: farewell
;
; Description: Displays a farewell message to the user, indicating that the 
; program has finished running.
; 
; Preconditions: None.
; 
; Postconditions: None.
;
; Receives: None.
; 
; Returns: None. Does not alter any parameters, edx is changed
;---------------------------------------------------------------------------

farewell PROC
    call Crlf
    mov edx, offset goodbye
    call WriteString
    call Crlf
    ret
farewell ENDP

END main