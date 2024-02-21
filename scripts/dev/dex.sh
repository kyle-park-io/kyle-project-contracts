# # add
# basic
cat "./accounts.json" | jq -c '.[] | {index: .index, address: .address}' | while read -r item; do
  index=$(echo "$item" | jq -r '.index')
  address=$(echo "$item" | jq -r '.address')

  # if [ "$index" -eq 1 ]; then
  # fi

  cat "./tokens.json" | jq -c '.[] | {tokenIndex: .index, tokenAddress: .address}' | while read -r item; do
    tokenAIndex=$(echo "$item" | jq -r '.tokenIndex')
    tokenA=$(echo "$item" | jq -r '.tokenAddress')

    cat "./tokens.json" | jq -c '.[] | {tokenIndex: .index, tokenAddress: .address}' | while read -r item; do
      tokenBIndex=$(echo "$item" | jq -r '.tokenIndex')
      tokenB=$(echo "$item" | jq -r '.tokenAddress')

      if [ "$tokenBIndex" -gt "$tokenAIndex" ]; then
        echo call addLiquidity
        ./scripts/dev/addLiquidity/addLiquidity.sh $tokenA $tokenB 5000 5000 $address
        sleep 1
      fi
    done
  done
done

# withETH
cat "./accounts.json" | jq -c '.[] | {index: .index, address: .address}' | while read -r item; do
  index=$(echo "$item" | jq -r '.index')
  address=$(echo "$item" | jq -r '.address')

  # if [ "$index" -eq 1 ]; then
  # fi

  cat "./tokens.json" | jq -c '.[] | {tokenIndex: .index, tokenAddress: .address}' | while read -r item; do
    tokenAIndex=$(echo "$item" | jq -r '.tokenIndex')
    tokenA=$(echo "$item" | jq -r '.tokenAddress')

    echo call addLiquidityETH
    ./scripts/dev/addLiquidity/addLiquidityETH.sh $tokenA 5000 10 $address
    sleep 1
  done
done

# # swap
