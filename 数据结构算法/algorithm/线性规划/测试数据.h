                 float                    coefficient[6][6]={
                                                          {0,0,0,1,1,3},{0,0,0,2,2,5},{0,0,0,4,1,2}
                                                };
//�ɳڱ��ʽ��ϵ������
                 float                    relaxConstants[6]={30,24,36};
//Ŀ�꺯��
                 float                    objectFunc[6]={0,0,0,3,1,2};
                 float                    objectConstant=0.0f;
//������������
                 int                       basicVariable[3]={0,1,2};
//�ǻ�����������
                 int                       nonbasicVariable[3]={3,4,5};
//******************************************************************                 
//ϵ������,ע�������ɳ���ϵ��
                 const                  int                       size=5;
                 float                    coefficient[5][5]={
                                                          {0,0,1,1,0},{0,0,0,-1,1}
                                                };
//�ɳڱ��ʽ��ϵ������
                 float                    relaxConstants[5]={8,0};
//Ŀ�꺯��
                 float                    objectFunc[5]={0,0,1,1,1};
                 float                    objectConstant=0.0f;
//������������
                 int                       variableSize=2;
                 int                       basicVariable[2]={0,1};
//�ǻ�����������
                 int                       nonVariableSize=3;
                 int                       nonbasicVariable[3]={2,3,4};