//2013��4��11��9:53:35
//��̬����ķ���
  #include<stdio.h>
  #include<stdlib.h>

  int  main(int argc,char  *argv[])
 {
        int    i,j;
        int    row,col;
        int    **dlary;

        row=12;
        col=12;
//������̬����
        dlary=(int **)malloc(sizeof(int *)*row);
        for(i=0;i<row;++i)
              dlary[i]=(int *)malloc(sizeof(int)*col);
//����������ķ���
        for(i=0;i<row;++i)
       {
              for(j=0;j<col;++j)
                    dlary[i][j]=i+j;
        }
//�������
        for(i=0;i<row;++i)
       {
              for(j=0;j<col;++j)
                    printf(" %4d ",dlary[i][j]);
              printf("\n");
        }

        return 0;
  }