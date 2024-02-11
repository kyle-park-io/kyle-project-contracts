tokenA=$1
tokenB=$2
amountA=$3
amountB=$4
user=$5

result=$(
  curl -X 'POST' \
    'http://localhost:8080/api/common/submit' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d "{
  \"userAddress\": \"${user}\",
  \"contractName\": \"Router\",
  \"function\": \"addLiquidity\",
  \"args\": [
		\"${tokenA}\",
		\"${tokenB}\",
		\"${amountA}\",
		\"${amountB}\",
		\"0\",
		\"0\",
		\"${user}\",
		0
  ]
}"
)
echo $result

sleep 2
