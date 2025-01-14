sender=$1
token=$2
router=$3

result=$(
  curl -X 'POST' \
    'http://localhost:8080/api-dex/api/common/submit' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d "{
  \"network\": \"hardhat\",
  \"userAddress\": \"${sender}\",
  \"contractAddress\": \"${token}\",
  \"function\": \"approve\",
  \"args\": [
		\"${router}\",
		\"10000000\"
  ]
}"
)
echo $result

sleep 2
