weth=$(
  curl -X 'GET' \
    'http://localhost:8080/api/utils/getWETH' \
    -H 'accept: text/plain'
)
echo weth = $weth

cat "./tokens.json" | jq -c '.[] | {tokenIndex: .index, tokenAddress: .address}' | while read -r item; do
  tokenAIndex=$(echo "$item" | jq -r '.tokenIndex')
  tokenA=$(echo "$item" | jq -r '.tokenAddress')

  cat "./tokens.json" | jq -c '.[] | {tokenIndex: .index, tokenAddress: .address}' | while read -r item; do
    tokenBIndex=$(echo "$item" | jq -r '.tokenIndex')
    tokenB=$(echo "$item" | jq -r '.tokenAddress')

    if [ "$tokenBIndex" -gt "$tokenAIndex" ]; then
      echo call createPair
      ./scripts/dev/factory/createPair.sh $tokenA $tokenB
      sleep 1
    fi
  done

  echo call createPair
  ./scripts/dev/factory/createPair.sh $tokenA $weth
  sleep 1
done
