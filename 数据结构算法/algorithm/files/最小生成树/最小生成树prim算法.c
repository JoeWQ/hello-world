//2013/1/22/18:44
//2013��1��22��18:52:54
//��С������de  Prim�㷨ʵ��
//�ڱ������У�Ϊ����������˼·����û��ʹ��쳲������ѣ���Ϊ���ǵ����ĸ�����
//���ң�����С��ģ��ͼ��Ҳ�����ʺ�
  #include<stdio.h>
  #include<stdlib.h>
  #include"�й�ͼ�����ݽṹ.h"
  #define   INT_F    0x70000000
/*************************************************/
  static  int  find_min(int *,int *,int);
//����ͼ���ڽӱ��ʾ,�����ڽӾ����ʾ��һ��ʵ�Գƾ���
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("������ͼ�Ķ�����Ŀ(>1 && <17)!\n");
       do
      {
             size=1;
             printf("���������Ҫ��Ķ�����:\n");
             scanf("%d",&size);
       }while(size<=1 || size>16);
       h->size=size;
       graph=(Graph *)malloc(sizeof(Graph)*size);
       h->graph=graph;
       for(i=0;i<size;++i,++graph)
      {
             graph->count=0;
             graph->v=0;
             graph->finish=0;
             graph->front=NULL;
       }
       graph=h->graph;
       printf("�����붥��֮��Ĺ��� (-1 -1)��ʾ�˳�!\n");
       do
      {
             printf("�����붥���붥��֮��Ĺ���:\n");
             i=j=0;
             weight=-1;
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                  break;
             if(i==j || i<0 || i>=size || j<0 || j>=size || weight<0)
            {
                    printf("�Ƿ�������!\n");
                    continue;
             }
             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=j;
             pst->vp=i;
             pst->weight=weight;
             pst->next=graph[i].front;
             graph[i].front=pst;
             ++graph[i].count;

             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=i;
             pst->vp=j;
             pst->weight=weight;
             pst->next=graph[j].front;
             graph[j].front=pst;

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
/********************��С��������prim�㷨***********************/
  void  min_span_tree_prim(GraphHeader  *h,int start)
 {
//��������¼ �����Ľ���Ƿ��Ѿ���ѡ����
       int        *tag,size;
//��¼���Ӧ������ ����Ӧ�ĸ����
       int        *parent,*key;
       Graph      *graph;
       PostGraph  *pst;
       int        i,k;
/*��ʼ����ʱ����*/
       size=h->size;
       tag=(int *)malloc(sizeof(int)*size);
       parent=(int *)malloc(sizeof(int)*size);
       key=(int *)malloc(sizeof(int)*size);
       graph=h->graph;
       pst=NULL;

       for(i=0;i<size;++i)
      {
             tag[i]=0;
             parent[i]=-1;
             key[i]=INT_F;
       }
//����ѭ���������� ��С��,�ӱ�ѡ�еĽ�㿪ʼ
       key[start]=0;
       for(i=1;i<size;++i)
      {
             k=find_min(tag,key,size);
             pst=graph[k].front;
//���� ����֮��ľ���
             for(  ; pst ;pst=pst->next)
            {
//�������û�б�ѡ�У����и�С��Ȩֵ���֣��͸���
/*ע���������㷨��˼�����ϣ����������ڵϽ�˹�����㷨*/
                     if(!tag[pst->vertex] && pst->weight<key[pst->vertex])
                    {
                             key[pst->vertex]=pst->weight;
                             parent[pst->vertex]=k;
                     }
             }
       }
//���������С������
       for(i=0;i<size;++i)
      {
            if(i!=start)
                printf(" ����%d--->%d: \n",i,parent[i]);
            else
                printf("������%d  \n",i);
       }
      free(key);
      free(parent);
      free(tag);
  }
  static  int  find_min(int *tag,int *key,int size)
 {
        int   i,k=0;
        int   min=INT_F;

        for(i=0;i<size;++i)
       {
//�������i��û�б�ѡ��,��������СȨֵ
              if(!tag[i] && min>key[i])
             {
                    min=key[i];
                    k=i;
              }
        }
        tag[k]=1;
        return k;
  }
//*********************************************
  int  main(int argc,char *argv[])
 {
       GraphHeader  hGraph,*h=&hGraph;
       printf("����ͼ���ڽӱ��ʾ:.............\n");
       CreateGraph(h);
     
       printf("****************������prim�㷨���ɵ���С������*****************************\n");
       min_span_tree_prim(h,0);
       return 0;
  }