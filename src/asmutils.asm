;Copyright (C) 1999 Konstantin Boldyshev <konst@voshod.com>
;
;$Id: asmutils.asm,v 1.1 2000/01/26 21:19:15 konst Exp $
;
;asmutils multicall binary

%include "system.inc"


CODESEG

    dd	"mkdi",p_mkdir
    dd	"unam",p_uname
    dd	"true",p_true
    dd	"slee",p_sleep
    dd	"pwd",p_pwd
    dd	"cat",p_cat
    dd	"tee",p_tee
    dd	"yes",p_yes
    dd	"upda",p_update
    dd	"sync",p_sync
    
    
START:

exit:
	sys_exit



    
p_mkdir:
p_uname:
p_true:
p_sleep:

p_cat:
p_tee:
p_yes:
p_pwd:

p_update:
p_sync:
