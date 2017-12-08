//��ʼ��ģ��
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>

  #define  MAX_SIZE  32
  typedef  struct _Stack
 {
     int  data;
//1�����������0��������
     int  op;
  }Stack;
  typedef  struct  _StackInfo
 {
      struct  _Stack  *front;
      int     len;
      int     index;
//��¼�Ƿ��д�����
      int     error;
  }StackInfo;

  typedef  struct  _Queue
 {
      int  *p;
      int  index;
      int  len;
  }Queue;
//���е�ȫ�ֱ���
  int  gvar[32];
  int  ginit[32];
  int  svar[32];
  int  sinit[32];
  int  globle_len=32;

  char  vbuf[256];
  char  exp[256];
  int   vlen=256;
//���ģ��Ĺ����ǹ��˶���ַ�
  void  delete_blank(char *input,int n)
 {
      char  data;
      int   i=0;
      while((data=getchar())!='\n')
     {
           if(data!=' ' && data!='	')
                input[i++]=data;
      }
      input[i]='\0';
  }

  int startWith(char *input,char *model)
 {
       while(*model && *input && *model==*input)
      {
             ++model;
             ++input;
       }
       return *model?0:1;   
  }
//*******************************************************
  void _push(Queue *front,int data)
 {
      if(front->index<front->len)
           front->p[front->index++]=data;
      else
           printf("�����ջ�ռ��Ѿ��������޷������!\n");
  }
  int  _pop(Queue *front)
 {
      int  c=0;
      if(front->index)
          c=front->p[--front->index];
      return c;
  }
//*******************************************************************
//1:�жϱ��ʽ�е������Ƿ�ƥ��,���ɹ�ƥ���򷵻�0�����򷵻ط�0
  int  match(char *input)
 {
      int i=0,len;
      Queue  front;
      char   data;
      len=strlen(input);
      front.len=MAX_SIZE;
      front.index=0;
      front.p=(int *)malloc(sizeof(int)*MAX_SIZE);
 
      for(;i<len;++i)
     {
          data=input[i];
          if(data=='(')
              _push(&front,data);
          else if(data==')')
              _pop(&front);
      }
      free(front.p);
      return front.index;
  }