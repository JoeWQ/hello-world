/*
  *@aim:�ձ��ʽ
  */
  package   inter;
  import     lexer.Type;
  
  public    class     Void     extends     Expr
 {
//ȫ��ֻ����һ�����ʽ,��Ϊ��ʲôҲ����ֻ��Ϊһ����ʾ����������ֵ�ж�,ֻ�����޷�������Return����
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