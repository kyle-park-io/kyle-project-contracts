token=$1
address=$2

result=$(
  curl -X 'POST' \
    'http://localhost:8080/api-dex/api/common/submit' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d "{
  \"userName\": \"admin\",
  \"contractAddress\": \"${token}\",
  \"function\": \"transfer\",
  \"args\": [
		\"${address}\",
		\"10000000\"
  ]
}"
)
echo $result

sleep 2
