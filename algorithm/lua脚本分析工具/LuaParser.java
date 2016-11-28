/*
  *Lua�ű�������
  *2016-1-7 15:33:43
  */
  import      java.io.IOException;
  public     class      LuaParser
 {
               private      LuaLexer     lex;
               private      Token           look;
               public       LuaParser(LuaLexer   _lexer)throws   IOException
              {
                           this.lex=_lexer;
                           LuaLexer.Lines=1;
                           move();
               }
//�﷨����
               private      void       error(String    s)
              {
                            throw   new     Error("Syntax error:because of "+s+" in line "+LuaLexer.Lines);
               }
//����ķ�
               private     void       emit(String   s)
              {
                            FileManager.output.println(s);
               }
               public      void       move()throws   IOException
              {
                            look=lex.scan();
//                            System.out.println(look);
               }
//��һ�ʷ���ԪԤ��
               private      boolean      match(int     _type)throws  IOException
              {
                            if( _type != look.tag)
                                          error("want identifier "+(char)_type+" but gived is '"+look+"'");
                            move();
                            return   true;
               }
               public      void       program()throws  IOException
              {
                              this.tableHead();
                              this.tableContent();
                              this.tableTail();
               }
//��ͷ������
               private      void      tableHead()throws  IOException
              {
                            Token        _pretable=look;
                            StringBuilder     _build=new    StringBuilder();
                            
                            while(look.tag !='{' && look.tag != 0)
                           {
                                         _build.append(look);
                                         move();
                            }
//ĩβһ��ƥ���������,����Ϊ�﷨����
                            _build.append(look);
                            match('{');
                            this.emit(_build.toString());
               }
//�������
               private     void      tableContent()throws  IOException
              {
                             int            _index=1;//��ʼ����
                             while( look.tag == '['  )
                            {
                                           StringBuilder    _build=new    StringBuilder("    ");
                                           Token          _ltok=look;
                                           move();
                                           Token          _rtok=look;//Ϊ���ֻ�����������
                                           if( look.tag == Tag.NUM  )
                                          {
                                                       move();
                                                       _rtok=look;
                                           }
                                           match(']');//����Ϊ������ƥ��
                                           match('=');
                                           match('{');
                                           _build.append(_ltok);
                                           _build.append(_index);
                                           _build.append(_rtok);
                                           _build.append("=");
                                           _build.append("{").append("\n");
                                           while(look.tag == Tag.ID || look.tag == Tag.INDEX)
                                          {
                                                         _build.append("        ");
                                                         Token    _tok=look;
                                                         _build.append(look);
                                                         move();//������ʶ��
                                                         match('=');
                                                         _build.append("=");
//��ʱ�ٶ���ֵΪ����
                                                        if(_tok.tag==Tag.ID)
                                                                   _build.append(look);
                                                        else
                                                                   _build.append(_index);
                                                         if(look.tag != Tag.NUM && look.tag != Tag.FLOAT && look.tag != Tag.STRING)
                                                                        error("want  valid  data,but gived is '"+look+"'");
                                                         move();
                                                         if(look.tag == ',')
                                                        {
                                                                      _build.append(",");
                                                                      move();
                                                         }
                                                         _build.append("\n");
                                           }
                                           match('}');
                                           _build.append("    }");
                                           if(look.tag == ',')
                                          {
                                                         _build.append(",");
                                                         move();
                                           }
//                                           _build.append("\n");
                                           this.emit(_build.toString());
                                           ++_index;
                             }
               }
//���ĩβ
               private     void      tableTail()throws    IOException
              {
                            match('}');
                            this.emit("}\n");
               }
  }
  