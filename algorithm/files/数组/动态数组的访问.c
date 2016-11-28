//2013年4月11日9:53:35
//动态数组的访问
  #include<stdio.h>
  #include<stdlib.h>

  int  main(int argc,char  *argv[])
 {
        int    i,j;
        int    row,col;
        int    **dlary;

        row=12;
        col=12;
//建立动态数组
        dlary=(int **)malloc(sizeof(int *)*row);
        for(i=0;i<row;++i)
              dlary[i]=(int *)malloc(sizeof(int)*col);
//下面是数组的访问
        for(i=0;i<row;++i)
       {
              for(j=0;j<col;++j)
                    dlary[i][j]=i+j;
        }
//产生输出
        for(i=0;i<row;++i)
       {
              for(j=0;j<col;++j)
                    printf(" %4d ",dlary[i][j]);
              printf("\n");
        }

        return 0;
  }