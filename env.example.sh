set -o errexit

export CACHE_BUCKET=example_metadata

if [ ! -f sources.json ]; then
  aws s3 cp s3://$CACHE_BUCKET/sources.json ./
fi

export CACHE_PREFIX=$(jq -r '.telemetry.metadata_prefix' < sources.json)/client_index
export DATA_BUCKET=$(jq -r '.telemetry.bucket' < sources.json)
export DATA_PREFIX=$(jq -r '.telemetry.prefix' < sources.json)

export HEKA_PATH=/mnt/work/heka-0_10_0-linux-amd64/bin

B=`basename $0`
if [ "$B" = "env.sh" ]; then
  echo "Metadata: s3://$CACHE_BUCKET/$CACHE_PREFIX"
  echo "Data:     s3://$DATA_BUCKET/$DATA_PREFIX"
  echo "Heka:     $HEKA_PATH"
fi
