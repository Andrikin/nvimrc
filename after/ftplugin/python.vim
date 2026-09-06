if executable('uv.exe')
    let &l:makeprg = 'uv run %:S'
elseif executable('python')
    let &l:makeprg = 'python3 %:S'
endif
compiler pyunit
