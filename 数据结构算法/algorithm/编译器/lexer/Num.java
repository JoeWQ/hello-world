/*
  *@instruction:整数词法单元
  */
   package     lexer;
   
   public    class    Num   extends    Token
  {
             public     final     int     value;
             
             public    Num(int    _value)
            {
                         super(Tag.NUM);
                         this.value=_value;
             }
             public    String    toString()
            {
                         return   ""+this.value;
             }
   }