ACTUAL_DOWNLOAD=$1
CHECK_SHA=$2

ACTUAL_HASH="$(shasum -a 256 $ACTUAL_DOWNLOAD | awk '{print $1}')"
EXPECTED_HASH="$(cat $CHECK_SHA | awk '{print $1}')"

echo "Checking equality of hashes..."
echo "ACTUAL: $ACTUAL_HASH"
echo "EXPECTED: $EXPECTED_HASH"

if [ "$ACTUAL_HASH" = "$EXPECTED_HASH" ]; then
  echo "Hashes match."
else
  echo "Hashes do NOT match."
fi

