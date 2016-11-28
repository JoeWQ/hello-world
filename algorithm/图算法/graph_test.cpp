/*
  *@aim:ÕºÀ„∑®≤‚ ‘
  *@date2014-11-1 16:52:00
  */
  #include"CGraph.h"
  #include"Array.h"
  #include<stdio.h>
  #include<stdlib.h>
//
  #define     infinite       0x37777777

  int    main(int    argc,char   *argv[] )
 {
           int    adj[5][5]={
                                       {0,1,0,0,0},
                                       {0,0,1,0,0},
                                       {0,0,0,1,0},
                                       {0,0,0,0,1},
                                       {0,1,0,0,0}
                                 };
           int      size=5;
           int      i,j;
           Array      garray(size,size),*y=&garray;
           for(i=0;i<size;++i)
                 for(j=0;j<size;++j)
                          y->set(i,j,adj[i][j]);
           y->setInvalideValue( 0 );
//
           CGraph     graph(y),*g=&graph;
//
           int            trace[size];
           int       cycle=g->topologicSort(trace);
           if( cycle > 0 )
          {
                      printf("trace is :\n");
                      for(i=0;i<cycle;++i)
                            printf("%d  ",trace[i]);
                      putchar('\n');
           }
           else
                       printf("Sorry , there is some cycle in graph !\n");
           return  0;
  }    
