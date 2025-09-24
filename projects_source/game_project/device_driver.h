#include "stm32f10x.h"
#include "option.h"
#include "macro.h"
#include "malloc.h"
#include "lcd.h"
#include "graphics.h"

// Led.c

extern void LED_Init(void);
extern void LED_Display(unsigned int num);
extern void LED_All_On(void);
extern void LED_All_Off(void);

// Uart.c

#define Uart_Init			Uart1_Init
#define Uart_Send_Byte		Uart1_Send_Byte
#define Uart_Send_String	Uart1_Send_String
#define Uart_Printf			Uart1_Printf

extern void Uart1_Init(int baud);
extern void Uart1_Send_Byte(char data);
extern void Uart1_Send_String(char *pt);
extern void Uart1_Printf(char *fmt,...);
extern char Uart1_Get_Char(void);
extern char Uart1_Get_Pressed(void);
extern void Uart1_Get_String(char *string);
extern int Uart1_Get_Int_Num(void);
extern void Uart1_RX_Interrupt_Enable(int en);

// Clock.c

extern void Clock_Init(void);

// Key.c

extern void Key_Poll_Init(void);
extern int Key_Get_Pressed(void);
extern void Key_Wait_Key_Released(void);
extern int Key_Wait_Key_Pressed(void);
extern void Key_ISR_Enable(int en);

// Timer.c

extern void TIM2_Delay(int time);
extern void TIM2_Repeat_Interrupt_Enable(int en, int time);

extern void TIM3_Out_Init(void);
extern void TIM3_Out_Freq_Generation(unsigned short freq);
extern void TIM3_Out_Stop(void);

extern void TIM4_Repeat_Interrupt_Enable(int en, int time);

// Asm_Function.s

extern unsigned int __get_IPSR(void);

// SysTick.c

extern void SysTick_OS_Tick(unsigned int msec);
extern void SysTick_Run(unsigned int msec);
extern int SysTick_Check_Timeout(void);
extern unsigned int SysTick_Get_Time(void);
extern unsigned int SysTick_Get_Load_Time(void);
extern void SysTick_Stop(void);

// Jog_Key.c

extern void Jog_Poll_Init(void);
extern int Jog_Get_Pressed_Calm(void);
extern int Jog_Get_Pressed(void);
extern void Jog_Wait_Key_Released(void);
extern int Jog_Wait_Key_Pressed(void);
extern void Jog_ISR_Enable(int en);

// Game
#define     LCDW 			(320) // LCD 화면의 가로 크기
#define     LCDH 			(240) // LCD 화면의 세로 크기
#define     X_MIN 			(0) // X축 최소값
#define     X_MAX 			(LCDW - 1) // X축 최대값
#define     Y_MIN 			(0) // Y축 최소값
#define     Y_MAX 			(LCDH - 1) // Y축 최대값
#define     DIPLAY_MODE		(3)

#define     PHYSICS_PERIOD 	(34) 	// 물리적 계산 주기 (20ms)
#define     RENDER_PERIOD 	(17) 	// 렌더링 주기 (20ms)

#define     JUMP_SPEED      (-15)     // 점프 시작 속도 (위 방향으로 음수)
#define     GRAVITY         (3)       // 중력 가속도 (픽셀/프레임^2)

#if 0

// ↓↓ 남쪽(아래)으로 쏘고 싶다면 ↓↓
s->bullet_vx    =   0;
s->bullet_vy    =   +4;
s->spawn_offx   =  (s->body.w - s->bullet_w)/2;  // 본체 가로 중앙 정렬
s->spawn_offy   =   s->body.h;                  // 본체 바로 밑

// ↓↓ 북쪽(위)으로 쏘고 싶다면 ↓↓
s->bullet_vx    =   0;
s->bullet_vy    =  -4;
s->spawn_offx   =  (s->body.w - s->bullet_w)/2;
s->spawn_offy   =  -s->bullet_h;                // 본체 바로 위

// ↓↓ 동쪽(오른쪽)으로 쏘고 싶다면 ↓↓
s->bullet_vx    =  +4;
s->bullet_vy    =   0;
s->spawn_offx   =   s->body.w;                  // 본체 바로 우측
s->spawn_offy   =  (s->body.h - s->bullet_h)/2;

// ↓↓ 서쪽(왼쪽)으로 쏘고 싶다면 ↓↓
s->bullet_vx    =  -4;
s->bullet_vy    =   0;
s->spawn_offx   =  -s->bullet_w;                // 본체 바로 좌측
s->spawn_offy   =  (s->body.h - s->bullet_h)/2;

#endif