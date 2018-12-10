FileEnd:
	ifndef vasm
		org &8000 
		save "..\BldCPC\program.bin",FileBegin,FileEnd-FileBegin	;address,size...}[,exec_address]
		save direct "program.bin",FileBegin,FileEnd-FileBegin	;address,size...}[,exec_address]
	endif