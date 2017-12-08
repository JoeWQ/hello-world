/*
  *@aim:取负值运算
  *@date:2015-10-19 19:00:47
  *@author:狄建彬
  */
  package     inter;
   import     lexer.Type;
   import     lexer.Word;
   import     lexer.Num;
   import     lexer.Float;
   import     lexer.Char;
   public      class      Neg     extends      Arith
 {
                public       Neg(Expr       _expr)
               {
                               super(Word.neg,_expr,_expr);
                }
                public     Expr       gen()
               {
                               return      new      Neg(this.left_expr.reduce());
                }
                public     Expr       reduceConstant()
               {
                              Expr     expr=this;
//第一种简化,是将两个连续的取负值合并
                              if( left_expr instanceof   Neg   )
                                          expr=((Neg)left_expr).left_expr;
                              else if(left_expr instanceof   Constant)
                             {
                                            if(left_expr.type==Type.Int )
                                                        expr=new    Constant(-((Num)left_expr.tok).value);
                                            else if(left_expr.type==Type.Float)
                                                        expr=new    Constant(-((Float)left_expr.tok).value);
                                            else if(left_expr.type==Type.Int)
                                                        expr=new   Constant(-((Char)left_expr.tok).value);
                              }
                              return    expr;
                }
                public     String    toString()
               {
                             return       this.tok+""+left_expr;
                }
  }