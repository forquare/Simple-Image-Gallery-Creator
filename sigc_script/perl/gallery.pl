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
use Getopt::Long qw(:config no_ignore_case bundling);
###############################################################################


###############################################################################
################################ "Global" variables ###########################
###############################################################################
#### SCRIPT VERSION ####
$REVISION=0.5;

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

#### SCRIPT SETTINGS ####
$QUIET = 0;
$EXIT_STATUS = 0;
$EXIT_REASON = undef;
$SEARCH_PATH = undef;
$HELP = 0;
$VERSION = 0;

#### DIRECTORIES & FILES ####
$ROOT = "";
$THUMBS = "$ROOT/thumbs";
$BIGS = "$ROOT/bigs";
$INDEX_FILE = "index.$INDEX_EXTENTION";
$INDEX = "$ROOT/$INDEX_FILE";
$NEWPATH = "";
$SOURCE = "";
$RELATIVE = "";
$DIRECTORY = "";
$DESCRIPTION_FILE = "$ROOT/description.txt";
$STORE = "$ROOT/.store";
###############################################################################


###############################################################################
################################ Cleanup Function #############################
###############################################################################
sub cleanup{
	#Do nothing so far
}

###############################################################################


###############################################################################
################################ Help Function ################################
###############################################################################
sub usage(){
	say "HELLO!";
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

#### Collect arguments ####

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


#### Check arguments ####
&usage() and exit if $HELP;
say "Current version is $REVISION" and exit if $VERSION;
die "The gallery directory was no specified.  Stopped" unless $DIRECTORY;
die "The gallery directory ($DIRECTORY) was not found, or it is not a directory.  Stopped" unless -d $DIRECTORY;

# Shave off any slashes at the end of the path
$DIRECTORY =~  s/\/$//;
$SOURCE =~  s/\/$// unless -d $SOURCE;
$RELATIVE =~  s/\/$// unless -e $RELATIVE;

# If user specified a title and told the script to generate a title 
# just take the title the user gave us and ignor the generation.
if($TITLE && $GENERATE_TITLE){
	$GENERATE_TITLE = 0;
}

# If LIGHTBOX_GROUP is set, we will group images by gallery name
# But only if TITLE has a non-zero value or a title is going to be generated
if($LIGHTBOX_GROUP){
	die "You have requested to group lightbox images, but have not provided a title or requested one to be auto-generated." unless $TITLE or $GENERATE_TITLE;
}

# Check user specified a correct HTML version
if($FULL_HTML){
	die "You have specified an unknown HTML version.  Valid versions are: $HTML4, $XHTML1, and $XHTML11." unless $FULL_HTML eq $HTML4 or $FULL_HTML eq $XHTML1 or $FULL_HTML eq $XHTML11;
}

# If user specifies full html, AND they ask for Lightbox, we'll throw an error.
# This combination is CURRENTLY unsupported
die "You have asked the script to create a standalone gallery page WITH lightbox capabilities.  This combination is UNSUPPORTED at this time." if $FULL_HTML and ($LIGHTBOX or $LIGHTBOX_GROUP);

# Check user specified a correct position for the decription
if($DESCRIPTION){
	die "There is no description file.  Please create the description file under $DIRECTORY/description.txt." unless -f $DIRECTORY . "/description.txt";
	die "You have specified an unknown location for the description text.  Valid locations are 'above' and 'below'." unless $DESCRIPTION eq "above" or $DESCRIPTION eq "below";
}

#### Check directories ####
#### Create bigs, thumbs & .store directories ####
#### Sort images into directories ####
#### Resize images ####
#### Generate index file ####
#### Print index file ####
#### Cleanup ####