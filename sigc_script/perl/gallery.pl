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
use warnings;
use 5.010;
use Getopt::Long;
###############################################################################


###############################################################################
################################ "Global" variables ###########################
###############################################################################
####FILE SETTINGS####
$INDEX_EXTENTION = "php";

####GALLERY SETTINGS####
$CAPTIONS = 0;
$TITLE = undef;
$GENERATE_TITLE = 0;
$COLUMNS = 4;
$LIGHTBOX = 0;
$LIGHTBOX_GROUP = 0;
$DESCRIPTION = undef;

#####HTML SETTINGS####
$FULL_HTML = 0;
$HTML4 = "HTML4.01";
$XHTML1 = "XHTML1.0";
$XHTML11 = "XHTML1.1";

####IMAGE SETTINGS####
$THUMB_PIXELS = 128;
$BIG_PIXELS = 640;
@IMAGES = undef;

####SCRIPT SETTINGS####
$QUIET = 0;
$EXIT_STATUS = 0;
$EXIT_REASON = undef;
$SEARCH_PATH = undef;
$HELP = 0;
$VERSION = 0;

####DIRECTORIES & FILES####
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
sub help{
	#Do nothing so far
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
GetOptions('B|big_size=s' => \$BIG_PIXELS);
GetOptions('c|columns:i' => \$COLUMNS);
GetOptions('C|captions' => \$CAPTIONS);
GetOptions('d|gallery_directory=s' => \$DIRECTORY);
GetOptions('D|description_location=s' => \$DESCRIPTION);
GetOptions('description_file=s' => \$DESCRIPTION_FILE);
GetOptions('e|extention=s' => \$INDEX_EXTENTION);
GetOptions('h|help|?' => \$HELP);
GetOptions('H|standalone_html_version=s' => \$FULL_HTML);
GetOptions('l' => \$LIGHTBOX);
GetOptions('L' => \$LIGHTBOX_GROUP);
GetOptions('q|quiet' => \$QUIET);
GetOptions('r|relative_to=s' => \$RELATIVE);
GetOptions('s|source_directory=s' => \$SOURCE);
GetOptions('S|thumb_size=i' => \$THUMB_PIXELS);
GetOptions('t=s' => \$TITLE);
GetOptions('T' => \$GENERATE_TITLE);
GetOptions('V' => \$VERSION);

#### Check arguments ####
#### Check directories ####
#### Create bigs, thumbs & .store directories ####
#### Sort images into directories ####
#### Resize images ####
#### Generate index file ####
#### Print index file ####
#### Cleanup ####