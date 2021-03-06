source env.sh
# List S3
aws s3 ls s3://$CACHE_BUCKET/$CACHE_PREFIX/ > s3cache.list

# List last 30 days
for n in $(seq 2 30); do
    D=$(date -d "$n days ago" +%Y%m%d)
    if [ -z "$(grep $D.txt s3cache.list)" ]; then
        echo "$D is missing"
        bash index.sh $D
        bash put_s3.sh $D
    else
        echo "$D is already in S3"
        if [ -z "$LAST_DAY" ]; then
            # This is the last day we've seen. Stash it for later.
            LAST_DAY=$D
        fi
    fi
done

# Make sure to check/update today and yesterday.
for n in $(seq 0 1); do
    D=$(date -d "$n days ago" +%Y%m%d)
    echo "Checking for diffs in $D"
    bash index.sh $D
    if [ ! -z "$(grep $D.txt s3cache.list)" ]; then
        NEWER_DAY=$D
        bash get_s3.sh $D
        if [ -f "$D.s3.txt" ]; then
            if [ ! -z "$(diff $D.s3.txt $D.txt)" ]; then
                echo "$D changed since it was last updated"
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

# We should try to re-calculate the last-seen date since
# it most likely only covers part of that day.
if [ ! -z "$LAST_DAY" -a -z "$NEWER_DAY" ]; then
    echo "Recalculating $LAST_DAY"
    bash index.sh $LAST_DAY
    bash put_s3.sh $LAST_DAY
fi
