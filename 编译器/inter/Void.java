/*
  *@aim:空表达式
  */
  package   inter;
  import     lexer.Type;
  
  public    class     Void     extends     Expr
 {
//全局只保留一个表达式,因为他什么也不做只作为一个标示而不用做空值判断,只用在无返回语句的Return类中
                public      static      final   Void    Null=new    Void();
                private      Void()
               {
                            super(Type.Void,Type.Void);
                }
                public     void     jumping(int  t,int  f)
               {
               
               }
               public      String     toString()
              {
                            return   "";
               }
  }