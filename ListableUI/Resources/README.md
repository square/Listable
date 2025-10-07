# Localizations

String translations are done by hand. Note that translation requests are handled asynchronously, and can take a couple of days to complete.

To update the localized string content:

1. Add and/or update the string(s) in the reference language, [en](en/lproj/Localizable.strings).
2. Create a translation request in [go/translate](https://go/translate). Make sure to request all the locales that Listable supports.
3. Upon receiving all of the translations, update the appropriate Localizable.strings files, and open a PR for review!