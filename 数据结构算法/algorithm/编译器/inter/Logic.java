/*
  *@aim:�������ʽ��������
  *@date:2015/10/6
  */
  package    inter;
  import      lexer.Word;
  import      lexer.Type;
  import      lexer.Token;
  
  public     class    Logic    extends    Expr
 {
 //�����ӱ��ʽ
              protected    Expr       left;
              protected    Expr       right;
              
              public    Logic(Token   tok,Expr     _left,Expr   _right)
             {
                            super(tok,Type.Bool);
//���ͼ��
                            if( this.check(_left.type,_right.type) !=Type.Bool)
                                          error("syntax error,express type is not  boolean in  Logic.");
                            this.left=_left;
                            this.right=_right;
              }
//���ͼ��,��������Ը����Լ���ƫ����ʵ���������
              public     Type     check(Type   p1,Type   p2)
             {
                            if(p1!=Type.Bool || p2!=Type.Bool)
                                           return  null;
                            return   Type.Bool;
              }
//���ɲ����������
              public    Expr       gen()
             {
                            int       false_port=new_label();
                            int       after=new_label();
                            Temp   temp=new    Temp(this.type);
                            this.jumping(0,false_port);
                            emit(temp+"= true");
                            emit("jmp   L"+after);
                            emit_label(false_port);
                            emit(temp+"=false");
                            emit_label(after);
                            return   temp;
              }
              public      String     toString()
             {
                           return      left.toString()+" "+tok.toString()+" "+right.toString();
              }
  }