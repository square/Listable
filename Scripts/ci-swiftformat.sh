./Scripts/swiftformat.sh

if [[ -n $(git status --porcelain) ]]; then
    echo "Please format your files with './Scripts/swiftformat.sh'"
    exit 1
fi
