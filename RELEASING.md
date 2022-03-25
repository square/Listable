# Releasing a new version

1. You must be listed as an owner of the pods `ListableUI` and `BlueprintUILists`.

   To check this run:

   ```bash
   bundle exec pod trunk info ListableUI
   bundle exec pod trunk info BlueprintUILists
   ```

   See [the CocoaPods documentation for pod trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk) for more information about setting up credentials on your device. If you need to be added as an owner, ping in #listable on Slack (Square only).

1. Make sure you're on the `main` branch, and `git pull` to get the latest commits.

1. Create a branch off `main` to update the version numbers and `Podfile.lock`. An example name would be `your-username/release-0.1.0`.

1. Update the library version in `version.rb` if it has not already been updated (it should match the version number that you are about to release).

1. Update `CHANGELOG.md` (in the root of the repo), moving current changes under `Main` to a new section under `Past Releases` for the version you are releasing.
  
   The changelog uses [reference links](https://daringfireball.net/projects/markdown/syntax#link) to link each version's changes. Remember to add a link to the new version at the bottom of the file, and to update the link to `[main]`.

1. Re-generate the documentation.
   ```bash
   bundle exec Scripts/generate_docs.sh
   ```

1. Run `bundle exec pod install` to update the `Podfile.lock` with the new versions.

1. Commit the podspec version bumps and the `Podfile.lock` update.
   ```bash
   git commit -am "Bumping versions to 0.1.0."
   ```

1. Push your branch and open a PR into `main`.

1. Once the PR is merged, fetch changes and tag the release, using the merge commit:
   ```bash
   git fetch
   git tag 0.1.0 <merge commit SHA>
   git push origin 0.1.0
   ```

1. Publish to CocoaPods

   Note: You may also need to quit Xcode before running these commands in order for the linting builds to succeed.

   ```bash
   LISTABLE_PUBLISHING=true bundle exec pod trunk push ListableUI.podspec
   # The --synchronous argument ensures this command builds against the
   # version of ListableUI that we just published.
   LISTABLE_PUBLISHING=true bundle exec pod trunk push BlueprintUILists.podspec --synchronous
   ```