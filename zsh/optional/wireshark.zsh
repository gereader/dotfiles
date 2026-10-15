# Open pcap files in a new Wireshark instance (macOS allows only one by default).
wireshark-open() {
    (wireshark -r "$1" > /dev/null 2>&1 &)
}
