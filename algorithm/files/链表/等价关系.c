//���ҵȼ۹�ϵ
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
     printf("����������Ĵ�С(<%d) !\n",MAX_SIZE);
   loop:
     scanf("%d",&n);
     if(n<=0 || n>MAX_SIZE)
    {
         printf("�������ֵ�Ƿ�,����������!\n");
         goto loop;
     }
     printf("������ȼ۹�ϵ(-1,-1)�˳�!\n");
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
         printf("\n������ȼ۹�ϵ:");
         scanf("%d %d",&i,&k);
     }
    printf("\n************************�ȼ۹�ϵ����**************************\n");
     for(i=0;i<n;++i)
    {
        if(out[i] || visited[i])
           continue;
        visited[i]=1;
        printf("\n�ȼ��� %4d",i);
        out[i]=1;
        top=nodes[i];
        tmp=top;
        while(1)
       {
//      find:
           while(tmp)
          {
              k=tmp->data;
              if(!out[k]) //�����û�����
             {
                  printf("%4d",k);
                  out[k]=1;
              }
              tmp=tmp->next;
           }
           if(!top)
              break;
           tmp=nodes[top->data];
//ע�⣬��һ���ǳ���Ҫ
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
//�ͷſռ�
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