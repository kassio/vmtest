# VMTest - Vim Minimal Test framework

:warning: alfa version :warning:

The main goal of this plugin is to give a _minimal structure_ to write vimscript
tests based on the existing `assert_*` functions that already exist.

* _minimal structure_: use basic vimscript structures and functions with minimal
custom functions/DSL.

## Structure

VMTest simple iterate over `g:vmtests` keys looking for functions to run and
print `Success` or `Failed` based on `v:errors`.

### Example

On your plugin you create a `vmtest` folder with a test file like:

* tests

```vimscript
if !exists('g:vmtests')
  let g:vmtests = {}
end

let g:vmtests = { 'plugin': { '_name': 'My Plugin' } }
let g:vmtests.plugin.first_scope = { '_name': 'My Scope' }

function! g:vmtests.plugin.first_scope._before()
  new
endfunction

function! g:vmtests.plugin.first_scope._after()
  bd
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
-> My Plugin
->> My Scope
>>> test_foo: Failed
>>> function <SNR>94_run_tests[12]..<SNR>94_scope[13]..<SNR>94_scope[15]..<SNR>94_execute[2]
..<SNR>94_execute_test[4]..313 line 1: Expected 1 but got 2
->> My Other Scope
>>> test_bar: Success
```

# Contribution

:warning: alfa version :warning:

Feedback and Pull Requests are welcome.
