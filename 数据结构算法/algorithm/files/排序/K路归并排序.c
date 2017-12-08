//2012/10/23/22:49
//K·�鲢����,���еĲ�����������飬�����鳤�ȴ洢������(p)����Ԫ���У��༴p[0]
/*
  ע�������棬��·�鲢�͵�·�鲢��˼·�����źܴ������
*/
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define  K_MERGE  32
  #define  MAX_SIZE  1024

  typedef  struct  _Node
 {
//��¼������������׵�ַ
      int   *p;
//��¼��������������Ԫ�ص��±�����
      int   index;
//Ψ���ܼӿ��������У�data��ʵ�ʱ�ʾΪp[index]
      int   data;
 }Node;
//���֧��32·�鲢����
  Node  nodes[K_MERGE];
//���д��鲢��������չ鴦
  int   heap[MAX_SIZE];
     
//��·�������ʵ��
  void  adjust(int *,int,int);
  void  heapSort(int *);
//K·�鲢�����ʵ��
  void  K_merge(int **,int ,Node *,int *);
  static void  K_adjust(Node *,int,int);
  void  K_mergeSort(Node *,int);
/*******************************************************/
//��������
  void  heapSort(int *heap)
 {
      int  child,tmp;
      int  n=heap[0];

      for(child=n>>1;child;--child)
           adjust(heap,n,child);
      for(child=n;child>1;--child)
     {
           tmp=heap[child];
           heap[child]=heap[1];
           heap[1]=tmp;

           adjust(heap,child-1,1);
      }
  }
//�����ѽṹ,ʹʣ�������Ԫ����Ȼ����һ�����ѽṹ
  void  adjust(int *heap,int n,int parent)
 {
      int child,tmp;
      
      tmp=heap[parent];
      for(child=parent<<1;child<=n;child<<=1)
     {
           if(child<n && heap[child]<heap[child+1])
                ++child;
           if(tmp<heap[child])
                heap[parent]=heap[child];
           else
                 break;
          parent=child;
      }
      heap[parent]=tmp;
  }
//����ʵ��K·�鲢����
  void  K_merge(int  **head,int nsize,Node  *nodes,int  *heap)
 {
       int  i,n;
       Node  *np=nodes;
//��һ���������еĴ������������Ԫ�ظ��Ƶ�ר�����ݽṹ��
       for(++np,i=0;i<nsize;++i,++np)
      {
            np->p=head[i];
            np->index=1;
            np->data=*(head[i]+1);
            printf(" %d ",np->data);
       }
       printf("\n");
//�ڵڶ�������ʼ�ϲ����е�Ԫ��
//ֻҪ�ṹ����ĳ��ȴ���0��ѭ����һֱ��ȥ
       n=nsize;
//      K_mergeSort(nodes,n);
      for(i=nsize>>1;i;--i)
          K_adjust(nodes,i,n);
/*
      for(np=nodes+1,i=1;i<=nsize;++i,++np)
           printf("%d  ",np->data);
      printf("\n");
*/
      np=nodes+1;
      i=1;
      while(n)
     {
           heap[i++]=np->data;
//�������ĳһ�����������Ѿ����ﾡͷ����ô�Ͱѱ���������������Ϣ�Ľṹ���������
           ++np->index;
           if(np->index>*np->p)
          {
               np->p=nodes[n].p;
               np->index=nodes[n].index;
               np->data=nodes[n].data;
               --n;
               K_adjust(nodes,1,n);
           }
           else
          {
               np->data=*(np->p+np->index);
               K_adjust(nodes,1,n);
           }
      }
      heap[0]=i-1;
  }
//*��K·�鲢�������õ����ݽṹ���е���
 //*��������Ƕ������һ������
 
  void  K_mergeSort(Node *nodes,int n)
 {
      int   child;
      Node  tmp;

      for(child=n>>1;child;--child)
           K_adjust(nodes,child,n);
/*
      for(child=n;child>1;--child)
     {
           tmp=nodes[child];
           nodes[child]=nodes[1];
           nodes[1]=tmp;

           tmp.p=nodes[child].p;
           tmp.index=nodes[child].index;
           tmp.data=nodes[child].data;

           nodes[child].p=nodes[1].p;
           nodes[child].index=nodes[1].index;
           nodes[child].data=nodes[1].data;

           nodes[child].p=tmp.p;
           nodes[child].index=tmp.index;
           nodes[child].data=tmp.data;


           K_adjust(nodes,1,child-1);
      }
*/
  }
//�������ݽṹ,����С�ѽ�������
  void  K_adjust(Node *nodes,int parent,int n)
 {
      int  child;
      Node  tmp;
      
      tmp.p=nodes[parent].p;
      tmp.index=nodes[parent].index;
      tmp.data=nodes[parent].data;
      for(child=parent<<1;child<=n;child<<=1)
     {
            if(child<n && nodes[child].data>nodes[child+1].data)
                  ++child;
            if(tmp.data>nodes[child].data)
           {
                 nodes[parent].p=nodes[child].p;
                 nodes[parent].index=nodes[child].index;
                 nodes[parent].data=nodes[child].data;
                 parent=child;
            }
            else
                 break;
      }
      nodes[parent]=tmp;
/*
      nodes[child].p=tmp.p;
      nodes[child].index=tmp.index;
      nodes[child].data=tmp.data;
*/
   }
/**********************************************************/
   int  main(int argc,char *argv[])
  {
       int  mat[5][9];
       int  i,k,flag;
       int  *p[5];
       int  seed=0x1237;

       srand(seed);
//�����ʼ��
       for(i=0;i<5;++i)
         for(k=1;k<=8;++k)
             mat[i][k]=rand();
//���ȴ洢
      for(i=0;i<5;++i)
          mat[i][0]=8;
 //��ӡ
      for(i=0;i<5;++i)
     {
           printf("����:%d \n",mat[i][0]);
           for(k=1;k<=8;++k)
                printf(" %d ",mat[i][k]);
           printf("\n");
      }
      printf("��ʼ����.....\n");
      for(i=0;i<5;++i)
          heapSort(mat[i]);

      printf("�Ե�����������������и���Ԫ�ص�λ��������ʾ:\n");
      for(i=0;i<5;++i)
     {
           printf("����:%d \n",mat[i][0]);
           for(k=1;k<=8;++k)
                printf(" %d ",mat[i][k]);
           printf("\n");
      }

      printf("\n*************************************************\n");
      printf("��ʼ���й鲢....\n");
      for(i=0;i<5;++i)
         p[i]=&mat[i][0];
      K_merge(p,5,nodes,heap);
      printf("�鲢������������������:\n");
      k=heap[0];
      flag=0;
      for(i=1;i<=k;++i)
     {
          printf(" %d ",heap[i]);
          if(flag & 0x8)
         {
              flag=0;
              putchar('\n');
          }
          ++flag;
      }
	  printf("\n");
      return 0;
  }
      