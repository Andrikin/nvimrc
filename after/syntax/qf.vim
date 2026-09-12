setlocal conceallevel=2
setlocal concealcursor=nvc
syn match qfFileNameConceal =[^/]*/= contained nextgroup=qfFileNameConceal,qfFileName conceal
syn match qfFileName /^[^|]*/ contains=qfFileNameConceal nextgroup=qfSeparator1
