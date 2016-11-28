//这个模块的功能是判断输入的字符串的类型
//返回值所代表的含义是:
//0:无法解析的字符串
//1：赋值语句
//2:表达式计算语句
//3:命令执行语句
  int  input_type(char *);
  static int input_contains(char *,int,char);

  int  input_type(char  *input)
 { 
      int  len=strlen(input);
      if(!len)
         return 0;
//如果是赋值语句
      if(input_contains(input,len,'='))
         return 1;
//如果是表达式计算
      if(input_contains(input,len,'+') || input_contains(input,len,'-') || 
          input_contains(input,len,'*')|| input_contains(input,len,'/') ||
          input_contains(input,len,'^'))
         return 2;
//如果是命令执行参数
      if(!strcmp(input,"clear") || !strcmp(input,"clrscr") || !strcmp(input,"exit")
         || startWith(input,"display"))
         return 3;
//一种不太明显的表达式计算
      if(len==1 && input[0]>='a' && input[0]<='z' || input[0]>='A' && input[0]<='Z')
           return 2;
//否则返回
      return 0;
  }
//返回值1:字符串中含有给定的字符，0：未包含
  static int  input_contains(char *input,int len,char c)
 {
      int i;
      for(i=0;i<len;++i,++input)
     {
          if(c==*input)
             return 1;
      }
      return 0;
  }