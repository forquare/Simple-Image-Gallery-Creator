#!/usr/bin/env perl

# Author Ben Lavery
# Contact the author: ben.lavery@gmail.com
# Author's website: hashbang0.com

# First created on 15/05/2010
# Perl script created on 08/07/2010
# Last edited on 12/07/2010

# Project site:
# http://code.google.com/p/simple-image-gallery-creator/

###############################################################################
################################ Licence ######################################
###############################################################################
# This code is licensed under the new BSD licence:
#
#Copyright (c) 2010, Ben Lavery
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright notice, 
#      this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice,
#      this list of conditions and the following disclaimer in the documentation
#      and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
#SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
#CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###############################################################################


###############################################################################
################################ Use modules ##################################
###############################################################################
#use warnings;
use 5.010;
use CPAN;

eval{use Getopt::Long qw(:config no_ignore_case bundling);};
if($@){
	CPAN::install("Getopt::Long");
}

eval{use File::Copy;};
if($@){
	CPAN::install("File::Copy");
}

eval{use File::Basename;};
if($@){
	CPAN::install("File::Basename");
}

eval{use File::Spec;};
if($@){
	CPAN::install("File::Spec");
}

eval{use Image::Magick;};
if($@){
	CPAN::install("Image::Magick");
}

###############################################################################


###############################################################################
################################ "Global" variables ###########################
###############################################################################
#### SCRIPT VERSION ####
$REVISION = '1.0';

#### FILE SETTINGS ####
$INDEX_EXTENTION = "php";

#### GALLERY SETTINGS ####
$CAPTIONS = 0;
$TITLE = undef;
$GENERATE_TITLE = 0;
$COLUMNS = 4;
$LIGHTBOX = 0;
$LIGHTBOX_GROUP = 0;
$DESCRIPTION = undef;

##### HTML SETTINGS ####
$FULL_HTML = 0;
$HTML4 = "HTML4.01";
$XHTML1 = "XHTML1.0";
$XHTML11 = "XHTML1.1";

#### IMAGE SETTINGS ####
$THUMB_PIXELS = 128;
$BIG_PIXELS = 640;
@IMAGES = undef;
$PWI = undef; #Present Working Image

#### SCRIPT SETTINGS ####
$QUIET = 0;
#$EXIT_STATUS = 0;
#$EXIT_REASON = undef;
#$SEARCH_PATH = undef;
$HELP = 0;
$VERSION = 0;

#### DIRECTORIES & FILES ####
$ROOT = undef;
$THUMBS = undef;
$BIGS = undef;
$INDEX_FILE = undef;
$INDEX = undef;
$SOURCE = undef;
$RELATIVE = undef;
$DIRECTORY = undef;
$DESCRIPTION_FILE = undef;
$STORE = undef;
###############################################################################


###############################################################################
################################ Cleanup Function #############################
###############################################################################
sub cleanup(){
	unlink glob "$STORE/* $STORE/.*";
	rmdir $STORE;
}
###############################################################################


###############################################################################
################################ Help Function ################################
###############################################################################
sub usage(){
	say "
Usage: gallery [options] -d directory

	-B big_image_size_in_pixels - The size of the main images.
		The number is applied to the longest side and is measured in pixels.
	-c - Number of columns per row.  Default is four.
	-C - Use captions - These are generated using the file names without
		the file extension.
	-d directory - Absolute link to directory with images in.
		Escape spaces with a \ symbol.
	-D description_location - Add the description found in description.txt
		which should be located in the directory specified with -d
	-e - Extension for the gallery file.  Default is php.
	-h - Show this help text.
	-H html_version - Create a standalone HTML page.  Specify $HTML4, $XHTML1, or
		$XHTML11 to make the script generate a standards compliant page.
	-l - Use lightbox for displaying images.
	-L - Use lightbox for displaying images and groupt them using gallery title.
		For this option to work, you must either specify a title
		or auto-generate one.
	-q - Be quiet - suppress all output.
	-r relative directory - Directory image links should be relative to.
		Escape spaces with a \ symbol.
	-s source directory - Use this directory as a source for images.
		Images will be copied from here into the directory specified
		using the -d option.
	-S small_image_size_in_pixels - The size of thumbnails.
		The number is applied to the longest side and is measured in pixels.
	-t title - Title of the gallery.  Use quotes when using multiple words.
	-T - Generate title based on directory name.
	-V - Print version (revision).
	
	NOTE: See regular documentation for more indepth help.
";
}
###############################################################################


###############################################################################
#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\MAIN/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/#
###############################################################################
#				ooo        ooooo       .o.       ooooo ooooo      ooo         #
#				`88.       .888'      .888.      `888' `888b.     `8'         #
#				 888b     d'888      .8"888.      888   8 `88b.    8          #
#				 8 Y88. .P  888     .8' `888.     888   8   `88b.  8          #
#				 8  `888'   888    .88ooo8888.    888   8     `88b.8          #
#				 8    Y     888   .8'     `888.   888   8       `888          #
#				o8o        o888o o88o     o8888o o888o o8o        `8          #
###############################################################################
#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\MAIN/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/#
###############################################################################

############ Collect arguments ############

	GetOptions(
		'B|big_size=s' => \$BIG_PIXELS,
		'c|columns:i' => \$COLUMNS,
		'C|captions' => \$CAPTIONS,
		'd|gallery_directory=s' => \$DIRECTORY,
		'D|description_location=s' => \$DESCRIPTION,
		'description_file=s' => \$DESCRIPTION_FILE,
		'e|extention=s' => \$INDEX_EXTENTION,
		'h|help|?' => \$HELP,
		'H|standalone_html_version=s' => \$FULL_HTML,
		'l' => \$LIGHTBOX,
		'L' => \$LIGHTBOX_GROUP,
		'q|quiet' => \$QUIET,
		'r|relative_to=s' => \$RELATIVE,
		's|source_directory=s' => \$SOURCE,
		'S|thumb_size=i' => \$THUMB_PIXELS,
		't=s' => \$TITLE,
		'T' => \$GENERATE_TITLE,
		'V|version' => \$VERSION
	);


############ Check arguments ############
&usage() and exit if $HELP;
say "You are running v$REVISION" and exit if $VERSION;

unless($QUIET){
	say "Checking arguments.";
}

# Check the gallery directory first.  If it's not there, why continue?
die "The gallery directory was no specified.  Stopped" unless $DIRECTORY;
die "The gallery directory ($DIRECTORY) was not found, or it is not a directory.  Stopped" unless -d $DIRECTORY;

# Shave off any slashes at the end of the path
$DIRECTORY =~  s/\/$//;
$SOURCE =~  s/\/$// if $SOURCE;
$RELATIVE =~  s/\/$// if $RELATIVE;

# If user specified a title and told the script to generate a title 
# just take the title the user gave us and ignor the generation.
if($TITLE && $GENERATE_TITLE){
	$GENERATE_TITLE = 0;
}

# If LIGHTBOX_GROUP is set, we will group images by gallery name
# But only if TITLE has a non-zero value or a title is going to be generated
if($LIGHTBOX_GROUP){
	die "You have requested to group lightbox images, but have not provided a title or requested one to be auto-generated.  Stopped" unless $TITLE or $GENERATE_TITLE;
}

# Check user specified a correct HTML version
if($FULL_HTML){
	die "You have specified an unknown HTML version.  Valid versions are: $HTML4, $XHTML1, and $XHTML11.  Stopped" unless $FULL_HTML eq $HTML4 or $FULL_HTML eq $XHTML1 or $FULL_HTML eq $XHTML11;
}

# If user specifies full html, AND they ask for Lightbox, we'll throw an error.
# This combination is CURRENTLY unsupported
die "You have asked the script to create a standalone gallery page WITH lightbox capabilities.  This combination is UNSUPPORTED at this time.  Stopped" if $FULL_HTML and ($LIGHTBOX or $LIGHTBOX_GROUP);

# Check user specified a correct position for the decription
if($DESCRIPTION){
	die "There is no description file.  Please create the description file under $DIRECTORY/description.txt.  Stopped" unless -f $DIRECTORY . "/description.txt" or -f $DESCRIPTION_FILE;
	die "You have specified an unknown location for the description text.  Valid locations are 'above' and 'below'.  Stopped" unless $DESCRIPTION eq "above" or $DESCRIPTION eq "below";
}

############ Check directories ############
unless($QUIET){
	say "Checking directories.";
}

## Check SOURCE directory if specified
if($SOURCE){
	die "Source directory and destination directory are the same.  Stopped" if $SOURCE eq $DIRECTORY;
	die "Source directory ($SOURCE) does not exist.  Stopped" unless -d $SOURCE;
}

## Check RELATIVE directory if specified
if($RELATIVE){
	die "Relavite directory ($RELATIVE) does not exist.  Stopped" unless -d $RELATIVE;
}

############ Populate variables with stuff ############
unless($QUIET){
	say "Populating some variables.";
}
$ROOT = "$DIRECTORY";
$THUMBS = "$ROOT/thumbs";
$BIGS = "$ROOT/bigs";
$STORE = "$ROOT/.store";
$INDEX_FILE = "index.$INDEX_EXTENTION";
$INDEX = "$ROOT/$INDEX_FILE";
$DESCRIPTION_FILE = "$ROOT/description.txt" unless $DESCRIPTION_FILE;
@dirs = File::Spec->splitdir($ROOT);
$TITLE = pop(@dirs) unless $TITLE;
undef @dirs;

############ Create directories ############
unless($QUIET){
	say "Creating directories:\n\t$THUMBS,\n\t$BIGS,\n\t$STORE\n";
}
mkdir $THUMBS;
mkdir $BIGS;
mkdir $STORE;

############ Sort images into directories and resize ############
unless($QUIET){
	say "Checking for the sourcedirectory.";
}
## If a source directory exists, copy any _IMAGE_ files accross.
if($SOURCE){
	opendir(SOURCEHANDLE,"$SOURCE") or die "Cannot open $SOURCE.  Stopped";
	my @files = sort readdir(SOURCEHANDLE);
	close(SOURCEHANDLE);
	
	unless($QUIET){
		say "Source directory found.";
	}
	
	foreach $file (@files){
		if($file =~ /png/i || $file =~ /jpeg/i || $file =~ /jpg/i || $file =~ /gif/i || $file =~ /tif/i || $file =~ /bmp/i){
			my $oldfile = "$SOURCE/$file";
			my $newfile = "$ROOT/$file";
			copy($oldfile, $newfile);
			
			unless($QUIET){
				say "Just copied $oldfile to $newfile";
			}
		}
	}
}

## Copy images into BIGS and THUMBS, move them into .store

## This gets all of the images which we can use for processing later.  
## Note that it only constains the image name, not the path
unless($QUIET){
	say "Gathering a list of your images.";
}
opendir(ROOTHANDLE,"$ROOT") or die "Cannot open $ROOT.  Stopped";
@images = sort readdir(ROOTHANDLE);
close(ROOTHANDLE);
foreach $image (@images){
	if($image =~ /png/i || $image =~ /jpeg/i || $image =~ /jpg/i || $image =~ /gif/i || $image =~ /tif/i || $image =~ /bmp/i){
		push(@IMAGES, $image);
	}
}
unless($QUIET){
	say "Images collected.";
}

## Take off front of array (It's empty)
shift(@IMAGES);

foreach $image (@IMAGES){
	
	my $oldimage = "$ROOT/$image";
	my $bigimage = "$BIGS/$image";
	my $thumbimage = "$THUMBS/$image";
	my $storedimage = "$STORE/$image";
	
	unless($QUIET){
		say "Copying and resizing $bigimage.";
	}
	$PWI = new Image::Magick;
	$PWI->Read("$oldimage");
	my $height = $PWI->Get('height');
	my $width = $PWI->Get('width');
	if($width > $height || $width == $height){
		my $ratio_main = $BIG_PIXELS / $width;
		$PWI->Resize(width=>$width * $ratio_main, height=>$height * $ratio_main) if $width > $BIG_PIXELS;
	}
	if($height > $width){
		my $ratio_main = $BIG_PIXELS / $height;
		$PWI->Resize(width=>$width * $ratio_main, height=>$height * $ratio_main) if $height > $BIG_PIXELS;
	}
	$PWI->Write("$bigimage");
	
	
	unless($QUIET){
		say "Copying and resizing $thumbimage.";
	}
	$PWI = new Image::Magick;
	$PWI->Read("$oldimage");
	$height = $PWI->Get('height');
	$width = $PWI->Get('width');
	if($width > $height || $width == $height){
		my $ratio_main = $THUMB_PIXELS / $width;
		$PWI->Resize(width=>$width * $ratio_main, height=>$height * $ratio_main) if $width > $THUMB_PIXELS;
	}
	if($height > $width){
		my $ratio_main = $THUMB_PIXELS / $height;
		$PWI->Resize(width=>$width * $ratio_main, height=>$height * $ratio_main) if $height > $THUMB_PIXELS;
	}
	$PWI->Write("$thumbimage");
	
	
	unless($QUIET){
		say "Moving $storedimage";
	}
	rename($oldimage, $storedimage);
	
}

############ Generate index file ############
unless($QUIET){
	say "Generating the index file.";
}
## This header is printed at the top of the file to show what version it is running
$scriptheader = "<!-- DO NOT DELETE THESE COMMENTS AS THEY MAY BE USED IN THE FUTURE TO UPDATE THE GALLERY WITH NEW FEATURES/FIXES -->
<!-- This gallery was created using the gallery script which can be found here: https://code.google.com/p/simple-image-gallery-creator/ -->
<!-- Gallery script revision: $REVISION -->\n";

$htmlheader = "";
if($FULL_HTML eq $HTML4){
	$htmlheader = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd"
	
	<html lang="en">';
}
if($FULL_HTML eq $XHTML1){
	$htmlheader =  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">';
}
if($FULL_HTML eq $XHTML11){
	$htmlheader = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">';
}

$htmlheader = "$htmlheader" . "\n<head>\n<meta httpequiv='Content-Type' content='text/html; charset=utf-8'/>\n<title>$TITLE</title>\n</head>\n<body>\n\n";

$markup = "$scriptheader" . "$htmlheader";

if($TITLE){
	$markup .= "<h1>$TITLE</h1>\n\n";
}

$DESCRIPTION = "" unless $DESCRIPTION;
if($DESCRIPTION eq "above"){
	open(DESCRIPTIONFILEHANDLE,"$DESCRIPTION_FILE") or die "Cannot open $DESCRIPTION_FILE.  Stopped";
	while(<DESCRIPTIONFILEHANDLE>){
		chomp;
		$markup .= "$_";
	}
	close(DESCRIPTIONFILEHANDLE);
}

$markup .= "<div id='gallery-body'>\n\n";

$x = 0;
while($x < @IMAGES){
	$markup .= "<div class='gallery-column'>\n\n";
	
	for(my $i = 0; $i <= $COLUMNS; $i++){
		if($x >= @IMAGES){
			last;
		}
		
		$markup .= "<div id='gallery-image'>\n\n";
		
		if($RELATIVE){
			$bigpath = File::Spec->abs2rel($BIGS, $RELATIVE);
			$thumbpath = File::Spec->abs2rel($THUMBS, $RELATIVE);
		}else{
			$bigpath = $BIGS;
			$thumbpath = $THUMBS;
		}
		
		$PWI = new Image::Magick;
		$PWI->Read("$THUMBS/$IMAGES[$x]");
		
		my $height = $PWI->Get('height');
		my $width = $PWI->Get('width');
		
		if($width > $height){
			$class = "class='landscape'";
		}else{
			$class = "class='portrait'";
		}
		
		if($LIGHTBOX){
			$rel = "rel='lightbox'";
		}
		if($LIGHTBOX_GROUP){
			$rel = "rel='lightbox $TITLE'";
		}
		
		$markup .= "<a href='$bigpath/$IMAGES[$x]' $rel><img $class alt='$IMAGES[$x]' src='$thumbpath/$IMAGES[$x]' /></a>\n";
		
		if($CAPTIONS){
			my $caption = $IMAGES[$x];
			$caption =~ s/(.*)\.([^\.]*)/$1/;
			$markup .= "<p class='gallery-caption'>$caption</p>\n";
		}
		
		$markup .= "</div>\n\n";
		
		$x++;
	}
	
	$markup .= "</div>\n\n";
}

$markup .= "</div>\n\n";

if($DESCRIPTION eq "below"){
	open(DESCRIPTIONFILEHANDLE,"$DESCRIPTION_FILE") or die "Cannot open $DESCRIPTION_FILE.  Stopped";
	while(<DESCRIPTIONFILEHANDLE>){
		chomp;
		$markup .= "$_";
	}
	close(DESCRIPTIONFILEHANDLE);
}

if($FULL_HTML){
	$markup .= "</body>";
	$markup .= "</html>";
}

############ Print index file ############
unless($QUIET){
	say "Printing the index file";
}
open(INDEXFILEHANDLE, ">", "$INDEX") or die "Cannot open $INDEX.  Stopped";
select INDEXFILEHANDLE;
$| = 1;
select STDOUT;
print INDEXFILEHANDLE "$markup";
close(INDEXFILEHANDLE);

############ Cleanup ############
unless($QUIET){
	say "Cleaning up.";
}
&cleanup();

unless($QUIET){
	say "Done :)\a";
}