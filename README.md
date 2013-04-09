# Berkshelf Ext

Berkshelf extensions to add features to berkshelf not
accepted upstream.

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

* Resolution via nested berksfiles (nested_berksfiles)
* Proper berksfile path when loading berksfiles (berksfile_loader_context)
* Proper dependency resolution (dependency_chains)

## Prevent extension loading

You can explicitly define what is allowed or not allowed to load via
environment variables

* `BERKSHELF_EXT_EXCEPT="nested_berksfiles"`
* `BERKSHELF_EXT_ONLY="nested_berksfiles,berksfile_loader_context"`

# Info
* Repository: https://github.com/chrisroberts/berkshelf_ext
