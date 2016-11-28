
//��������
  static int push(StackInfo *,Stack *);
  static int pow(StackInfo *,Stack *);
  static int multip(StackInfo *,Stack *);
  static int divid(StackInfo  *,Stack *);
  static int add(StackInfo *,Stack *);
  static int sub(StackInfo *,Stack *);
  static int string_to_int(char *,int *);
  int   infix_to_postfix(char *,char *);
  int    comput_postfix(char *,int *);
//ջʽ���ʽ���㣨������ĳЩ����ı��ʽ������ȡ�����������㣩
  static  int push(StackInfo  *info,Stack *stack)
 {
//��������ʽ���ݣ���ֱ����ջ
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
//�����������^(������)
            if(stack->data=='^')
                 return pow(info,stack);
//�����������*(�˷�)
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
                 printf("δ֪���쳣����!\n");
                 info->error=1;
                 return 0; 
            }
      }
     printf("��������Ҫ��Ĵ�����!\n");
     return 0;
  }
 
//������
   static int  pow(StackInfo  *info,Stack *stack)
  {
       int  i,data;
	     int  op1,op2;
       Stack  *tmp=info->front;
       i=info->index;

       if(i<2)
      {
             printf("�����ϲ���������Ĵ������%c",stack->data);
             info->error;
             return 0;
       }
       op1=tmp[i-2].data;
       op2=tmp[i-1].data;
       if(op2<0)
      {
             printf("�ܱ�Ǹ���������ָ�����ֲ���Ϊ����!\n");
             info->error=1;
             return 0;
       }
       for(i=0,data=1;i<op2;++i)
             data*=op1;
       tmp[info->index-2].data=data;
       --info->index;
       return 1;
  }
//�˷�����
  static  int multip(StackInfo *info,Stack *stack)
 {
      Stack  *tmp=info->front;
      int    op1,op2;
      int    i=info->index;
     
      if(i<2)
     {
           printf("����������ĿС��2���������������%c�Ĺ���",stack->data);
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
//��������
  static  int  divid(StackInfo *info,Stack *stack)
 {
      Stack  *tmp=info->front;
      int    op1,op2;
      int  i=info->index;
      
      if(i<2)
     {
           printf("����������ĿС��2��������%c�Ĺ���������!\n",stack->data);
           info->error=1;
      }
      op1=tmp[i-2].data;
      op2=tmp[i-1].data;
//���������Ϊ0����ô���ᷢ���������
      if(!op2)
     {
           printf("�����������,����������Ϊ0!\n");
           info->error=1;
           return 0;
      }
      op1/=op2;
      tmp[i-2].data=op1;
      --info->index;
      return 1;
  }
//�ӷ�����(ע��ӷ����������Ʒ��е����⣬��Ϊ���ǿ��������ڵ�������!\n
  static int  add(StackInfo *info,Stack *stack)
 {
      Stack  *tmp=info->front;
      int    op1,op2;
      int    i=info->index;
    
      if(!i)
     {
          printf("�޲�������������%c!\n",stack->data);
          info->error=1;
          return 0;
      }
//����ǵ�������
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
        printf("�ӷ���δ֪���쳣����!\n");
        info->error=1;
        return 0;
  }
//��������
  static  int  sub(StackInfo  *info,Stack *stack)
 {
       Stack  *tmp=info->front;
       int    op1,op2;
       int    i=info->index;

       if(!i)
      {
            printf("������δ0�����������������Ĺ���!\n");
            info->error=1;
            return 0;
       }
//����ǵ�������
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
//�ַ���ת��Ϊ����(����ֻ��Ϊ����ת��)
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
           printf("�ַ���ת���쳣!\n"); 
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
//1:��׺���ʽת��׺���ʽ
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
					  printf("������ַ�%c�Ƿ�!\n",c);
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
//��׺���ʽ�ļ���
//���ɹ��򷵻�1�����򷵻�0
  int  compute_postfix(char *input,int *value)
 {
      int  index,data;
      int  i,len;
      StackInfo  info;
//����������صı���(���ݣ�������)
      Stack     ds,ops;
      
      char  c;
//����ص����ݽ��г�ʼ��
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
//�����û�ж��Ա������г�ʼ��
              if(!sinit[index])
             {
                   printf("����%c��δ���г�ʼ���������޷�����!\n",c);
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
                   printf("����%c��û�н��г�ʼ���������޷�����!\n",c);
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
//����ǲ�����
          else if(c=='^' || c=='*' || c=='/' || c=='+' || c=='-')
         {
              ops.data=c;
              push(&info,&ops);
          }
          else
         {
              if(c!=' ')
             {
                printf("δ������ַ�%c",c);
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