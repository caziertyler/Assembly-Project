TITLE CS2810 Assembler Assignment Template

; Student Name: Tyler Cazier
; Assignment Due Date: 4/12/15

INCLUDE Irvine32.inc
.data
	;--------- Enter Data Here (Variables)

	;--------- Application Display Variables
		vSemester byte "CS2810 Spring Semester 2015", 0
		vAssignment byte "Assembler Assignment #4", 0
		vName byte "Tyler Cazier", 0
		vPrompt byte "Enter a FAT16 file date in Hex: ", 0
	
	;--------- Month Array
		vMonthArray byte "January ",0,"  "
					byte "February ",0," "
					byte "March ",0,"    "
					byte "April ",0,"    "
					byte "May ",0,"      "
					byte "June ",0,"     "
					byte "July ",0,"     "
					byte "August ",0,"   "
					byte "September ",0
					byte "October ",0,"  "
					byte "November ",0," "
					byte "December ",0," "

	;--------- Day Variables
	vDayOne byte "0",0
	vDayTwo byte "00",0

		;--------- Suffixes
		vTh byte "th, ",0
		vSt byte "st, ",0
		vNd byte "nd, ",0
		vRd byte "rd, ",0

	;--------- Year Storage
	vYear byte "0000"


.code
main PROC
	;--------- Enter Code Below Here

	;--------- Call Functions
		;--------- Clear Screen and Write Assignment Information
		call ClrScr
		call DisplaySemester
		call DisplayAssignment
		call DisplayName

		;--------- Prompt User for and Read FAT16 Date
		call ReadDate

		;--------- Find and Store Month
		call FindMonth
		

		;--------- Find and Store Day
		call FindDay

		;--------- Find and Store Year
		call FindYear

		;--------- Move to End
		call EndPause

	;--------- Clear Screen and Write Assignment Information
	DisplaySemester:
		mov dh, 4
		mov dl, 33
		call GoToXY

		mov edx, offset vSemester
		call WriteString
		ret

	DisplayAssignment:
		mov dh, 5
		mov dl, 33
		call GoToXY

		mov edx, offset vAssignment
		call WriteString
		ret

	DisplayName:
		mov dh, 6
		mov dl, 33
		call GoToXY

		mov edx, offset vName
		call WriteString
		ret

	;--------- Prompt User for and read Date Value
	ReadDate:

		;--------- Position the Cursor and Prompt User for FAT16 Date Value in Hex
		mov dh, 8
		mov dl, 33
		call GoToXY

		mov edx, offset vPrompt
		call WriteString	

		;--------- Read Hex Value
		call ReadHex
		ror ax,8

		;--------- Move Cursor to Position for Writing
		mov dh, 10
		mov dl, 33
		call GoToXY

		ret

	;--------- Decode Binary Date to ASCII

		;--------- Months
		FindMonth:

			;--------- Preserve a Copy of EAX
			mov ecx, eax

			;--------- Isolate the Four Month Bits
			and ax, 0000000111100000b
			shr ax, 5

			;--------- Check for Zero Case
			cmp eax,0
			jz TheEnd
		
			;--------- Find Month in Month Array
			sub eax, 1
			mov edx, offset [vMonthArray]
			mov bl, 11
			mul bl
			
			;--------- Write to Screen
			add edx, eax
			call WriteString

			ret

		;---------	Day
		FindDay:

			;--------- Restore EAX to Original State
			mov eax, ecx

			;--------- Isolate the Last Five Bits and Convert to Decimal
			and ax, 0000000000011111b

			;--------- Determine Whether Day is One Digit or Two and Proceed Accordingly
			cmp eax, 10
			jl OneDigit

			jmp TwoDigit

			;--------- Convert Copy to ASCII and Write to Screen
			
			;--------- One Digit Case
			OneDigit:
				mov ebx, eax
				add bx, 30h
				mov word ptr [vDayOne+0], bx
				mov edx, offset [vDayOne]
				call WriteString
				jmp CompareLoop

			;--------- Two Digit Case
			TwoDigit:
				;--------- Divide by Ten
				mov bh, 10
				div bh

				;--------- Store and Display
				mov ebx, eax
				add bx, 3030h
				mov word ptr [vDayTwo+0], bx
				mov edx, offset [vDayTwo]
				call WriteString

				;--------- Restore AX
				mov eax, ecx
				and ax, 0000000000011111b

			;--------- Loop Through Possible Suffixes until Correct One is Found
			CompareLoop:
				cmp eax,0
				jz TheEnd
				cmp eax,1
				jz dSt
				cmp eax,2
				jz dNd
				cmp eax,3
				jz dRd
				cmp eax,21
				jz dSt
				cmp eax,22
				jz dNd
				cmp eax,23
				jz dRd
				cmp eax,31
				jz dSt

				;--------- Offset to Correct Suffix and Write to Screen
				mov edx, offset [vTh]
				jmp Display

				dSt:
					mov edx, offset [vSt]
					jmp Display

				dNd:
					mov edx, offset [vNd]
					jmp Display

				dRd:
					mov edx, offset [vRd]
					jmp Display

				Display:
					call WriteString

				ret

		;--------- Year
		FindYear:

			;--------- Isolate the Seven Year Bits
			mov eax, ecx
			and ax, 1111111000000000b
			shr ax, 9
			add ax, 1980

			cmp ax, 0
			jz TheEnd

			;--------- Find 1000 Year's Position and Store
			xor dx,dx
			mov bx, 1000
			div bx
			add al, 30h
			mov byte ptr [vYear], al
			mov ax, dx

			;--------- Find 100 Year's Position and Store
			xor dx,dx
			mov bx, 100
			div bx
			add al, 30h
			mov byte ptr [vYear+1], al
			mov ax, dx

			;--------- Find 10 Year's Position and Store
			xor dx,dx
			mov bl, 10
			div bl
			add ax, 3030h
			mov word ptr [vYear+2], ax
			mov edx, offset [vYear]
			call WriteString
		
	;--------- End Pause
	EndPause:
		xor ecx, ecx
		call ReadChar
		call TheEnd

	;--------- End Program
	TheEnd:
		exit

main ENDP

END main