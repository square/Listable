# Releasing a new version

1. Make sure you're on the `main` branch, and `git pull` to get the latest commits.

1. Determine the version number of the release you are creating.

1. Invoke the release script: `Scripts/release.sh ${VERSION}`. You will be prompted to update CHANGELOG.md, create a pull request into `main`, and tag the release post-merge.
