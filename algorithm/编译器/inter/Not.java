/*
  *@aim:ȡ�������
  *@date:2015/10/7
  */
  package    inter;
  
  import    lexer.Token;
  import    lexer.Word;
  import    lexer.Type;

  public    class    Not    extends    Logic
 {
//�������ʽ����һ��
              public    Not(Expr     expr)
             {
                          super(Word.not,expr,expr);
              }
//�򻯳ɳ���,����п���
              public    Expr       reduceConstant()
             {
                             Expr    _expr=this;
                             if( left instanceof   Not )
                                          _expr=((Not)left).left;
                             if( left   instanceof    Constant  )
                            {
                                          if( left==Constant.True)
                                                    return   Constant.False;
                                          else
                                                    return   Constant.True;
                             }
                             return   _expr;
              }
              public    Expr      reduce()
             {
                             if( left  instanceof   Not   )
                                       return     ((Not)left).left;
//����Է��ǲ�������,����Կ϶��ؾ�����������һ
                             if( left   instanceof    Constant  )
                            {
                                          if( left==Constant.True)
                                                    return   Constant.False;
                                          else
                                                    return   Constant.True;
                             }
                             return   this;
              }
//������תָ��
              public      void     jumping(int     tport,int  fport)
             {
                          this.left.jumping(fport,tport);
              }
              public     String     toString()
             {
                          return     this.tok.toString()+" "+this.left.toString();
              }
  }