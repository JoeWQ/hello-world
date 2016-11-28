//2012/12/15/15:10
//��Դ��Ŀ������·���㷨
//������ǲ��� �Ͻ�˹�����㷨,�������ڽӾ���ı�ʾ�У����ǲ����� ��һ���ϴ����������ʾ��������
//����ֱ������������������0����ʾ������㷨�ı����ĳЩ������Ҫ�޸�
//���ǣ��������޸ģ���ʹ����ı�����������
//�������Ƿ��֣�����˼·�ǲ��е�
  #include<stdio.h>
  #include<stdlib.h>
//��INF_T��ʾ����󣬱�ʾ�������㲻�ɴ�
  #define   INF_T   0x10000000

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
       int    *found;
       int    i,j,cost,u=0;
       int    n=size-1,min;

       found=(int *)malloc(sizeof(int)*size);
       for(i=0;i<size;++i)
      {
              found[i]=0;
//����i������v�ľ���
              distance[i]=matx[v][i];
       }

       found[v]=1;
       distance[v]=0;
 
       for(i=0;i<n;++i)
      {
//Ѱ����һ��·�������С�Ķ���u
              min=INF_T;
              for(j=0;j<size;++j)
             {
                    if(!found[j]  && min>distance[j])
                   {
                           min=distance[j];
                           u=j;
                    }
              }
              if(min==INF_T)
             {
                  printf("δ֪���쳣����!\n");
                  break;
              }
              found[u]=1;
              for(j=0;j<size;++j)
             {
                  cost=matx[u][j];
//���costΪINF_T��ô�����С������Ͳ�����ͨ��
                  if(!found[j] && distance[u]+cost<distance[j])
                 {
                        distance[j]=distance[u]+cost;
                  }
              }
       }
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