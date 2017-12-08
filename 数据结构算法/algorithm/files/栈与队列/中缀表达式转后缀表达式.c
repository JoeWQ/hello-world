//中缀表达式转后缀表达式(这是一个糟糕的版本)6.0.0.5909
//系统词频: 20060101
//组词数据: 20110307
//辅助码  : 20101217
//编译时间: Jun 16 2011 16:53:43

  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  #define  MAX_SIZE  127

  int  queue[MAX_SIZE+1];
  int  index;

//注意这里已经假设使用者输入的中缀表达式已经是合法的且不能有任何的空格,否则程序会出错
//输入的变量必须为单字母
  void  postfix(char  *);
//将出入的数据入栈
  void  push(int );
//从栈顶弹出元素
  void  pop(int *);

//一下是关于栈的相关操作
  void  push(int data)
 {
       if(index<MAX_SIZE)
      {
           queue[index++]=data;
       }
       else
      {
           printf("栈已经满，不能再填充!\n");
       }
  }
  void  pop(int *data)
 {
      if(index)
     {
          *data=queue[--index];
      }
      else
         *data=0;
  }
  int  isEmpty()
 {
      return !index;
  }
           
  void  postfix(char  *expre)
 {
      int  data,i,len;
      char c,*p;
      
      len=strlen(expre);
      data=0;
      for(p=expre,i=0;i<len;++i,++p)
     {
           c=*p;
//如果输入的是数字,则可以直接输出
           if((c>='a' && c<='z') || (c>='A' && c<='Z') || (c>='0' && c<='9'))
          {
                 printf("%c ",c);
           } 
           else if(c=='+' || c=='-' || c=='*' || c=='/')
          {
                 pop(&data);
               //  printf("..%d..",data);
//如果栈顶是左括号或者为空,则直接压入输入符号
                 if(c=='*' || c=='/')
                {
//如果输入的符号的优先级大于栈顶元素的优先级
                     if(data=='+' || data=='-')
                    {
                          push(data);
                          push(c);
                     }
//如果栈顶元素是左括号,仍眼压入栈顶
                     else if(data=='*' || data=='/')
                    {
                          printf("%c ",data);
                          push(c);
                     }
                     else
                    {
                         if(data)
                            push(data);
                         push(c);
                     }
                 }
                 else if(c=='+' || c=='-')
                {
//注意这一步操作，在删除栈顶元素后，接下来的元素可能为+-号，那些元素必须要在这个元素
//的前面被输出
                     if(data=='*' || data=='/')
                    {
                          printf("%c ",data);
                          --i;
                          --p;
                          continue;
                     }
                     else if(data=='+' || data=='-')
                    {
                          printf("%c ",data);
                          push(c);
                     }
                     else
                    {
                         if(data)
                           push(data);
                         push(c);
                     }
                 }
           }
           else if(c==')')
          {
               pop(&data);
               while(data && data!='(')
              {
                   printf("%c ",data);
                   pop(&data);
               }
           }
           else if(c=='(')
          {
               push(c);
           }
     }
//如果栈中还有剩余的元素，则直接输出
     pop(&data);
     while(data)
    {
         printf("%c ",data);
         pop(&data);
     }
  }
  
  int  main(int argc,char *argv[])
 {
     char  *p0="2+3*4";
     char  *p1="a*b+5";
     char  *p2="(1+2)*5";
     char  *p3="a*b/c";
     char  *p4="(a/(b-c+d))*(e-a)*c";
     char  *p5="a/b-c+d*e-a*c";

//注意下面的代码
     int   i;
     char  **pp=&p5;
     for(i=0;i<6;++i)
    {
         printf("第%d个源表达式为: %s\n",i,pp[i]);
         printf("转换之后的表达式为:");
         postfix(pp[i]);
         printf("\n--------------------------------------------\n");
     }
     return 0;
 }