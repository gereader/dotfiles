# Stock price lookup, provide ticker symbol, case insensitive, this requires a finnhub api key
stonks() {
    TICKER=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    echo -n "$TICKER Current Price: \$" && curl -s "https://finnhub.io/api/v1/quote?symbol=$TICKER&token=$FINNHUB_API_KEY" | jq -r .c
}

# Wireshark opener, used to open multiple instances of Wireshark on a mac
wireshark-open() {
    (wireshark -r "$1" > /dev/null 2>&1 &)
}