

 //**�Զѽṹ�ķ�ʽչʾ���������*/
  void  display_deap(int *heap)
  {
	     int  len=*heap;
	     int  i,total;
         int  k,h;
//�������ĸ߶�
       h=0;
       k=*heap;
       while(k)
      {
           ++h;
           k>>=1;
       }
       k=1;
	     for(i=1;i<=len;)
	    {
	       	  total=(1<<(h-k))-3;
		        for(  ;total>0;--total)
		    	        printf(" ");
            total=1<<(k-1);
		        for( ;i<=len && total;--total,++i)
			            printf("%d ",heap[i]);
            ++k;
		        printf("\n");
	     }
  }