  Title 查找目标数字
  .586
  .model flat,C
  .code
  ASMFindArray PROC,searchVal:dword,array:PTR dword,Array_Size:dword

    mov ecx,Array_Size
    cmp ecx,0
    jle notfind

    mov eax,searchVal
    mov edi,array
    cld
    repne scasd
    je find
    jmp notfind
   find:
     mov al,1
     jmp over
   notfind:
     xor al,al
   over:
     ret
  ASMFindArray ENDP
  end