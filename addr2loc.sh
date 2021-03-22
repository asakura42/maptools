#!/bin/bash
addresses="$HOME/.local/share/qmapshack/Addresses/addresses.csv"
if [[ "$1" == "-g" ]] ; then
	command -v osmconvert || ( echo "No osmconvert found in \$PATH" && exit )
	command -v osmfilter || ( echo "No osmfilter found in \$PATH" && exit )
	if ls addresses.csv > /dev/null 2>&1; then echo "addresses.csv exists in folder" && exit ; fi
	temp=$(mktemp -d)
	printf "%s\n" "Enter path to .pbf file"
	read pbf
	osmconvert "$pbf" -o="$temp"/XXX.xml --all-to-nodes --statistics
	osmfilter "$temp"/XXX.xml --keep="place=city OR building OR addr* OR name OR amenity" --drop-author --drop-version -o="$temp"/xxx-buildg.xml
	osmconvert "$temp"/xxx-buildg.xml -o="$temp"/result.csv --csv-headline --csv-separator=; --csv="@id addr:city addr:street addr:housenumber name amenity @lat @lon"
	awk -F';' '$4 && $7' > addresses.csv
	echo -e "now do:\nmkdir -p $(dirname ${addresses}) && cat addresses.csv >> \"$addresses\" && sort -u \"$addresses\" -o \"$addresses\""
	exit
fi
echo -e "Enter your query:\n(city?), street, house number"
read query
list=$(grep -i "$(echo "$query" | sed 's/[-, ]/.*/g')" "$addresses" | awk -F';' '{print $2 ";" $3 ";" $4 ";" $7 ";" $8}')
echo "$list" | sed 's/;\+/;/g;s/;/ | /g' | fzf | awk -F'|' '{print $(NF-1) $NF}' | sed 's/^ //;s/  / /'
