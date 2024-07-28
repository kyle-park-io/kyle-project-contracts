tokenA=0x5FbDB2315678afecb367f032d93F642f64180aa3
tokenB=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512

result=$(
  curl -X 'POST' \
    'http://localhost:3000/api/common/submit' \
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
