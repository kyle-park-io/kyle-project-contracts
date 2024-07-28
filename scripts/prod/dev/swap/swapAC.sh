curl -X 'POST' \
  'http://localhost:8080/api-dex/api/common/submit' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "userName": "user1",
  "contractName": "Router",
  "function": "swapExactTokensForTokens",
  "args": [
    "100",
    "0",
		[
      "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707",
      "0x0165878A594ca255338adfa4d48449f69242Eb8F",
      "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853"
    ],
		"0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
		1
  ]
}'
sleep 2
