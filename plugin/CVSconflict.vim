" CVSconflict: a vimdiff-based way to view and edit cvs-conflict containing files
" Author:	Charles E. Campbell, Jr.
" Date:		Sep 28, 2005
" Version:	1
" Copyright:    Copyright (C) 2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               CVSconflict.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
" GetLatestVimScripts: 1370 1 :AutoInstall: CVSconflict.vim

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_CVSconflict") || &cp
 finish
endif
let g:loaded_CVSconflict = "v1"
let s:keepcpo            = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface:	{{{1
com! CVSconflict	call <SID>CVSconflict()

" ---------------------------------------------------------------------
" CVSconflict: this function splits the current, presumably {{{1
"              cvs-conflict'ed file into two versions, and then applies
"              vimdiff.  The original file is left untouched.
fun! s:CVSconflict()
  "call Dfunc("CVSconflict()")

  " sanity check
  if !search('^>>>>>>>','nw')
   echo "***CVSconflict*** no cvs-conflicts present"
   "call Dret("CVSconflict")
   return
  endif

  " construct A and B files
  let curfile = expand("%")
  if curfile =~ '\.'
   let fileA= substitute(curfile,'\.[^.]\+$','A&','')
   let fileB= substitute(curfile,'\.[^.]\+$','B&','')
  else
   let fileA= curfile."A"
   let fileB= curfile."B"
  endif

  " check if fileA or fileB already exists (as a file).  Although CVSconflict
  " doesn't write these files, I don't want to have a user inadvertently
  " writing over such a file.
  if filereadable(fileA)
   echohl WarningMsg | echo "***CVSconflict*** ".fileA." already exists!"
   "call Dret("CVSconflict")
   return
  endif
  if filereadable(fileB)
   echohl WarningMsg | echo "***CVSconflict*** ".fileB." already exists!"
   "call Dret("CVSconflict")
   return
  endif

  " make two windows with separate copies of curfile, named fileA and fileB
  silent vsplit
  let ft=&ft
  exe "silent file ".fileA
  wincmd l
  enew
  exe "r ".curfile
  0d
  exe "silent file ".fileB
  let &ft=ft
  wincmd h

  " fileA: remove
  "   =======
  "   ...
  "   >>>>>>>
  " sections, and remove the <<<<<<< line
  silent g/^=======/.;/^>>>>>>>/d
  silent g/^<<<<<<</d
  set nomod

  " fileB: remove
  "   >>>>>>>
  "   ...
  "   =======
  " sections, and remove the <<<<<<< line
  wincmd l
  silent g/^<<<<<<</.;/^=======/d
  silent g/^>>>>>>>/d
  set nomod

  " set up vimdiff'ing
  diffthis
  wincmd h
  diffthis

  "call Dret("CVSconflict")
endfun

" ---------------------------------------------------------------------
"  Restore Cpo: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: ts=4 fdm=marker
" HelpExtractor:
"  Author:	Charles E. Campbell, Jr.
"  Version:	3
"  Date:	May 25, 2005
"
"  History:
"    v3 May 25, 2005 : requires placement of code in plugin directory
"                      cpo is standardized during extraction
"    v2 Nov 24, 2003 : On Linux/Unix, will make a document directory
"                      if it doesn't exist yet
"
" GetLatestVimScripts: 748 1 HelpExtractor.vim
" ---------------------------------------------------------------------
set lz
let s:HelpExtractor_keepcpo= &cpo
set cpo&vim
let docdir = expand("<sfile>:r").".txt"
if docdir =~ '\<plugin\>'
 let docdir = substitute(docdir,'\<plugin[/\\].*$','doc','')
else
 if has("win32")
  echoerr expand("<sfile>:t").' should first be placed in your vimfiles\plugin directory'
 else
  echoerr expand("<sfile>:t").' should first be placed in your .vim/plugin directory'
 endif
 finish
endif
if !isdirectory(docdir)
 if has("win32")
  echoerr 'Please make '.docdir.' directory first'
  unlet docdir
  finish
 elseif !has("mac")
  exe "!mkdir ".docdir
 endif
endif

let curfile = expand("<sfile>:t:r")
let docfile = substitute(expand("<sfile>:r").".txt",'\<plugin\>','doc','')
exe "silent! 1new ".docfile
silent! %d
exe "silent! 0r ".expand("<sfile>:p")
silent! 1,/^" HelpExtractorDoc:$/d
exe 'silent! %s/%FILE%/'.curfile.'/ge'
exe 'silent! %s/%DATE%/'.strftime("%b %d, %Y").'/ge'
norm! Gdd
silent! wq!
exe "helptags ".substitute(docfile,'^\(.*doc.\).*$','\1','e')

exe "silent! 1new ".expand("<sfile>:p")
1
silent! /^" HelpExtractor:$/,$g/.*/d
silent! wq!

set nolz
unlet docdir
unlet curfile
"unlet docfile
let &cpo= s:HelpExtractor_keepcpo
unlet s:HelpExtractor_keepcpo
finish

" ---------------------------------------------------------------------
" Put the help after the HelpExtractorDoc label...
" HelpExtractorDoc:
*CVSconflict.txt*	Cvs Conflict Visualizer		Sep 29, 2005

Author:  Charles E. Campbell, Jr.  <drNchipO@ScampbellPfamilyA.bizM>
	  (remove NOSPAM from Campbell's email to use)
Copyright: (c) 2005 by Charles E. Campbell, Jr.	*CVSconflict-copyright*

==============================================================================
1. Contents						*CVSconflict-contents*

	1. Contents.........................: |CVSconflict-contents|
	2. CVSconflict Manual...............: |CVSconflict|
	3. CVSconflict History..............: |CVSconflict-history|

==============================================================================
2. CVSconflict							*CVSconflict*

When one uses cvs to update local files, cvs will report that: >
  U 	The file was updated without trouble.
  P 	The file was updated without trouble
  (you will see this only when working with a remote repository).
  M 	The file has been modified by another, but was merged without conflicts.
  C 	The file has been modified by another, but was merged with conflicts.
The CVSconflict plugin works with conflict files.  Cvs will insert sections
such as >
  <<<<<<<
  ...local version...
  =======
  ...repository version...
  >>>>>>>
into your file where it couldn't decide what to do.  With such files, >
  :CVSconflict
will open two vertically split windows and use vim's vimdiff engine
to display two variants of the file (the leftside will be the "local
version" and the right side will be the "repository version").  The
two windows will convert the name "file.c" to
>
  +--------+--------+
  |fileA.c | fileB.c|
  +--------+--------+
<
Neither of these buffers have actually been written; when you're done
modifying them (using |dp|, |do| |]c|, etc), pick one to save.  Please
remember that neither of the two buffers have exactly the same name
as the original file (with conflicts) when you do your saving.


==============================================================================
3. CVSconflict History					*CVSconflict-history*

	v1 Sep 28, 2005 : Initial version

vim:tw=78:ts=8:ft=help

