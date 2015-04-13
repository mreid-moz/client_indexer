source env.sh

TARGET=$1
echo "Updating s3://$CACHE_BUCKET/$CACHE_PREFIX/$TARGET.txt.gz"

if [ ! -f "$1.txt.gz" ]; then
    gzip "$1.txt"
fi
aws s3 cp "$1.txt.gz" "s3://$CACHE_BUCKET/$CACHE_PREFIX/" --content-type "text/plain" --content-encoding gzip
