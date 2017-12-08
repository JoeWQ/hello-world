/*
  *@aim:do-while循环
  *@date:2015-10-07 11:12:36
  */
  package    inter;
  import    lexer.Type;
  
  public    class    Do   extends    Stamt
 {
             private       Expr      expr;
             private       Stamt    stamt;
             
             public     Do()
            {
             }
             public     void   init(Expr    _expr,Stamt   _stamt)
            {
                          this.expr=_expr;
                          this.stamt=_stamt;
                          if(_expr.type != Type.Bool)
                                   error("syntax error in 'do' ,caused by no matched express type.");
 //                         System.out.println("_exp:"+_expr);
             }
//生成代码
            public    void    gen(int  _after,int  _before)
           {
//注意生成的前驱代码
                          this.after=_after;

                          int    label=new_label();
                          this.before=label;//continue语句需要跳转到布尔表达式计算处而不是整个循环体的开始

                          stamt.gen(label,_before);
                          emit_label(label);
                          
                          expr.jumping(_before,0);
            }   
  }