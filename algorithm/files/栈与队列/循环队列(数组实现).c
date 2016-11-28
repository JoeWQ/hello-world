//使用数组实现的循环队列
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
//创建一个新的队列
   QueueInfo *CreateQueue(int length);
//向队列添加元素
   int addElem(QueueInfo *,int elem);
//判断队列是否为空
   int isQueueEmpty(QueueInfo *);
//删除队列的起始元素
   int removeFirst(QueueInfo *);
//将整个队列清空
   int clearQueue(QueueInfo *);
//将循环队列的相关信息输出
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
      printf("队列中的各个元素如下所示:\n");
      queueInfo(queue);
      printf("元素输出完毕!\n");
//........................................................
      printf("开始删除队列中的元素(4个)!\n");
	  i=0;
      while(i<4 && removeFirst(queue))
        ++i;
      printf("被删除后的队列的内容如下所示:\n");
      queueInfo(queue);
//*********************************************************
      printf("队列全部被删除!\n");
      clearQueue(queue);
      printf("被删除后，队列的内容如下:\n");
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