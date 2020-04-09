

fpath="$1"

# Parse prerequisites
# lineprereqs=$(sed -n '/PREREQS/=' "$fpath")
# pline1=$(($lineprereqs + 1))
# echo "$pline1"

sed -n '/PREREQS/{:a;N;/^$/ba;}' $fpath