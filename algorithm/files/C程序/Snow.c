/*deskSnow.c -- 2008-05-01*/

#include <windows.h>
#include <math.h>
#define ID_TIMER     1
#define SNOWNUM      500   // 雪花数量
#define CONTRAST     50    // 对比度
#define YSTART       5     // 用于确定雪花初始时的y坐标
#define SNOWCR       RGB(0xFF, 0xFF, 0xFF) //雪花的颜色—白色
#define SNOWGATHERCR RGB(0xDB, 0xDB, 0xFF) //堆积雪花的颜色

typedef struct tagSnow
{
   POINT ptSnowsPos[SNOWNUM]; //用于保存各个雪花的坐标
   COLORREF crOrg[SNOWNUM]; //用于画雪花前屏幕原来的颜色
   int iVx, iVy, iAllVx, iAllVy;
   //iVx雪花的x飘动速度,iAllVx雪花总体水平飘行速度
}Snow;

void initSnow(HDC hdc, Snow *sn, int iSnow, int cxScreen); // 初始化雪花
int GetContrast(HDC hdc, Snow *sn, int iSnow); // 获取对比度
void drawSnow(HDC hdc, Snow *sn, int cxScreen); // 画雪花

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

        hwnd = CreateWindow (szAppName,        TEXT ("桌面下雪"),
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
      static int cxScreen, cyScreen; //屏幕宽高度(单位:像素)
      static int iTimes, iLoopTimes=100;
      static Snow snowDream;
      int i;

      switch (message)
      {
        case WM_CREATE:
             cxScreen = GetSystemMetrics (SM_CXSCREEN) ;
             cyScreen = GetSystemMetrics (SM_CYSCREEN) ;
             srand ((int) GetCurrentTime ()) ; //初始化随机数发生器
             snowDream.iAllVx = (unsigned)rand()%3 - 1; //雪花总体水平飘行速度(-1,0,1)
             snowDream.iAllVy = (unsigned)rand()%2 + 1; //雪花总体垂直下落速度(1,2)
             hdc = GetDC(NULL); //检索整个屏幕的设备上下文环境
             for(i=0; i<SNOWNUM; i++)
             {
                snowDream.ptSnowsPos[i].x = rand() % cxScreen; //一个雪花开始下落的x坐标
                snowDream.ptSnowsPos[i].y = rand() % YSTART; //一个雪花开始下落的y坐标
                snowDream.crOrg[i] = GetPixel(hdc, snowDream.ptSnowsPos[i].x,
                           snowDream.ptSnowsPos[i].y); //获取给定点的原来的颜色值
             }
             ReleaseDC(NULL, hdc);
             SetTimer(hwnd, ID_TIMER, 10, NULL); //定时器，10毫秒
             return 0 ;
             
        case WM_DISPLAYCHANGE: //当显示分辨率改变的时候
             cxScreen = GetSystemMetrics (SM_CXSCREEN) ;
             cyScreen = GetSystemMetrics (SM_CYSCREEN) ;
             return 0;
             
        case WM_TIMER:
             hdc = GetDC(NULL); //检索整个屏幕的设备上下文环境
             if(iTimes > iLoopTimes)
             {
                iTimes = 0;
                iLoopTimes = 50 + (unsigned)rand()%50;
                if(snowDream.iAllVx != 0)
                  snowDream.iAllVx = 0;
                else                  
                  snowDream.iAllVx = (unsigned)rand()%3 - 1; //雪花总体水平飘行速度(-1,0,1)
                snowDream.iAllVy = (unsigned)rand()%2 + 1; //雪花总体垂直下落速度(1,2)
             }
             else
                iTimes++;
             drawSnow(hdc, &snowDream, cxScreen);
             ReleaseDC(NULL, hdc);
             return 0;

        case WM_PAINT:
             hdc = BeginPaint (hwnd, &ps) ;
             GetClientRect (hwnd, &rect) ;
             DrawText (hdc, TEXT ("桌面下雪!"), -1, &rect,
                       DT_SINGLELINE | DT_CENTER | DT_VCENTER) ;
             EndPaint (hwnd, &ps) ;
             return 0 ;

        case WM_DESTROY:
             KillTimer(hwnd, ID_TIMER); // 中止定时器
             InvalidateRect(NULL, NULL, TRUE); // 刷新桌面
             PostQuitMessage (0) ;
             return 0 ;
        }
        return DefWindowProc (hwnd, message, wParam, lParam) ;
}

void initSnow(HDC hdc, Snow *sn, int iSnow, int cxScreen) //初始化第iSnow个雪花
{
   sn->ptSnowsPos[iSnow].x = (unsigned)rand() % cxScreen; //x范围整个屏幕宽
   sn->ptSnowsPos[iSnow].y = (unsigned)rand() % YSTART; //y范围离屏幕顶部YSTART像素点以内
   sn->crOrg[iSnow] = GetPixel(hdc, sn->ptSnowsPos[iSnow].x,
             sn->ptSnowsPos[iSnow].y ) ;//获取给定点的原来的颜色值
}

int GetContrast(HDC hdc, Snow *sn, int iSnow) 
{
   int iR, iG, iB;
   COLORREF crCmp;
   
   if(0 == sn->iVx) //若水平速度为0，则取比其大一个像素的正下方的点
     crCmp = GetPixel(hdc, sn->ptSnowsPos[iSnow].x, sn->ptSnowsPos[iSnow].y + 1);
   else //若水平速度>0，取右下方的点。<0则取左下方的点
     crCmp = GetPixel(hdc, sn->ptSnowsPos[iSnow].x + (sn->iVx>0?1:-1), sn->ptSnowsPos[iSnow].y + 1);

   if(crCmp==SNOWCR) //如果为雪花的颜色
     return 0;

   //分别获取crCmp与对比点的蓝、绿、红部分的差值
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
      //如果保存的原来的颜色不是雪花的颜色
      if(sn->crOrg[i] != SNOWCR)
        SetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y, 
           sn->crOrg[i]); //还原上一个位置的颜色

      sn->iVx = sn->iAllVx*(i%3+1); //雪花的x飘动速度
      sn->iVy = sn->iAllVy*(i%3+1); //雪花的y飘动速度
      //rand()%5-2使雪花下落的时候 有抖动效果
      sn->ptSnowsPos[i].x += sn->iVx+rand()%5-2; //雪花的下一个x坐标
      sn->ptSnowsPos[i].y += sn->iVy+1; //雪花的下一个y坐标

      //获取给定点的原来的颜色值
      sn->crOrg[i] = GetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y);
     
      if(CLR_INVALID == sn->crOrg[i]) //如果获取颜色失败,即雪花飘出了屏幕
      {
         initSnow(hdc, sn, i, cxScreen); //重新初始化 雪花
         continue;
      }
      if(sn->crOrg[i] != SNOWCR) //若当前点的颜色 不等于 雪花的颜色
      {
         if(SNOWGATHERCR == sn->crOrg[i]) //当前点的颜色=堆积的雪的颜色
      	 {  //设置为雪花的颜色
      	    SetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y, SNOWCR);
      	    sn->crOrg[i] = SNOWCR;
      	    //initSnow(hdc, sn, i, cxScreen); //重新初始化 雪花
      	 }
      	 else if(GetContrast(hdc, sn, i) > CONTRAST) //若对比度>CONTRAST
         {  //堆积雪花
            SetPixel(hdc, sn->ptSnowsPos[i].x,   sn->ptSnowsPos[i].y,   SNOWGATHERCR);
            SetPixel(hdc, sn->ptSnowsPos[i].x-1, sn->ptSnowsPos[i].y+1, SNOWGATHERCR);
            SetPixel(hdc, sn->ptSnowsPos[i].x+1, sn->ptSnowsPos[i].y+1, SNOWGATHERCR);
            initSnow(hdc, sn, i, cxScreen); //重新初始化 雪花
         }
         else //对比度<CONTRAST,不堆积,画出这帧雪花.等下次的时候再还原此点原本的颜色.以产生飘动效果
           SetPixel(hdc, sn->ptSnowsPos[i].x, sn->ptSnowsPos[i].y, SNOWCR);
      }
   }
}