/*deskSnow.c -- 2008-05-01*/

#include <windows.h>
#include <math.h>
#define ID_TIMER     1
#define SNOWNUM      500   // ѩ������
#define CONTRAST     50    // �Աȶ�
#define YSTART       5     // ����ȷ��ѩ����ʼʱ��y����
#define SNOWCR       RGB(0xFF, 0xFF, 0xFF) //ѩ������ɫ����ɫ
#define SNOWGATHERCR RGB(0xDB, 0xDB, 0xFF) //�ѻ�ѩ������ɫ

typedef struct tagSnow
{
   POINT ptSnowsPos[SNOWNUM]; //���ڱ������ѩ��������
   COLORREF crOrg[SNOWNUM]; //���ڻ�ѩ��ǰ��Ļԭ������ɫ
   int iVx, iVy, iAllVx, iAllVy;
   //iVxѩ����xƮ���ٶ�,iAllVxѩ������ˮƽƮ���ٶ�
}Snow;

void initSnow(HDC hdc, Snow *sn, int iSnow, int cxScreen); // ��ʼ��ѩ��
int GetContrast(HDC hdc, Snow *sn, int iSnow); // ��ȡ�Աȶ�
void drawSnow(HDC hdc, Snow *sn, int cxScreen); // ��ѩ��

LRESULT CALLBACK WndProc (HWND, UINT, WPARAM, LPARAM) ;
int main()
{
	WinMain(GetModuleHandle(NULL),NULL,NULL,SW_SHOWNORMAL);
	return 0;
}

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    PSTR szCmdLine, int iCmdShow)
{
        static TCHAR szAppName[] = TEXT ("clsDeskSnow") ;
        HWND             hwnd ;
        MSG             msg ;
        WNDCLASS     wndclass ;

        wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
        wndclass.lpfnWndProc   = WndProc ;
        wndclass.cbClsExtra    = 0 ;
        wndclass.cbWndExtra    = 0 ;
        wndclass.hInstance     = hInstance ;
        wndclass.hIcon         = LoadIcon (NULL, IDI_APPLICATION) ;
        wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
        wndclass.hbrBackground = (HBRUSH) GetStockObject (WHITE_BRUSH) ;
        wndclass.lpszMenuName  = NULL ;
        wndclass.lpszClassName = szAppName ;

        if(!RegisterClass (&wndclass))
        {
             MessageBox (NULL, TEXT ("This program requires Windows NT!"), szAppName, MB_ICONERROR) ;
             return 0;
        }

        hwnd = CreateWindow (szAppName,        TEXT ("������ѩ"),
                             WS_MINIMIZEBOX | WS_SYSMENU,
                             CW_USEDEFAULT, CW_USEDEFAULT,
                             240, 120,
                             NULL, NULL, hInstance, NULL) ;

        ShowWindow (hwnd, iCmdShow) ;
        UpdateWindow (hwnd) ;

        while (GetMessage (&msg, NULL, 0, 0))
        {
             TranslateMessage (&msg) ;
             DispatchMessage (&msg) ;
        }
        return msg.wParam ;
}

LRESULT CALLBACK WndProc (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
      HDC          hdc ;
      PAINTSTRUCT  ps ;
      RECT         rect ;
      static int cxScreen, cyScreen; //��Ļ��߶�(��λ:����)
      static int iTimes, iLoopTimes=100;
      static Snow snowDream;
      int i;

      switch (message)
      {
        case WM_CREATE:
             cxScreen = GetSystemMetrics (SM_CXSCREEN) ;
             cyScreen = GetSystemMetrics (SM_CYSCREEN) ;
             srand ((int) GetCurrentTime ()) ; //��ʼ�������������
             snowDream.iAllVx = (unsigned)rand()%3 - 1; //ѩ������ˮƽƮ���ٶ�(-1,0,1)
             snowDream.iAllVy = (unsigned)rand()%2 + 1; //ѩ�����崹ֱ�����ٶ�(1,2)
             hdc = GetDC(NULL); //����������Ļ���豸�����Ļ���
             for(i=0; i<SNOWNUM; i++)
             {
                snowDream.ptSnowsPos[i].x = rand() % cxScreen; //һ��ѩ����ʼ�����x����
                snowDream.ptSnowsPos[i].y = rand() % YSTART; //һ��ѩ����ʼ�����y����
                snowDream.crOrg[i] = GetPixel(hdc, snowDream.ptSnowsPos[i].x,
                           snowDream.ptSnowsPos[i].y); //��ȡ�������ԭ������ɫֵ
             }
             ReleaseDC(NULL, hdc);
             SetTimer(hwnd, ID_TIMER, 10, NULL); //��ʱ����10����
             return 0 ;
             
        case WM_DISPLAYCHANGE: //����ʾ�ֱ��ʸı��ʱ��
             cxScreen = GetSystemMetrics (SM_CXSCREEN) ;
             cyScreen = GetSystemMetrics (SM_CYSCREEN) ;
             return 0;
             
        case WM_TIMER:
             hdc = GetDC(NULL); //����������Ļ���豸�����Ļ���
             if(iTimes > iLoopTimes)
             {
                iTimes = 0;
                iLoopTimes = 50 + (unsigned)rand()%50;
                if(snowDream.iAllVx != 0)
                  snowDream.iAllVx = 0;
                else                  
                  snowDream.iAllVx = (unsigned)rand()%3 - 1; //ѩ������ˮƽƮ���ٶ�(-1,0,1)
                snowDream.iAllVy = (unsigned)rand()%2 + 1; //ѩ�����崹ֱ�����ٶ�(1,2)
             }
             else
                iTimes++;
             drawSnow(hdc, &snowDream, cxScreen);
             ReleaseDC(NULL, hdc);
             return 0;

        case WM_PAINT:
             hdc = BeginPaint (hwnd, &ps) ;
             GetClientRect (hwnd, &rect) ;
             DrawText (hdc, TEXT ("������ѩ!"), -1, &rect,
                       DT_SINGLELINE | DT_CENTER | DT_VCENTER) ;
             EndPaint (hwnd, &ps) ;
             return 0 ;

        case WM_DESTROY:
             KillTimer(hwnd, ID_TIMER); // ��ֹ��ʱ��
             InvalidateRect(NULL, NULL, TRUE); // ˢ������
             PostQuitMessage (0) ;
             return 0 ;
        }
        return DefWindowProc (hwnd, message, wParam, lParam) ;
}

void initSnow(HDC hdc, Snow *sn, int iSnow, int cxScreen) //��ʼ����iSnow��ѩ��
{
   sn->ptSnowsPos[iSnow].x = (unsigned)rand() % cxScreen; //x��Χ������Ļ��
   sn->ptSnowsPos[iSnow].y = (unsigned)rand() % YSTART; //y��Χ����Ļ����YSTART���ص�����
   sn->crOrg[iSnow] = GetPixel(hdc, sn->ptSnowsPos[iSnow].x,
             sn->ptSnowsPos[iSnow].y ) ;//��ȡ�������ԭ������ɫֵ
}

int GetContrast(HDC hdc, Snow *sn, int iSnow) 
{
   int iR, iG, iB;
   COLORREF crCmp;
   
   if(0 == sn->iVx) //��ˮƽ�ٶ�Ϊ0����ȡ�����һ�����ص����·��ĵ�
     crCmp = GetPixel(hdc, sn->ptSnowsPos[iSnow].x, sn->ptSnowsPos[iSnow].y + 1);
   else //��ˮƽ�ٶ�>0��ȡ���·��ĵ㡣<0��ȡ���·��ĵ�
     crCmp = GetPixel(hdc, sn->ptSnowsPos[iSnow].x + (sn->iVx>0?1:-1), sn->ptSnowsPos[iSnow].y + 1);

   if(crCmp==SNOWCR) //���Ϊѩ������ɫ
     return 0;

   //�ֱ��ȡcrCmp��Աȵ�������̡��첿�ֵĲ�ֵ
   iB = abs((crCmp>>16)&0xFF - (sn->crOrg[iSnow]>>16)&0xFF);
   iG = abs((crCmp>>8)&0xFF  - (sn->crOrg[iSnow]>>8)&0xFF);
   iR = abs((crCmp)&0xFF     - (sn->crOrg[iSnow])&0xFF);

   return (iR+iG+iB)/3;
}

void drawSnow(HDC hdc, Snow *sn, int cxScreen)
{
   int i;
   for(i=0; i<SNOWNUM; i++)
   {
      //��������ԭ������ɫ����ѩ������ɫ
      if(sn->crOrg[i] != SNOWCR)
        SetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y, 
           sn->crOrg[i]); //��ԭ��һ��λ�õ���ɫ

      sn->iVx = sn->iAllVx*(i%3+1); //ѩ����xƮ���ٶ�
      sn->iVy = sn->iAllVy*(i%3+1); //ѩ����yƮ���ٶ�
      //rand()%5-2ʹѩ�������ʱ�� �ж���Ч��
      sn->ptSnowsPos[i].x += sn->iVx+rand()%5-2; //ѩ������һ��x����
      sn->ptSnowsPos[i].y += sn->iVy+1; //ѩ������һ��y����

      //��ȡ�������ԭ������ɫֵ
      sn->crOrg[i] = GetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y);
     
      if(CLR_INVALID == sn->crOrg[i]) //�����ȡ��ɫʧ��,��ѩ��Ʈ������Ļ
      {
         initSnow(hdc, sn, i, cxScreen); //���³�ʼ�� ѩ��
         continue;
      }
      if(sn->crOrg[i] != SNOWCR) //����ǰ�����ɫ ������ ѩ������ɫ
      {
         if(SNOWGATHERCR == sn->crOrg[i]) //��ǰ�����ɫ=�ѻ���ѩ����ɫ
      	 {  //����Ϊѩ������ɫ
      	    SetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y, SNOWCR);
      	    sn->crOrg[i] = SNOWCR;
      	    //initSnow(hdc, sn, i, cxScreen); //���³�ʼ�� ѩ��
      	 }
      	 else if(GetContrast(hdc, sn, i) > CONTRAST) //���Աȶ�>CONTRAST
         {  //�ѻ�ѩ��
            SetPixel(hdc, sn->ptSnowsPos[i].x,   sn->ptSnowsPos[i].y,   SNOWGATHERCR);
            SetPixel(hdc, sn->ptSnowsPos[i].x-1, sn->ptSnowsPos[i].y+1, SNOWGATHERCR);
            SetPixel(hdc, sn->ptSnowsPos[i].x+1, sn->ptSnowsPos[i].y+1, SNOWGATHERCR);
            initSnow(hdc, sn, i, cxScreen); //���³�ʼ�� ѩ��
         }
         else //�Աȶ�<CONTRAST,���ѻ�,������֡ѩ��.���´ε�ʱ���ٻ�ԭ�˵�ԭ������ɫ.�Բ���Ʈ��Ч��
           SetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y, SNOWCR);
      }
   }
}