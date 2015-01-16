# !/bin/sh 
# This script will generate a html document listing the newest files in the given filesystem
# Arguments:
#	-p [searchpath]    : Path in which to search
#	-o [output file]   : file to which to write the list
#   -d [number of days]: number of days in the past to search
#   -b [new_basepath]  : replace the searchpath in file links with new_basepath
#   -v 				   : verbose output during execution
#
DAYS=7
REPLACEBASELINK=""
VERBOSE=false
OUTPUT_FILE=latestfiles.html
while getopts ":p:o:d:b:v" optname
  do
    case "$optname" in
      "p")
		DIRECTORY=$OPTARG
      	;;
      "o")
		OUTPUT_FILE=$OPTARG
        ;;
      "d")
		DAYS=$OPTARG
        ;;
      "b")
		REPLACEBASELINK=$OPTARG
		;;
	  "v")
		VERBOSE=true
		;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
  done

if $VERBOSE; then
	echo "   output: $OUTPUT_FILE"
	echo "     days: $DAYS"
	echo "  replace: $REPLACEBASELINK"
fi

TEMP_FILE="temp.html"

START="start.$$"
END="end.$$"

echo "<html><body>" > "$TEMP_FILE"

SDATE=$(date +"%Y-%m-%d" --date="1 days ago")
touch --date "$SDATE" "$START"
echo "<h1>Today</h1><ul>" >> "$TEMP_FILE"

if $VERBOSE; then
	echo "searching: $DIRECTORY"
fi

find $DIRECTORY -newer $START -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f</a> - %kk - %Tk:%TM</li></br>" >> "$TEMP_FILE"
echo "</ul>" >> "$TEMP_FILE"
I=1
while [ $I -le $DAYS ]
do
	EDATE=$(date +"%Y-%m-%d" --date="$I days ago")
	I=$(( I+1 ))
	SDATE=$(date +"%Y-%m-%d" --date="$I days ago")

	touch --date "$SDATE" "$START"
	touch --date "$EDATE" "$END"

	echo "<h1>$SDATE</h1><ul>" >> "$TEMP_FILE"

	if $VERBOSE; then
		echo "searching: $SDATE - $(( DAYS-I+2 )) day(s) to go"
	fi

	find $DIRECTORY -newer $START \! -newer $END -type f \( ! -regex '.*/\..*' \) -printf "<li class=\"%y\"><a href=\"%p\">%f</a> - %kk - %Tk:%TM</li></br>" >> "$TEMP_FILE"

	echo "</ul>" >> "$TEMP_FILE"
done


echo "</ul></body></html>" >> "$TEMP_FILE"

/bin/rm -f "$START" 
/bin/rm -f "$END"

if [ $REPLACEBASELINK == "" ]; then
	mv -f "$TEMP_FILE" "$OUTPUT_FILE"
	echo "not replacing"
else
	if $VERBOSE; then
	echo "replacing: s-${DIRECTORY}-${REPLACEBASELINK}-g"
	fi
	sed "s:${DIRECTORY}:${REPLACEBASELINK}:g" < "$TEMP_FILE" > "$OUTPUT_FILE"
	rm "$TEMP_FILE"
fi