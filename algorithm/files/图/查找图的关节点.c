//*����ͼ�Ĺؽڵ�*,������������ͼ�ǵ���ͨ��
//һ��ʧ�ܵ���Ʒ,ע��
  #include<stdio.h>
  #include<stdlib.h>
  #define  ROW_SIZE  8
  #define  IDATA     '0'
  #define  I_START   7

  typedef  struct  _Post
 {
//��¼��һ�����ӽڵ������
     int  index;
//��¼���Ӵ˽ڵ������
     int  preindex;
//Ϊ�˱��ڽ���ɾ������,������prevָ��
     struct  _Post  *prev;
     struct  _Post  *next;
  }Post;
//��¼����ͼ�ڵ��������ӵ���Ϣ
  typedef  struct  _Graph
 {
//�˽ڵ���������������
     short    data;
	 short    mark;
//�ʹ˽ڵ������ӵĽڵ���Ŀ
     int  len;
     struct  _Post  *front;
     struct  _Post  *rear;
  }Graph;
//�������нڵ��ͳ����
  typedef  struct  _GraphInfo
 {
     int  len;
     struct  _Graph  *front;
  }GraphInfo;
//�ڼ���ؽڵ�ʱ��Ҫ�õ���ջ�ṹ�Ķ�����Ϣ
  typedef  struct  _Stack
 {
     struct  _Post   *post;
     struct  _Stack  *next;
  }Stack;
//ͳ��ջ�ṹ��������Ϣ
  typedef  struct  _StackInfo
 {
     int  len;
     int  unuse;
     struct  _Stack  *front;
     struct  _Stack  *rear;
  }StackInfo;
//����ȫ������
  int  len;
//  int  *visited;
  int  *dfsn;
  int  *low;
  int  *prenode;
  GraphInfo  *ginfo;
  int  index;
//ͼ���ڽӾ����ʾ
  int mat_0[10][10]={{0,1,0,0,0,0,0,0,0,0},
                   {1,0,0,1,1,0,0,0,0,0},
                   {0,1,0,0,1,0,0,0,0,0},
                   {0,1,0,0,1,1,0,0,0,0},
                   {0,0,1,1,0,0,0,0,0,0},
                   {0,0,0,1,0,0,1,1,0,0},//5
                   {0,0,0,0,0,1,0,1,0,0},
                   {0,0,0,0,0,1,1,0,1,1},//7
                   {0,0,0,0,0,0,0,1,0,0},//8
                   {0,0,0,0,0,0,0,1,0,0}};
   int mat[8][8]={{0,1,1,0,0,0,0,0},
                  {1,0,1,1,0,0,0,0},
                  {1,0,0,0,0,1,1,0},//2
                  {0,1,0,0,0,0,0,1},//3
                  {0,1,0,0,0,0,0,1},
                  {0,0,1,0,0,0,0,1},//5
                  {0,0,1,0,0,0,0,1},
                  {0,0,0,1,1,1,1,0}};//7
                                    
  GraphInfo  *CreateGraphInfo(int *mat,int row,int idata);
  
  void  addStack(StackInfo *,Post *);
  
  Post  *removeStack(StackInfo *);
//�жϸ��ڵ��Ƿ�Ϊ�ؽڵ�
  void  is_root_artic(GraphInfo  *,int);
//�ж������ڵ��Ƿ�Ϊ�ؽڵ�
  void  judge_node(GraphInfo  *,int);
//����ͼ�Ĺؽڵ�
  void  dfsnlow(int ,int );
//���ݸ������ڽӾ��󣬴�����Ӧ���ڽӱ�
  GraphInfo  *CreateGraphInfo(int *mat,int row,int idata)
 {
      GraphInfo  *info;
      Graph      *graph;
      Post       *post;
      int        *tmp;
      int        i,k;
//��ʼ���ڽӾ���ͼ�������Ϣ
      info=(GraphInfo *)malloc(sizeof(GraphInfo));
      info->len=row;
      info->front=(Graph *)malloc(sizeof(Graph)*row);
      graph=info->front;

      for(i=0,tmp=mat;i<row;++i,++graph)
     {
          graph->len=0;
          graph->data=idata++;
		  graph->mark=0;
          graph->front=NULL;
          graph->rear=NULL;
          for(k=0;k<row;++k,++tmp)
         {
               if(*tmp)
              {
                  post=(Post *)malloc(sizeof(Post));
                  post->preindex=i;
                  post->prev=NULL;
                  post->next=NULL;
                  post->index=k;
                  if(graph->len)
                 {
                       graph->rear->next=post;
                       post->prev=graph->rear;
                       graph->rear=post;
                   }
                  else
                 {
                       graph->front=post;
                       graph->rear=post;
                  }
                  ++graph->len;
               }
           }
      }
      for(graph=info->front,i=0;i<row;++i)
     {
          printf("��%d�нڵ���������:\n",i);
          post=graph[i].front;
          while(post)
         {
              printf("%d ,",post->index);
              post=post->next;
          }
          putchar('\n');
      }
      printf(".........................................\n");
     return  info;
  }
//��ջ������µ���(��?���� �롫
  void  addStack(StackInfo  *info,Post  *post)
 {
       Stack  *item=(Stack *)malloc(sizeof(Stack));
       item->post=post;
       item->next=NULL;
       if(info->len)
      {
           item->next=info->front;
           info->front=item;
       }
       else
      {
           info->front=item;
           info->rear=item;
       }
       ++info->len;
  }
//��ջ��ɾ����
  Post  *removeStack(StackInfo  *info)
 {
      Post   *post=NULL;
      Stack  *item;
      if(info->len)
     {
          item=info->front;
          info->front=item->next;
          --info->len;
          post=item->post;
          free(item);
      }
      return post;
  }

//���������������,����ͼ�е����йؽڵ�
  void  dfsnlow(int u,int v)
 {
       Post  *post;
       int    w;
       dfsn[u]=index;
       low[u]=index;
       ++index;
       for(post=ginfo->front[u].front;post;post=post->next)
      {
           w=post->index;
           if(dfsn[w]<0)
          {
                dfsnlow(w,u);
                low[u]=low[u]<low[w] ? low[u]:low[w];
           }
           else if(w!=v)
                low[u]=low[u]<dfsn[w]? low[u]:dfsn[w];
       }
       printf("�ڵ�%d��lowֵΪ%d,dfsnֵΪ%d\n",u,low[u],dfsn[u]);
  }
//�ͷ�ͼ�еĽڵ�
  void  releaseGraph(GraphInfo  *info)
 {
       Graph  *graph;
       Post   *post,*tmp;
       int   i;
       graph=info->front;
       for(i=0;i<info->len;++i)
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
  } 
//*****************************************
  int main(int argc,char *argv[])
 {
       printf("��ʼ����ʼ.....\n");
       ginfo=CreateGraphInfo((int *)mat,ROW_SIZE,IDATA);
       len=ROW_SIZE;
//       visited=(int *)malloc(sizeof(int)*ROW_SIZE);
       dfsn=(int *)malloc(sizeof(int)*ROW_SIZE);
       low=(int *)malloc(sizeof(int)*ROW_SIZE);
       prenode=(int *)malloc(sizeof(int)*ROW_SIZE);
    
       for(index=0;index<ROW_SIZE;++index)
      {
//           visited[index]=-1;
           dfsn[index]=-1;
           low[index]=-1;
           prenode[index]=-1;
       }
       index=0;
       printf("��ʼ����ͼ�Ĺؽڵ�...\n");
       dfsnlow(I_START,-1);
	   printf("--------------------------------------------------\n");
//�жϸ��ڵ��Ƿ�Ϊ�ؽڵ�
       is_root_artic(ginfo,I_START);
//��ʼ�ж������ڵ�
       judge_node(ginfo,I_START);
       releaseGraph(ginfo);
//       free(visited);
       free(dfsn);
       free(low);
       free(prenode);
       return 0;
  }
//�����������,�жϴӽڵ�����index���Ƿ��������������ϵ����������
  void  is_root_artic(GraphInfo  *info,int  root_index)
 {
      int     *visited;
      Graph   *graph;
      Post    *post,*tmp;
      StackInfo  *sinfo;
      int     i,index=0,mark=0;
      
      visited=(int *)malloc(sizeof(int)*info->len);
      for(i=0;i<info->len;++i)
         visited[i]=0;
      graph=info->front;
      sinfo=(StackInfo *)malloc(sizeof(StackInfo));
      sinfo->len=0;
      sinfo->front=NULL;
      sinfo->rear=NULL;
 
      printf("��ʼ�ӵ�%d��Ԫ�ؽ�����ȷ���:\n",root_index);
	    if(graph[root_index].len<=1)
     {
          printf("..���ڵ�%d����һ���ؽڵ�!\n",root_index);
		      return;
      }
//������ڵ������������������ϵĺ�̽ڵ㣬��ô�����ÿһ���ڵ����������������������
//���ʵ����ڵ㣬��ô������ڵ㽫ʹһ���ؽڵ�
      for(tmp=graph[root_index].front;tmp;tmp=tmp->next)
     {
           addStack(sinfo,tmp);
           post=tmp->next;
           while(post)
          {
               if(post->index!=root_index && post->preindex!=root_index)
                   addStack(sinfo,post);
               post=post->next;
           }
           while(sinfo->len)
          {
               post=removeStack(sinfo); 
               if(!visited[post->index])
              {
                   visited[post->index]=1;
                   post=graph[post->index].front;
                   while(post)
                  {
                       if(!visited[post->index])
                           addStack(sinfo,post);
                       post=post->next;
                   }
               }
               else if(post->index==root_index)
              {
                   printf("���ڵ�%d����һ���ؽڵ�\n",root_index);
                   return;
               }
          }
         for(i=0;i<info->len;++i)
             visited[i]=0;
         while(sinfo->len)
        {
             removeStack(sinfo);
         }
     }
     free(visited);
     printf("���ڵ�%d��һ���ؽڵ�!\n",root_index);
     printf("�ӵ�%d��������������!\n",root_index);
   }
//�ж������ڵ��Ƿ�Ϊ�ؽڵ�
  void  judge_node(GraphInfo  *info,int root_index)
 {
      int    *visited;
      Graph  *graph;
      StackInfo  *sinfo;
      Post   *post;
      int    index,k;
 
      index=root_index;
      sinfo=(StackInfo *)malloc(sizeof(StackInfo));
      sinfo->len=0;
      sinfo->front=NULL;
      sinfo->rear=NULL;
      graph=info->front;
      visited=(int *)malloc(sizeof(int)*info->len);
      for(k=0;k<info->len;++k)
          visited[k]=0;
      visited[root_index]=1;

      post=graph[root_index].rear;
      while(post)
     {
          addStack(sinfo,post);
          post=post->prev;
      }
      while(sinfo->len)
     {
           post=removeStack(sinfo);
           if(post->preindex!=root_index && !visited[post->preindex] && low[post->index]>=dfsn[post->preindex])
		   {
                 printf("�ڵ�%d��һ���ؽڵ�.\n",post->preindex);
				 graph[post->preindex].mark=1;
		    }
           else if(post->preindex!=root_index && visited[post->preindex] && !graph[post->preindex].mark && low[post->index]>=dfsn[post->preindex])
           {
                printf("�ڵ�%d��һ���ؽڵ�.\n",post->preindex);
				graph[post->preindex].mark=1;
		   }  
            visited[post->preindex]=1;
		    if(!visited[post->index])
			{
				post=graph[post->index].front;
                while(post)
				{
				     if(!visited[post->index])
					 {
			//			 printf("����ڵ�%dǰ��%d\n",post->index,post->preindex);
                         addStack(sinfo,post);
					 }
                     post=post->next;
				}
			}
      }
      free(visited);
      printf("���еĽڵ㶼�ж����!\n");
  }
      