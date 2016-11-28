//��ȫ���������������⣬��������ṹʵ��
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  
  #define  MAX_SIZE   16
  #define  INIT_SIZE  8
//����һ������
  void  CreateMaxHeap(int *);
  void  insert_item(int *,int);
  void  remove_root(int *);
  void  print_heap(int *);
  
  int main(int argc,char *argv[])
 {
     int  heap[MAX_SIZE];
     int  i,seed;
//��ʼ����
     heap[0]=INIT_SIZE;
     seed=time(NULL);
     srand(seed);
     for(i=1;i<INIT_SIZE;++i)
        heap[i]=rand();

     printf("��δ����ʱ�ĳ�ʼ��Ϊ:\n");
     print_heap(heap,MAX_SIZE);
     printf("�����Ķ�Ϊ:\n");
     CreateMaxHeap(heap);
     print_heap(heap);
     
     seed=rand();
     printf("���ڽ�Ҫ����һ��Ԫ��:%d \n",seed);
     insert_item(heap,seed);
     printf("����Ԫ�غ�Ķ�Ϊ:\n");
     print_heap(heap);

     printf("ɾ�����ѵ���Ԫ�غ�:\n");
     remove_root(heap);
     print_heap(heap);
     return 0;
  }
//��������
  void  CreateMaxHeap(int *heap)
 {
      int i,child,tmp,k;
      int len=heap[0];
      for(i=len;i>=1;--i)
     {
          child=i;
          while(child>=1)
         {
             k=child>>1;
             if(k>=1 && heap[child]>heap[k])
            {
                tmp=heap[k];
                heap[k]=heap[child];
                heap[child]=tmp;
             }
             child>>=1;
          }
      }
  }
//�������в���һ��Ԫ��
  void  insert_item(int *heap,int item)
 {
     int  child;
     child=++heap[0];
     
     while(child>1 && item>heap[child>>1])
    {
        heap[child]=heap[child>>1];
        child>>=1;
     }
     heap[child]=item;
   }
//ɾ�����ѵĸ��ڵ�,���������ṹ
  void  remove_root(int *heap)
 {
     int  len=heap[0]--;
     int  child,parent;
     int  item=heap[len];
     child=2,parent=1;
     --len;
     while(child<=len)
    {
         if(child<len && heap[child]<heap[child+1])
            ++child;
         if(heap[child]<=item)
            break;
         heap[parent]=heap[child];
         parent=child;
         child<<=1;
      }
//ע�⣬��һ���е�parent���ܸ�Ϊlen��������ĳЩ����¿��Ի���,������Щ����£�����ִ���
     heap[parent]=item;
  }
//���������
  void  print_heap(int *heap)
 {
     int len=heap[0];
     int  i;
     for(i=1;i<=len;++i)
    {
         printf("Ԫ��%d : %d \n",i,heap[i]);
     }
     printf("****************************�������******************************\n");
  }