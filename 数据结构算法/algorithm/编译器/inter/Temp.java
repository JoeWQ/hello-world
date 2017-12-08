/*
  *@aim:临时变量
  *@date:2015/10/6
  */
  package     inter;
  import      lexer.Token;
  import      lexer.Type;
  import      lexer.Word;
  
  public     class    Temp  extends    Expr
 {
 //对临时变量进行计数
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