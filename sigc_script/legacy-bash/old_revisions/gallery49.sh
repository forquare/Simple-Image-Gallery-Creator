#!/bin/bash
#Author Ben Lavery
#Contact the author: ben.lavery@gmail.com
#Created on 15/05/2010
#Last edited on 05/06/2010
REVISION=49


###############################################################################################################
########################################## Licence ##########################################################
###############################################################################################################
#TThis is licensed under the Creative Commons Licence.
#To view the human-readable summary of this licence, please direct your browser to:
#http://creativecommons.org/licenses/by-sa/2.0/uk/
#For the full licence, direct your browser to:
#http://creativecommons.org/licenses/by-sa/2.0/uk/legalcode
###############################################################################################################


###############################################################################################################
###############################################################################################################
###############################################################################################################
####Set error checking for non-zero returning commands####
set -e

####For loops should only split at new lines####
SAVEDIFS=$IFS
IFS="
"
NEWIFS=$IFS
###############################################################################################################


###############################################################################################################
########################################## Variables ##########################################################
###############################################################################################################
####IMAGE TOOL####
IMAGE_TOOL=""

####FILE SETTINGS####
INDEX_EXTENTION="php"

####GALLERY SETTINGS####
CAPTIONS="FALSE"
TITLE=""
GENERATE_TITLE="FALSE"
COLUMNS=4
LIGHTBOX=""
FULL_HTML="FALSE"

####IMAGE SETTINGS####
HEIGHT=""
WIDTH=""
THUMB_PIXELS=128
BIG_PIXELS=640
declare -a IMAGES
NUMBER_OF_IMAGES=0

####SCRIPT SETTINGS####
QUIET="FALSE"
EXIT_STATUS=0
EXIT_REASON=""
SEARCH_PATH=""
HELP=""
VERSION=""

####DIRECTORIES####
ROOT=""
THUMBS="$ROOT/thumbs"
BIGS="$ROOT/bigs"
INDEX_FILE="index.$INDEX_EXTENTION"
INDEX="$ROOT/$INDEX_FILE"
NEWPATH=""
SOURCE=""
RELATIVE=""
DIRECTORY=""
###############################################################################################################


###############################################################################################################
########################################## Relative Path Function #############################################
###############################################################################################################
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
###############################################################################################################


###############################################################################################################
########################################## Image Property Functions ###########################################
###############################################################################################################
#Sets variable HEIGHT to height of image, pass in image
get_height(){
	if [[ $IMAGE_TOOL =~ "sips" ]]; then
		HEIGHT=`$SIPS --getProperty pixelHeight $1 | grep pixelHeight | awk '{ print $2 }'`
	else
		HEIGHT=`$INDENTIFY -format '%h' $1`
	fi
}

#Sets variable WIDTH to width of image, pass in image
get_width(){
	if [[ $IMAGE_TOOL =~ "sips" ]]; then
		WIDTH=`sips --getProperty pixelWidth $1 | grep pixelWidth | awk '{ print $2 }'`
	else
		WIDTH=`$INDENTIFY -format '%w' $1`
	fi
}

#Scales image based on height, pass in scale in pixels then image
resize_height(){
	if [[ $IMAGE_TOOL == "sips" ]]; then
		$SIPS --resampleHeight $1 $2 > /dev/null 2>&1
	else
		#Using x$1 we apply the resizing to the height, not the width.
		#Must specify this in a new variable:
		TMP="x$1"
		$CONVERT -sample $TMP $2 $2 > /dev/null 2>&1
	fi
}

#Scales image based on height, pass in scale in pixels then image
resize_width(){
	if [[ $IMAGE_TOOL == "sips" ]]; then
		$SIPS --resampleWidth $1 $2 > /dev/null 2>&1
	else
		$CONVERT -sample $1 $2 $2 > /dev/null 2>&1
	fi
}
###############################################################################################################


###############################################################################################################
########################################## Print Revision Function ############################################
###############################################################################################################
print_revision(){
	echo "Revision: $REVISION"
	exit 0
}
###############################################################################################################


###############################################################################################################
########################################## Print usage Function ###############################################
###############################################################################################################
EXIT_STATUS=0
EXIT_REASON=""
usage(){
	if [[ $EXIT_REASON ]]; then
		echo
		echo "Exiting because: $EXIT_REASON"
		echo "About to show usage"
		sleep 2
		echo
	fi
	echo "Usage: gallery [-ChqTV] [-l | -L] [-B big_image_size_in_pixels] \ "
	echo "    [-c number_of_columns] [-e extension] [-t title] [-r relative_to] \ "
	echo "    [-s source_directory] [-S small_image_size_in_pixels] -d directory"
	echo
	echo "    -B big_image_size_in_pixels - The size of the main images."
	echo "       The number is applied to the longest side and is measured in pixels."
	echo "    -c - Number of columns per row.  Default is four."
	echo "    -C - Use captions - These are generated using the file names without"
	echo "         the file extension."
	echo "    -d directory - Absolute link to directory with images in."
	echo "         Escape spaces with a \ symbol."
	echo "    -e - Extension for the gallery file.  Default is php."
	echo "    -h - Show this help text."
	echo "    -l - Use lightbox for displaying images."
	echo "    -L - Use lightbox for displaying images and groupt them using gallery title."
	echo "         For this option to work, you must either specify a title"
	echo "         or auto-generate one.  This option will break strict web pages such"
	echo "         as XHTML 1.1 and HTML 4 STRICT."
	echo "    -q - Be quiet - suppress all output."
	echo "    -r relative directory - Directory image links should be relative to."
	echo "       Escape spaces with a \ symbol."
	echo "    -s source directory - Use this directory as a source for images."
	echo "       Images will be copied from here into the directory specified"
	echo "       using the -d option."
	echo "    -S small_image_size_in_pixels - The size of thumbnails."
	echo "       The number is applied to the longest side and is measured in pixels."
	echo "    -t title - Title of the gallery.  Use quotes when using multiple words."
	echo "    -T - Generate title based on directory name."
	echo "    -V - Print version (revision)."
	echo "    "
	echo "    "
	exit $EXIT_STATUS
}
###############################################################################################################


###############################################################################################################
########################################## Find tools Function ################################################
###############################################################################################################
get_tool(){
	set +e
	SIPS=`which sips`
	CONVERT=`which convert`
	INDENTIFY=`which identify`
	set -e

	if [[ $QUIET != "TRUE" ]]; then
		echo "Checking image manipulation tools."
	fi

	if [[ -n $SIPS ]]; then
		if [[ $SIPS =~ "no sips in" ]]; then
			IMAGE_TOOL="convert+indentify"
		else
			IMAGE_TOOL="sips"
		fi
	elif [[ -n $CONVERT && -n $INDENTIFY ]]; then
		if [[ $CONVERT =~ "no convert in" || $INDENTIFY =~ "no identify in" ]]; then
			IMAGE_TOOL="convert+indentify"
		fi
	else
		EXIT_STATUS=1
		EXIT_REASON="No image manipulation tools found.  Please try installing ImageMagick, specifically the `convert` and `identify` commands."
		usage
	fi
}
###############################################################################################################


###############################################################################################################
########################################## Get and Check Flags Function #######################################
###############################################################################################################
check_flags(){
	#Check for help of version flags
	if [[ $HELP == "TRUE" ]]; then
		usage
	fi
	
	if [[ $VERSION == "TRUE" ]]; then
		print_revision
	fi
	
	#If user didn't specify -d or didn't specify a directory, quit.
	if [[ -z $DIRECTORY ]]; then
		EXIT_STATUS=1
		EXIT_REASON="You have not specified the -d flag with an argument."
		usage
	fi
	
	#Shave off any leading slash
	DIRECTORY=`echo $DIRECTORY | sed 's/\/$//g'`
	
	#Remove any alphabetic characters from pixel strings
	THUMB_PIXELS=`echo $THUMB_PIXELS | sed 's/[a-zA-Z]//g'`
	BIG_PIXELS=`echo $BIG_PIXELS | sed 's/[a-zA-Z]//g'`
	
	#If user specified a title and told the script to generate a title
	#just take the title the user gave us and ignor the generation.
	if [[ -n $TITLE && $GENERATE_TITLE == "TRUE" ]]; then
		$GENERATE_TITLE == "FALSE"
	fi
	
	#If LIGHTBOX is set to group, we will group them by gallery name
	#But only if TITLE has a non-zero value or a title is going to be generated
	if [[ $LIGHTBOX == "GROUP" ]]; then
		if [[ -n $TITLE || $GENERATE_TITLE == "TRUE" ]]; then
			EXIT_STATUS=1
			EXIT_REASON="You have requested to group lightbox images, but have not provided a title or requested one to be auto-generated."
			usage
		fi
	fi
}
###############################################################################################################


###############################################################################################################
########################################## Check source directory Function ####################################
###############################################################################################################
check_source_directory(){
	if [[ $QUIET != "TRUE" ]]; then
		echo "Checking to make sure source directory exists."
	fi

	if [[ $SOURCE == $DIRECTORY ]]; then
		EXIT_STATUS=1
		EXIT_REASON="Source directory and destination directory are the same."
		usage
	fi

	if [[ -d $SOURCE ]]; then
		mkdir -p $DIRECTORY
		SEARCH_PATH=`find "$SOURCE"`
		X=0
		for EACH in $SEARCH_PATH; do
			TYPE=`file $EACH`
			if [[ $TYPE =~ "image" || $TYPE =~ "PNG" || $TYPE =~ "JPEG" || $TYPE =~ "GIF" || $TYPE =~ "TIFF" ]]; then
				if [[ $QUIET != "TRUE" ]]; then
					FILE=`echo $EACH | sed 's/\(.*\)\/\([^/]*\)/\2/'`
					echo "Copying image: $FILE to gallery directory."
				fi
				cp $EACH $DIRECTORY
				
				#Count number of images
				X=$(( X + 1))
			fi
		done
		if [[ $X -eq 0 ]]; then
			EXIT_STATUS=1
			EXIT_REASON="There are no images in the source folder ('$SOURCE')."
			usage
		fi
	else
		EXIT_STATUS=1
		EXIT_REASON="Source folder '$SOURCE' does not exist."
		usage
	fi
	
}
###############################################################################################################


###############################################################################################################
########################################## Check gallery directory Function ###################################
###############################################################################################################
check_gallery_directory(){
	if [[ $QUIET != "TRUE" ]]; then
		echo "Checking to make sure gallery directory exists."
	fi
	if [[ -d $DIRECTORY ]]; then
		INDEX_FILE="index.$INDEX_EXTENTION"
		ROOT=$DIRECTORY
		THUMBS=`echo $ROOT/thumbs`
		BIGS=`echo $ROOT/bigs`
		INDEX="$ROOT/$INDEX_FILE"
	else
		EXIT_STATUS=1
		EXIT_REASON="Location '$DIRECTORY' does not exist."
		usage
	fi
}
###############################################################################################################


###############################################################################################################
########################################## Check relative directory Function ##################################
###############################################################################################################
check_relative_directory(){
	if [[ $QUIET != "TRUE" ]]; then
		echo "Checking to make sure relative directory exists."
	fi
	if [[ -d $RELATIVE ]]; then
		echo "A.O.K" > /dev/null
	else
		EXIT_STATUS=1
		EXIT_REASON="Location '$RELATIVE' does not exist."
		usage
	fi
}
###############################################################################################################


###############################################################################################################
########################################## Generate title Function ############################################
###############################################################################################################
generate_title(){
	if [[ $QUIET != "TRUE" ]]; then
		echo "Generating title."
	fi
	TITLE=`echo $DIRECTORY | sed 's/\(.*\)\/\([^/]*\)/\2/'`
}
###############################################################################################################


###############################################################################################################
########################################## Sort images Function ###############################################
###############################################################################################################
sort_images(){
	SEARCH_PATH=`find "$ROOT"`
	for EACH in $SEARCH_PATH; do
		TYPE=`file $EACH`
		if [[ $TYPE =~ "image" || $TYPE =~ "PNG" || $TYPE =~ "JPEG" || $TYPE =~ "GIF" || $TYPE =~ "TIFF" ]]; then
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
}
###############################################################################################################


###############################################################################################################
########################################## Resize thumbnails Function #########################################
###############################################################################################################
resize_thumbnails(){
	SEARCH_PATH=`find "$THUMBS"`
	for EACH in $SEARCH_PATH; do
		TYPE=`file $EACH`
		if [[ $TYPE =~ "image" || $TYPE =~ "PNG" || $TYPE =~ "JPEG" || $TYPE =~ "GIF" || $TYPE =~ "TIFF" ]]; then
			if [[ $QUIET != "TRUE" ]]; then
				FILE=`echo $EACH | sed 's/\(.*\)\/\([^/]*\)/\2/'`
				echo "Resizing image $FILE to create a thumbnail."
			fi

			get_height $EACH
			get_width $EACH

			if [[ $WIDTH -gt $HEIGHT ]]; then
				resize_width $THUMB_PIXELS $EACH
			else
				resize_height $THUMB_PIXELS $EACH
			fi
		fi
	done
}
###############################################################################################################


###############################################################################################################
########################################## Resize bigs Function ###############################################
###############################################################################################################
resize_bigs(){
	SEARCH_PATH=`find "$BIGS"`
	for EACH in $SEARCH_PATH; do
		TYPE=`file $EACH`
		if [[ $TYPE =~ "image" || $TYPE =~ "PNG" || $TYPE =~ "JPEG" || $TYPE =~ "GIF" || $TYPE =~ "TIFF" ]]; then
			if [[ $QUIET != "TRUE" ]]; then
				FILE=`echo $EACH | sed 's/\(.*\)\/\([^/]*\)/\2/'`
				echo "Resizing image $FILE to create a large image."
			fi

			get_height $EACH
			get_width $EACH

			if [[ $WIDTH -gt $HEIGHT ]]; then
				if [[ $WIDTH -gt $BIG_PIXELS ]]; then
					resize_width $BIG_PIXELS $EACH
				fi
			else
				if [[ $HEIGHT -gt $BIG_PIXELS ]]; then
					resizeHeight $BIG_PIXELS $EACH
				fi
			fi
		fi
	done
}
###############################################################################################################


###############################################################################################################
########################################## Sort images into array Function ####################################
###############################################################################################################
sort_into_array(){
	if [[ $QUIET != "TRUE" ]]; then
		echo "Counting images."
	fi
	SEARCH_PATH=`find "$BIGS"`
	for EACH in $SEARCH_PATH; do
		TYPE=`file $EACH`
		if [[ $TYPE =~ "image" || $TYPE =~ "PNG" || $TYPE =~ "JPEG" || $TYPE =~ "GIF" || $TYPE =~ "TIFF" ]]; then
			IMAGES[$NUMBER_OF_IMAGES]=$EACH
			NUMBER_OF_IMAGES=$(( NUMBER_OF_IMAGES + 1 ))
		fi
	done
}
###############################################################################################################








###############################################################################################################
#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\MAIN/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/#
###############################################################################################################
#								ooo        ooooo       .o.       ooooo ooooo      ooo                         #
#								`88.       .888'      .888.      `888' `888b.     `8'                         #
#								 888b     d'888      .8"888.      888   8 `88b.    8                          #
#								 8 Y88. .P  888     .8' `888.     888   8   `88b.  8                          #
#								 8  `888'   888    .88ooo8888.    888   8     `88b.8                          #
#								 8    Y     888   .8'     `888.   888   8       `888                          #
#								o8o        o888o o88o     o8888o o888o o8o        `8                          #
###############################################################################################################
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/MAIN\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\#
###############################################################################################################
#Get flags
while getopts ":B:c:d:e:H:r:s:S:t:CThvlLV" flag
do
	case $flag in
		B) BIG_PIXELS=$OPTARG;;
		c) COLUMNS=$OPTARG;;
		C) CAPTIONS="TRUE";;
		d) DIRECTORY=$OPTARG;;
		e) INDEX_EXTENTION=$OPTARG;;
		H) FULL_HTML=$OPTARG;;
		h) HELP="TRUE";;
		l) LIGHTBOX="YES";;
		L) LIGHTBOX="GROUP";;
		q) QUIET="TRUE";;
		r) RELATIVE=$OPTARG;;
		s) SOURCE=$OPTARG;;
		S) THUMB_PIXELS=$OPTARG;;
		t) TITLE=$OPTARG;;
		T) GENERATE_TITLE="TRUE";;
		V) VERSION="TRUE";;
	esac
done

#Check all of the flags the user has specified
check_flags

#Find out what tool we will be using
get_tool

#If the user specified a source directory, check to see if it exists.
#If it does, copy images into destination directory.
if [[ -n $SOURCE ]]; then
	check_source_directory
fi

#If the user specified a relative directory, check to see if it exists.
if [[ -n $RELATIVE ]]; then
	check_relative_directory
fi

#Checks to see if the gallery directory exists.
check_gallery_directory

#If the user wants the script to generate a title, call the generation function
if [[ $GENERATE_TITLE == "TRUE" ]]; then
	generate_title
fi

#Create folders for large and small images
if [[ $QUIET != "TRUE" ]]; then
	echo "Creating folders"
fi
mkdir -p $THUMBS
mkdir -p $BIGS

#Sort images into bigs and thumbs folders
sort_images

#Resize images to conform to thumbnail or bigs sizes
resize_thumbnails
resize_bigs

#Put big images into an array
sort_into_array

#Create gallery page
if [[ $QUIET != "TRUE" ]]; then
	echo "Creating index file."
fi
touch $INDEX

#Print version details into file
echo "<!-- DO NOT DELETE THESE COMMENTS AS THEY MAY BE USED IN THE FUTURE TO UPDATE THE GALLERY WITH NEW FEATURES/FIXES -->" >> $INDEX
echo "<!-- This gallery was created using the gallery script which can be found here: http://hashbang0.com/?location=downloads/gallery_script/index -->" >> $INDEX
echo "<!-- Gallery script revision: $REVISION -->" >> $INDEX

#If user wants a title, add it now
if [[ -n $TITLE ]]; then
	if [[ $QUIET != "TRUE" ]]; then
		echo "Printing title into file."
	fi
	echo "<h1>$TITLE</h1>" >> $INDEX
	echo "" >> $INDEX
fi

#Format the page
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

		get_height ${IMAGES[$X]}
		get_width ${IMAGES[$X]}
		
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
		
		if [[ $CAPTIONS == "TRUE" ]]; then
			CAPT=`echo $FILE | sed 's/\(.*\)\.\([^\.]*\)/\1/'`
			echo "            <p class='gallery-caption'>$CAPT</p>" >> $INDEX
		fi
		
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