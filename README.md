# VMTest - Vim Minimal Test framework

:warning: alfa version :warning:

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

```vimscript
call vmtest#plugin('plugin')
let g:vmtests.plugin.first_scope = {}

function! g:vmtests.plugin.first_scope._before()
  echo 'call back to run before each test'
endfunction

function! g:vmtests.plugin.first_scope._after()
  echo 'call back to run after each test'
endfunction

function! g:vmtests.plugin.first_scope.test_foo()
  call assert_equal(1, 2)
endfunction

let g:vmtests.plugin.second_scope = { '_name': 'My Other Scope' }

function! g:vmtests.plugin.second_scope.test_bar()
  call assert_equal(1, 1)
endfunction
```

* output

```text
-> first_scope
call back to run before each test
>> test_foo: Failed
 » Expected 1 but got 2
call back to run after each test
-> My Other Scope
>> test_bar: Success
```

# Contribution

:warning: alfa version :warning:

Feedback and Pull Requests are welcome.
