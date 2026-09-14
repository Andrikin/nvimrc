setlocal conceallevel=2
setlocal concealcursor=nvc
if has('win32')
    syn match qfFileNameConceal =[^|]\{-}\\= contained nextgroup=qfFileNameConceal,qfFileName conceal
else
    syn match qfFileNameConceal =[^|]\{-}/= contained nextgroup=qfFileNameConceal,qfFileName conceal
end
syn match qfFileName /^[^|]*/ contains=qfFileNameConceal nextgroup=qfSeparator1
