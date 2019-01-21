#include <windows.h>
#include <stdlib.h>
#define null 0
#define SNOWNUM  128
#define TIMER_ID   0x1000
#define CONTRAST   50
#define SNOWCR     0xFFFFFF
#define SNOWGATHERCR  0xDBDBFF
#define YSTART     0x06
#define ICON_MAIN  0x100
#define IDC_CUR   0x200
#define ID_SNOW   0x300
#define TYPE_Y    0x0
#define TYPE_X    0x1

typedef struct _LOCAL
{
	POINT   p0;
	POINT   p1;
	POINT   p2;
	POINT   p3;
	COLORREF cr0;
	COLORREF cr1;
	COLORREF cr2;
	COLORREF cr3;
}  LOCAL;

typedef  struct  _Snow
{
	LOCAL Ysnow[SNOWNUM];
	LOCAL Xsnow[SNOWNUM];
	int iVAllx;
	int iVAlly;
	int iVx;
	int iVy;
	int iSx;
	int iSy;
	}Snow;
Snow  snow;
int  cxScreen;
int  cyScreen;
void initSnow(HDC hdc,Snow *sn,int index,int type);
int  GetContrast(HDC hdc,Snow *sn,int index,int type);
void drawSnow(HDC  hdc);
int ffabs(int e);
LRESULT CALLBACK WinMainProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam);

int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance,PSTR szCmd,int iCmd)
{

    MSG  msg;
	WNDCLASSEX  WndClass;
	HWND  hWnd;
	static TCHAR pName[]=TEXT("Hello !小花熊!");
	static TCHAR pCaption[]=TEXT("雪花程序 !");
	TCHAR   pError[]=TEXT("程序初始化错误 !");
	TCHAR   pTitle[]=TEXT("提示");
    
	WndClass.style=CS_HREDRAW|CS_VREDRAW;
	WndClass.lpfnWndProc=WinMainProc;
	WndClass.cbClsExtra=0;
	WndClass.cbWndExtra=0;
	WndClass.lpszMenuName=0;
	WndClass.cbSize=sizeof(WNDCLASSEX);
	WndClass.hInstance=GetModuleHandle(null);
	WndClass.lpszClassName=pName;
	WndClass.hCursor=LoadCursor(NULL,IDC_ARROW);
	WndClass.hbrBackground=(HBRUSH)GetStockObject(WHITE_BRUSH);
	WndClass.hIconSm=LoadIcon(NULL,IDI_APPLICATION);
	WndClass.hIcon=0;

    if(!RegisterClassEx(&WndClass))
	{
		MessageBox(null,TEXT("程序初始化错误!"),TEXT("提示!"),MB_OK |MB_ICONERROR);
		return 0;
	}
	hWnd=CreateWindowEx(WS_EX_CLIENTEDGE,pName,pCaption,WS_OVERLAPPEDWINDOW,240,120,280,180,null,null,hInstance,null);
	ShowWindow(hWnd,SW_SHOWNORMAL);
	UpdateWindow(hWnd);
	while(GetMessage(&msg,null,0,0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return 0;
}
LRESULT CALLBACK WinMainProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
	HDC hdc;
    static  int iTimes=0;
	static  int iLoopTimes=64;
	int ii=0;
	int ix=0;
	int iy=0;
    
	switch(uMsg)
	{
	case WM_CREATE:

		cxScreen=GetSystemMetrics(SM_CXSCREEN);
		cyScreen=GetSystemMetrics(SM_CYSCREEN);
        srand((unsigned int)GetTickCount());
        snow.iVAllx=(unsigned)rand()%3-1;
		snow.iVAlly=(unsigned)rand()%2+1;
		hdc=GetDC(null);
		for(ii=0;ii<SNOWNUM;++ii)
		{
			ix=rand()%cxScreen;
			snow.Ysnow[ii].p2.x=ix;	
	    	iy=rand()%YSTART;
			snow.Ysnow[ii].p2.y=iy;
			snow.Ysnow[ii].p0.x=ix-1;
			snow.Ysnow[ii].p0.y=iy-1;
			snow.Ysnow[ii].p1.x=ix+1;
			snow.Ysnow[ii].p1.y=iy-1;
			snow.Ysnow[ii].p3.x=ix;
			snow.Ysnow[ii].p3.y=iy+1;
            snow.Ysnow[ii].cr0=GetPixel(hdc,snow.Ysnow[ii].p0.x,snow.Ysnow[ii].p0.y);
			snow.Ysnow[ii].cr1=GetPixel(hdc,snow.Ysnow[ii].p1.x,snow.Ysnow[ii].p1.y);
			snow.Ysnow[ii].cr2=GetPixel(hdc,snow.Ysnow[ii].p2.x,snow.Ysnow[ii].p2.y);
			snow.Ysnow[ii].cr3=GetPixel(hdc,snow.Ysnow[ii].p3.x,snow.Ysnow[ii].p3.y);
            ix=rand()%cxScreen;
			iy=rand()%YSTART;
			snow.Xsnow[ii].p0.x=ix;
			snow.Xsnow[ii].p0.y=iy;
			snow.Xsnow[ii].p1.x=ix+2;
			snow.Xsnow[ii].p1.y=iy;
			snow.Xsnow[ii].p2.x=ix;
			snow.Xsnow[ii].p2.y=iy+2;
			snow.Xsnow[ii].p3.x=ix+2;
			snow.Xsnow[ii].p3.y=iy+2;
			snow.Xsnow[ii].cr0=GetPixel(hdc,snow.Xsnow[ii].p0.x,snow.Xsnow[ii].p0.y);
			snow.Xsnow[ii].cr1=GetPixel(hdc,snow.Xsnow[ii].p1.x,snow.Xsnow[ii].p1.y);
			snow.Xsnow[ii].cr2=GetPixel(hdc,snow.Xsnow[ii].p2.x,snow.Xsnow[ii].p2.y);
			snow.Xsnow[ii].cr3=GetPixel(hdc,snow.Xsnow[ii].p3.x,snow.Xsnow[ii].p3.y);
		}
	    ReleaseDC(null,hdc);
	   	SetTimer(hWnd,TIMER_ID,10,null);
		return 0;
	case WM_DISPLAYCHANGE:
		cxScreen=GetSystemMetrics(SM_CXSCREEN);
		cyScreen=GetSystemMetrics(SM_CYSCREEN);
		return 0;
	case WM_TIMER:
		hdc=GetDC(null);
		if(iTimes>=iLoopTimes)
		{
			iTimes=0;
			iLoopTimes=(unsigned)rand()%32+32;
			if(!snow.iVAllx)
				snow.iVAllx=(unsigned)rand()%3-1;
			else
			    snow.iVAllx=0;
			snow.iVAlly=(unsigned)rand()%2+1;
		}
		else
			++iTimes;
		drawSnow(hdc);
		ReleaseDC(null,hdc);
		return 0;
	case WM_CLOSE:
		DestroyWindow(hWnd);
		KillTimer(hWnd,TIMER_ID);
		PostQuitMessage(null);
		InvalidateRect(null,null,TRUE);
        return 0;
	}
	return DefWindowProc(hWnd,uMsg,wParam,lParam);
}
void drawSnow(HDC hdc)
{
    int ii=0;
	int iYx=0;
	int iYy=0;
	int iXx=0;
	int iXy=0;
	COLORREF crY=0;
	COLORREF crX=0;
	int Yflag=1;
	int Xflag=1;
	for(ii=0;ii<SNOWNUM;++ii)
	{
    	SetPixel(hdc,snow.Ysnow[ii].p0.x,snow.Ysnow[ii].p0.y,snow.Ysnow[ii].cr0);
		SetPixel(hdc,snow.Ysnow[ii].p1.x,snow.Ysnow[ii].p1.y,snow.Ysnow[ii].cr1);
		SetPixel(hdc,snow.Ysnow[ii].p2.x,snow.Ysnow[ii].p2.y,snow.Ysnow[ii].cr2);
		SetPixel(hdc,snow.Ysnow[ii].p3.x,snow.Ysnow[ii].p3.y,snow.Ysnow[ii].cr3);

		SetPixel(hdc,snow.Xsnow[ii].p0.x,snow.Xsnow[ii].p0.y,snow.Xsnow[ii].cr0);
		SetPixel(hdc,snow.Xsnow[ii].p1.x,snow.Xsnow[ii].p1.y,snow.Xsnow[ii].cr1);
		SetPixel(hdc,snow.Xsnow[ii].p2.x,snow.Xsnow[ii].p2.y,snow.Xsnow[ii].cr2);
		SetPixel(hdc,snow.Xsnow[ii].p3.x,snow.Xsnow[ii].p3.y,snow.Xsnow[ii].cr3);
		snow.iVx=snow.iVAllx*((unsigned)rand()%3+1);
		snow.iVy=snow.iVAlly*((unsigned)rand()%3+1);
		snow.iSx=snow.iVAllx*((unsigned)rand()%3+1);
		snow.iSy=snow.iVAlly*((unsigned)rand()%3+1);
		snow.Ysnow[ii].p2.x+=snow.iVx+(unsigned)rand()%5-2;
		snow.Ysnow[ii].p2.y+=snow.iVy+1;
		snow.Xsnow[ii].p0.x+=snow.iSx+(unsigned)rand()%5-2;
		snow.Xsnow[ii].p0.y+=snow.iSy+1;
		iYx=snow.Ysnow[ii].p2.x;
		iYy=snow.Ysnow[ii].p2.y;
		crY=GetPixel(hdc,iYx,iYy);
		snow.Ysnow[ii].cr2=crY;
		iXx=snow.Xsnow[ii].p0.x;
		iXy=snow.Xsnow[ii].p0.y;
		crX=GetPixel(hdc,iXx,iXy);
		snow.Xsnow[ii].cr0=crX;
		if(crY==CLR_INVALID)
		{
			initSnow(hdc,&snow,ii,TYPE_Y);
			Yflag=0;
		}
		if(crX==CLR_INVALID)
		{
			initSnow(hdc,&snow,ii,TYPE_X);
			Xflag=0;
		}
		if(Yflag)
		{
			snow.Ysnow[ii].p0.x=iYx-1;
			snow.Ysnow[ii].p0.y=iYy-1;
			snow.Ysnow[ii].p1.x=iYx+1;
			snow.Ysnow[ii].p1.y=iYy-1;
			snow.Ysnow[ii].p3.x=iYx;
			snow.Ysnow[ii].p3.y=iYy+1;
            snow.Ysnow[ii].cr0=GetPixel(hdc,snow.Ysnow[ii].p0.x,snow.Ysnow[ii].p0.y);
			snow.Ysnow[ii].cr1=GetPixel(hdc,snow.Ysnow[ii].p1.x,snow.Ysnow[ii].p1.y);
			snow.Ysnow[ii].cr3=GetPixel(hdc,snow.Ysnow[ii].p3.x,snow.Ysnow[ii].p3.y);
		}
		if(Xflag)
		{
			snow.Xsnow[ii].p1.x=iXx+2;
			snow.Xsnow[ii].p1.y=iXy;
			snow.Xsnow[ii].p2.x=iXx;
			snow.Xsnow[ii].p2.y=iXy+2;
			snow.Xsnow[ii].p3.x=iXx+2;
			snow.Xsnow[ii].p3.y=iXy+2;
            snow.Xsnow[ii].cr1=GetPixel(hdc,snow.Xsnow[ii].p1.x,snow.Xsnow[ii].p1.y);
			snow.Xsnow[ii].cr2=GetPixel(hdc,snow.Xsnow[ii].p2.x,snow.Xsnow[ii].p2.y);
			snow.Xsnow[ii].cr3=GetPixel(hdc,snow.Xsnow[ii].p3.x,snow.Xsnow[ii].p3.y);
		}
		if(Yflag&&crY!=SNOWCR)
		{
			if(crY==SNOWGATHERCR)
			{
                 SetPixel(hdc,snow.Ysnow[ii].p2.x,snow.Ysnow[ii].p2.y,SNOWCR);
				 snow.Ysnow[ii].cr2=SNOWCR;
			}
			else if(GetContrast(hdc,&snow,ii,TYPE_Y)>CONTRAST)
			{
				SetPixel(hdc,snow.Ysnow[ii].p2.x,snow.Ysnow[ii].p2.y,SNOWGATHERCR);
                SetPixel(hdc,snow.Ysnow[ii].p2.x+1,snow.Ysnow[ii].p2.y+1,SNOWGATHERCR);
				SetPixel(hdc,snow.Ysnow[ii].p2.x-1,snow.Ysnow[ii].p2.y+1,SNOWGATHERCR);
                initSnow(hdc,&snow,ii,TYPE_Y);
			}
			else
			{
				SetPixel(hdc,iYx-1,iYy-1,SNOWCR);
				SetPixel(hdc,iYx+1,iYy-1,SNOWCR);
				SetPixel(hdc,iYx,iYy,SNOWCR);
				SetPixel(hdc,iYx,iYy+1,SNOWCR);
			}
		}
		if(Xflag&&crX!=SNOWCR)
		{
			if(crX==SNOWGATHERCR)
			{
				SetPixel(hdc,snow.Xsnow[ii].p0.x,snow.Xsnow[ii].p0.y,SNOWCR);
				snow.Xsnow[ii].cr0=SNOWCR;
			}
			else if(GetContrast(hdc,&snow,ii,TYPE_X)>CONTRAST)
			{
				SetPixel(hdc,snow.Xsnow[ii].p0.x,snow.Xsnow[ii].p0.y,SNOWGATHERCR);
				SetPixel(hdc,snow.Xsnow[ii].p0.x-1,snow.Xsnow[ii].p0.y+1,SNOWGATHERCR);
				SetPixel(hdc,snow.Xsnow[ii].p0.x+1,snow.Xsnow[ii].p0.y+1,SNOWGATHERCR);
				initSnow(hdc,&snow,ii,TYPE_X);
			}
			else
			{
				SetPixel(hdc,iXx,iXy,SNOWCR);
                SetPixel(hdc,iXx+2,iXy,SNOWCR);
				SetPixel(hdc,iXx,iXy+2,SNOWCR);
				SetPixel(hdc,iXx+2,iXy+2,SNOWCR);
			}
		}
	}
  }
  void initSnow(HDC hdc,Snow *sn,int index,int type)
  {
	  int ix=0,iy=0;
	  COLORREF cr=0;
	  if(type==TYPE_Y)
	  {
		  ix=(unsigned)rand()%cxScreen;
		  iy=(unsigned)rand()%YSTART;
		  cr=GetPixel(hdc,ix,iy);
		  sn->Ysnow[index].p2.x=ix;
		  sn->Ysnow[index].p2.y=iy;
		  sn->Ysnow[index].cr2=cr;
          sn->Ysnow[index].p0.x=ix-1;
		  sn->Ysnow[index].p0.y=iy-1;
		  sn->Ysnow[index].p1.x=ix+1;
		  sn->Ysnow[index].p1.y=iy-1;
		  sn->Ysnow[index].p3.x=ix;
		  sn->Ysnow[index].p3.y=iy+1;
		  sn->Ysnow[index].cr0=GetPixel(hdc,sn->Ysnow[index].p0.x,sn->Ysnow[index].p0.y);
		  sn->Ysnow[index].cr1=GetPixel(hdc,sn->Ysnow[index].p1.x,sn->Ysnow[index].p1.y);
		  sn->Ysnow[index].cr2=GetPixel(hdc,sn->Ysnow[index].p2.x,sn->Ysnow[index].p2.y);
	  }
	  else if(type==TYPE_X)
	  {
		  ix=(unsigned)rand()%cxScreen;
		  iy=(unsigned)rand()%YSTART;
		  cr=GetPixel(hdc,ix,iy);
		  sn->Xsnow[index].p0.x=ix;
		  sn->Xsnow[index].p0.y=iy;
		  sn->Xsnow[index].p1.x=ix+2;
		  sn->Xsnow[index].p1.y=iy;
		  sn->Xsnow[index].p2.x=ix;
		  sn->Xsnow[index].p2.y=iy+2;
		  sn->Xsnow[index].p3.x=ix+2;
		  sn->Xsnow[index].p3.y=iy+2;
		  sn->Xsnow[index].cr0=cr;
		  sn->Xsnow[index].cr1=GetPixel(hdc,sn->Xsnow[index].p1.x,sn->Xsnow[index].p1.y);
		  sn->Xsnow[index].cr2=GetPixel(hdc,sn->Xsnow[index].p2.x,sn->Xsnow[index].p2.y);
		  sn->Xsnow[index].cr3=GetPixel(hdc,sn->Xsnow[index].p3.x,sn->Xsnow[index].p3.y);
	  }
  }
  int GetContrast(HDC hdc,Snow *sn,int index,int type)
  {
        int ix=0,iy=0;
		COLORREF cr=0;
		COLORREF Ycr=0;
		COLORREF Xcr=0;
		int iR=0,iG=0,iB=0;
		if(type==TYPE_Y)
		{
			if(sn->iVx==0)
			{
				ix=sn->Ysnow[index].p2.x;
				iy=sn->Ysnow[index].p2.y+1;
			}
			else if(sn->iVx<0)
			{
				ix=sn->Ysnow[index].p2.x-1;
				iy=sn->Ysnow[index].p2.y+1;
			}
			else
			{
				ix=sn->Ysnow[index].p2.x+1;
				iy=sn->Ysnow[index].p2.y+1;
			}
			cr=GetPixel(hdc,ix,iy);
			if(cr==SNOWCR)
				return 0;
			Ycr=sn->Ysnow[index].cr2;
            iR=ffabs(((Ycr>>16)&0xFF)-((cr>>16)&0xFF));
			iG=ffabs(((Ycr>>8)&0xFF)-((cr>>8)&0xFF));
			iB=ffabs((Ycr&0xFF)-(Ycr&0xFF));
			return (iR+iG+iB)/3;
		}
		else if(type==TYPE_X)
		{
			if(sn->iSx==0)
			{
				ix=sn->Xsnow[index].p0.x;
				iy=sn->Xsnow[index].p0.y+1;
			}
			else if(sn->iSx<0)
			{
				ix=sn->Xsnow[index].p0.x-1;
				iy=sn->Xsnow[index].p0.y+1;
			}
			else
			{
				ix=sn->Xsnow[index].p0.x+1;
				ix=sn->Xsnow[index].p0.y+1;
			}
			cr=GetPixel(hdc,ix,iy);
			if(cr==SNOWCR)
				return 0;
			Xcr=sn->Xsnow[index].cr0;
			iR=ffabs(((Xcr>>16)&0xFF)-((cr>>16)&0xFF));
			iG=ffabs(((Xcr>>8)&0xFF)-((cr>>8)&0xFF));
			iB=ffabs((Xcr&0xFF)-(cr&0xFF));
			return (iR+iG+iB)/3;
		}
		return 0;
  }
  int ffabs(int e)
  {
	  if(e<0)
		  return -e;
	  return e;
  }