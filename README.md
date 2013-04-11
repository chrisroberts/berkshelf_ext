# Berkshelf Ext

Berkshelf extensions to add features to berkshelf.

## Usage

### Via Bundler

If using via `bundler`, just add an entry in the Gemfile:

`gem 'berkshelf_ext'`

and it will auto inject itself.

### Direct

Since bundler does some special loading that rubygems proper
does not, we can't auto-inject ourselves in. Instead, just
call the custom executable:

`berks_ext`

Which will add the extensions to berkshelf, and then initialize
it as usual.

## Current extensions

These extensions are auto loaded by default.

* Resolution via nested berksfiles (nested_berksfiles)[1]
* Proper berksfile path when loading berksfiles (berksfile_loader_context)[2]
* Proper dependency resolution (dependency_chains)[3]
* Do not include recommends entries in cookbook dependencies (non_recommends_depends)

## Prevent extension loading

You can explicitly define what is allowed or not allowed to load via
environment variables

* `BERKSHELF_EXT_EXCEPT="nested_berksfiles"`
* `BERKSHELF_EXT_ONLY="nested_berksfiles,berksfile_loader_context"`

## Current addons

Addons are extensions that must be explicitly enabled via environment variable:

* `BERKSHELF_EXT_ADDONS="knife_uploader"`

### Available addons

* Knife based cookbook uploading (disables Ridley)[4]

# References

1. https://github.com/RiotGames/berkshelf/pull/304
2. https://github.com/RiotGames/berkshelf/pull/304
3. https://github.com/RiotGames/berkshelf/pull/302
4. https://github.com/RiotGames/berkshelf/pull/291 

# Info
* Repository: https://github.com/chrisroberts/berkshelf_ext
