//2013��4��17��16:04:21
//��N�����п��ٲ���������,ʹ����������ʱ����ԴﵽO(N*lnN)��������
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>
  #include<time.h>

  #define   INF_TE    1e8
//
  typedef  struct  _Point
 {
       int        x;
       int        y;
  }Point;
static  float  cmp_points(Point  **ypoint,int  size);
//һ�����ƽ�������Ե��㷨
  int  generic_point_pair(Point  *point,int size)
 {
       int       i,k;
       int       x,y;
       float     dist,e;

       dist=(float)INF_TE;
       for(i=1;i<size;++i)
      {
               for(k=i+1;k<=size;++k)
              {
                       x=point[k].x-point[i].x;
                       y=point[k].y-point[i].y;
                       e=(float)sqrt(x*x+y*y);
                       if(e<dist)
                             dist=e;
               }
       }
       return  (int)dist;
  }
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
//�����갴��y�����������
  static  void  yadjust(Point  **point,int  parent,int  size)
 {
       int    child;
       Point  *key=point[parent];
 
       for(child=parent<<1;child<=size;     )
      {
              if(child<size && point[child]->y<point[child+1]->y)
                       ++child;
              if(key->y<point[child]->y)
                      point[parent]=point[child];
              else
                      break;
              parent=child;
              child<<=1;
       }
       point[parent]=key;
  }
//
  static  void  yheap_sort(Point  **point,int  size)
 {
       int    i;
       Point  *key;
 
       for(i=size>>1; i>0 ;--i)
               yadjust(point,i,size);
//����
       for(i=size;i>1;    )
      {
               key=point[1];
               point[1]=point[i];
               point[i]=key;

               yadjust(point,1,--i);
       }
  }
//�����ǿ�������С���֮�����Ĺ���
  int   fast_point_pair(Point  *point,int  size)
 {
//m����¼�ż����Ծ���Ŀ��
       int        i,k,m,n,j;
       int        x,y,mid;
       Point      **ypoint;
       float      *dist,theta=INF_TE,e,ret=INF_TE;
//dist��¼��ÿһ��������ĵ��֮�����С���롢�������������ÿ���Ҫ����һЩ
       dist=(float *)malloc(sizeof(float)*((size>>1)+1));
       ypoint=(Point **)malloc(sizeof(Point *)*(size+1));
//�Ե㰴x�����������
       xheap_sort(point,size);
//          printf("��ӡ���������:\n");
//          for(i=0;i<=size;++i)
//                  printf("%d  :x:%d ,  %d  \n",i,point[i].x,point[i].y);

//��һ��������ÿ�������ڵĵ�֮��ľ��룬����ÿ����ֻ����һ������
       for(i=1;i<size;i+=2)
      {
            x=point[i+1].x-point[i].x;
            y=point[i+1].y-point[i].y;
            dist[i>>1]=(float)(sqrt(x*x+y*y));
       }
//���size������
       if( size & 0x1 )
               dist[i>>1]=INF_TE;
//һ�µĹ��̵ĺ���˼���Ǻϲ����߳�Ϊ�鲢
//m��������Ҫ��������������ڵ� ����Ŀ��
       ypoint[0]=NULL;
       for(k=1,m=2;m<size;m<<=1,++k)
      {
              for(i=1;i<=size;i+=(m<<1))
             {
//������mid ���ں���
                    mid=i+m;
//���ʣ��ľֲ� �㲻�� һ����(���Ϊm)����Ͱ���ǰ������ĵ�ľ��� ǰ�ƣ�Ȼ��������ǰ���ڲ��� ѭ��
                    if(mid>size)
                   {
                           dist[i>>(k+1)]=dist[i>>k];
                           break;
                    }
                    x=i>>k;
                    theta=dist[x]<dist[x+1]?dist[x]:dist[x+1];
//ɸѡ�����㣬��������(point[mid].x-theta,theta+point[mid].x)��Χ�ĵ�ѡȡ����
                    x=(point[mid].x+point[mid-1].x)>>1;
                    y=x+1+(int)theta;
                    x-=(int)theta;
                    n=0;
                    for(j=mid-1; j>=i ;--j)
                   {
                            if(point[j].x>=x)
                                  ypoint[++n]=point+j;
                            else 
                                  break;
                    }
//�� mid�ұߵĵ�Ҳ���˵�ypoint������
                    j=mid;
                    mid+=m-1;
                    mid=(mid<=size)?mid:size;
                    for(    ; j<=mid ;   ++j)
                   {
                            if(point[j].x<=y)
                                  ypoint[++n]=point+j;
                            else
                                   break;
                    }
//                    printf("size:%d ,���߽�:Ϊ  %d  \n",size,mid);
//�����ǱȽϵĹ���
                    yheap_sort(ypoint,n);
                    e=cmp_points(ypoint,n);
                    if(e<theta)
                         theta=e;
//ע�������һ�����
                    dist[i>>(k+1)]=theta;
                    if(ret>theta)
                         ret=theta;
                }
       }
       free(ypoint);
       free(dist);
       return  (int)ret;
   }
//����size����Ե��������/ypoint�������Ѿ�����y�����ź����
   static  float  cmp_points(Point  **ypoint,int  size)
  {
          int      k,i,j;
          int      x,y;
          double    dist,e;

          dist=INF_TE;
//7���㣬���д������ܼ��ĵ����ʱ���������С�Ͻ磬���С������������ּ����Դ���
//         printf("size--n---->%d\n",size);
         for(i=1;i<size;++i)
        {
                 k=i+5<=size?(i+5):size;
                 for(j=i+1;j<=k;++j)
                {
                       x=ypoint[i]->x-ypoint[j]->x;
                       y=ypoint[i]->y-ypoint[j]->y;

                       if(!x && !y)
                      {
                            printf("i:%d,j:%d \n",i,j);
                            printf("i���� x:%d y:%d   ,j����x:%d ,y: %d \n",ypoint[i]->x,ypoint[i]->y,ypoint[j]->x,ypoint[j]->y);
                            e=sqrt(x*x+y*y);
                            if(e<dist)
                                 dist=e;
                            printf("e--> %lf ,dist--->%lf\n",e,dist);
                       }
                       e=sqrt(x*x+y*y);
                       if(  e<dist  )
                             dist=e;
                 }
          }
//         printf("cmp_points--->%lf\n",dist);
         return (float)dist;
  }
//����
  int  main(int  argc,char *argv[])
 {
          Point    point[129];
          int      size=124,i;
          int      dist;
          
          srand(time(NULL));
          point[0].x=0;
          point[0].y=0;
          for(i=1;i<=size;++i)
         {
                  point[i].x=rand();
                  point[i].y=rand();
          }
          printf("ʹ��һ��ļ��㷽��������������ľ���Ϊ:\n");
          dist=generic_point_pair(point,size);
          printf("%d\n",dist);

          printf("\nʹ�ÿ��ٵ�Է���������ľ���Ϊ:\n");
          dist=fast_point_pair(point,size);
          printf("%d\n",dist);

//          printf("��ӡ���������:\n");
//          for(i=0;i<=size;++i)
//                  printf("%d  :x:%d ,  %d  \n",i,point[i].x,point[i].y);

          return 0;
  }