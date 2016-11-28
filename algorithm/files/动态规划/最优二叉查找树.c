//2012/12/28/14:04
//�������Ŷ��������
  #include<stdio.h>
  #include<stdlib.h>
/******************************************/
  #define   INF_T    0x30000000
//���������ά����ĺ�
  #define  GET_ARRAY(m,i,j,c)    *(m+(i)*c+(j))
  #define  SET_ARRAY(m,i,j,c,s)    *(m+(i)*c+(j))=(s)
/*********************************************************/
//�����ĺ���:p��Ȩֵ(ÿ�ֹؼ��ֵĲ��Ҹ���)�����鼯�ϣ�q�������(�����ڵ���ֵ�ĸ���)�����鼯��,Ϊ�˱��⸡��Ĳ���ȷ
//���������������������

//n�����������p�ĳ��ȣ�q�ĳ��ȵ�(n+1)
//�������Ŷ��������
  void  optimal_bin_tree(int  *p,int *q,int n)
 {
       int    *w,*e,*root;
       int    size=n+1;
       int    i,j,k,lc;
       int    le,le2,t;
//ע������ʹ��һά��������˶�ά����
       w=(int *)malloc(sizeof(int)*(size*size));
       e=(int *)malloc(sizeof(int)*(size*size));
       root=(int *)malloc(sizeof(int)*(size*size));
       
       for(i=1;i<=n;++i)
      {
            j=q[i-1];
            SET_ARRAY(w,i,i-1,size,j);
            SET_ARRAY(e,i,i-1,size,j);
       }
//ע���������һ��,�����������Ҫ
       --p;
//�Ӵӳ���1��ʼ��ֱ��n
       for(le=1;le<=n;++le)
      {
            le2=n-le+1;
            for(i=1;i<=le2;++i)
           {
                  j=i+le-1;
                  k=GET_ARRAY(w,i,j-1,size);
                  SET_ARRAY(w,i,j,size,k+p[j]+q[j]);
                  SET_ARRAY(e,i,j,size,INF_T);
                  t=GET_ARRAY(w,i,j,size,);
                  for(k=i;k<=j;++k)
                 {
                        lc=GET_ARRAY(e,i,k-1,size)+GET_ARRAY(e,k+1,j,size)+t;
                        if(lc<GET_ARRAY(e,i,j,size))
                       {
                              SET_ARRAY(e,i,j,size,lc);
                              SET_ARRAY(root,i,j,size,k);
                        }
                  }
            }
       }
//��һ����ʼ����
       for(i=1;i<=n;++i)
      {
           printf("��%d�� :\n",i);
           for(j=i;j<=n;++j)
                 printf(" %d ",GET_ARRAY(root,i,j,size));
           printf(" \n");
       }
       free(w);
       free(e);
       free(root);
   }
/********************************************************/
  int  main(int argc,char *argv[])
 {
        int  p[5]={15,10,5,10,20};
        int  q[6]={5,10,5,5,5,10};

        printf("���Ŷ��������:\n");
        optimal_bin_tree(p,q,5);
        return 0;
  }
        