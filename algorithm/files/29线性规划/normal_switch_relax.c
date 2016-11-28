//2013��3��20��19:55:10
//��������
    static  void  operate_and_move_data(Linear  *p);
    static  int  solve_new_exp(Linear  *p);
    static  void  operate_relax_exp(Linear  *p );
//���Թ滮����׼��ת��Ϊ�ɳ���,���ɹ�������1��ʧ�ܷ���0
  int   formal_to_relax_type(Linear   *p)
 {
         int  i,j,k;
         int  min;
         double   e;
         double  (*ma)[10]=p->ma,*exp,*save;
//���ԭ�������Թ滮�е���С����ֵ

         e=E_INF;
         k=0;
         for(i=0;i<p->bsize;++i)  //p->bsizeΪ���̵ĸ���
        {
               if(e>p->bcst[i])
              {
                      k=i;
                      e=p->bcst[i];
               }
         }
         if(e>0)    //��ʱ����Ϊ���еĳ���������0�������ھ������ݵ��ƶ���Ϳ���ֱ�ӷ���1
        {
               operate_and_move_data(p);
               return 1;
         }
         min=k;
//�����ԭ���ı�׼���к��и��������ͽ���ת������һ�ֺ����ȼ۵���ʽ
         k=p->bsize+p->nsize+1;
         exp=(double  *)malloc(sizeof(double)*k);
         for(i=0;i<k;++i)
              exp[i]=0;
         exp[k-1]=-1;
//��ԭ�����ʽ�б�������
         save=p->aimc;
         p->aimc=exp;
//�����µ��ɳ���
//��ϵ�������������µ���,֮��ת������
         operate_and_move_data(p);
         p->nbase[p->nsize]=k-1;
         p->nsize+=1;
         for(i=0;i<p->bsize;++i)
        {
               j=p->base[i];
               ma[j][k-1]=-1;
         }
//ѡȡ�µ���Ԫ
//����ѡȡ��Сֵ
         min+=p->bsize;
         printf("\nmin:%d  \n",min);
         pivot(p,k-1,min);
         print_relax_type(p);
         printf("\n****************************************\n");
//�������ɵ��ɳڱ��ʽ�������
         if( !solve_new_exp(p) )
        {
                p->aimc=save;
                free(exp);
                return 0;
         }
         printf("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
         print_relax_type(p);
         printf("\n****************************************\n");
//�鿴���յ���⼯��
         j=0;
         for(i=0;i<p->nsize;++i)
        {
                if(p->nbase[i]==(k-1))//��� k-1 ��һ���ǻ���������ô�������յ�ֵһ��Ϊ0
               {
//��ʱ �Ϳ����ٴν���ת����
                     j=1;
                     break;
                }
         }
         free(exp);
         p->aimc=save;
         if( ! j )
        {
                printf("������Թ滮�޿��н�!\n");
                return 0;
         }
//ת��ԭ�����ɳ��͵�Ŀ����ʽ
         operate_relax_exp(p);
//�� (k-1)ɾ����
         for(i=0;i<p->nsize;++i)
        {
              if(p->nbase[i]==(k-1))
                     break;
         }
         for(++i;i<p->nsize;++i)
                  p->nbase[i-1]=p->nbase[i];
         --p->nsize;
         return 1;     
  }
  static  void  operate_and_move_data(Linear  *p)
 {
         int   i,j,k;
		     double  (*ma)[10]=p->ma;
//���ӻ�����  && �����ƶ������е�����
         for(i=0;i<p->bsize;++i)
        {
               j=p->bsize+i;
               p->base[i]=p->nsize+i;
               p->bcst[j]=p->bcst[i];
               for(k=0;k<p->nsize;++k)
                     ma[j][k]=ma[i][k];
         }
  }
//���������ɳ���
  static  int  solve_new_exp(Linear  *p)
 {
         int      max,i,k;
         double   e,*limit;
         double   (*ma)[10]=p->ma;
         limit=(double *)malloc(sizeof(double)*p->bsize);
 
         while( judge_const(p,&max) )
        {
                for(i=0;i<p->bsize;++i)
               {
                       k=p->base[i];
                       e=ma[k][max];
                       if( e>0 )
                             limit[i]=p->bcst[k]/e;
                       else
                             limit[i]=E_INF;
                }
     //������СԪ��
                e=E_INF;
                k=0;
                for(i=0;i<p->bsize;++i)
               {
                       if( e>limit[i] )
                      {
                             e=limit[i];
                             k=p->base[i];
                       }
                }
                if( e==E_INF )
               {
                        printf("������Թ滮���޽��!\n");
                        free(limit);
                        return 0;
                }
                else
                        pivot(p,max,k);
         }
         free(limit);
         return 1;
  }
//���������ɳڱ��ʽ��Ŀ�꺯��
  static  void  operate_relax_exp(Linear  *p )
 {
         int  k=p->nsize-1;
         int  i,j,m,n;
         double   e;
         double  (*ma)[10]=p->ma;

//�ȶԱ��ʽ���д���
         for(i=0;i<p->bsize;++i)
        {
//������ʽ�������������ͽ���������
                j=p->base[i];
                if(j<k && p->aimc[j]!=0)
               {
//���³�����
                       e=p->aimc[j];
                       p->v+=p->bcst[j]*e;
//����Ŀ����ʽ�зǻ�������ϵ��,���� j �б��ʽ����
                       for(m=0;m<p->nsize;++m)
                      {
                             n=p->nbase[m];
                             p->aimc[n]-=ma[j][n]* e;
                       }
                }
         }       
  }