token=$1
amountToken=$2
amountETH=$3
user=$4

result=$(
  curl -X 'POST' \
    'http://localhost:8080/api-dex/api/common/submitWithETH' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d "{
  \"userAddress\": \"${user}\",
  \"contractName\": \"Router\",
  \"function\": \"addLiquidityETH\",
  \"args\": [
		\"${token}\",
		\"${amountToken}\",
		\"0\",
		\"0\",
		\"${user}\",
		0
  ],
  \"eth\": \"${amountETH}\"
}"
)
echo $result

sleep 2
