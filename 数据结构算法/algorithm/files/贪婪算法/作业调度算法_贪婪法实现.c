//2013/1/3/14:09
//̰���㷨ʵ�ֵ���ҵ���ȣ�ע�⣬������ĵ��ȺͶ�̬�滮�еĵ��������ʵ�����
  #include<stdio.h>
  #include<stdlib.h>

  typedef  struct  _Greed_Job 
 {
//��ҵ��ʼ��ʱ��
        int   start;
//��ҵ������
        int   delay;
  }Greed_Job;
 
//��������ı����õ�ǰ���ǣ�job������������Ѿ�����delay���ź����
//job[0].delay=0,��job�ĳ���=n+1,bufΪҪд���Ŀ���ַ
  void  greed_job_select(Greed_Job  *job,int n,int  *buf)
 {
        int  i,k,m,size;
       
        k=1;
        m=1;
        i=1;
        size=0;
        while(  i<=n  )
       {
//ע������ȽϵĶ���
/*
             if(job[i].start>=job[m].delay)
            {
                   buf[k++]=i; 
                   m=i;
             }
*/
//ע���������һ�д���,��һ�д��벻��Ϊ�˶Ը������⣬����Ϊ�˶Ը�����һ��̰��ѡ�����ʵ�����
             if(size+job[i].start<=job[i].delay)
            {
                   buf[k++]=i;
                   size+=job[i].start;
                   m=i;
                  
             }
             ++i;
        }
        *buf=k-1;
  }
/***********************************************************************************/
  int  main(int argc,char *argv[])
 {
//ע�⣬���µ��������Ѿ��ź����(��.delay,.start����)
/*
        Greed_Job   job[12]={{0,0},{1,4},{3,5},{0,6},{5,7},{3,8},{5,9},{6,10},{8,11},{8,12},{2,13},{12,14}};
        int         size=11,i;
        int         vbuf[12]
*/
//�ڶ������ݲ���
        Greed_Job   job[12]={{0,0},{1,6},{3,6},{4,7},{5,9},{4,14},{3,14},{6,20},{7,20}};
        int         size=8,i;
        int         vbuf[12];
        printf("ʹ��̰����������ҵѡ��\n");
        greed_job_select(job,size,vbuf);
        size=vbuf[0];
        
        for(i=1;i<=size;++i)
            printf("  %d  ",vbuf[i]);
        printf("\n");
        return 0;
  }