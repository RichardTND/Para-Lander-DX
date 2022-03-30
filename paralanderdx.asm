;----------------------------------
;Paralander DX - Linker 
;----------------------------------

	;Game character set 
	*=$0800-2
	.binary "bin/charset.prg"
	
	;Game music 
	*=$1000-2 
	.binary "bin/gamemusic.prg" 
	
	;Game sprites 
	*=$2000-2
	.binary "bin/gamesprites.prg" 
	
	;Game screen colour + screen RAM 
	*=$2800-2
	.binary "bin/gamescreen.prg"
	
	;Game code 
	*=$3000-2
	.binary "gamecode.tgt"
	
	;Title screen scrolltext 
	*=$3c00-2
	.binary "bin/scrolltext.prg"
	
	;Hi score list 
	*=$4400-2
	.binary "bin/hiscorelist.prg"
	
	;Title code 
	*=$4800-2
	.binary "titlecode.tgt"
	
	;Hi score code 
	*=$5000-2 
	.binary "hiscorecode.tgt"
	
	;Disk Access code 
	*=$5700-2 
	.binary "diskaccesscode.tgt"
	
	;VIDCOM PAINT formatted title logo
	
	*=$5800-2
	.binary "bin/titlelogo.prg"
	
	;Title music 
	*=$7000-2
	.binary "bin/titlemusic.prg"
	
	;Hi score music 
	*=$8000-2
	.binary "bin/hiscoremusic.prg"
	
