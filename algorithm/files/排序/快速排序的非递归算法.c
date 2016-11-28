//��������ķǵݹ�ʵ��
  #include<stdio.h>
  #include<stdlib.h>
  #define  MAX_SIZE  15
  #define  SEED_T    0x6792

  typedef  struct  _Queue
 {
      int  low;
      int  high;
      struct  _Queue  *next;
  }Queue;

  typedef  struct _QueueInfo
 {
      int     len;
      struct  _Queue  *front;
      struct  _Queue  *rear;
  }QueueInfo;
//�����������µ���
  void  addQueue(QueueInfo  *info,Queue *item)
 {
      Queue  *tmp=(Queue *)malloc(sizeof(Queue));
      tmp->low=item->low;
      tmp->high=item->high;
      tmp->next=NULL;
 
      if(info->len)
          info->rear->next=tmp;
      else
          info->front=tmp;
      info->rear=tmp;
      ++info->len;
  }
//�Ӷ�����ɾ���µ���
  void  removeQueue(QueueInfo *info,Queue *item)
 {
      Queue *tmp=NULL;
      if(info->len)
     {
          tmp=info->front;
          info->front=tmp->next;
          item->low=tmp->low;
          item->high=tmp->high;
          --info->len;
          free(tmp);
      }
  }
//����������㷨ʵ��
  void   QuickSort(int  *list,int n)
 {
       Queue      item;
       QueueInfo  info;
       int        low,high;
       int        i,k;
       int        tmp,key;

       info.len=0;
       info.front=NULL;
       info.rear=NULL;
       item.low=0;
       item.high=n;
       addQueue(&info,&item);

       while(info.len)
      {
           removeQueue(&info,&item);
           if(item.low<item.high)
          {
               low=item.low;
               high=item.high;
               i=low;
               k=high;

               key=list[i];
               while(i<k)
              {
                   ++i;
                   while(i<high && list[i]<key)
                       ++i;
                   --k;
                   while(k>low &&  list[k]>key)
                       --k;
                   if(i<k)
                  {
                       tmp=list[i];
                       list[i]=list[k];
                       list[k]=tmp;
                   }
               }
              list[low]=list[k];
              list[k]=key;

              item.low=low;
//ע������high��ֵ��Ҫ�������ѭ���е���ʽ����һ�£��������ֲ��
              item.high=k;
              addQueue(&info,&item);

              item.low=k+1;
              item.high=high;
              addQueue(&info,&item);
           }
       }
  }
//���������в���
  int  main(int argc,char *argv[])
 {
      int  list[MAX_SIZE];
      int  i;
      srand(SEED_T);
      for(i=0;i<MAX_SIZE;++i)
          list[i]=rand();
      printf("����ǰ�����:\n");
      for(i=0;i<MAX_SIZE;++i)
          printf(" %d \n",list[i]);

      printf("�����:\n");
      QuickSort(list,MAX_SIZE);
      for(i=0;i<MAX_SIZE;++i)
          printf(" %d \n",list[i]);
  }