//2012/12/26/9:20
//求取最小的矩阵链乘法的惩罚序列
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
//第一步初始化矩阵的对角元素
       for(i=0;i<n;++i)
            m[i][i]=0;
//第二部，计算矩阵序列的代价,一次从长度2,3,4....n计算
      for(le=2;le<=n;++le)
     {
//注意这里面的下表索引的取值及其范围
             tpl=n-le;
            for(i=0;i<=tpl;++i)
           {
                  j=i+le-1;
                  m[i][j]=INF_T;
                  for(k=i;k<j;++k)
                 {
//注意这一步的含义:n*m阶矩阵 和m*k阶矩阵相乘，结果是n*k阶矩阵
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
//输出最小矩阵链乘法的计算顺序，使用小括号分隔
//注意在矩阵m,s中，我们只使用了它们的上三角，所以，在对s进行解码时必须要注意这一点
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
//非递归输出
      StackHeader  hs,*h;
      Stack        stc,*st;
      int         v=0;

      if(i>j || j+1!=size)
     {
           printf("非法的参数输入");
           return;
      }
      st=&stc;
      h=&hs;
      h->stack=(Stack *)malloc(sizeof(Stack)*(size<<2));
      h->size=0;
      h->max=size<<2;
//开始计算最小矩阵链顺序
      st->from=i,st->to=j;
      push(h,st);
//只要栈非空，循环进继续进行下去
      while(h->size)
     {
           pop(h,st);
           if(st->from==st->to)
          {
               printf(" %c ",(char)('A'+st->from));
//注意下面的这一步,当对一个矩阵序列进行标量乘法时，必定会两个两个地相结合，所以只有当两个矩阵被连续地输出时， 
//才可以对其后面加括号
               if(!v)
                   printf(")");
               v=0;
           }
           else
          {
               printf("(");
//注意下面的入栈顺序
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
             printf("栈栈已经满，不能再输入\n");
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
           printf("栈已经为空，已不能再弹出元素\n");
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
//开始计算
       least_matrix_sequence(p,size);
       printf("最小矩阵序列为:\n");
       split_matrix_sequence(0,n,size-1);
       return 0;
  }