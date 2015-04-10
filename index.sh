source env.sh

TARGET=$1
if [ -z "$TARGET" ]; then
    echo "ERROR: Missing required date argument"
    exit -1
fi

BASE=$(pwd)
P=/mnt/work/heka-0_10_0-linux-amd64/bin

echo "Getting client offsets for $TARGET in $DATA_BUCKET"

# Make a schema
cat $BASE/schema_template.json | sed -r "s/__TARGET__/$TARGET/" > $BASE/schema.$TARGET.json

LIST=$BASE/s3files.$TARGET.list

echo "Listing files for $TARGET"
$HEKA_PATH/heka-s3list -bucket $DATA_BUCKET -bucket-prefix $DATA_PREFIX -schema $BASE/schema.$TARGET.json > $LIST

# TODO: save $LIST too.

echo "Fetching data for $(wc -l $LIST) files..."
time cat $LIST | $HEKA_PATH/heka-s3cat -bucket $DATA_BUCKET -format offsets -stdin -output $BASE/$TARGET.tmp &> $TARGET.log

echo "Sorting data..."
# Explicitly set locale so that sorts are stable.
LC_ALL=C
sort -k 2,2 -k 1,1 -k 3,3n $BASE/$TARGET.tmp > $BASE/$TARGET.txt
