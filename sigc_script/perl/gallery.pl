#!/usr/bin/env perl

# Author Ben Lavery
# Contact the author: ben.lavery@gmail.com
# Author's website: hashbang0.com

# First created on 15/05/2010
# Perl script created on 08/07/2010
# Last edited on 08/07/2010

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
################################ Global variables #############################
###############################################################################

###############################################################################


###############################################################################
################################ Cleanup Function #############################
###############################################################################
sub cleanup{
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

#### Check dependancies ####
#### Collect arguments ####
#### Check arguments ####
#### Check directories ####
#### Create bigs, thumbs & .store directories ####
#### Sort images into directories ####
#### Resize images ####
#### Generate index file ####
#### Print index file ####
#### Cleanup ####