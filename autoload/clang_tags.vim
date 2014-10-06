function! clang_tags#get_offset()
    return eval(line2byte(line('.')) + col('.'))
endfunction

function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

let g:clang_tags#root_file = '.ct.pid'
let g:clang_tags#command = 'clang-tags'

function! clang_tags#find_root_dir(dir)
    let ldir = a:dir
    while 1
        if filereadable(ldir . '/' . g:clang_tags#root_file)
            break
        else
            let ndir = fnamemodify(ldir, ':h')
            if ndir == ldir
                echoerr "Root file not found. Are you sure clang-tags server is running?"
                break
            endif
            let ldir = ndir
        endif
    endwhile
    return ldir
endfunction

function! clang_tags#do_cmd(cmd)
    let oldwd = getcwd()
    exec 'chdir ' . clang_tags#find_root_dir(oldwd)
    let res = split(system(g:clang_tags#command . ' ' . a:cmd), '\n')
    exec 'chdir ' . oldwd
    return res
endfunction

function! clang_tags#get_USR()
    let path = expand('%:p')
    let offset = clang_tags#get_offset()
    let res = clang_tags#do_cmd('find-def ' . path . ' ' . offset)
    for i in res
        let line = Strip(i)
        if line =~ "^USR: "
            return line[5:]
        endif
    endfor
    return ""
endfunction

function! clang_tags#grep()
    let def = clang_tags#get_USR()

    if strlen(def) > 0
        let loclist = []
        let res = clang_tags#do_cmd('grep \'' . def . '\'')
        let cwd = clang_tags#find_root_dir(getcwd())
        for i in res[1:]
            let t = split(i, ':')
            let item = {'filename' : cwd . '/' . t[0], 'lnum' : t[1], 'text' : join(t[2:], ':')}
            call add(loclist, item)
        endfor
        call setloclist(0, loclist)
        exec "lopen"
    endif
endfunction

function! clang_tags#update()
    clang_tags#do_cmd('update')
endfunction

