# Releasing a new version

1. Make sure you're on the `main` branch, and `git pull` to get the latest commits.

1. Create a branch off `main` to update the version numbers. An example name would be `your-username/release-0.1.0`.

1. Update localized strings. Find the sha of the latest commit with `git log`, then run `./Scripts/install_localized_strings.sh [sha]` to download the latest translations. 

1. Update `CHANGELOG.md` (in the root of the repo), moving current changes under `Main` to a new section under `Past Releases` for the version you are releasing.

1. Re-generate the documentation.
   ```bash
   bundle exec Scripts/generate_docs.sh
   ```

1. Commit the version bumps and doc changes.
   ```bash
   git commit -am "Bumping version to 0.1.0"
   ```

1. Push your branch and open a PR into `main`.

1. Go to the [Releases](https://github.com/square/Listable/releases) and `Draft a new release`.

1. In the release notes, copy the changes from the changelog.

1. Ensure the `Title` corresponds to the version we're publishing.

1. Merge the PR, then hit `Publish release`.