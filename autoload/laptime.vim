if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================

let g:laptimes = {}
function! g:laptimes.show(...)
  let items = sort(items(filter(copy(self), 'v:key!="show"')), 's:sort')
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
  while i < len
    let self.result .= printf("%3d: %s  %s  %s\n", i+1, self.totaltimes[i], self.laptimes[i], self.messages[i])
    let i += 1
  endwhile
  let before_lt = get(s:stock, self.num-1, {})
  if before_lt != {} && before_lt._isnot_ended()
    let self.contained = before_lt.num
    let self.result = s:_resultheader(self). self.result
    let g:laptimes[self.num] = self.result
    let before_lt.contain = self.num
    call extend(self, before_lt)
  else
    let self.result = s:_resultheader(self). self.result
    let g:laptimes[self.num] = self.result
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

function! s:_resultheader(this) "{{{
  return printf("%s\n       TOTAL       LAP        %14s %14s\n", a:this.__caption__, (a:this.contain ? 'CONTAIN: ['. a:this.contain. '] ' : ' '), (a:this.contained ? 'CONTAINED: ['. a:this.contained. ']': ''))
endfunction
"}}}

function! laptime#new(...) "{{{
  let lt = {'laptimes': [], 'totaltimes': [[0, 0]], 'messages': [], '__caption__': get(a:, 1, ''), 'contain': 0, 'contained': 0, 'result': ''}
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
