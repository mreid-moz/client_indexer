source env.sh

TARGET=$1
if [ -z "$TARGET" ]; then
    echo "ERROR: Missing required date argument"
    exit -1
fi

BASE=$(pwd)

time cat | $HEKA_PATH/heka-s3cat -bucket $DATA_BUCKET -format offsets -stdin -output $BASE/$TARGET.append.tmp &> $TARGET.append.log

echo "Checking for errors..."
# TODO: If there are any, exit nonzero.
ERRS=$(grep -i error $TARGET.append.log | wc -l)
if [ "$ERRS" -ne "0" ]; then
    echo "Encountered indexing errors:"
    grep -i error $TARGET.log
fi

echo "Number of new rows:"
wc -l $BASE/$TARGET.append.tmp
echo "Number of existing rows:"
wc -l $BASE/$TARGET.tmp
sort -u $BASE/$TARGET.append.tmp $BASE/$TARGET.tmp > $BASE/$TARGET.fixed.tmp
echo "Number of combined rows:"
wc -l $BASE/$TARGET.fixed.tmp

echo "Sorting data..."
# Explicitly set locale so that sorts are stable.
LC_ALL=C
sort -k 2,2 -k 1,1 -k 3,3n $BASE/$TARGET.fixed.tmp > $BASE/$TARGET.txt
