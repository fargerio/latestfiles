# !/bin/sh 
# This script will generate a html document listing the newest files in the given filesystem
DIRECTORY=$1
OUTPUT_FILE="latestfiles.html"

START="start.$$"
END="end.$$"

SDATE=$(date +"%Y-%m-%d" --date="3 days ago")
EDATE=$(date +"%Y-%m-%d" --date="2 days ago")

touch --date "$SDATE" $START
touch --date "$EDATE" $END

echo "<html><body>" > $OUTPUT_FILE
echo "<h1>$SDATE</h1><ul>" >> $OUTPUT_FILE
find $DIRECTORY -newer $START \! -newer $END -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f - %kk - %Tk:%TM</a></li></br>" >> $OUTPUT_FILE

SDATE=$(date +"%Y-%m-%d" --date="2 days ago")
EDATE=$(date +"%Y-%m-%d" --date="1 days ago")
touch --date "$SDATE" $START
touch --date "$EDATE" $END
echo "</ul><h1>$SDATE</h1><ul>" >> $OUTPUT_FILE
find $DIRECTORY -newer $START \! -newer $END -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f - %kk - %Tk:%TM</a></li></br>" >> $OUTPUT_FILE
echo "</ul></body></html>" >> $OUTPUT_FILE

/bin/rm -f "$START" 
/bin/rm -f "$END"