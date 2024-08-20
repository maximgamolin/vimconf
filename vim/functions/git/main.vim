function! FindGitRelativePath(file)
  " Поиск ближайший папки гит от файла
  let l:current_dir = fnamemodify(a:file, ':h')
  let l:git_dir = ''

  while l:current_dir != '/' && l:git_dir == ''
    if isdirectory(l:current_dir . '/.git')
      let l:git_dir = l:current_dir
    else
      let l:current_dir = fnamemodify(l:current_dir, ':h')
    endif
  endwhile

  if l:git_dir == ''
    echo "Error: .git directory not found"
    return ''
  endif

  return substitute(a:file, l:git_dir . '/', '', '')
endfunction

function! GitLogForVisualRange()
  " Функция для показа куска истории через гит лог
  let l:start = line("'<")
  let l:end = line("'>")
  let l:file = expand('%:p')
  let l:relative_path = FindGitRelativePath(l:file)

  " Create the command string with --graph option
  let l:cmd = 'Git log -L ' . l:start . ',' . l:end . ':' . l:relative_path . ' --graph'

  " Execute the command
  execute l:cmd
endfunction

function! GitLogForFile()
  " Функция для показа всей истории файла через гит лог
  let l:file = expand('%:p')
  let l:relative_path = FindGitRelativePath(l:file)

  " Create the command string with --graph option
  let l:cmd = 'Git log --stat -p '. l:relative_path

  " Execute the command
  execute l:cmd
endfunction


