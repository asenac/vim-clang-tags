if &cp || exists("g:loaded_clang_tags")
 finish
endif
let g:loaded_clang_tags = 1

command! -nargs=0 ClangTagsGrep :call clang_tags#grep()
