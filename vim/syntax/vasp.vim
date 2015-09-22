" Vim Syntax File for vasp
" Andrew McAllister
" September 22nd, 2015

syntax case ignore

" Integer with - + or nothing in front
 syn match celNumber '\d\+'
 syn match celNumber '[-+]\d\+'
" " Floating point number with decimal no E or e (+,-)
 syn match celNumber '\d\+\.\d*'
 syn match celNumber '[-+]\d\+\.\d*'
" " Floating point like number with E and no decimal point (+,-)
 syn match celNumber '[-+]\=\d[[:digit:]]*[eE][\-+]\=\d\+'
 syn match celNumber '\d[[:digit:]]*[eE][\-+]\=\d\+'
" " Floating point like number with E and decimal point (+,-)
 syn match celNumber '[-+]\=\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'
 syn match celNumber '\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'
 " Letters Highlighting
 syn match celWord '=.*$'
 syn match celWord '\..*$'

"Keywords
syn keyword namelists GENERAL ELECTRONIC IONIC PARALLELIZATION

" NOTE: The space in the line continuations must be there!
syn keyword flags ADDGRID AEXX AGGAC AGGAX ALDAC ALGO AMIN AMIX AMIX ANDERSEN
  \ APACO BMIX BMIX CMBJ CMBJA CMBJB CSHIFT DEPER DIPOL DQ EBREAK EDIFF EDIFFG
  \ EFIELD EFIELD EMAX EMIN ENAUG ENCUT EPSILON EVENONLY FERDO FERWE GGA HFSCREEN
  \ HILLS HILLS HILLS I IALGO IBRION ICHARG ICHIBARE IDIPOL IMAGES IMIX INCREM
  \ INIMIX INIWAV IPEAD ISIF ISMEAR ISPIN ISTART ISYM KBLOCK KPAR LAMBDA LANGEVIN
  \ LANGEVIN LASPH LBLUEOUT LCALCEPS LCALCPOL LCHARG LCHIMAG LDAU LDAUJ LDAUL
  \ LDAUPRINT LDAUTYPE LDAUU LDIPOL LEFG LELF LEPSILON LHFCALC LHYPERFINE LKPROJ
  \ LMAXFOCK LMAXFOCKAE LMAXMIX LMAXPAW LMAXTAU LMIXTAU LMONO LNABLA LNMR
  \ LNONCOLLINEAR LOPTICS LORBIT LPEAD LPLANE LREAL LRPA LSCALAPACK LSCALU LSORBIT
  \ LSPECTRAL LTHOMAS LVTOT LWANNIER90 LWANNIER90 LWAVE LWRITE M MAGMOM MAXMIX
  \ MDALGO METAGGA MIXPRE NBANDS NBLOCK NCORE NDAV NEDOS NELECT NELM NELMDL NELMIN
  \ NFREE NGX NGXF NGY NGYF NGYROMAG NGZ NGZF NKRED NKREDX NKREDY NKREDZ NLSPLINE
  \ NOMEGA NOMEGAR NPACO NPAR NSIM NSUBSYS NSW ODDONLY OMEGAMAX OMEGATL PFLAT
  \ PLEVEL PMASS POTIM PREC PRECFOCK PROUTINE PSUBSYS PTHRESHOLD QUAD RANDOM ROPT
  \ RWIGS SAXIS SHAKEMAXITER SHAKETOL SIGMA SMASS SPRING SYMPREC TEBEG TEEND TIME
  \ TSUBSYS VALUE VALUE WC WEIMIN SYSTEM
"Matches
"

" Highlighting
hi def link namelists Statement
hi def link flags Constant
hi def link celNumber Type
hi def link celWord Type
