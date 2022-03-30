
del paralanderdx.prg 
del gamecode.tgt
del titlecode.tgt
del hiscorecode.tgt
del diskaccess.tgt 

c:\64tass\64tass.exe gamecode.asm -ogamecode.tgt 
c:\64tass\64tass.exe titlecode.asm -otitlecode.tgt 
c:\64tass\64tass.exe hiscore.asm -ohiscorecode.tgt
c:\64tass\64tass.exe diskaccess.asm -odiskaccesscode.tgt 
c:\64tass\64tass.exe paralanderdx.asm -oparalanderdx.prg

ifnotexist paralanderdx.prg goto abort 
c:\exomizer\win32\exomizer.exe sfx $5780 paralanderdx.prg -o paralanderdx.prg -x1
c:\vice_runtime\x64sc.exe paralanderdx.prg
abort:

