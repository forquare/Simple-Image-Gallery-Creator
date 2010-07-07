#!/bin/bash
#Author Ben Lavery
#Contact the author: ben.lavery@gmail.com
#Created on 05/06/2010
#Last edited on 05/06/2010

REVISION=`cat gallery.sh | grep "REVISION=" | sed 's/=/ /g' | awk '{print $2}'`
PREV_REVISION=$(( $REVISION - 1))

cat index.php | sed "s/\(downloads\/gallery_script\/archive\/gallery1_revision_\)\(.*\)\(\.zip\)/\1$REVISION\3/g" > .index.php
cat .index.php > index.php
rm .index.php

cat archive.php | sed "s/<li><a href=\"downloads\/gallery_script\/archive\/gallery1_revision_$PREV_REVISION.zip\">Revision $PREV_REVISION<\/a><\/li>/<li><a href=\"downloads\/gallery_script\/archive\/gallery1_revision_$REVISION.zip\">Revision $REVISION<\/a><\/li>\\
    <li><a href=\"downloads\/gallery_script\/archive\/gallery1_revision_$PREV_REVISION.zip\">Revision $PREV_REVISION<\/a><\/li>/" > .archive.php
cat .archive.php > archive.php
rm .archive.php

cat source.php | sed "s/<li><a href=\"downloads\/gallery_script\/source\/shell\/gallery$PREV_REVISION.sh\">Revision $PREV_REVISION<\/a><\/li>/<li><a href=\"downloads\/gallery_script\/source\/shell\/gallery$REVISION.sh\">Revision $REVISION<\/a><\/li>\\
    <li><a href=\"downloads\/gallery_script\/source\/shell\/gallery$PREV_REVISION.sh\">Revision $PREV_REVISION<\/a><\/li>/" > .source.php
cat .source.php > source.php
rm .source.php

cp gallery.sh source/shell/gallery$REVISION.sh
mkdir gallery1_revision_$REVISION
mv gallery.sh gallery1_revision_$REVISION/gallery
chmod 555 gallery1_revision_$REVISION/gallery
cp gallery.1 gallery1_revision_$REVISION
groff -t -e -mandoc -Tps gallery1_revision_$REVISION/gallery.1 > gallery1_revision_$REVISION/gallery1.ps
ps2pdf gallery1_revision_$REVISION/gallery1.ps gallery1_revision_$REVISION/gallery1.pdf
rm gallery1_revision_$REVISION/gallery1.ps
zip -rq gallery1_revision_$REVISION.zip gallery1_revision_$REVISION
mv gallery1_revision_$REVISION.zip archive
rm -rf gallery1_revision_$REVISION


echo "Please edit the changelog and the roadmap separately!!!"