amountN() {
        echo $1 > longest.txt
        seqtk subseq $2 longest.txt > longest.fa
        echo $(grep 'N' longest.fa | tr -cd 'N' | wc -m)
        rm longest.txt longest.fa
}

if [[ $1 == '-N' ]]; then
        longest=$(cat longest)
        longest_gap=$(echo $longest | sed 's|len[0-9]*_||')

        if [[ -n $3 ]]; then
                printf "%s" "amountN: "
                amountN $longest $2
                printf "%s" "amountN_gap: "
                amountN $longest_gap $3
                exit
        fi

        if [[ -n $(head -n1 $2 | grep 'len') ]]; then
                printf "%s" "amountN: "
                amountN $longest $2
                exit
        fi

        printf "%s" "amountN_gap: "
        amountN $longest_gap $2
        exit
fi


sorted=$(grep '>' $1 | sed 's|.*len\([0-9]\+\).*|\1|g' | sort -nr)

echo "TOTAL: $(echo "$sorted" | wc -l)"

sum=0
for line in $sorted; do
        sum=$((sum+line))
done
echo "SUM: $sum"

longest=$(echo "$sorted" | head -n1)
grep "$longest" $1 | sed 's|.||' > longest
echo "LONGEST: $longest"

half=$((sum/2)); sum=0
for line in $sorted; do
        sum=$((sum+line))
        if [[ sum -gt half ]]; then
                n50=$line
                break
        fi
done
echo "N50: $n50"
