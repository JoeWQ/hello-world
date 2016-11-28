//2012/12/26/9:20
//��ȡ��С�ľ������˷��ĳͷ�����
  #include<stdio.h>
  #include<stdlib.h>
  #define  INF_T   0x30000000
  typedef  struct  _Stack
 {
       int  from;
       int  to;
//       int  v;
  }Stack;
  typedef  struct  _StackHeader
 {
       Stack  *stack;
       int  size;
       int  max;
  }StackHeader;
//*****************************************************
  static void  push(StackHeader *,Stack *);
  static void  pop(StackHeader *,Stack *);

  static int  m[10][10];
  static int  s[10][10];
  void  least_matrix_sequence(int  *p,int nsize)
 {
       int  i,j,k,le,mp=0,cost=0; 
       int  tpl;
       int  *price=p+1,n=nsize-1;
//��һ����ʼ������ĶԽ�Ԫ��
       for(i=0;i<n;++i)
            m[i][i]=0;
//�ڶ���������������еĴ���,һ�δӳ���2,3,4....n����
      for(le=2;le<=n;++le)
     {
//ע����������±�������ȡֵ���䷶Χ
             tpl=n-le;
            for(i=0;i<=tpl;++i)
           {
                  j=i+le-1;
                  m[i][j]=INF_T;
                  for(k=i;k<j;++k)
                 {
//ע����һ���ĺ���:n*m�׾��� ��m*k�׾�����ˣ������n*k�׾���
                        mp=m[i][k]+m[k+1][j]+price[i-1]*price[k]*price[j];
                        if(mp<m[i][j])
                       {
                               m[i][j]=mp;
                               s[i][j]=k;
                        }
                  }
            }
       }
  }
//�����С�������˷��ļ���˳��ʹ��С���ŷָ�
//ע���ھ���m,s�У�����ֻʹ�������ǵ������ǣ����ԣ��ڶ�s���н���ʱ����Ҫע����һ��
  void  split_matrix_sequence(int i,int j,int  size)
 { 
/*
       if(i==j)
           printf("%c ",(char)('A'+i));
       else
      {
           printf("( ");
                split_matrix_sequence(i,s[i][j]);
                split_matrix_sequence(s[i][jj]+1,j);
           printf(") ");
       }
*/
//�ǵݹ����
      StackHeader  hs,*h;
      Stack        stc,*st;
      int         v=0;

      if(i>j || j+1!=size)
     {
           printf("�Ƿ��Ĳ�������");
           return;
      }
      st=&stc;
      h=&hs;
      h->stack=(Stack *)malloc(sizeof(Stack)*(size<<2));
      h->size=0;
      h->max=size<<2;
//��ʼ������С������˳��
      st->from=i,st->to=j;
      push(h,st);
//ֻҪջ�ǿգ�ѭ��������������ȥ
      while(h->size)
     {
           pop(h,st);
           if(st->from==st->to)
          {
               printf(" %c ",(char)('A'+st->from));
//ע���������һ��,����һ���������н��б����˷�ʱ���ض����������������ϣ�����ֻ�е������������������ʱ�� 
//�ſ��Զ�����������
               if(!v)
                   printf(")");
               v=0;
           }
           else
          {
               printf("(");
//ע���������ջ˳��
               i=st->from;
               j=st->to;

               st->from=s[i][j]+1;
               st->to=j;
               push(h,st);

               st->from=i;
               st->to=s[i][j];
               push(h,st);
               v=1;
          }
      }
      free(h->stack);
  }
  static  void  push(StackHeader *h,Stack *s)
 {
       Stack  *t;
       if(h->size>=h->max)
      {
             printf("ջջ�Ѿ���������������\n");
             return;
       }
       t=&h->stack[h->size++];
       t->from=s->from;
       t->to=s->to;
  }
  static  void  pop(StackHeader *h,Stack *s)
 {
       Stack  *t;
       if(!h->size)
      {
           printf("ջ�Ѿ�Ϊ�գ��Ѳ����ٵ���Ԫ��\n");
           return;
       }
       t=&h->stack[--h->size];
       s->from=t->from;
       s->to=t->to;
  }
      
//*********************************************
  int  main(int argc,char *argv[])
 {
       int  p[10]={30,35,15,5,10,20,25};
       int  size=7,n=size-2;
//��ʼ����
       least_matrix_sequence(p,size);
       printf("��С��������Ϊ:\n");
       split_matrix_sequence(0,n,size-1);
       return 0;
  }