//括号匹配
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  typedef struct _Stack
 {
//记录下括号
      int paren;
      struct _Stack   *next;
  }Stack;
  typedef struct _StackInfo
 {
      int len;
      struct _Stack  *front;
      struct _Stack  *rear;
  }StackInfo;
//**********************************************

  StackInfo  *CreateEmptyStackInfo();
//如果匹配就返回1,否则返回0
  int        parseParenExp(char *);
  void       freeStackInfo(StackInfo *);
  char paren[256];
  
  int main(int argc,char *argv[])
 {
     int match;
  //   StackInfo *info;
     printf("请输入括号表达式(<256)!\n");
     gets(paren);
     printf("括号表达式为:%s \n",paren);
     match=parseParenExp(paren);
     if(match)
        printf("恭喜，您输入的括号表达式匹配!\n");
     else
        printf("很遗憾，您输入的括号表达式不能匹配!\n");
     return 0;
  }
  int  parseParenExp(char *paren)
 {
     int result=1;
     int len,i;
     StackInfo *info;
     Stack     *tmp;
     char *p,c,ctp;
     len=strlen(paren);
//判断表达式中是否含有括号，若没有括号，也视为正确合法的表达式
     for(p=paren,i=0;i<len;++i,++p)
    {
        c=*p;
        if((c=='{') || (c=='}') || (c=='[') || (c==']') || (c=='(') || (c==')'))
       {
            ++result;
        }
     }
     if(!result)
        return 1;
//如果包含括号
     info=CreateEmptyStackInfo();
     for(p=paren,i=0;i<len;++i,++p)
    {
        c=*p; 
        ctp=0;
        if(c=='{' || c=='[' || c=='(')
       {
//建立一个新的节点
            tmp=(Stack *)malloc(sizeof(Stack));
            tmp->paren=c;
            tmp->next=info->front;
            info->front=tmp;
            ++info->len;
        }
        else if(c=='}')
       {
            ctp='{';
        }
        else if(c==']')
       {
           ctp='[';
        }
        else if(c==')')
       {
           ctp='(';
        }
        if(ctp)
       {
            if(info->len)
           {
                if(info->front->paren==ctp)
               {
                    --info->len;
                    tmp=info->front;
                    info->front=tmp->next;
                    free(tmp);
                }
                else
               {
                    result=0;
                    break;
                }
            }
            else
           {
                result=0;
                break;
            }
        }
     }
//如果建立的动态栈还有剩余项，那么匹配失败
     if(info->len)
        result=0;
     freeStackInfo(info);
     return result;
  }
//********************************************************
  StackInfo  *CreateEmptyStackInfo()
 {
      StackInfo *info;
      info=(StackInfo *)malloc(sizeof(StackInfo));
      info->front=NULL;
      info->rear=NULL;
      info->len=0;
      return info;
  }
//***********************************************************
//释放由于没有匹配而剩余的空间
  void freeStackInfo(StackInfo *info)
 {
     Stack *tmp;
     int i;
     for(i=0;i<info->len;++i)
    {
         tmp=info->front;
         info->front=tmp->next;
         free(tmp);
     }
     free(info);
//	 printf("剩余的空间已经被释放!\n");
  }