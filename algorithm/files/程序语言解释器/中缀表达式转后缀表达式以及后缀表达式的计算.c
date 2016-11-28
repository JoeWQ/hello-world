
//函数声明
  static int push(StackInfo *,Stack *);
  static int pow(StackInfo *,Stack *);
  static int multip(StackInfo *,Stack *);
  static int divid(StackInfo  *,Stack *);
  static int add(StackInfo *,Stack *);
  static int sub(StackInfo *,Stack *);
  static int string_to_int(char *,int *);
  int   infix_to_postfix(char *,char *);
  int    comput_postfix(char *,int *);
//栈式表达式计算（忽略了某些特殊的表达式，比如取正和屈服计算）
  static  int push(StackInfo  *info,Stack *stack)
 {
//如果输入的式数据，则直接入栈
	  Stack  *tmp=info->front;
       if(!stack->op && info->index<info->len && !info->error)
      {
            tmp[info->index].op=stack->op;
            tmp[info->index].data=stack->data;
            ++info->index;
            return 1;
       }
       else if(stack->op && !info->error)
      {
//如果操作符是^(幂运算)
            if(stack->data=='^')
                 return pow(info,stack);
//如果操作符是*(乘法)
            else if(stack->data=='*')
                 return multip(info,stack);
            else if(stack->data=='/')
                 return divid(info,stack);
            else if(stack->data=='+')
                 return add(info,stack);
            else if(stack->data=='-')
                 return sub(info,stack);
            else
           {
                 printf("未知的异常发生!\n");
                 info->error=1;
                 return 0; 
            }
      }
     printf("不能满足要求的错误发生!\n");
     return 0;
  }
 
//幂运算
   static int  pow(StackInfo  *info,Stack *stack)
  {
       int  i,data;
	     int  op1,op2;
       Stack  *tmp=info->front;
       i=info->index;

       if(i<2)
      {
             printf("不符合操作符规则的错误产生%c",stack->data);
             info->error;
             return 0;
       }
       op1=tmp[i-2].data;
       op2=tmp[i-1].data;
       if(op2<0)
      {
             printf("很抱歉，幂运算的指数部分不能为负数!\n");
             info->error=1;
             return 0;
       }
       for(i=0,data=1;i<op2;++i)
             data*=op1;
       tmp[info->index-2].data=data;
       --info->index;
       return 1;
  }
//乘法运算
  static  int multip(StackInfo *info,Stack *stack)
 {
      Stack  *tmp=info->front;
      int    op1,op2;
      int    i=info->index;
     
      if(i<2)
     {
           printf("操作数的数目小于2，不能满足操作符%c的规则",stack->data);
           info->error=1;
           return 0;
      }
      op1=tmp[i-2].data;
      op2=tmp[i-1].data;
      op1*=op2;
      tmp[i-2].data=op1;
      --info->index;
      return 1;
  }
//除法运算
  static  int  divid(StackInfo *info,Stack *stack)
 {
      Stack  *tmp=info->front;
      int    op1,op2;
      int  i=info->index;
      
      if(i<2)
     {
           printf("操作数的数目小于2，操作符%c的规则不能满足!\n",stack->data);
           info->error=1;
      }
      op1=tmp[i-2].data;
      op2=tmp[i-1].data;
//如果被除数为0，那么僵会发生溢出错误
      if(!op2)
     {
           printf("除法溢出错误,被除数不能为0!\n");
           info->error=1;
           return 0;
      }
      op1/=op2;
      tmp[i-2].data=op1;
      --info->index;
      return 1;
  }
//加法运算(注意加法、减法的云发有点特殊，因为他们可以作用于单操作数!\n
  static int  add(StackInfo *info,Stack *stack)
 {
      Stack  *tmp=info->front;
      int    op1,op2;
      int    i=info->index;
    
      if(!i)
     {
          printf("无操作数参与运算%c!\n",stack->data);
          info->error=1;
          return 0;
      }
//如果是单操作数
//      if(i=1)
 //    {
//      }
        if(i>=2)
       {
            op1=tmp[i-2].data;
            op2=tmp[i-1].data;
            op1+=op2;
            tmp[i-2].data=op1;
            --info->index;
            return 1;
        }
        printf("加法中未知的异常发生!\n");
        info->error=1;
        return 0;
  }
//减法操作
  static  int  sub(StackInfo  *info,Stack *stack)
 {
       Stack  *tmp=info->front;
       int    op1,op2;
       int    i=info->index;

       if(!i)
      {
            printf("操作数未0，不能满足减法运算的规则!\n");
            info->error=1;
            return 0;
       }
//如果是单操作数
       if(i==1)
      {
            tmp[i-1].data=-tmp[i-1].data;
            return 1;
       }
       op1=tmp[i-2].data;
       op2=tmp[i-1].data;
       op1-=op2;
       tmp[i-2].data=op1;
       --info->index;
       return 0;
  }
//字符串转换为数字(这里只能为正数转换)
  static int  string_to_int(char  *input,int *value)
 {
       int  i=0;
       int  data=0;
       int  k=1;
       int  tmp;
       while(input[i]>='0' && input[i]<='9')
            ++i;
       if(!i)
      {
           printf("字符串转换异常!\n"); 
           return 0;
       }
       --i;
       tmp=i;
       while(i>=0)
      {
          data+=(input[i]-'0')*k;
          k*=10;
          --i;
       }
       *value=data;
       return tmp;
  }
//1:中缀表达式转后缀表达式
  int  infix_to_postfix(char  *input,char  *postfix)
 {
       int    i,k,len;
       Queue  front;
       char   c;
       int    data;

       front.index=0;
       front.len=MAX_SIZE;
       front.p=(int *)malloc(sizeof(int)*MAX_SIZE);

       len=strlen(input);
       for(i=0,k=0;i<len;++i)
      {
           c=input[i];
           if(c>='a' &&c<='z' || c>='A' && c<='Z')
                postfix[k++]=c;
           else if(c>='0' && c<='9')
          {
                do
               {
                    postfix[k++]=c;
                    c=input[++i];
                }while(i<len && c>='0' && c<='9');
                postfix[k++]=' ';
                --i;
           }
           else if(c=='^')
          {
                _push(&front,c);
            }
            else if(c=='*' || c=='/' || c=='%')
           {
                data=_pop(&front);
                if(data=='(')
               {
                    _push(&front,data);
                    _push(&front,c);
                }
                else if(data=='+' || data=='-')
               {
                    _push(&front,data);
                    _push(&front,c);
                }
                else
               {
                    while(data && data!='(')
                   {
                        postfix[k++]=(char)data;
                        data=_pop(&front);
                    }
                    if(data)
                        _push(&front,data);
                    _push(&front,c);
                }
            }
            else if(c=='+' || c=='-')
           {
                 data=_pop(&front);
                 if(data=='(')
                {
                     _push(&front,data);
                     _push(&front,c);
                 }
                 else
                {
                     while(data && data!='(')
                    {
                          postfix[k++]=(char)data;
                          data=_pop(&front);
                     }
                     if(data)
                          _push(&front,data);
                     _push(&front,c);
                 }
             }
             else if(c=='(')
                 _push(&front,c);
             else if(c==')')
            {
                 data=_pop(&front);
                 while(data && data!='(')
                {
                     postfix[k++]=(char)data;
                     data=_pop(&front);
                 }
             }
             else
            {
                 if(c!=' ')
				 {
					  printf("输入的字符%c非法!\n",c);
					  return 0;
				 }
             }

       }
       while(data=_pop(&front))
      {
           postfix[k++]=(char)data;
       }
       postfix[k]='\0';
	   return 1;
  }
//后缀表达式的计算
//若成功则返回1，否则返回0
  int  compute_postfix(char *input,int *value)
 {
      int  index,data;
      int  i,len;
      StackInfo  info;
//设置两个相关的变量(数据，操作符)
      Stack     ds,ops;
      
      char  c;
//对相关的数据进行初始化
      info.len=128;
      info.index=0;
      info.front=(Stack *)malloc(sizeof(Stack)*128);
      info.error=0;

      ds.op=0;
      ops.op=1;
 
      len=strlen(input);
      for(i=0;i<len;++i)
     {
          c=input[i];
          if(c>='a' && c<='z')
         {
              index=c-'a';
//如果还没有独对变量进行初始化
              if(!sinit[index])
             {
                   printf("变量%c还未进行初始化，操作无法进行!\n",c);
                   return 0;
              }
              ds.data=svar[index];
              push(&info,&ds);
          }
          else if(c>='A' && c<='Z')
         {
              index=c-'A';
              if(!ginit[index])
             {
                   printf("变量%c还没有进行初始化，计算无法进行!\n",c);
                   return 0;
              }
              ds.data=gvar[index];
              push(&info,&ds);
          }
          else if(c>='0' && c<='9')
         {
               i+=string_to_int(&input[i],&data);
               ds.data=data;
               push(&info,&ds);
          }
//如果是操作符
          else if(c=='^' || c=='*' || c=='/' || c=='+' || c=='-')
         {
              ops.data=c;
              push(&info,&ops);
          }
          else
         {
              if(c!=' ')
             {
                printf("未定义的字符%c",c);
                return 0;
              }
          }
     }
     i=0;
     if(!info.error && info.index==1)
    {
         *value=info.front[0].data;
         i=1;
     }
     free(info.front);
     return i;
  }