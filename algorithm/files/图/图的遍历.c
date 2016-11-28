//����ͼ,ͼ�����ڽӾ�����ڽӱ�洢
  #include<stdio.h>
  #include<stdlib.h>
  #define  ROW_SIZE  7
  #define  _IDATA     '0'

//��¼���̽ڵ�������ṹ  
  typedef  struct  _Post
 {
     int  index;
     struct  _Post  *next;
  }Post;

  typedef  struct  _Graph
 {
     int  data;
     int  len;
     struct  _Post  *rear;
     struct  _Post  *front;
  }Graph;
//��¼�����������ݽṹ����Ϣ
  typedef  struct  _GraphInfo
 {
     int    len;
     struct  _Graph  *front;
  }GraphInfo;

//**************************************************
  int  graph[7][7]={{0,1,1,0,0,0,0},
             {1,0,0,1,1,0,0},
             {1,0,0,0,0,1,1},
             {0,1,0,0,0,0,0},
             {0,1,0,0,0,0,0},
             {0,0,1,0,0,0,0},
             {0,0,1,0,0,0,0}};

  GraphInfo  *CreateGraphInfo(int *,int,int);
  void       VisitGraph(GraphInfo  *);
  void       releaseGraph(GraphInfo  *);
//������ͼ��ص���Ϣ�Լ�ͼ���ڽӱ��ʾ
  GraphInfo  *CreateGraphInfo(int *agraph,int row,int idata)
 {
      GraphInfo  *info;
      Graph      *gh;
      Post       *post;
      int        *tmp;
      int        i,k,size;
      info=(GraphInfo *)malloc(sizeof(GraphInfo));
      info->len=row;
      info->front=(Graph *)malloc(sizeof(Graph)*row);    
      size=row*row;

      for(i=0,tmp=agraph;i<row;++i)
     {
          gh=&info->front[i];

          gh->data=idata++;
          gh->len=0;
          gh->rear=NULL;
          gh->front=NULL;      
          for(k=0;k<row;++k,++tmp)
         {
              if(*tmp)
             {
                  post=(Post *)malloc(sizeof(Post));
                  post->index=k;
                  post->next=NULL;
                  if(gh->len)
                 {
                     gh->rear->next=post;
                     gh->rear=post;
                  }
                  else
                 {
                     gh->front=post;
                     gh->rear=post;
                  }
                 ++gh->len;
              }
           }
       }
      return  info;
  }
//�����ڽӱ��ʾ��ͼ,һ����˵���õݹ鷨���ʸ��򵥣����ǿ�¯��Ч�ʺ�ͨ����
//���ǲ��������ַ���
  void  VisitGraph(GraphInfo  *info)
 {
      Post   *post;
      Graph  *graph;
      int    *visited;
      int   i;
      
      visited=(int *)malloc(sizeof(int)*info->len);
//��ʼ����
      for(i=0;i<info->len;++i)
          visited[i]=0;
 
      graph=info->front;
      for(i=0;i<info->len;++i)
     {
//����ýڵ��Ѿ������ʹ�����ô�ʹ���һ��ѭ����ʼ
          if(visited[i])
              continue;
          visited[i]=1;
          post=graph[i].front;
          printf("�ӽڵ�%c ��ʼ����,����Ϊ:",graph[i].data);
          while(post)
         {
              if(!visited[post->index])
			  {
				  visited[post->index]=1;
                  printf("%c ",graph[post->index].data);
			  }
              post=post->next;

          }
          putchar('\n');
      }
      free(visited);
  }
//�ͷ����ж�̬����Ŀռ�
  void  releaseGraph(GraphInfo  *info)
 {
      Graph  *graph;
      Post   *post,*tmp;
      int    i=0;
      for(graph=info->front;i<info->len;++i)
     {
          post=graph[i].front;
          while(post)
         {
              tmp=post;
              post=post->next;
              free(tmp);
          }
      }
      free(graph);
      free(info);
      printf("�Ѿ��ɹ����ͷŵ����еĿռ�\n");
  }
  int main(int argc,char  *argv[])
 {
      GraphInfo  *info=CreateGraphInfo((int *)graph,ROW_SIZE,_IDATA);
      printf("���ڿ�ʼ����������ͼ�Ĺ켣!\n");
      VisitGraph(info);
      printf("��ʼ�ͷ����е��Ѿ�����Ŀռ�!\n");
      releaseGraph(info);
      info=NULL;
      return  0;
  }