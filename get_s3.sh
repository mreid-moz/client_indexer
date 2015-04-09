source env.sh

aws s3 cp s3://$CACHE_BUCKET/$CACHE_PREFIX/$1.txt ./$1.s3.txt

# TODO:
#aws s3 cp s3://$CACHE_BUCKET/$CACHE_PREFIX/$1.txt.gz ./$1.s3.txt.gz
#gunzip ./$1.s3.txt
