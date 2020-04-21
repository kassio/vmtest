if !exists('g:vmtests')
  let g:vmtests =  {}
end

command -nargs=? VMTestRun call vmtest#run(<f-args>)
command VMTestQuit call vmtest#quit()
