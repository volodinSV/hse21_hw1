#! /bin/bash

sorted=$(grep '>' $1 | sed 's|.*len\([0-9]\+\).*|\1|g' | sort -nr)

echo "TOTAL: $(echo "$sorted" | wc -l)"

sum=0
for line in $sorted; do
	sum=$((sum+line))
done
echo "SUM: $sum"

echo "LONGEST: $(echo "$sorted" | head -n1)"

half=$((sum/2)); sum=0
for line in $sorted; do
	sum=$((sum+line))
	if [[ sum -gt half ]]
	then
		n50=$line
		break
	fi
done
echo "N50: $n50"
