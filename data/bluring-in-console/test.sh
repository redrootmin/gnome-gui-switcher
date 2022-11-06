#!/bin/bash
#expecting 1 arg:
#	a directory containing images

#window size
YAD_W=800
YAD_H=800

#max number of files to delete
MAX_DELETE=50

#window title
WIN_TITLE="Image Sorter"


#exit if $1 is null or can't enter directory $1
if [[ -z $1 ]] || ! cd "$1" 2>/dev/null; then exit; fi

function dclick {
	xnview "$4" &
}
export -f dclick

function selectImages {

	returnList=`\
		while
			read w h file
		do
			if [[ $w ]] && [[ $h ]]; then
				printf "\n%05d\n%05d\n%s\n" $w $h "$file"
			fi
		done < <(identify -format "%w %h %f\n" * 2>/dev/null) | \
			yad --list --checklist --title="$WIN_TITLE" --print-column=4 \
					--width=$YAD_W --height=$YAD_H --center \
					--text="\tDouble-click row to view the image\n\n\tTick box(es) to mark for deletion\n" \
					--dclick-action="bash -c \"dclick %s\"" \
					--button="Cancel:1" --button="Delete & Exit:0" \
					--column="" --column="width:NUM" --column="height:NUM" --column="file name" 2>/dev/null |
			sed -r "s/\|$//"`
}

selectImages
if [[ $returnList ]]; then
	readarray -n $MAX_DELETE -t images <<< "$returnList"

	rm -f "${images[@]}"
fi

#don't exit till all child processes have finished
wait
