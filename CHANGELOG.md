## v1.0.20
* Include `--nested-depth` option on `install` command

## v1.0.18
* Include full source loading all the time (missed when extracting from the 302 PR)

## v1.0.16
* Add nesting support to `install` command (#2)

## v1.0.14
* Use chef configurations from berks config if unset by knife
* Fix exception namespacing
* Provide path information when Berksfile processing fails
* Allow limiting depth of nested berksfiles `--nested-depth n`
* Attempt to properly identify cookbook causing solution failure
  * Provide better output for solution failures

## v1.0.12
* Add proper support for metadata with missing name

## v1.0.10
* Forcibly set name when uploading via knife
* Only load sources of specified cookbooks when uploading with `--skip-dependencies`

## v1.0.8
* Add environment variable to allow loading all available extensions
* Add new addon extension fast_resolution to locate and use cached cookbooks faster

## v1.0.6
* Add custom resolve to berksfile for dependency_chains to account for reverted changeset

## v1.0.4
* Properly autoload berksfile module in dependency_chains

## v1.0.2
* Add `non_recommends_depends` to fix dependency resolution
* Add `knife_uploader` addon to disable ridley based uploads
* Remove preemptive cookbook fetching. Fixes proper dependency resolution to use dependencies defined within Berksfile when explicitly defining cookbooks to upload.

## v1.0.0
* Initial release
