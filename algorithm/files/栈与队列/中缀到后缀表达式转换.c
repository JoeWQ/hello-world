//��׺���ʽ����׺���ʽ��ת��,��һ��ʵ�ְ汾6.0.0.5909
//����ʱ��: Jun 16 2011 16:53:43
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>

  typedef  struct  _Queue
 {
      int  len;
      int  *que;
      int  index;
  }Queue;

  void  push(Queue *,int);
  int  pop(Queue *);
  void  postfix(char *,char *);

//һ�������ǹ���ջ����صĲ���
  void  push(Queue *queue,int data)
 {
       if(queue->index<queue->len)
      {
            queue->que[queue->index++]=data;
       }
       else
      {
            printf("ջ�Ѿ���,����ʧ��!\n");
       }
  }
  int  pop(Queue *queue)
 {
       int  data=0;
       if(queue->index)
          data=queue->que[--queue->index];
       return data;
  }
//��׺���ʽתΪ��׺���ʽ,ע������output�����������㹻��,������ܻ�����������
  void  postfix(char  *expr,char  *output)
 {
       int   i,k,len;
       int   data;
       char  *p,c;
       Queue queue;

       len=strlen(expr);
       queue.len=len;
       queue.index=0;
       queue.que=(int *)malloc(sizeof(int)*len);

       p=expr;
       k=0;
       for(i=0;i<len;++i,++p)
      {
            c=*p;
            if((c>='a' && c<='z') || (c>='A' && c<='Z'))
           {
                 if(k && output[k-1]==' ')
                     output[k-1]=c;
                 else
                     output[k++]=c;
            }
            else if(c>='0' && c<='9')
           {
                 output[k++]=c;
                 output[k++]=' ';
            }
            else if(c=='*' || c=='/')
           {
                 data=pop(&queue);
                 if(data=='(')
                {
                      push(&queue,data);
                      push(&queue,c);
                 }
                 else if(data=='+' || data=='-')
                {
                      push(&queue,data);
                      push(&queue,c);
                 }
                 else
                {
                      while(data && data!='(')
                     {
                           output[k++]=data;
                           data=pop(&queue);
                      }
                      if(data)
                     {
                          push(&queue,data);
                          push(&queue,c);
                      }
                      else
                          push(&queue,c);
                 }
             }
             else if(c=='+' || c=='-')
            {
                 data=pop(&queue);
                 if(data=='(')
                {
                      push(&queue,data);
                      push(&queue,c);
                 }
                 else
                {
                      while(data && data!='(')
                     {
                           output[k++]=data;
                           data=pop(&queue);
                      }
                      if(data)
                     {
                          push(&queue,data);
                      }
                      push(&queue,c);
                 }
             }
             else if(c=='(')
                 push(&queue,c);
             else if(c==')')
            {
                 while((data=pop(&queue))!='(' && data)
                {
                      output[k++]=data;
                 }
             }
      }
     while((data=pop(&queue)))
    {
          output[k++]=data;
     }
     output[k]='\0';
     free(queue.que);
  }
  int  main(int argc,char *argv[])
 {

     char  *p1="a*b+5";
     char  *p2="(1+2)*5";
     char  *p3="a*b/c";
     char  *p4="(a/(b-c+d))*(e-a)*c";
     char  *p5="a/b-c+d*e-a*c";
     char  *p0="2+3*4";

     char  **p=&p0;
     int   i;
     char  buf[256];
     
     for(i=0;i<6;++i)
    {
         printf("Դ��׺���ʽΪ:%s \n",p[i]);
         postfix(p[i],buf);
         printf("ת����ĺ�׺���ʽΪ:%s \n",buf);
         printf("------------------------------------------------------\n");
     }
     return 0;
  }