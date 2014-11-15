# !/bin/sh 
# This script will generate a html document listing the newest files in the given filesystem
# Arguments: $1 Directory for search
#			 $2 output file (will be overwritten if exists)
# 			 $3 number of days to show
DIRECTORY=$1
OUTPUT_FILE=$2
DAYS=$3
TEMP_FILE="temp.html"

START="start.$$"
END="end.$$"

echo "<html><body>" > $TEMP_FILE

SDATE=$(date +"%Y-%m-%d" --date="1 days ago")
touch --date "$SDATE" $START
echo "<h1>Today</h1><ul>" >> $TEMP_FILE
find $DIRECTORY -newer $START -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f</a> - %kk - %Tk:%TM</li></br>" >> $TEMP_FILE
echo "</ul>" >> $TEMP_FILE
I=1
while [ $I -le $DAYS ]
do
	EDATE=$(date +"%Y-%m-%d" --date="$I days ago")
	I=$(( I+1 ))
	SDATE=$(date +"%Y-%m-%d" --date="$I days ago")

	touch --date "$SDATE" $START
	touch --date "$EDATE" $END

	echo "<h1>$SDATE</h1><ul>" >> $TEMP_FILE

	find $DIRECTORY -newer $START \! -newer $END -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f</a> - %kk - %Tk:%TM</li></br>" >> $TEMP_FILE

	echo "</ul>" >> $TEMP_FILE
done


echo "</ul></body></html>" >> $TEMP_FILE

/bin/rm -f "$START" 
/bin/rm -f "$END"
rm $OUTPUT_FILE
mv $TEMP_FILE $OUTPUT_FILE