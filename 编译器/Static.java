
   public    class   Static
  {
                 public    static     final     Static   other;
                 static
               {
                               other=new   Static(2);
                }
                public    static     final     Static   s=new    Static(1);
                public     Static(int  i)
               {
                           System.out.println(i);
                }
                public     static   void       main(String[]   argv)
               {
                                 Static  s=new   Static(3);
                                 float     a=8.0f;
                                 float     b=7.0f;
                                 
                                 int        c=(int)(a*b);
                }
   }