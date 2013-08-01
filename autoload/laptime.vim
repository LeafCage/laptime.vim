if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================

let s:laptimes = {'disable': 0}
function! s:laptimes.show(...)
  let items = sort(items(filter(copy(self), 'v:key=~''\d\+''')), 's:sort')
  let bgnidx = get(a:, 1, 0)
  let bgnidx = bgnidx > 0 ? bgnidx-1 : bgnidx
  let bgnidx = len(items)-1 < bgnidx ? -1 : bgnidx
  let items = items[(bgnidx):]
  let lastidx = get(a:, 2, -1)
  let lastidx = lastidx >= 0 ? lastidx-1 : lastidx
  let lastidx = len(items)-1 < lastidx ? -1 : lastidx
  for [key, val] in items[:lastidx]
    echohl Title
    echo '['. key. ']'
    echohl NONE
    for line in split(val, '\n')
      echo line
    endfor
    echo ' '
  endfor
  return ''
endfunction
let g:laptimes = get(g:, 'laptimes', {})
call extend(g:laptimes, s:laptimes, 'keep')

function! s:sort(list1, list2)
  return a:list1[0] - a:list2[0]
endfunction

let s:stock = {}
let s:count = 0
function! s:_lt_num() "{{{
  let s:count += 1
  return s:count
endfunction
"}}}

"======================================
let s:lt = {}
function! s:lt.lap(...)
  call add(self.messages, a:000)
  call add(self.totaltimes, reltime(self.start))
  call add(self.laptimes, reltime(self.totaltimes[-2], self.totaltimes[-1]))
endfunction

function! s:lt.end(...)
  call call(self.lap, a:000, self)
  let self.totaltimes = map(self.totaltimes[1:], 'reltimestr(v:val)')
  call map(self.laptimes, 'reltimestr(v:val)')
  let i = 0
  let len = len(self.totaltimes)
  while i < len
    let self.result .= printf("%3d: %s  %s  %s\n", i+1, self.totaltimes[i], self.laptimes[i], s:_message(self.messages[i]))
    let i += 1
  endwhile
  let before_lt = get(s:stock, self.num-1, {})
  if before_lt != {} && before_lt._isnot_ended()
    let self.contained = before_lt.num
    call s:_set_result(self)
    let before_lt.contain = self.num
    call extend(self, before_lt)
  else
    call s:_set_result(self)
    call filter(s:stock, 'v:key == self.num')
  endif
endfunction

function! s:lt.show()
  exe 'echo "'. self.result. '"'
  return ''
endfunction

function! s:lt._isnot_ended()
  return self.result == ''
endfunction

"======================================
function! s:_message(meslist) "{{{
  let ret = ''
  let p = 0
  for mes in a:meslist
    let ret .= p ? "\n                             " : '> '
    let ret .= type(mes) == type('') ? mes : string(mes)
    let p = 1
    unlet mes
  endfor
  return ret
endfunction
"}}}
function! s:_set_result(this) "{{{
  let a:this.result = s:_resultheader(a:this). a:this.result
  if !g:laptimes.disable
    let g:laptimes[a:this.num] = a:this.result
  endif
endfunction
"}}}
function! s:_resultheader(this) "{{{
  return printf("%s\n       TOTAL       LAP        %14s %14s\n", a:this.caption, (a:this.contain ? 'CONTAIN: ['. a:this.contain. '] ' : ' '), (a:this.contained ? 'CONTAINED: ['. a:this.contained. ']': ''))
endfunction
"}}}
"======================================
function! laptime#new(...) "{{{
  let lt = {'laptimes': [], 'totaltimes': [[0, 0]], 'messages': [], 'caption': join(a:000, "\n"), 'contain': 0, 'contained': 0, 'result': ''}
  let lt.num = s:_lt_num()
  call extend(lt, s:lt, 'keep')
  let s:stock[lt.num] = lt
  let lt.start = reltime()
  return lt
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
