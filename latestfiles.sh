# !/bin/sh 
# This script will generate a html document listing the newest files in the given filesystem
# Arguments:
#	-p [searchpath]    	: Path in which to search
#	-o [output file]   	: file to which to write the list. default: latestfiles.html
#   -d [number of days]	: number of days in the past to search
#   -b [new_basepath]  	: replace the searchpath in file links with new_basepath
#   -v 				   	: verbose output during execution
#	-t [theme name]		: which theme to use, currently only default exists
#
DAYS=7
REPLACEBASELINK=""
VERBOSE=false
OUTPUT_FILE=latestfiles.html
THEME=default
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
	  "t")
		THEME=$OPTARG
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

printf '<html><body><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><link href="' > "$TEMP_FILE"
echo $THEME >> "$TEMP_FILE"
printf '.css" media="all" rel="stylesheet" type="text/css" /><script src="sorttable.js"></script></head>\n' >> "$TEMP_FILE"

SDATE=$(date +"%Y-%m-%d" --date="1 days ago")
touch --date "$SDATE" "$START"
printf '<h1>Today</h1>\n<table class="sortable"><thead><tr><th>type</th><th>name</th><th>size</th><th>time</th></tr></thead>\n' >> "$TEMP_FILE"

if $VERBOSE; then
	echo "searching: $DIRECTORY"
fi

find $DIRECTORY -newer $START -type f \( ! -regex '.*/\..*' \) -printf "<tr><td class=\"%f\"></td><td><a href=\"%p\">%f</a></td><td>%kk</td><td>%TH:%TM</td></tr>\n" >> "$TEMP_FILE"
printf "</table>/n" >> "$TEMP_FILE"
I=1
while [ $I -le $DAYS ]
do
	EDATE=$(date +"%Y-%m-%d" --date="$I days ago")
	I=$(( I+1 ))
	SDATE=$(date +"%Y-%m-%d" --date="$I days ago")

	touch --date "$SDATE" "$START"
	touch --date "$EDATE" "$END"

	printf '<h1>${SDATE}</h1>\n<table class="sortable"><thead><tr><th>type</th><th>name</th><th>size</th><th>time</th></tr></thead>\n' >> "$TEMP_FILE"

	if $VERBOSE; then
		echo "searching: $SDATE - $(( DAYS-I+2 )) day(s) to go"
	fi

	find $DIRECTORY -newer $START \! -newer $END -type f \( ! -regex '.*/\..*' \) -printf "<tr><td class=\"%f\"></td><td><a href=\"%p\">%f</a></td><td>%kk</td><td>%Tk:%TM</td></tr>\n" >> "$TEMP_FILE"

	printf "</table>/n" >> "$TEMP_FILE"
done

echo "</ul></body></html>" >> "$TEMP_FILE"
/bin/rm -f "$START" 
/bin/rm -f "$END"

sed -i 's:class\=".*\.\(.*\)">:class=\"\1\">:g' "$TEMP_FILE"


if [ "$REPLACEBASELINK" == "" ]; then
	mv -f "$TEMP_FILE" "$OUTPUT_FILE"
	echo "not replacing"
else
	if $VERBOSE; then
	echo "replacing: s-${DIRECTORY}-${REPLACEBASELINK}-g"
	fi
	sed "s:${DIRECTORY}:${REPLACEBASELINK}:g" < "$TEMP_FILE" > "$OUTPUT_FILE"
	rm "$TEMP_FILE"
fi