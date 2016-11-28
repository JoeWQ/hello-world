/*
  *@aim:char¿‡–Õ
  *@date:2015-10-23 17:18:30
  *@author:µ“Ω®±Ú
  */
  package    lexer;
  public    class    Char   extends    Token
 {
              public      final       char       value;
              public     Char(char   _value)
             {
                            super(Tag.CHAR);
                            this.value=_value;
              }
              public     String     toString()
             {
                           return   ""+value;
              }
  }