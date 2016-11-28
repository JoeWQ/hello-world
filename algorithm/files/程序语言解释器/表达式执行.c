  #include"初始数据结构.c"
  #include"中缀表达式转后缀表达式以及后缀表达式的计算.c"
  #include"判断输入字符的类型.c"
//表达式的执行包括3中情况
  int  value_exp(char *,char *);
  int  exp_compute(char *,char *,int *);
  int  exc_commd(char *);
//第1种:赋值语句
  
//若成功则为1，否则为0
  int  value_exp(char *input,char *postfix)
 {
     int  len=strlen(input);
     int  value,index,i;
	  int  *tmp,*init;
     char  c;

     if(len<2)
    {
         printf("赋值表达式语法错误，没有给定的值!\n");
         return 0;
     }
     c=*input;
     tmp=0;
     if(c>='A' && c<='Z')
    {
         index=c-'A';
         tmp=gvar;
         init=ginit;
     }
     else if(c>='a' && c<='z')
    {
         index=c-'a';
         tmp=svar;
         init=sinit;
     }
     else
    {
         printf("赋值表达式语法错误,语句的首字母不在约定的变量范围!\n");
         return 0;
     }
     i=2;
     if(!infix_to_postfix(&input[2],postfix))
          return 0;
          
     if(!compute_postfix(postfix,&value))
    {
          printf("赋值表达式的值计算部分语法错误!\n");
          return 0;
     }
     tmp[index]=value;
     init[index]=1;
     printf("%c=%d\n",c,value);
     return 1;
  }
//第2种:表达式计算
//若成功，则返回1，否则返回0
  int  exp_compute(char  *input,char *postfix,int *value)
 {
     if(!infix_to_postfix(input,exp))
         return 0;
     if(!compute_postfix(postfix,value))
    {
//          printf("表达式计算语法错误!\n");
          return 0;
     }
     printf("%d \n",*value);
     return 0;
  }
//第3种:执行给定的命令
//若成功返回1，否则返回0
  int  exec_commd(char  *input)
 {
     int i=0,k;
     int  flag;
     if(!strcmp(input,"clrscr"))
    {
         ++i;
         system("cls");
     }
//执行使变量未初始化的命令
     else if(!strcmp(input,"clear"))
    {
         ++i;
         for(k=0;k<globle_len;++k)
        {
              gvar[k]=svar[k]=0;
              ginit[k]=sinit[k]=0;
         }
     }
//执行退出命令
     else if(!strcmp(input,"exit"))
    {
         ++i;
         exit(0);
     }
//执行display命令
     else if(startWith(input,"display"))
    {
          i=strlen("display");
          
//如果不带任何参数，则显示所有的变量的当前情况
          if(input[i]!='#')
         {
              flag=0;
              for(i=0;i<26;++i)
             {
//如果没有进行初始化
                 ++flag;
                 if(!sinit[i])
                      printf("%c未初始化",('a'+i));
                 else
                      printf("%c:%d ",('a'+i),svar[i]);
                 if(flag & 0x4)
                {
                     putchar('\n');
                     flag=0;
                 }
              }
              putchar('\n');
//大写字符变量
              flag=0;
              for(i=0;i<26;++i)
             {
                  ++flag;
                  if(!ginit[i])
                       printf("%c未初始化",('A'+i));
                  else
                       printf("%c:%d",('A'+i),gvar[i]);
                  if(flag & 0x4)
                 {
                      putchar('\n');
                      flag=0;
                  }
              }
              putchar('\n');
          }
         else
        {
              flag=0;
              for(++i;input[i];++i)
             {
                  if(input[i]>='a' && input[i]<='z')
                 {
                      ++flag;
                      k=input[i]-'a';
                      if(!sinit[k])
                           printf("变量%c未初始化",input[i]);
                      else
                           printf("%c:%d, ",input[i],svar[k]);
                  }
                  else if(input[i]>='A' && input[i]<='Z')
                 {
                      ++flag;
                      k=input[i]-'A';
                      if(!ginit[k])
                            printf("变量%c未初始化",input[i]);
                      else
                            printf("%c:%d, ",input[i],gvar[k]);
                  }
                  if(flag & 0x4)
                 {
                      putchar('\n');
                      flag=0;
                  }
              }
              putchar('\n');
          }
     }
     return i;
  }
  int  main(int argc,char *argv[])
 {
      int  i=0;
      int  data;
      while(1)
     {
           printf("请输入一个字符串表达式!\n");
           delete_blank(vbuf,256);
           if(match(vbuf))
          {
               printf("小括号表达式不匹配，请重新输入.\n");
               continue;
           }
           switch(input_type(vbuf))
          {
		        case 0: printf("无法解析的命令.\n");break;
//赋值语句
                case 1: value_exp(vbuf,exp);break;
//如果是表达式
                case 2: exp_compute(vbuf,exp,&data);break;
//如果是执行命令的语句
                case 3: exec_commd(vbuf);break;
           }
       }
       return 0;
  }
            