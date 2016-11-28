//2012/12/10:14:49
//ͼ��������������͹����������,��������ͼ�Ĵ洢�����ڽӱ����ʽ
  #include<stdio.h>
  #include<stdlib.h>
//�����ͼ��ص����ݽṹ
  typedef  struct  _PostGraph
 {
      int                  vertex;
      struct  _PostGraph   *next;
  }PostGraph;
  typedef  struct  _Graph
 {
//��¼�ʹ˶�������������ж������Ŀ
      int                  len;
//��¼ָ��ʹ˶�����������ڽӱ��ͷָ��
      struct  _PostGraph   *front;
      struct  _PostGraph   *rear;
  }Graph;
//Ϊ�˷���ͼ�Ĺ������ƵĶ�������ݽṹ����ʵ���ϣ����ǿ�����ȥ��
  typedef  struct  _GraphInfo
 {
//ָ��ͼ�ж�������ɵ�����
      struct  _Graph   *graph;
//��¼ͼ�Ķ������Ŀ
      int              len;
  }GraphInfo;
//�ڷ���ͼʱ����Ҫʹ�ö�̬���У������ǹ��ڶ�̬ ���е�������ݽṹ
  typedef  struct  _Stack
 {
//��¼��һ����Ҫ���ʵĺ͵�ǰ����������ĺ�̽��
      struct  _PostGraph   *vet;
      struct  _Stack       *next;
  }Stack;
  typedef  struct  _StackInfo
 {
//��¼��̬����/ջ���׽���ָ��
      struct   _Stack      *front;
      struct   _Stack      *rear;
//��ǰ����/ջ�ĳ���
      int                  len;
  }StackInfo;
//�����ĺ���ֱ��ʾ:����ͼ��Ϣ�ṹָ�룬�ڽӾ���ĵ�ַ���������/�п�
  void  CreateGraph(GraphInfo *,int *,int );
//�����������
  void  deep_vf(GraphInfo  *);
//�����������
  void  breath_vf(GraphInfo *);
//��̬��ջ�Ĵ���
  static void  push(StackInfo *,Stack *);
  static int  pop(StackInfo  *,Stack *);
//��̬���еĴ���
  static  void  pushq(StackInfo *,Stack *);
  static  int  popq(StackInfo  *,Stack *);
/**************************************************************/
  int  main(int argc,char *argv[])
 {
       int  i,j,n;
       int  *mx;
       GraphInfo   info;

       n=-1;
       do
      {
             printf("�����뽫Ҫ������ͼ�������Ķ������Ŀ(>1)!\n");
             scanf("%d",&n);
       }
       while(n<1);
       j=n*n;
//�������
       mx=(int *)malloc(j<<2);
       for(i=0;i<j;++i)
            mx[i]=0;
//���Ƚ����ڽӾ���
       printf("������������Ķ���(ÿ������)(-1,-1)����������\n");
       do
      {
            i=-1,j=-1;
            printf("����������������Ķ���:\n");
            scanf("%d %d",&i,&j);
            if(i==-1 && j==-1)
                break;
            if(i>=n || i<0 ||  j>=n || j<0)
           {
                 printf("�������ֵ%d,%d���ڶ������Ŀ������������!\n");
//                 system("cls");
                 continue;
            }
            mx[i*n+j]=1;
            mx[j*n+i]=1;
            printf("����%d�Ͷ���%d��������\n",i,j);
      }while( 1 );
//�������

      info.graph=NULL;
      info.len=0;
//����ͼ���ڽӱ�洢
      CreateGraph(&info,mx,n);
//���������������
      printf("\n*******************�����������************************\n");
      deep_vf(&info);
      _sleep(10);
      printf("\n*******************�����������************************\n");
      breath_vf(&info);
//�ͷ��Ѿ�������ڴ�
      free(mx);
      return 0;
  }
//����ͼ���ڽӱ�洢
  void  CreateGraph(GraphInfo *info,int *mx,int n)
 {
      int  i,j;
      Graph       *graph;
      PostGraph   *post;

      info->len=n;
      graph=(Graph *)malloc(sizeof(Graph)*n);
      info->graph=graph;
      
      for(i=0;i<n;++i,++graph)
     {
           graph->len=0;
           graph->front=NULL;
           graph->rear=NULL;
           for(j=0;j<n;++j,++mx)
          {
                 if( *mx )
                {
                        post=(PostGraph *)malloc(sizeof(PostGraph));
                        post->next=NULL;
                        post->vertex=j;
                        if(!graph->front)
                              graph->front=post;
                        else
                              graph->rear->next=post;
                        graph->rear=post;
                        ++graph->len;
                 }
           }
      }
/*
//����ڽӱ������
      for(i=0,graph=info->graph;i<len;++i,++graph)
     {
             post=graph->front;
             printf("����%d��->:",i);
             while( post )
            {
                   printf("  %d  ",post->vertex);
                   post=post->next;
             }
             printf("\n");
      }
*/
  }
//Ϊ������������������Ķ���
  static  void  pushq(StackInfo *info,Stack *s)
 {
       Stack  *item=(Stack *)malloc(sizeof(Stack));
       item->vet=s->vet;
       item->next=NULL;
       
       if(!info->front)
            info->front=item;
       else
            info->rear->next=item;
       info->rear=item;
       ++info->len;
  }
//�Ӷ�����ɾ�����׽��Ԫ��
  static  int  popq(StackInfo *info,Stack *s)
 {
       Stack  *item=info->front;
       
       if(info->len)
      {
              --info->len;
              s->vet=item->vet;
              info->front=item->next;
              if(info->rear==item)
                   info->rear=NULL;
              free(item);
              return 1;
       }
       else
              s->vet=NULL;
       return 0;
  }
//Ϊ������������������Ķ�̬ջ,ע�⣬������û�в����ļ��
  static  void  push(StackInfo *info,Stack *s)
 {
       Stack  *item=(Stack *)malloc(sizeof(Stack));
       item->next=NULL;
       item->vet=s->vet;
       
       ++info->len;
       item->next=info->front;
       info->front=item;
  }
//��ջ��̽�����Ԫ��
  static  int  pop(StackInfo *info,Stack *s)
 {
       Stack *item=info->front;

       if(item)
      {
             --info->len;
             s->vet=item->vet;
             info->front=item->next;
             free(item);
             return 1;
       }
       return 0;
  }
//�����������
  void  deep_vf(GraphInfo  *info)
 {
       int         len=info->len;
       Graph       *graph=info->graph;
       PostGraph   *post,*tmp;
       StackInfo   stack;
       Stack       item;
       int         *visit,i;
//�������������Ҫʹ�õ����ݽṹ���Ƕ���
       visit=(int *)malloc(sizeof(int)*len);//������������״̬��Ϊ0���ʾΥ�����ʣ������ʾ������
       for(i=0;i<len;++i)
           visit[i]=0;
       
       stack.front=NULL;
       stack.rear=NULL;
       stack.len=0;
       if(! len)
           return;
//��ʼ����̬����
       post=(PostGraph *)malloc(sizeof(PostGraph));
       post->vertex=0;
       post->next=graph->front;
       item.vet=post;
       tmp=post;
       push(&stack,&item);
//��һ����ʼ�����������
       while(  stack.len )
      {
           pop(&stack,&item);
           post=item.vet;
//           printf(" %d  ",stack.len);
           i=post->vertex;
           if(!visit[i])
          {
                printf("���%d������!\n",i);
                visit[i]=1;

                post=graph[i].front;
                while( post )
               {
                     if(!visit[post->vertex])
                    {
                         item.vet=post;
                         push(&stack,&item);
                     }
                    post=post->next;
               }
           }
       }
       free(tmp);
       free(visit);
       printf("\n");
  }
//�����������,ע��������û�� �Բ����ĺϷ��Խ��м��
  void  breath_vf(GraphInfo  *info)
 {
       Graph       *graph=info->graph;
       int        len=info->len;
       int        i,*visit;
       Stack      item;
       StackInfo  queue;
       PostGraph  *post;

       visit=(int *)malloc(sizeof(int)*len);
       for(i=0;i<len;++i)
            visit[i]=0;
       
       printf("����%d�Ѿ�������!\n",0); 
       visit[0]=1;
       
       queue.len=0;
       queue.front=NULL;
       queue.rear=NULL;
       post=graph->front;

       while( post )
      {
              item.vet=post;
              pushq(&queue,&item);
              post=post->next;
       }
       while( queue.len)
      {
             popq(&queue,&item);
             post=item.vet;
             i=post->vertex;
             if(!visit[i])
            {
                  printf("����%d�Ѿ�������!\n",post->vertex);
                  visit[i]=1;
             
                  post=graph[i].front;
                  while( post )
                 {
                       if(!visit[post->vertex])
                      {
                            item.vet=post;
                            pushq(&queue,&item);
                      }
                      post=post->next;
                 }
            }
       }
        free(visit);
       printf("\n");
  }