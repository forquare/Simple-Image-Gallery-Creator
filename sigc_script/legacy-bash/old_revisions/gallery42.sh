#!/bin/bash
#Author Ben Lavery
#Contact the author: ben.lavery@gmail.com
#Created on 15/05/2010
#Last edited on 29/05/2010
#Revision 42

############## LICENCE ##############
#TThis is licensed under the Creative Commons Licence.
#To view the human-readable summary of this licence, please direct your browser to:
#http://creativecommons.org/licenses/by-sa/2.0/uk/
#For the full licence, direct your browser to:
#http://creativecommons.org/licenses/by-sa/2.0/uk/legalcode
#####################################

#Set error checking for non-zero returning commands
set -e

#For loops should only split at new lines
SAVEDIFS=$IFS
IFS="
"
NEWIFS=$IFS

#Global variables
INDEX_EXTENTION="php"
IMAGE_MANIPULATION_TOOL="/usr/bin/sips"
ROOT=""
THUMBS="$ROOT/thumbs"
BIGS="$ROOT/bigs"
INDEX_FILE="index.$INDEX_EXTENTION"
INDEX="$ROOT/$INDEX_FILE"
NEWPATH=""

#Relative path function
relative(){
	NEWPATH=""
	if [[ "$1" == "$2" ]]
	then
	    NEWPATH="."
	    exit
	fi

	IFS="/"

	CURRENT=($1)
	ABSOLUTE=($2)

	ABSSIZE=${#ABSOLUTE[@]}
	CURSIZE=${#CURRENT[@]}

	while [[ ${ABSOLUTE[$LEVEL]} == ${CURRENT[$LEVEL]} ]]
	do
	    (( LEVEL++ ))
	    if (( LEVEL > ABSSIZE || LEVEL > CURSIZE ))
	    then
	        break
	    fi
	done

	for ((i = LEVEL; i < CURSIZE; i++))
	do
	    if ((i > LEVEL))
	    then
	        NEWPATH=$NEWPATH"/"
	    fi
	    NEWPATH=$NEWPATH".."
	done

	for ((i = LEVEL; i < ABSSIZE; i++))
	do
	    if [[ -n $NEWPATH ]]
	    then
	        NEWPATH=$NEWPATH"/"
	    fi
	    NEWPATH=$NEWPATH${ABSOLUTE[i]}
	done
	
	IFS=$NEWIFS
}

#Usage information
EXIT_STATUS=0
EXIT_REASON=""
usage(){
	if [[ $EXIT_REASON ]]; then
		echo
		echo "Exiting because $EXIT_REASON"
		echo "About to show usage"
		sleep 2
		echo
	fi
	echo "Usage: gallery [-hTq] [-l | -L] [-c number_of_columns] [-e extension] [-t title] [-r relative_to] -d directory"
	echo "    -h - Show this help text."
	echo "    -q - Be quiet - suppress all output."
	echo "    -c - Number of columns per row.  Default is four."
	echo "    -l - Use lightbox for displaying images."
	echo "    -L - Use lightbox for displaying images and groupt them using gallery title."
	echo "        For this option to work, you must either specify a title or auto-generate one."
	echo "        This option will break strict web pages such as XHTML 1.1 and HTML 4 STRICT."
	echo "    -t title - Title of the gallery.  Use quotes when using multiple words."
	echo "    -T - Generate title based on directory name."
	echo "    -r relative directory, escape spaces with a \ symbol."
	echo "    -d directory - Absolute link to directory with images in."
	echo "        Do not put a slash on the end of the path and escape spaces with a \ symbol."
	echo "    "
	echo "    "
	exit $EXIT_STATUS
}

#Gather and check information
HELP="FALSE"
CAPTIONS=""
TITLE=""
GENERATE_TITLE="FALSE"
COLUMNS=4
QUIET="FALSE"
LIGHTBOX=""
while getopts ":c:d:r:t:ThvlL" flag
do
	case $flag in
		c) COLUMNS=$OPTARG;;
		d) DIRECTORY=$OPTARG;;
		e) INDEX_EXTENTION=$OPTARG;;
		h) HELP="TRUE";;
		l) LIGHTBOX="YES";;
		L) LIGHTBOX="GROUP";;
		q) QUIET="TRUE";;
		r) RELATIVE=$OPTARG;;
		t) TITLE=$OPTARG;;
		T) GENERATE_TITLE="TRUE";;
	esac
done

if [[ $HELP == "TRUE" ]]; then
	usage
fi

DIRECTORY=`echo $DIRECTORY | sed 's/\/$//g'`

#Check directory exists, if not then show usage with error message and exist with a stutus of 1
if [[ $QUIET != "TRUE" ]]; then
	echo "Checking to make sure directory exists."
fi
if [[ -d $DIRECTORY ]]; then
	ROOT=$DIRECTORY
	THUMBS=`echo $ROOT/thumbs`
	BIGS=`echo $ROOT/bigs`
	INDEX="$ROOT/$INDEX_FILE"
else
	EXIT_STATUS=1
	EXIT_REASON="location '$DIRECTORY' does not exist."
	usage
fi

#If TITLE has a length of zero, set it to that of the folder
if [[ $GENERATE_TITLE == "TRUE" ]]; then
	if [[ $QUIET != "TRUE" ]]; then
		echo "Generating title."
	fi
	TITLE=`echo $DIRECTORY | sed 's/\(.*\)\/\([^/]*\)/\2/'`
fi

#If LIGHTBOX is set to group, we will group them by gallery name
#But only if TITLE has a non-zero value
if [[ $LIGHTBOX == "GROUP" && -z $TITLE ]]; then
	EXIT_STATUS=1
	EXIT_REASON="You have requested to group lightbox images, but have not provided a title or requested one to be auto-generated."
	usage
fi

#Create folders
if [[ $QUIET != "TRUE" ]]; then
	echo "Creating folders"
fi
mkdir -p $THUMBS
mkdir -p $BIGS


#Copy & move images to folders
SEARCH_PATH=`find "$ROOT"`
for EACH in $SEARCH_PATH; do
	TYPE=`file $EACH`
	if [[ $TYPE =~ image ]]; then
		if [[ $QUIET != "TRUE" ]]; then
			FILE=`echo $EACH | sed 's/\(.*\)\/\([^/]*\)/\2/'`
			echo "Copying image: $FILE."
		fi
		cp $EACH $THUMBS
		if [[ $QUIET != "TRUE" ]]; then
			echo "Moving image: $FILE."
		fi
		mv $EACH $BIGS
	fi
done

#Resize images, first thumbs then bigs
SEARCH_PATH=`find "$THUMBS"`
for EACH in $SEARCH_PATH; do
	TYPE=`file $EACH`
	if [[ $TYPE =~ image ]]; then
		if [[ $QUIET != "TRUE" ]]; then
			FILE=`echo $EACH | sed 's/\(.*\)\/\([^/]*\)/\2/'`
			echo "Resizing image $FILE to create a thumbnail."
		fi
		
		HEIGHT=`$IMAGE_MANIPULATION_TOOL --getProperty pixelHeight $EACH | grep pixelHeight | awk '{ print $2 }'`
		WIDTH=`$IMAGE_MANIPULATION_TOOL --getProperty pixelWidth $EACH | grep pixelWidth | awk '{ print $2 }'`
		if [[ $WIDTH -gt $HEIGHT ]]; then
			$IMAGE_MANIPULATION_TOOL --resampleWidth 128 $EACH > /dev/null 2>&1
		else
			$IMAGE_MANIPULATION_TOOL --resampleHeight 128 $EACH > /dev/null 2>&1
		fi
	fi
done

SEARCH_PATH=`find "$BIGS"`
for EACH in $SEARCH_PATH; do
	TYPE=`file $EACH`
	if [[ $TYPE =~ image ]]; then
		if [[ $QUIET != "TRUE" ]]; then
			FILE=`echo $EACH | sed 's/\(.*\)\/\([^/]*\)/\2/'`
			echo "Resizing image $FILE to create a large image."
		fi
		
		HEIGHT=`$IMAGE_MANIPULATION_TOOL --getProperty pixelHeight $EACH | grep pixelHeight | awk '{ print $2 }'`
		WIDTH=`$IMAGE_MANIPULATION_TOOL --getProperty pixelWidth $EACH | grep pixelWidth | awk '{ print $2 }'`
		if [[ $WIDTH -gt $HEIGHT ]]; then
			if [[ $WIDTH -gt 640 ]]; then
				$IMAGE_MANIPULATION_TOOL --resampleWidth 640 $EACH > /dev/null 2>&1
			fi
		else
			if [[ $HEIGHT -gt 640 ]]; then
				$IMAGE_MANIPULATION_TOOL --resampleHeight 640 $EACH > /dev/null 2>&1 
			fi
		fi
	fi
done

#Put big images into array IMAGES
if [[ $QUIET != "TRUE" ]]; then
	echo "Counting images."
fi
declare -a IMAGES
NUMBER_OF_IMAGES=0
SEARCH_PATH=`find "$BIGS"`
for EACH in $SEARCH_PATH; do
	TYPE=`file $EACH`
	if [[ $TYPE =~ image ]]; then
		IMAGES[$NUMBER_OF_IMAGES]=$EACH
		NUMBER_OF_IMAGES=$(( NUMBER_OF_IMAGES + 1 ))
	fi
done

#Create gallery page
if [[ $QUIET != "TRUE" ]]; then
	echo "Creating index file."
fi
touch $INDEX

if [[ -n $TITLE ]]; then
	if [[ $QUIET != "TRUE" ]]; then
		echo "Printing title into file."
	fi
	echo "<h1>$TITLE</h1>" >> $INDEX
	echo "" >> $INDEX
fi

#Format page
if [[ $QUIET != "TRUE" ]]; then
	echo "Generating gallery."
fi
echo "<div id='gallery-body'>" >> $INDEX
echo "" >> $INDEX
X=0
while [[ $X -lt ${#IMAGES[*]} ]]; do
	echo "    <div class='gallery-column'>" >> $INDEX
	echo "" >> $INDEX
	
	for ((j=1; j <= $COLUMNS; j += 1)); do
		
		if [[ $X -ge ${#IMAGES[*]} ]]; then
			break
		fi
		
		FILE=`echo ${IMAGES[$X]} | sed 's/\(.*\)\/\([^/]*\)/\2/'`

		if [[ -n $RELATIVE ]]; then
			relative $RELATIVE $BIGS
			BIGPATH=$NEWPATH
			relative $RELATIVE $THUMBS
			THUMBPATH=$NEWPATH
		else
			BIGPATH=$BIGS
			THUMBPATH=$THUMBS
		fi

		HEIGHT=`$IMAGE_MANIPULATION_TOOL --getProperty pixelHeight ${IMAGES[$X]} | grep pixelHeight | awk '{ print $2 }'`
		WIDTH=`$IMAGE_MANIPULATION_TOOL --getProperty pixelWidth ${IMAGES[$X]} | grep pixelWidth | awk '{ print $2 }'`
		
		echo "        <div class='gallery-image'>" >> $INDEX
		
		if [[ $WIDTH -gt $HEIGHT ]]; then
			CLASS="class='landscape'"
		else
			CLASS="class='portrait'"
		fi
		
		REL=""
		if [[ $LIGHTBOX == "YES" ]]; then
			REL="rel='lightbox'"
		fi
		if [[ $LIGHTBOX == "GROUP" ]]; then
			REL="rel='lightbox[$TITLE]'"
		fi
		
		echo "            <a href='$BIGPATH/$FILE' $REL><img $CLASS  alt='$FILE' src='$THUMBPATH/$FILE' /></a>" >> $INDEX
		
		echo "        </div>" >> $INDEX
		echo "" >> $INDEX
		X=$(( X + 1 ))
	done
	
	echo "    </div>" >> $INDEX
	echo "" >> $INDEX
	
done
echo "</div>" >> $INDEX

if [[ $QUIET != "TRUE" ]]; then
	echo "Finished."
fi