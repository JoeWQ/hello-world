/*
  *@aim:��ʱ����
  *@date:2015/10/6
  */
  package     inter;
  import      lexer.Token;
  import      lexer.Type;
  import      lexer.Word;
  
  public     class    Temp  extends    Expr
 {
 //����ʱ�������м���
            static          int           temp_count=0;
            private       int            label;
            
            public    Temp(Type   type)
           {
                      super(Word.temp,type);
                      label=++temp_count;
            }
            public      String     toString()
           {
                      return     "t"+label;
            }
  }