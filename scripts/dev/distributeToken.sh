router=$(
  curl -X 'GET' \
    'http://localhost:8080/api/utils/getRouter' \
    -H 'accept: text/plain'
)
echo router = $router

cat "./accounts.json" | jq -c '.[] | {index: .index, address: .address}' | while read -r item; do
  index=$(echo "$item" | jq -r '.index')
  address=$(echo "$item" | jq -r '.address')

  cat "./tokens.json" | jq -c '.[] | {tokenAddress: .address}' | while read -r item; do
    tokenAddress=$(echo "$item" | jq -r '.tokenAddress')
    # echo token = $tokenAddress

    ./scripts/dev/token/transfer.sh $tokenAddress $address
    sleep 1
    ./scripts/dev/token/approve.sh $address $tokenAddress $router
    sleep 1
  done

done
