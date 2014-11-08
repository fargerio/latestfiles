# !/bin/sh 
# This script will generate a html document listing the newest files in the given filesystem
# Arguments: $1 Directory for search
#			 $2 output file
# 			 $3 number of days to show
DIRECTORY=$1
OUTPUT_FILE=$2
DAYS=$3

START="start.$$"
END="end.$$"

echo "<html><body>" > $OUTPUT_FILE

while [ $DAYS -ge 1 ]
do
	SDATE=$(date +"%Y-%m-%d" --date="$DAYS days ago")
	DAYS=$(( DAYS-1 ))
	EDATE=$(date +"%Y-%m-%d" --date="$DAYS days ago")

	touch --date "$SDATE" $START
	touch --date "$EDATE" $END

	echo "<h1>$SDATE</h1><ul>" >> $OUTPUT_FILE

	find $DIRECTORY -newer $START \! -newer $END -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f</a> - %kk - %Tk:%TM</li></br>" >> $OUTPUT_FILE

	echo "</ul>" >> $OUTPUT_FILE
done

SDATE=$(date +"%Y-%m-%d" --date="1 days ago")
touch --date "$SDATE" $START
echo "</ul><h1>Today</h1><ul>" >> $OUTPUT_FILE
find $DIRECTORY -newer $START -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f</a> - %kk - %Tk:%TM</li></br>" >> $OUTPUT_FILE

echo "</ul></body></html>" >> $OUTPUT_FILE

/bin/rm -f "$START" 
/bin/rm -f "$END"