/*
  *@aim:关系运算符
  *@date:2015/10/7
  */
  package    inter;
  import     lexer.Token;
  import     lexer.Word;
  import     lexer.Type;
  
  public     class    Rel      extends     Logic
 {
 //             private       Expr      left;
//              private       Expr      right;
              public    Rel(Token    tok,Expr     _left,Expr   _right)
             {
                            super(tok,_left,_right);
 //                           this.left=_left;
 //                           this.right=_right;
 //                           if(_left.type !=Type.Bool || _right.type!=Type.Bool)
 //                                       error("Syntax error,no matched operator component:required bool ,but type is: "+_left.type+" and "+_right.type);
              }
//实现自己的类型检测函数
              public     Type       check(Type   p1,Type   p2)
             {
                           if( Type.isNumber(p1) && Type.isNumber(p2))
                                      return   Type.Bool;
                           if( p1==Type.Bool && p2==Type.Bool)
                                      return   Type.Bool;
                           return  null;
              }
//生成三地址代码
              public    Expr     gen()
             {
                           Temp    temp=new     Temp(type);
                           int         label=new_label();
                           int         after=new_label();
                           this.jumping(0,label);
                           emit(temp+"= true");
                           emit("jmp  "+after);
                           
                           emit_label(label);
                           emit(temp+"= false");
                           emit_label(after);
                           return  temp;
              }
              public    void     jumping(int   tport,int   fport)
             {
                           Expr   r1= left.reduce();
                           Expr   r2= right.reduce();
                           
                           String    test=r1.toString()+tok.toString()+r2.toString();
                           emit_jump(test,tport,fport);
              }
              public     Expr       reduce()
             {
                             return    new      Rel(this.tok,left.reduce(),right.reduce());
              }
              public     String     toString()
             {
                            return     left.toString()+" "+tok.toString()+" "+right.toString();
              }
  }