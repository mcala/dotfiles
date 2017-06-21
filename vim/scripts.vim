if did_filetype()  " filetype already set..
  finish    " ..don't do these checks
endif
if getline(1) =~ '!qe'
  set filetype=qe
elseif getline(1) =~ '!vasp'
  set filetype=vasp
endif
