source env.sh

TARGET=$1
echo "Updating s3://$CACHE_BUCKET/$CACHE_PREFIX/$TARGET.txt"

aws s3 cp "$TARGET.txt" "s3://$CACHE_BUCKET/$CACHE_PREFIX/"
# TODO:
# gzip "$1.txt"
# aws s3 cp "$1.txt.gz" "s3://$CACHE_BUCKET/$CACHE_PREFIX/" --content-type "text/plain" --content-encoding gzip
