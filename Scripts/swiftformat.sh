if ! command -v swiftformat &> /dev/null
then
    echo "Installing swiftformat with brew..."
    brew install swiftformat
fi

swiftformat .
