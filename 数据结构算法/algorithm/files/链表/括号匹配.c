//����ƥ��
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  typedef struct _Stack
 {
//��¼������
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
//���ƥ��ͷ���1,���򷵻�0
  int        parseParenExp(char *);
  void       freeStackInfo(StackInfo *);
  char paren[256];
  
  int main(int argc,char *argv[])
 {
     int match;
  //   StackInfo *info;
     printf("���������ű��ʽ(<256)!\n");
     gets(paren);
     printf("���ű��ʽΪ:%s \n",paren);
     match=parseParenExp(paren);
     if(match)
        printf("��ϲ������������ű��ʽƥ��!\n");
     else
        printf("���ź�������������ű��ʽ����ƥ��!\n");
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
//�жϱ��ʽ���Ƿ������ţ���û�����ţ�Ҳ��Ϊ��ȷ�Ϸ��ı��ʽ
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
//�����������
     info=CreateEmptyStackInfo();
     for(p=paren,i=0;i<len;++i,++p)
    {
        c=*p; 
        ctp=0;
        if(c=='{' || c=='[' || c=='(')
       {
//����һ���µĽڵ�
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
//��������Ķ�̬ջ����ʣ�����ôƥ��ʧ��
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
//�ͷ�����û��ƥ���ʣ��Ŀռ�
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
//	 printf("ʣ��Ŀռ��Ѿ����ͷ�!\n");
  }