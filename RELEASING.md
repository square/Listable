# Releasing a new version

1. Make sure you're on the `main` branch, and `git pull` to get the latest commits.

1. Determine the version number of the release you are creating.

1. Invoke the release script: `Scripts/release.sh ${VERSION}`. You will be prompted to update CHANGELOG.md and create a pull request into `main`.

1. Go to the [Releases](https://github.com/square/Listable/releases) and `Draft a new release`.

1. In the release notes, copy the changes from the changelog.

1. Ensure the `Title` corresponds to the version we're publishing.

1. Merge the PR, then hit `Publish release`.
