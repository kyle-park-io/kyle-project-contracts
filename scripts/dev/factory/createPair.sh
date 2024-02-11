tokenA=$1
tokenB=$2

result=$(
  curl -X 'POST' \
    'http://localhost:8080/api/common/submit' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d "{
  \"userName\": \"admin\",
  \"contractName\": \"Factory\",
  \"function\": \"createPair\",
  \"args\": [
		\"${tokenA}\",
		\"${tokenB}\"
  ]
}"
)
echo $result

sleep 2
