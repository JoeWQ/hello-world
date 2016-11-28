//2013��4��9��12:47:55
//��Դ��Ŀ������·���㷨
//������ǲ��� �Ͻ�˹�����㷨,���ǲ��õ��� ��С��ʵ��
  #include<stdio.h>
  #include<stdlib.h>
//��INF_T��ʾ����󣬱�ʾ�������㲻�ɴ�
  #define   INF_T   0x10000000

  typedef   struct  _VertexInfo
 {
         int       vertex;
//��¼vertex����ľ���
         int       disc;
  }VertexInfo;

//������С��
  static  void  adjust(VertexInfo  *info,int *rindex,int  parent,int  size)
 {
         int          child,index;
         VertexInfo   key;

         key=info[parent];
         index=rindex[parent];
         for(child=parent<<1;  child<=size ;    )
        {
                if(child<size && info[child].disc>info[child+1].disc)
                         ++child;
                if(key.disc>info[child].disc)
               {
                         info[parent]=info[child];
                         rindex[parent]=rindex[child];
                }
                else
                         break;
                parent=child;
                child<<=1;
         }
         rindex[parent]=index;
         info[parent]=key;
  }
//�Ը�����Ŀ����������������ֵ��ѵĶ�������
  static  void  bubble_fly(VertexInfo  *info,int *rindex,int  child)
 {
         int          parent,index;
         VertexInfo   key;

         key=info[child];
         index=rindex[child];
         for(parent=child>>1; parent>=1 ;    )
        {
                 if(info[parent].disc>key.disc)
                {
                         info[child]=info[parent];
                         rindex[child]=rindex[parent];
                 }
                 else
                         break;
                 child=parent;
                 parent>>=1;
         }
         info[child]=key;
         rindex[child]=index;
  }
//�ھ�̬����ʹ�ö�ά����ֱ��ʵ���ڽӾ���
  static  int  matrix[10][10];
  static  int   distance[10];
//����ͼ���ڽӾ����ʾ
  void  CreateAdjMatrix(int (*matx)[10],int *size)
 {
       int  i,j,weight,n;
       
       do
      {   
           n=-1;
           printf("������ͼ�Ķ�����(>=2 && <=10:\n");
           scanf("%d",&n);
       }while(n<1 || n>10);

       *size=n;
       for(i=0;i<n;++i)
          for(j=0;j<n;++j)
              matx[i][j]=INF_T;
 
       printf("�����붥���붥��֮���Ȩֵ,����1 2 3�ͱ�ʾ����1,2 ֮���ȨֵΪ3������-1 -1 -1��ʾ�˳�!\n");
       do
      {
             i=-1,j=-1,weight=-1;
             printf("�����붥���붥��Ȩֵ:\n");
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                 break;
             if(i<0 || i>=n || i==j || j<0 || j>=n || weight<0)
            {
                   printf("�Ƿ�������,��������������!\n");
                   continue;
             }
             printf("����%d-->%d ,weight:%d\n",i,j,weight);
             matx[i][j]=weight;
             matx[j][i]=weight;
      }while( 1 );
  }
//���㵥Դ��Ŀ������·��,distance��ʾ�洢��̾�������黺����,v��ʾԴ����
  void  ShortestPath(int (*matx)[10],int size,int v,int *distance)
 {
//rindex��¼��info�����У�����¼���ڵ�����
       int         *found,*rindex;
       int         i,j,cost,u=0;
       int         info_size=size;
       VertexInfo  *info;

       found=(int *)malloc(sizeof(int)*size);
       rindex=(int *)malloc(sizeof(int)*(size+1));
       info=(VertexInfo *)malloc(sizeof(VertexInfo)*(size+1));
       
       for(i=0;i<size;++i)
      {
              rindex[i]=i+1;
              found[i]=0;
//����i������v�ľ���
              distance[i]=matx[v][i];
       }
//ע������ĸ�ֵ���� һ��Ҫע������ȷ��
       distance[v]=0;
       for(i=1;i<=size;++i)
      {
              info[i].vertex=i-1;
              info[i].disc=distance[i-1];
       }
//�����ѽṹ
       for(i=info_size>>1;i>=1;--i)
              adjust(info,rindex,i,info_size);
/*
       for(i=1;i<=size;++i)
            printf("vertex:%d -->disc:%d  \n",info[i].vertex,info[i].disc);
       printf("\n");
       for(i=0;i<size;++i)
            printf("rindex:%d--->vertex %d \n",i,rindex[i]);
*/
       for(i=0;i<size-1;++i)
      {
//Ѱ����һ��·�������С�Ķ���u
              u=info[1].vertex;
              found[u]=1;
              info[1]=info[info_size];
              rindex[info[1].vertex]=1;
              adjust(info,rindex,1,--info_size);
//��������ڽӱ� ����ô��������������ʱ��������� �����һ�����͵� (V*lnV+E)
              for(j=0;j<size;++j)
             {
                  cost=matx[u][j];
//���costΪINF_T��ô�����С������Ͳ�����ͨ��
                  if(!found[j] && distance[u]+cost<distance[j])
                 {
                        distance[j]=distance[u]+cost;
                        v=rindex[j];
                        info[v].disc=distance[j];
//ע���������һ������
                        bubble_fly(info,rindex,v);
                  }
              }
       }
       free(info);
       free(rindex);
       free(found);
  }
//*********************************************************************************
  int  main(int argc,char *argv[])
 {
      int   size,i;
//
      printf("�����ڽӾ���...........\n");
      CreateAdjMatrix(matrix,&size);
      printf("����ͼ������С·��(�Ӷ���0��ʼ)...\n");
      ShortestPath(matrix,size,0,distance);
      for(i=0;i<size;++i)
     {
           if(distance[i]!=INF_T)
          {
                printf("����0--->%d  :%d\n",i,distance[i]);
           }
      }
      return 0;
  }