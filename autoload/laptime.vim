if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================

let g:laptimes = {}
let s:count = 0
function! s:_lt_num() "{{{
  let s:count += 1
  return s:count
endfunction
"}}}

let s:lt = {}
function! s:lt.lap(...)
  call add(self.messages, get(a:, 1, ''))
  call add(self.totaltimes, reltime(self.start))
  call add(self.laptimes, reltime(self.totaltimes[-2], self.totaltimes[-1]))
endfunction

function! s:lt.end(...)
  call self.lap(get(a:, 1, ''))
  let self.totaltimes = map(self.totaltimes[1:], 'reltimestr(v:val)')
  call map(self.laptimes, 'reltimestr(v:val)')
  let i = 0
  let len = len(self.totaltimes)
  let self.result .= "       TOTAL       LAP\n"
  while i < len
    let self.result .= printf("%3d: %s  %s  %s\n", i+1, self.totaltimes[i], self.laptimes[i], self.messages[i])
    let i += 1
  endwhile
  let g:laptimes[self.num] = self.result
endfunction

function! s:lt.show()
  exe 'echo "'. self.result. '"'
  return ''
endfunction


function! laptime#new(...) "{{{
  let lt = {'laptimes': [], 'totaltimes': [[0, 0]], 'messages': [], '__caption__': get(a:, 1, '')}
  let lt.result = lt.__caption__. "\n"
  let lt.num = s:_lt_num()
  call extend(lt, s:lt, 'keep')
  let lt.start = reltime()
  return lt
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
