//ʹ������ʵ�ֵ�ѭ������
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define ARRAY_MAX_SIZE   16
  typedef struct _QueueInfo
 {
     int front;
     int rear;
     int actSize;
     int maxSize;
     int *ary;
  }QueueInfo;
//����һ���µĶ���
   QueueInfo *CreateQueue(int length);
//��������Ԫ��
   int addElem(QueueInfo *,int elem);
//�ж϶����Ƿ�Ϊ��
   int isQueueEmpty(QueueInfo *);
//ɾ�����е���ʼԪ��
   int removeFirst(QueueInfo *);
//�������������
   int clearQueue(QueueInfo *);
//��ѭ�����е������Ϣ���
   void queueInfo(QueueInfo *);
//*****************************************
   int main(int argc,char *argv[])
  {
      int seed;
      int i=0,tmp=0;
      QueueInfo *queue=CreateQueue(ARRAY_MAX_SIZE);
      seed=time(NULL);
      srand(seed);
      while(i++<queue->maxSize)
	  {
		 tmp=rand();
		 tmp=(tmp>>16) ^(tmp & 0xFFFF);
         addElem(queue,tmp);
	  }
      printf("�����еĸ���Ԫ��������ʾ:\n");
      queueInfo(queue);
      printf("Ԫ��������!\n");
//........................................................
      printf("��ʼɾ�������е�Ԫ��(4��)!\n");
	  i=0;
      while(i<4 && removeFirst(queue))
        ++i;
      printf("��ɾ����Ķ��е�����������ʾ:\n");
      queueInfo(queue);
//*********************************************************
      printf("����ȫ����ɾ��!\n");
      clearQueue(queue);
      printf("��ɾ���󣬶��е���������:\n");
      queueInfo(queue);
      free(queue->ary);
      free(queue);
      return 0;
  }
//*************************************************************
  QueueInfo *CreateQueue(int length)
 {
     QueueInfo *info;
     if(length<=1)
       return NULL;
     info=(QueueInfo *)malloc(sizeof(QueueInfo));
     info->ary=(int *)malloc(sizeof(int)*length);
     info->rear=0;
     info->front=0;
     info->actSize=0;
     info->maxSize=length;
     return info;
  }
//************************************************************
  int addElem(QueueInfo *info,int elem)
 {
     int result=0;
     if(info->actSize<=info->maxSize)
    {
        info->ary[info->rear]=elem;
        info->rear=(++info->rear)%info->maxSize;
        ++info->actSize;
        result=1;
     }
     else
        result=0;
     return result;
  }
//************************************************************
  int removeFirst(QueueInfo *info)
 {
     int result=0;
     if(!info)
         return 0;
     if(info->actSize)
    {
        --info->actSize;
        info->front=++info->front%info->maxSize;
        result=1;
     }
     else
        result=0;
     return result;
  }
  int isQueueEmpty(QueueInfo *info)
 {
     if(!info)
       return 1;
     return info->actSize;
  }
  int clearQueue(QueueInfo *info)
 {
     if(!info)
       return 0;
     info->actSize=0;
     info->rear=0;
     info->front=0;
     return 1;
  }
  void queueInfo(QueueInfo *info)
 {
     int i,size,k,tmp;
     int *p;
     if(!info)
       return;
     size=info->actSize;
     p=info->ary;
     i=info->front;
     for(k=0;k<size;++k)
    {
        tmp=i%info->maxSize;
        printf("%d :%d\n",tmp,*(p+tmp));
		++i;
     }
  }