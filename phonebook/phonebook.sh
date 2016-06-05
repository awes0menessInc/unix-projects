#!/bin/bash
#
#	Setting traps for the kill signals.
#
trap exit 1 15
trap graceful_exit 2 3	# Find graceful_exit under functions
#########################################################################
#			Project - Phoneboook				#
#			  By Shivam Bajpayi			   	#
#########################################################################

#
#	We are including various functions from "functions.sh"
#	Usage message - Enter name of the data file to use the program
#	$0 indicates the filename of the current shell program
#
. phonebook/functions.sh

[ $# = 1 ] || usage $0 filename

#Exits the program if the user does not enter the specific amount of parameters(1)

#
###########################################################
#fname is taken as a command line parameter from the user.#
#Variable 'fname' stores the name of the file stored.	  #
#Change 'fname' to write details on a different file.	  #
###########################################################
#
fname="$1"

#
#
#Checking if file exists...
#	and if not, then creating the file.
#
#
if [ ! -f "$fname" ]
	then
		while :
		do
			echo "\n\tFile $fname does not exist..."
			if yesno "\tDo you want to create a file named $fname?"
			then
				>$fname
				if [ -f "$fname" -a -w "$fname" ]
				then
					break
				fi
			else
				exit
			fi
		done
elif [ ! -w "$fname" ]
then
	echo "\n\tFile $fname is not writable."
	echo "\tExiting..."
	exit
fi
#
#	We have now confirmed that the data file exists and is writable
#

#
#	Main code starts here...
#
#
choice=""
while :
	do
		#
		#Printing Menu
		#
		clear
		echo
		echo "\t\t\tWelcome to your Phonebook!"
		echo "\t\t\t     PID: $$"
		echo "\tPlease choose your action: "
		echo "\t\t 1. Create a record"
		echo "\t\t 2. View records"
		echo "\t\t 3. Search for records"
		echo "\t\t 4. Delete records that match a pattern"
		echo "\n\t Answer (or 'q' to quit)? \c"
		read ch

		#
		#Empty answers (pressing ENTER) causes the menu to redisplay.
		#
		[ "$ch" = "" ] && continue

		#
		#Building up cases for menu choices
		#
		case "$ch" in
			1)	do_create;;
			2)	do_view $fname ;;
			3)	do_search;;
			4)	do_delete;;
			q*|Q*) 	yesno "\tDo you really wish to exit" && exit
			        ;;
			*)
				echo "\tYou have entered an incorrect choice, please try again. \n"
				;;
		esac
		#
		#	Pause to give user a chance to see whats on the screen.
		#
		pause
done
