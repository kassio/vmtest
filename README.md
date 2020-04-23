# VMTest - Vim Minimal Test framework

:warning: alfa version :warning:

[![example](https://github.com/kassio/vmtest/workflows/example/badge.svg?branch=master)](https://github.com/kassio/vmtest/actions)

The main goal of this plugin is to give a _minimal structure_ to write vimscript
tests based on the existing `assert_*` functions that already exist.

* _minimal structure_: use basic vimscript data structures and functions.

## Structure

VMTest simple iterate over `g:vmtests` keys looking for functions to run and
print `Success` or `Failed` based on `v:errors`.

There are a few reserved keys, used internally:
* `_name` - Optional custom name of a scope
* `_before` - Call back to run before each test of the scope
* `_after` - Call back to run after each test of the scope
* `_errors` - List of all errors

### Example

On your plugin you create a `vmtest` folder with a test file like:

* tests

```viml
" Setup the vmtest for the given plugin
call vmtest#plugin('vmtest')

" Scope without a custom name
" The scope key will be used as its name
let g:vmtests.vmtest.first_scope = {}

" Similar to the `setup` of some test libraries
function! g:vmtests.vmtest.first_scope._before()
  echo "callback to run before each test\n"
  let self.context_var = 'foo'
endfunction

" Similar to the `teardown` of some test libraries
function! g:vmtests.vmtest.first_scope._after()
  echo "callback to run after each test\n"
endfunction

" A test function on the `first_scope` scope
function! g:vmtests.vmtest.first_scope.test_foo()
  call assert_equal(self.context_var, 2)
endfunction

" A test function on the `first_scope` scope
function! g:vmtests.vmtest.first_scope.test_bar()
  call assert_notequal(self.context_var, 2)
endfunction

" Scope with a custom name
let g:vmtests.vmtest.second_scope = { '_name': 'My Other Scope' }

" A test function on the `second_scope` scope
function! g:vmtests.vmtest.second_scope.test_bar()
  call assert_equal(1, 1)
endfunction
```

* output

```text
=> vmtest
 -> first_scope
callback to run before each test
  » test_bar: Success
callback to run after each test
callback to run before each test
  » test_foo: Failed
  ! Expected 'foo' but got 2
callback to run after each test
 -> second_scope
  » test_bar: Success
```

# Contribution

:warning: alfa version :warning:

Feedback and Pull Requests are welcome.
