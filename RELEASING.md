# Releasing a new version

1. Make sure you're on the `main` branch, and `git pull` to get the latest commits.

1. Create a branch off `main` to update the version numbers. An example name would be `your-username/release-0.1.0`.

1. Update localized strings. Find the sha of the latest commit with `git log`, then run `./Scripts/install_localized_strings.sh [sha]` to download the latest translations. 

1. Update the library version in `version.rb` if it has not already been updated (it should match the version number that you are about to release).

1. Update `CHANGELOG.md` (in the root of the repo), moving current changes under `Main` to a new section under `Past Releases` for the version you are releasing.
  
   The changelog uses [reference links](https://daringfireball.net/projects/markdown/syntax#link) to link each version's changes. Remember to add a link to the new version at the bottom of the file, and to update the link to `[main]`.

1. Commit the version bumps.
   ```bash
   git commit -am "Bumping versions to 0.1.0."
   ```

1. Re-generate the documentation.
   ```bash
   bundle exec Scripts/generate_docs.sh
   ```

1. Push your branch and open a PR into `main`.

1. Once the PR is merged, fetch changes and tag the release, using the merge commit:
   ```bash
   git fetch
   git tag 0.1.0 <merge commit SHA>
   git push origin 0.1.0
   ```
