#!/bin/sh

#
# Description of the various functions follows below.
#

#
#	Creating a usage message function to provide
#	info on how to enter the command line parameters.
#

usage(){
	script=$1
	shift

	echo "Usage: `basename $script` $*" 1>&2
	exit 2
}

#usage $0 filename username ...

#
#	pause()
#
#	Asks user to press ENTER and wait for then to do so.
#
pause(){
	echo "\n\tPlease press <ENTER> to continue \c"
	read junk
}

#
#	yesno()
#
#	A function, which when called, prints out the parameter and asks for a Yes or No kind of answer.
#	If nothing is entered then the function repeats the "echo" and "read" statement again.
#	If Yes is answered, the function returns an exit status of 0 (True)
#	If No is answered, the function returns an exit status of 1 (False)
#

yesno(){
	#
	#	Loop until a valid response is entered
	#
	while true
	do
		#
		#	Displaying the string(s) using $*
		#
		echo "\n\t $* (Y/N)? \c"

		#
		#	Accepting answer
		#
		read ans junk
		case $ans in
			[yY]|[yY]es|YES)
					return 0 ;;
		          [nN]|no|No|NO)
					return 1 ;;
			              *)
					      echo "\n\t\tPlease enter Yes or No" ;;
		esac
	done
}

#
#	graceful_exit()
#
#	If a kill signal of 2 or 3 is supplied by the user, graceful_exit() is called...
#	The function reconfirms the user's choice to quit the program shell.
#	The function exits the shell if the user enters "Yes", else continues with the program.
#
graceful_exit(){
	yesno Do you really wish to quit now? && exit
}

#
#	do_create()
#
#	Create records for our database
#
do_create(){
	while :
	do
		while :
		do
				#
				# Asking for details
				#
				clear
				echo "\tPlease enter the following details- "
				echo "\n\tFirst Name: \c"
				read name
				echo "\tSurname: \c"
				read surname
				echo "\tStreet No.: \c"
				read street
				echo "\tCity: \c"
				read city
				echo "\tState: \c"
				read state
				echo "\tZip: \c"
				read zip

				echo "\tYou have entered the following details:- \n"
				echo "\t\tFirst Name: $name"
 				echo "\t\tSurname: $surname"
				echo "\t\tStreet No.: $street"
				echo "\t\tCity: $city"
				echo "\t\tState: $state"
				echo "\t\tZip: $zip"

				#
				#	Asking user to confirm the record.
				#


					# Note: Here, we are not going to use : "yesno Are these details correct? || break"
					# Like a few lines below for creating another record.
					# This is because if we say "No" - it will work properly
					# i.e. it will break from the current while loop and ask for
					# a new record promt - which is fine.
					# HOWEVER, if we type "Yes" it continues the infinite loop
					# and asks for new details without asking for a create new record prompt.
					#
					# Now, when we use if statement, the "Yes" option works perfectly and the "No"
					# option results in the shell once more asking for details, without
					# prompting for a create new record which is in a different loop.

				if yesno Are these details correct?
				then
					#
					# Writing the details to the text file
					#
					echo "\t$name:$surname:$street:$city:$state:$zip" >> $fname
					#
					#Above, '$fname' refers to the file in which the data is to be written.
					# It WILL NOT store the echo output to the variable fname.
					#
					break
				fi
		done
		#
		#	Asking the user if they wish to create another record
		#	The "break" bit will only be executed if the user answers "No"
		#
		yesno Do you want to create another record? || break
	done
}

#
#	do_view
#
#	Displays the currently stored records.
#
#
do_view(){

	clear
	# Showing the details of the file
	#
	(
		echo
		echo "Here are the details of the file: "
		echo

		#
		# Sorting output using the -t for delimiter ":"
		# 		 using the -k2 option for sorting by surname('2' is for the second field)
		# And then piping the result to awk.
		#

		sort -t : -k2 $1 | awk -F : '
		BEGIN{
			print ("=====================================================================================================================");
			printf("\t\t%-15s %-10s %-30s %-15s %-15s %-6s\n", "Name", "Surname", "Street No.", "City", "State", "Zip");
			print ("=====================================================================================================================");
		}
		{
			printf("\t %-15s %-10s %-30s %-15s %-15s %-6d \n", $1, $2, $3, $4, $5, $6);
		}
		'
	)|more
	echo
	echo "\tThe number of records are: `cat $1 | wc -l` \n"
}

#
#	do_search
#
#	Searches the stored records.
#
do_search(){
	while :
	do
		while :
		do
			clear
			echo "\n\n\t\tPlease enter your search pattern: \c"
			read sp
			if [ "$sp" = "" ]
			then
				echo "\n\t\tYou did not enter any search pattern."
				echo "\n\t\tIf you wish to view all the contacts, please select view option."
				pause
			else
				break
			fi
		done
		if [ "`grep -c $sp $fname`" != "0" ]
		then
			grep -e $sp $fname > search.$$
			do_view search.$$
			rm search.$$
		else
			echo "\n\n\t\tSorry! There are no records that match your search pattern."
		fi
		yesno "Would you like to search again?" || break
	done
}

#
#	do_delete
#
#	Deletes stored records.
#
do_delete(){
	while :
	do
		clear
		echo "\n\n\t\tPlease enter your search pattern: \c"
		read sp
		if [ "$sp" = "" ]
		then
			yesno "Do you really wish to DELETE ALL records?" || break
			rm $fname
			> $fname
			echo "\n\t\tAll records deleted successfully!"
			break
		fi
		if [ "`grep -c $sp $fname`" != "0" ]
		then
			grep -e $sp $fname > search.$$
			do_view search.$$
			rm search.$$
			if yesno "Do you want to DELETE these contact(s) ?"
			then
				if yesno "Are you sure?"
				then
					grep -v -e $sp $fname >> names.$$
					rm $fname
					cp names.$$ $fname
					rm names.$$
					echo "\n\t The records are deleted!"
				else
					break
				fi
			else
				break
			fi

		else
			echo "\n\n\t\tSorry! There are no records that match your search pattern."
		fi
		yesno "Do you want to delete any other records?" || break
	done
}
