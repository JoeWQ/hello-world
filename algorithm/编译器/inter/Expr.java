/*
  *@aim:���ʽ
  *@date:2015/10/6
  */
  package    inter;
  import    tool.FileManager;
  import    lexer.Token;
  import    lexer.Type;
 
  public    class    Expr   extends   Node
 {
 //������ʽ����������������������,���������ղ�����ֵ������
               Token           tok;
               Type             type;
//
               public    Expr(Token   _tok,Type   _type)
              {
                            this.tok=_tok;
                            this.type=_type;
               }
//��������ַ����,��Ϊ�ڱ����ʽ�ļ�����,����������������ԭ�ӵ�,����ֻ��Ҫ���ض�����Ϳ���
               public      Expr        gen()
              {
                            return    this;
               }
//��Լ,���ڽ����ʽ��Լ�ɵ�һ���������,����Ϊ����������Ϊ��ʱ��������Ϊһ����ʶ��
               public     Expr         reduce()
              {
                            return     this;
               }
//ת��Ϊ����,���ڱ���ʱ����,�������ѡ����ʵ�ָ÷���,ע��˺��������ټ����ڼ�����κε����
               public    Expr          reduceConstant()
              {
                           return    this;
               }
//������ת����
//true_port:���ʽ����ֵ����
//false_port:���ʽ�ļ�ֵ����
//0��ʾƽ������
//test:�ж�����
               public     void       jumping(int    true_port,int   false_port)
              {
                             emit_jump(toString(),true_port,false_port);
               }
               public     void       emit_jump(String  test,int    true_port,int    false_port)
              {
                           if( true_port!=0 && false_port!=0 )
                          {
                                         emit("if \t"+test+"\tL"+true_port);
                                         emit("jmp  L"+false_port);
                           }
                           else if( true_port !=0 )
                                         emit("if\t"+test+"\t jmp L"+true_port);
                           else if(false_port !=0)
                                         emit("iffalse\t"+test+"\t jmp L"+false_port);
//����ʲôҲ������
               }
               public      String    toString()
              {
                           return       tok.toString();
               }
  }