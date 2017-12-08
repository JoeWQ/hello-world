//2013��4��20��10:30:32
//ʹ�ö�̬�滮���˫��ŷ���������������
/*
  *@note:������㷨����˼��������ȷ �ģ��������㷨�����Ǵ����
  *@date:2014-9-29
  */
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>
  #define    INF_TE   1e8

  typedef  struct  _Point
 {
         int         x;
         int         y;
  }Point;
//�� �㰴 x�����ֵ��������
  static  void  xadjust(Point *point,int parent,int size)
 {
       int     child=parent<<1;
       Point   key=point[parent];
      
       for(     ;child<=size; child<<=1  )
      {
               if(child<size && point[child].x<point[child+1].x)
                        ++child;
               if(key.x<point[child].x)
                       point[parent]=point[child];
               else
                       break;
               parent=child;
       }
       point[parent]=key;
  }
//����Ĺ���
  static  void  xheap_sort(Point *point,int size)
 {
       int      i;
       Point    key;

       for(i=size>>1;i>0 ;--i)
               xadjust(point,i,size);
//��������
       for(i=size;i>1;    )
      {
               key=point[1];
               point[1]=point[i];
               point[i]=key;

               xadjust(point,1,--i);
       }
  }
//˫��ŷ���������������
  float  distance(Point  *p,Point  *q)
 {
        int  x=p->x-q->x;
        int  y=p->y-q->y;
    
        return  (float)sqrt(x*x+y*y);
  }
// �㷨�ĺ���˼���� ��̬�滮
  float  double_ouclid_traval(Point  *point,int  n,float (*d)[12],float (*dist)[12])
 {
        int      i,k,u,p=0; 
        int      *parent=(int *)malloc(sizeof(int)*n);
        float    tmp=0,e;
//
//�����еĶ��㰴��x���������������
        for(i=0;i<n;++i)
             parent[i]=0;
        xheap_sort(point-1,n);
        k=n-1;
        for(i=0;i<k;++i)
       {
             dist[i][i]=0;
             for(u=i+1;u<n;++u)
                     dist[i][u]=distance(&point[i],&point[u]);
        }
//�����i��k���������(˫��������i--->0,�ٴ�0---->k,�ҶԲ�ͬ��kֵ��ѡȡ��ͬ�Ĳ���)
        d[1][0]=dist[0][1];
        d[0][0]=0;
        parent[1]=0;
        parent[0]=-1;
        for(i=2;i<n;++i)
       {
                for(k=0;k<=i;++k)
               {
                       if( k<i-1 )
                      {
                              d[i][k]=d[i-1][k]+dist[i-1][i];
                              parent[i]=i-1;
                       }
                       else if( k==i-1 )
                      {
                              tmp=INF_TE;
                              for(u=0;u<k;++u)
                             { 
                                    e=d[k][u]+dist[u][i];
                                    if(e<tmp)
                                   { 
                                          tmp=e;
                                          p=u;
                                    }
                              }
                              d[i][k]=tmp;
                              parent[i]=p;
                       }
//ֻ�����һ�Զ���(n-1,n-1)���м��㣬�������򲻱�Ҫ
                       else if(i==n-1 )
                      {
// ѡȡmin{d[n-1][u]+dist[u][n-1]}( 0=<u<n )
                              tmp=INF_TE;
                              for(u=0;u<i-1;++u)
                             {
                                     e=d[i-1][u]+dist[i-1][i]+dist[u][i];
                                     if( e<tmp )
                                    {
                                           tmp=e;
                                           p=u;
                                     }
                              }
                              d[i][i]=tmp;
                              parent[i]=p;
                         //     parent[i-1]=i;
                       }
                 }
          }
//
        for(i=0;i<n;++i)
              printf("%dǰ��Ϊ:%d\n",i,parent[i]);
        free(parent);
        return d[n-1][n-1];
  }
//
  int  main(int  argc,char *argv[])
 {
         float      xd[12][12];
         float      dist[12][12];
         Point       point[16]={{0,0},{2,3},{1,5},{5,2},{5,6},{7,1},{8,4}};
         int         size=7,i;

         float       e=double_ouclid_traval(point,size,xd,dist);

         printf("˫��ŷ����������� �����·��Ϊ: %f\n",e);
         printf("����� ���������Ϊ:\n");
         for(i=0;i<size;++i)
                printf("p[%d].x=%x .y=%d  \n",i,point[i].x,point[i].y);
         
         return 0;
  }
         