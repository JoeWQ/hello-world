/*
  *¸¡µãµ¥Ôª
  */
  public     class      Float     extends     Token
 {
              public      final      float       value;
              public      Float(float    _value)
             {
                          super(Tag.FLOAT);
                          this.value=_value;
              }
              public      String      toString()
             {
                          return   ""+value;
              }
  }