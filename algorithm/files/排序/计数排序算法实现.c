//**���������㷨��ʵ��
//2012/10/24/18:53

  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

  #define  RANGE      16
  #define  N_SIZE     16
  #define  BUF_SIZE   128

  int  tmp[BUF_SIZE];
  int  out[N_SIZE];
  int  in[N_SIZE];
/*ע�⣬���������ǻ��ڱȽϵ������㷨����������ʱ��Ľ�ΪO(n).
 *�����������÷�Χ�Ƚ�խ��һ�����ڹؼ��ַ�Χ�Ƚ�խ����Ԫ�ص���Ŀ�Ƚ��ٵ����,
 *��Ԫ����Ŀ�Ƚ϶������£����ڻ���������Ҫ�Ŀռ�Ƚϴ��Ҳ��ǽ���ԭ������
 *���ԶԸ��ٻ�������ò����ã����Ծ�����������ʱ����������Ƚ�С���ŵ㣬������
 *�ʺ����е������
 *���ʱ���Ӧ�ÿ������ö����򣬻������ù鲢�����ˡ�
 */
  void  CountSort(int *p,int n,int *out,int *tmp)
 {
      int  i,k,m;
      int  *ip=tmp;

//��������г�ʼ��
      for(i=0;i<n;++i,++ip)
           *ip=0;
//��ʼ����
      for(i=0;i<n;++i)
     {
          k=p[i];
          ++tmp[k];
      }
//����С��i��Ԫ�ص���Ŀ
      for(k=0,i=1;i<n;++i,++k)
          tmp[i]+=tmp[k];
      for(i=0;i<n;++i)
     {
           k=p[i];
           m=tmp[k];
           out[m-1]=k;
           --tmp[k];
      }
  }
//*********************************************************
  int  main(int argc,char *argv[])
 {
      int  i,seed;
      seed=time(NULL);
      srand(seed);
       
      for(i=0;i<N_SIZE;++i)
           in[i]=rand()%RANGE;
//���δ���������Ԫ��
      for(i=0;i<N_SIZE;++i)
          printf(" %d ",in[i]);

      printf("\n��ʼ���м�������\n");
      CountSort(in,N_SIZE,out,tmp);
      printf("����������е�Ԫ��������ʾ:\n");
      for(i=0;i<N_SIZE;++i)
          printf(" %d ",out[i]);
      printf("\n");
      return 0;
  }