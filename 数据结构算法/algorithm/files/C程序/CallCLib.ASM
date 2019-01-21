  Title 在汇编语言中调用C库函数
  include Irvine32.inc
  .586

  printf PROTO C,pp:PTR byte,arg:vararg
;  showArray PROTO C,pp:PTR dword,count:dword
;  WriteMesg PROTO C
  printMesg PROTO C

  .code
  WriteMesg PROC C
   .data
   mesg  byte "Hello XiaoHuaXiong! %d .",0dh,0ah
   .code
   lea edi,mesg
   mov eax,22
   invoke printf,edi,eax
   add esp,8
;   invoke printMesg
   ret
  WriteMesg ENDP
  end

  .code
  showArray PROC C,pp:PTR dword,count:dword
    cmp count,0
    jle over

    mov esi,pp
    mov ecx,count
    cld
   L1:
     lodsd
     call WriteInt
     mov al,' '
     call WriteString
    loop L1
    ret
  showArray ENDP
  end