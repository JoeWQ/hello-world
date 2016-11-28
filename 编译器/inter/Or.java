/*
  *@aim:||�������
  *@date:2015/10/6
  */
  package    inter;
  import    lexer.Token;
  import    lexer.Type;
  import    lexer.Word;
  
  public    class    Or    extends    Logic
 {
//�����ӱ��ʽ
 //            private      Expr    left;
 //            private      Expr    right;
             
             public      Or(Token  tok,Expr    _left,Expr  _right)
            {
                          super(tok,_left,_right);
                          if( _left.type != Type.Bool || _right.type!=Type.Bool)
                                     error("syntax error,operator || does not have matched components.");
                          this.left=_left;
                          this.right=_right;
//                          System.out.println(" Or   Left expr:  "+_left+"   right expr:  "+_right);
             }
//������ת����,ע���������0�Ĵ���,true_port��false_port�����ϲ������
             public     void     jumping(int    true_port,int   false_port)
            {
                          int    label=true_port!=0?true_port:new_label();
                          this.left.jumping(label,0);
                          this.right.jumping(true_port,false_port);
//true port
                         if(true_port==0)
                                emit_label(label);
             }
  }