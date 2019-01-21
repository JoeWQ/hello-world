//��׺���ʽת��׺���ʽ(����һ�����İ汾)6.0.0.5909
//ϵͳ��Ƶ: 20060101
//�������: 20110307
//������  : 20101217
//����ʱ��: Jun 16 2011 16:53:43

  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  #define  MAX_SIZE  127

  int  queue[MAX_SIZE+1];
  int  index;

//ע�������Ѿ�����ʹ�����������׺���ʽ�Ѿ��ǺϷ����Ҳ������κεĿո�,�����������
//����ı�������Ϊ����ĸ
  void  postfix(char  *);
//�������������ջ
  void  push(int );
//��ջ������Ԫ��
  void  pop(int *);

//һ���ǹ���ջ����ز���
  void  push(int data)
 {
       if(index<MAX_SIZE)
      {
           queue[index++]=data;
       }
       else
      {
           printf("ջ�Ѿ��������������!\n");
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
//��������������,�����ֱ�����
           if((c>='a' && c<='z') || (c>='A' && c<='Z') || (c>='0' && c<='9'))
          {
                 printf("%c ",c);
           } 
           else if(c=='+' || c=='-' || c=='*' || c=='/')
          {
                 pop(&data);
               //  printf("..%d..",data);
//���ջ���������Ż���Ϊ��,��ֱ��ѹ���������
                 if(c=='*' || c=='/')
                {
//�������ķ��ŵ����ȼ�����ջ��Ԫ�ص����ȼ�
                     if(data=='+' || data=='-')
                    {
                          push(data);
                          push(c);
                     }
//���ջ��Ԫ����������,����ѹ��ջ��
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
//ע����һ����������ɾ��ջ��Ԫ�غ󣬽�������Ԫ�ؿ���Ϊ+-�ţ���ЩԪ�ر���Ҫ�����Ԫ��
//��ǰ�汻���
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
//���ջ�л���ʣ���Ԫ�أ���ֱ�����
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

//ע������Ĵ���
     int   i;
     char  **pp=&p5;
     for(i=0;i<6;++i)
    {
         printf("��%d��Դ���ʽΪ: %s\n",i,pp[i]);
         printf("ת��֮��ı��ʽΪ:");
         postfix(pp[i]);
         printf("\n--------------------------------------------\n");
     }
     return 0;
 }