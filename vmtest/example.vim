" Setup the vmtest for the given plugin
call vmtest#plugin('vmtest')

" Scope without a custom name
" The scope key will be used as its name
let g:vmtests.vmtest.first_scope = {}

" Similar to the `setup` of some test libraries
function! g:vmtests.vmtest.first_scope._before()
  echo "call back to run before each test\n"
  let self.context_var = 'foo'
endfunction

" Similar to the `teardown` of some test libraries
function! g:vmtests.vmtest.first_scope._after()
  echo "call back to run after each test\n"
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
