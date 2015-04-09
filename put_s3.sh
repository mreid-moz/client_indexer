source env.sh
echo "TODO: Updating s3://$CACHE_BUCKET/$CACHE_PREFIX/$1.txt"
# TODO:
# gzip "$1.txt"
# aws s3 cp "$1.txt.gz" "s3://$CACHE_BUCKET/$CACHE_PREFIX/" --content-type "text/plain" --content-encoding gzip
