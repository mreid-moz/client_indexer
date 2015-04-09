source env.sh
# List S3
aws s3 ls s3://$CACHE_BUCKET/$CACHE_PREFIX/ > s3cache.list

# List last 30 days
for n in $(seq 2 30); do
    D=$(date -d "$n days ago" +%Y%m%d)
    if [ -z "$(grep $D s3cache.list)" ]; then
        echo "$D is missing"
        bash index.sh $D
        bash put_s3.sh $D
    else
        echo "$D is already in S3"
    fi
done

# Make sure to check/update today and yesterday.
for n in $(seq 0 1); do
    D=$(date -d "$n days ago" +%Y%m%d)
    echo "Checking for diffs in $D"
    bash index.sh $D
    if [ ! -z "$(grep $D s3cache.list)" ]; then
        bash get_s3.sh $D
        if [ -f "$D.s3.txt" ]; then
            if [ ! -z "$(diff $D.s3.txt $D.txt)"]; then
                echo "$D had changes since it was last updated"
                bash put_s3.sh $D
            else
                echo "$D was correct in S3"
            fi
        else
            echo "$D was not in the cache (or we failed to download it)"
            bash put_s3.sh $D
        fi
    else
        echo "$D was not in the list"
        bash put_s3.sh $D
    fi
done
