# Stock price lookup by ticker (case-insensitive). Requires FINNHUB_API_KEY in ~/.zshrc.local.
stonks() {
    TICKER=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    echo -n "$TICKER Current Price: \$" && curl -s "https://finnhub.io/api/v1/quote?symbol=$TICKER&token=$FINNHUB_API_KEY" | jq -r .c
}
