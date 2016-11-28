//查找等价关系
  #include<stdio.h>
  #include<stdlib.h>
//*******************************************
  #define  MAX_SIZE    16
  typedef  struct  _Node
 {
     int data;
     struct  _Node  *next;
  }Node;
  
  Node  *nodes[MAX_SIZE];
  int   out[MAX_SIZE];
  int   visited[MAX_SIZE];
//************************************8888
  int  main(int argc,char *argv[])
 {
     int n;
     int i,k;
     Node  *tmp,*top;
     printf("请输入数组的大小(<%d) !\n",MAX_SIZE);
   loop:
     scanf("%d",&n);
     if(n<=0 || n>MAX_SIZE)
    {
         printf("您输入的值非法,请重新输入!\n");
         goto loop;
     }
     printf("请输入等价关系(-1,-1)退出!\n");
     scanf("%d %d",&i,&k);
     while(i>=0)
    {
         tmp=(Node *)malloc(sizeof(Node));
         tmp->data=k;
         tmp->next=nodes[i];
         nodes[i]=tmp;
         
         tmp=(Node *)malloc(sizeof(Node));
         tmp->data=i;
         tmp->next=nodes[k];
         nodes[k]=tmp;
         printf("\n请输入等价关系:");
         scanf("%d %d",&i,&k);
     }
    printf("\n************************等价关系如下**************************\n");
     for(i=0;i<n;++i)
    {
        if(out[i] || visited[i])
           continue;
        visited[i]=1;
        printf("\n等价类 %4d",i);
        out[i]=1;
        top=nodes[i];
        tmp=top;
        while(1)
       {
//      find:
           while(tmp)
          {
              k=tmp->data;
              if(!out[k]) //如果还没有输出
             {
                  printf("%4d",k);
                  out[k]=1;
              }
              tmp=tmp->next;
           }
           if(!top)
              break;
           tmp=nodes[top->data];
//注意，这一步非常重要
           if(!top->next && !visited[top->data])
          {
              visited[top->data]=1;
              top=nodes[top->data];
              tmp=top;
              continue;
           }
           top=top->next;
         }
     }
	  putchar('\n');
//释放空间
    for(i=0;i<n;++i)
   {
       tmp=nodes[i];
       while(tmp)
      {
          top=tmp;
          tmp=tmp->next;
          free(top);
       }
    }
     return 0;
  }        