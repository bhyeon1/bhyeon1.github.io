//------------------------------------------------------------------------------
// define
//------------------------------------------------------------------------------
#include <math.h>
#include "bgm.h"
#include "device_driver.h"

#define MAX_STAGE                (9)     // 최대 스테이지 수
#define MAX_PLATFORMS            (12)    // 최대 플랫폼 수
#define MAX_OBSTACLES            (6)     // 최대 장애물 수
#define MAX_SHOOTERS             (5)
#define MAX_BULLETS_PER_SHOOTER  (5)
#define BAR_THICK                (10)    // 플랫폼 두께

#define CHAR_STEP 		         (5)    // 캐릭터가 한 번 이동하는 스텝
#define CHAR_JUMP_STEP           (5)    // 캐릭터가 한 번 점프하는 스텝
#define CHAR_SIZE_X 	         (20)  
#define CHAR_SIZE_Y 	         (20) 

#define BACK_COLOR 		         (5)     // 배경색
#define CHAR_COLOR 		         (4)     // 캐릭터 색

#define BASE                     (500)   // msec

// 색상 정의 배열
static unsigned short color[] = {RED, YELLOW, GREEN, BLUE, WHITE, BLACK, GRAY, PURPLE};

//------------------------------------------------------------------------------
// 데이터 구조
//------------------------------------------------------------------------------

typedef signed char    s8;
typedef unsigned char  u8;
typedef signed short   s16;
typedef unsigned short u16;

// object 그리기 (위치, 크기, 색)
typedef struct {
    u16           x, y;
    u16           w, h;                                  
    u8            ci;                                     
} QUERY_DRAW;                                   

// 발판 (platforms)의 이동 정보 설정
typedef struct {
    s8            vx, vy;  
    s16           min_x, max_x;
    s16           min_y, max_y;
} PlatformCfg;                                

// 장애물 (Obstacles)의 이동 정보 설정
typedef struct {
    s8            vx, vy;
    s16           min_x, max_x;
    s16           min_y, max_y;
} ObstacleCfg;                                  

// 총알 설정
typedef struct {
    QUERY_DRAW    draw;                           
    s8            vx, vy;
    u8            active;           // 0 또는 1
    s16           prev_x, prev_y;
} Bullet;

// 총알 발사하는 장애물 설정
typedef struct {
    QUERY_DRAW    body;                         
    ObstacleCfg   move_cfg;                     
    u16           fire_rate;
    u16           fire_timer;

    // 총알 버스트 모드
    u8            burst_size;      // 한 번에 쏠 총알 개수
    u8            burst_fired;     // 이미 쏜 총알 개수
    u16           burst_pause;     // 버스트 후 쉴 프레임 수
    u16           pause_timer;     // 휴지 타이머

    // 발사 각 조정
    u16           dir_angle;       // 현재 발사 각도 (degree)
    u8            dir_step;        // 한 발마다 회전할 각도 
    u16           dir_min;         // 최소 허용 각도 
    u16           dir_max;         // 최대 허용 각도 
    s8            dir_inc;         // 각도 증감 방향: +1 또는 -1

    // 총알 초기 설정
    s8            bullet_vx, bullet_vy;
    u8            bullet_w, bullet_h, bullet_ci;
    s16           prev_x, prev_y;                       // 총알의 이전 정보를 저장.

    s16           spawn_offx, spawn_offy;               // 오브젝트에서 총알의 스폰 위치
    Bullet        bullets[MAX_BULLETS_PER_SHOOTER];     // 총알이 화면에 떠있을 수 있는 최대 개수.
} ShooterObstacleCfg;

// 스테이지 구성
typedef struct {
    u8           	     platform_count;                // 발판 개수
    QUERY_DRAW    	     platforms[MAX_PLATFORMS];      // 발판 정보 배열
    PlatformCfg          plat_cfg[MAX_PLATFORMS];       // 발판 이동 정보

    u8           	     obstacle_count;                // 장애물 개수
    QUERY_DRAW    	     obstacles[MAX_OBSTACLES];      // 장애물 정보 배열
    ObstacleCfg   	     obs_cfg[MAX_OBSTACLES];        // 장애물별 이동 설정 배열

    u8                   shooter_count;
    ShooterObstacleCfg   shooters[MAX_SHOOTERS];

    QUERY_DRAW           goal;                          // 목표 위치 추가

    s16                  char_start_x, char_start_y;    // 캐릭터 x, y축 위치
} StageCfg;

//------------------------------------------------------------------------------
// 전역 변수
//------------------------------------------------------------------------------

static StageCfg 	    stages[MAX_STAGE];   		    // 모든 스테이지 설정을 담는 테이블
static int      	    current_stage = 0;   		    // 현재 진행 중인 스테이지 인덱스

static QUERY_DRAW 	    character;         			    // 플레이어
static int      	    char_prev_x, char_prev_y;  	    // 플레이어 이전 좌표

static int              prev_obs_x[MAX_OBSTACLES];
static int              prev_obs_y[MAX_OBSTACLES];

static int              prev_pf_x[MAX_PLATFORMS];
static int              prev_pf_y[MAX_PLATFORMS];

volatile int            vel_y = 0;                      // 캐릭터 수직 속도

volatile int            is_jumping = 0;				    // 실제 점프 중인지 상태 표시
volatile int            request_jump = 0;
volatile int            request_stop = 0;

extern volatile int     Jog_key_in;
extern volatile int     Jog_key;
extern volatile int     TIM2_Expired;
extern volatile int     TIM4_Expired;
extern volatile long    msTicks;
static int              death_count = 0;

extern volatile int     USART1_rx_data;
extern volatile int     USART1_rx_ready;

static volatile int     game_won = 0;                   // stage all clear flag
static volatile int     game_over = 0;

//------------------------------------------------------------------------------
// BGM
//------------------------------------------------------------------------------

enum tone {
    C3=0,   C3_=1, D3=2,  D3_=3, E3=4,  F3=5,  F3_=6,
    G3=7,   G3_=8, A3=9,  A3_=10,B3=11,
    C4=12,  C4_=13,D4=14, D4_=15,E4=16, F4=17, F4_=18,
    G4=19,  G4_=20,A4=21, A4_=22,B4=23,
    C5=24,  C5_=25,D5=26, D5_=27,E5=28, F5=29, F5_=30,
    G5=31,  G5_=32,A5=33, A5_=34,B5=35
};

enum note{N16=BASE/4, N8=BASE/2, N4=BASE, N2=BASE*2, N1=BASE*4};

const Note bgmTheme[] = {
    { C5_, N8 }, { D5, N8 },  { E5, N8 }, { D5, N8 }, { G5, N4 }, { D5, N16 }, 
	{ B4, N8 },  { G4, N8 },  { B4, N8 }, { A4, N8 }, { G4_, N8}, { A4, N8 },
	{ E5, N4 },  { E5, N8 },  { F5_, N8}, { F5, N8 }, { E5, N8 }, { D5_, N8},
	{ D5, N8 },  { C5_, N16}, { D5, N16}, { E5, N8 }, { C5, N8 }, { B4, N8},
	{ A4_, N8},  { B4, N8 },  { E5, N8 }, { D5, N2 }
};

const int THEME_LEN = sizeof(bgmTheme)/sizeof(bgmTheme[0]);

volatile int bgm_timer;
volatile int bgm_idx;

unsigned short SemitoneToFreq(unsigned char st) {       // 주파수 계산 함수
    float f = 130.0f * powf(2.0f, st/12.0f);
    return (unsigned short)(f + 0.5f);
}

//------------------------------------------------------------------------------
// Prototypes
//------------------------------------------------------------------------------

static void System_Init(void);
static void Game_Start_Screen(void);
static void DefineStages(void);
static void Stage_Init(int idx);
static void Physics_Update(void);
static void Render_Update(void);
static void Draw_Object(QUERY_DRAW *obj);
static int  IsCollide(QUERY_DRAW *a, QUERY_DRAW *b);
static void CHARICTER_Move(int k);
static void Win_Screen(void);
static void Stop_Character(void);

static int intersect_rect( 
    int ax1,int ay1,int aw,int ah,
    int bx1,int by1,int bw,int bh,
    int *ix1,int *iy1,int *iw,int *ih);

static int rectIntersect(int ax, int ay, int aw, int ah,
    int bx, int by, int bw, int bh);    

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

static void Stop_Character(void) {
    Jog_key    = 0;
    Jog_key_in = 0;
}

static void Draw_Object(QUERY_DRAW * obj) {
	Lcd_Draw_Box(obj->x, obj->y, obj->w, obj->h, color[obj->ci]);
}

static int IsCollide(QUERY_DRAW *a, QUERY_DRAW *b) { 	// 즉 박스가 겹치면 1을 리턴.
    return (a->x < b->x + b->w) &&						// a의 왼쪽이 b의 오른쪽보다 왼쪽에 있음.
           (a->x + a->w > b->x) &&						// a의 오른쪽이 b의 왼쪽보다 오른쪽에 있다
           (a->y < b->y + b->h) &&						// a의 위쪽이 b의 아래쪽보다 위에 있다
           (a->y + a->h > b->y);						// a의 아래쪽이 b의 위쪽보다 아래에 있다
}

static int intersect_rect( 
    int ax1,int ay1,int aw,int ah,
    int bx1,int by1,int bw,int bh,
    int *ix1,int *iy1,int *iw,int *ih)
{
    int ax2 = ax1 + aw, ay2 = ay1 + ah;
    int bx2 = bx1 + bw, by2 = by1 + bh;
    int x1 = ax1 > bx1 ? ax1 : bx1;
    int y1 = ay1 > by1 ? ay1 : by1;
    int x2 = ax2 < bx2 ? ax2 : bx2;
    int y2 = ay2 < by2 ? ay2 : by2;
    if (x2 > x1 && y2 > y1) {
        *ix1 = x1; *iy1 = y1;
        *iw  = x2 - x1;
        *ih  = y2 - y1;
        return 1;
    }
    return 0;
}

static int rectIntersect(int ax, int ay, int aw, int ah,
    int bx, int by, int bw, int bh)
{
return (ax < bx + bw) && (bx < ax + aw) &&
       (ay < by + bh) && (by < ay + ah);
}

static void k2(void)
{
    StageCfg *s = &stages[current_stage];
    int i;
    // 1) 새 X 계산 + 경계 클램프
    int newX = character.x - CHAR_STEP;
    if (newX < X_MIN) newX = X_MIN;

    // 2) 충돌 검사용 임시 박스
    QUERY_DRAW tmp = character;
    tmp.x = newX;

    // 3) 플랫폼 전부와 충돌 검사: 하나라도 겹치면 이동 취소
    for (i = 0; i < s->platform_count; ++i) {
        if (IsCollide(&tmp, &s->platforms[i])) {
            return;  // 그대로 리턴하면 character.x 변경 안 함
        }
    }

    // 4) 실제 이동
    char_prev_x   = character.x;
    character.x   = newX;
}

static void k3(void)
{
    StageCfg *s = &stages[current_stage];
    int i;
    // 1) 새 X 계산 + 경계 클램프
    int newX = character.x + CHAR_STEP;
    if (newX + character.w > X_MAX) 
        newX = X_MAX - character.w;

    // 2) 충돌 검사용 임시 박스
    QUERY_DRAW tmp = character;
    tmp.x = newX;

    // 3) 플랫폼 전부와 충돌 검사
    for (i = 0; i < s->platform_count; ++i) {
        if (IsCollide(&tmp, &s->platforms[i])) {
            return;
        }
    }

    // 4) 실제 이동
    char_prev_x   = character.x;
    character.x   = newX;
}

static void CHARICTER_Move(int k)
{
	// LEFT(2), RIGHT(3)
	static void (*key_func[])(void) = {k2, k3};
	if(k <= 3) key_func[k-2]();
}

static void DefineStages(void) {
    int i;
    // ───── Stage 1 ─────
    {
        StageCfg *s = &stages[0];
        s->platform_count = 1;
        s->platforms[0] = (QUERY_DRAW){0, LCDH-10, LCDW, BAR_THICK, 2};
        s->plat_cfg[0] = (PlatformCfg){0, 0, 0, 0, 0, 0};

        s->obstacle_count = 4;
        int obs_x_positions1[4] = {60, 120, 180, 240};
        for (i = 0; i < s->obstacle_count; ++i) {
            int px = obs_x_positions1[i];
            int py = s->platforms[0].y - 20;
            s->obstacles[i] = (QUERY_DRAW){ px, py, 20, 20, 0 };
            s->obs_cfg[i] = (ObstacleCfg){
                .vx    = 0, .vy = 0,
                .min_x = px, .max_x = px + 20,
                .min_y = py, .max_y = py + 20
            };
        }
        s->shooter_count = 0;

        s->goal = (QUERY_DRAW){ X_MAX-20, s->platforms[0].y - CHAR_SIZE_Y, 20, 20, 1 };
        s->char_start_x = 0;
        s->char_start_y = s->platforms[0].y - CHAR_SIZE_Y;
    }

    // ───── Stage 2 ─────
    {
        StageCfg *s = &stages[1];
        s->platform_count = 5;
        s->platforms[0] = (QUERY_DRAW){0, LCDH-10, LCDW,    BAR_THICK, 2};
        s->platforms[1] = (QUERY_DRAW){0, LCDH-50, LCDW-60, BAR_THICK, 2};
        s->platforms[2] = (QUERY_DRAW){60,LCDH-90, LCDW-60, BAR_THICK, 2};
        s->platforms[3] = (QUERY_DRAW){0, LCDH-130, LCDW-60, BAR_THICK, 2};
        s->platforms[4] = (QUERY_DRAW){60,LCDH-170, LCDW-60, BAR_THICK, 2};

        for (i = 0; i < s->platform_count; i++) {
            s->plat_cfg[i] = (PlatformCfg){0, 0, 0, 0, 0, 0};
        }

        s->obstacle_count = 3;
        int obs_x_positions2[3] = {60, (LCDW - 20) / 2, LCDW - 80};
        for (i = 0; i < s->obstacle_count; ++i) {
            int p  = i+1;
            int px = obs_x_positions2[i];
            int py = s->platforms[p].y - 20;
            s->obstacles[i] = (QUERY_DRAW){ px, py, 20, 20, 0 };
            s->obs_cfg[i] = (ObstacleCfg){
                .vx    = 0, .vy = 3 + i,
                .min_x = px, .max_x = px + 20,
                .min_y = Y_MIN + BAR_THICK,
                .max_y = LCDH - BAR_THICK
            };
            prev_obs_y[i] = py;
        }

        s->shooter_count = 0;

        s->goal = (QUERY_DRAW){ LCDW-30, BAR_THICK, 20, 20, 1 };
        s->char_start_x = 0;
        s->char_start_y = s->platforms[0].y - CHAR_SIZE_Y;
    }

    // ───── Stage 3 ─────
    {
        StageCfg *s = &stages[2];
        s->platform_count = 11;
        s->platforms[0] = (QUERY_DRAW){0, LCDH-10, LCDW,    BAR_THICK, 2};  // 밑바닥
        s->platforms[1] = (QUERY_DRAW){154, 70, BAR_THICK, 160, 2};  // 가운데 벽

        int x[8] = { 30, 94, 30, 94, 194, 254, 194, 254};
        for (i=2;i<=5;i++) {
            s->platforms[i] = (QUERY_DRAW){x[i-2], LCDH-10-40*(i-1), 60, BAR_THICK, 2};
        }
        for (i=6;i<=9;i++) {
            s->platforms[i] = (QUERY_DRAW){x[i-2], LCDH-10-40*(i-5), 60, BAR_THICK, 2};
        }

        s->platforms[10] = (QUERY_DRAW){194, 0, BAR_THICK, 110, 2};

        for (i = 0; i < s->platform_count; i++) {
            s->plat_cfg[i] = (PlatformCfg){0, 0, 0, 0, 0, 0};
        }

        s->obstacle_count = 5;
        int obs_x_positions2[5] = {74, (LCDW - 20) / 2, LCDW - 80, 30, 204};
        int obs_y_positions2[5] = {LCDH-70, 20, LCDH-190, LCDH-70, LCDH-150};
        int obs_vx[5] = {0, 0, 0, 6, 6};
        int obs_vy[5] = {5, 3, 5, 0, 0};
        for (i = 0; i < s->obstacle_count; i++) {
            int px = obs_x_positions2[i];
            int py = obs_y_positions2[i];
            s->obstacles[i] = (QUERY_DRAW){ px, py, 20, 20, 0 };

            if (obs_vy[i] == 5) {
                s->obs_cfg[i] = (ObstacleCfg){
                    .vx    = obs_vx[i], .vy = obs_vy[i],
                    .min_x = px, .max_x = px + 20,
                    .min_y = Y_MIN + BAR_THICK,
                    .max_y = LCDH - BAR_THICK
                };
            }

            else if (obs_vy[i] == 3) {
                s->obs_cfg[i] = (ObstacleCfg){
                    .vx    = obs_vx[i], .vy = obs_vy[i],
                    .min_x = px, .max_x = px + 20,
                    .min_y = Y_MIN + BAR_THICK,
                    .max_y = s->platforms[1].y 
                };
            }

            else {
                s->obs_cfg[i] = (ObstacleCfg){
                    .vx    = obs_vx[i], .vy = obs_vy[i],
                    .min_x = X_MIN, .max_x = X_MAX - CHAR_SIZE_X,
                    .min_y = py,
                    .max_y = py + 20
                };
            }
            prev_obs_x[i] = px;
            prev_obs_y[i] = py;
        }

        s->shooter_count = 0;

        s->goal = (QUERY_DRAW){ LCDW-30, BAR_THICK, 20, 20, 1 };
        s->char_start_x = 0;
        s->char_start_y = s->platforms[0].y - CHAR_SIZE_Y;
    }

    // ───── Stage 4 ─────
    {
        StageCfg *s = &stages[3];
        s->platform_count = 5;
        s->platforms[0] = (QUERY_DRAW){0,   LCDH-10,  LCDW,  BAR_THICK, 3};  // 밑바닥
        s->plat_cfg[0] = (PlatformCfg){0, 0, 0, 0, 0, 0};

        s->platforms[1] = (QUERY_DRAW){194, LCDH-50,  60,   BAR_THICK, 3};
        s->platforms[2] = (QUERY_DRAW){30,  LCDH-90,  60,   BAR_THICK, 3};
        s->platforms[3] = (QUERY_DRAW){194, LCDH-130, 60,   BAR_THICK, 3};
        s->platforms[4] = (QUERY_DRAW){30,  LCDH-170, 60,   BAR_THICK, 3};

        for (i = 1; i < s->platform_count; i++) {
            s->plat_cfg[i] = (PlatformCfg){
                .vx    = 3,
                .vy    = 0,
                .min_x = 0,
                .max_x = LCDW,
                .min_y = s->platforms[i].y,
                .max_y = s->platforms[i].y
            };
        }

        s->obstacle_count = 0;
        s->shooter_count = 0;

        s->goal = (QUERY_DRAW){ LCDW-30, BAR_THICK, 20, 20, 1 };
        s->char_start_x = 0;
        s->char_start_y = s->platforms[0].y - CHAR_SIZE_Y;
    }

    // ───── Stage 5 ─────
    {
        StageCfg *s = &stages[4];
        
        s->obstacle_count = 6;
        s->obstacles[0] = (QUERY_DRAW){0,  LCDH-10,  LCDW,      BAR_THICK, 0};
        s->obstacles[1] = (QUERY_DRAW){80, LCDH-95,  LCDW - 80, BAR_THICK, 0};
        s->obstacles[2] = (QUERY_DRAW){0,  LCDH-180, LCDW - 80, BAR_THICK, 0};
        s->obstacles[3] = (QUERY_DRAW){0,  LCDH-125, 20, 20, 0};

        s->obstacles[4] = (QUERY_DRAW){150,  LCDH-105, 10, 10, 0};
        s->obstacles[5] = (QUERY_DRAW){240, LCDH-65,  10, 10, 0};
        for (i=0;i<3;i++) {
            s->obs_cfg[i] = (ObstacleCfg){0, 0, 0, 0, 0, 0};
        }
        s->obs_cfg[3] = (ObstacleCfg){5, 0, X_MIN, X_MAX, 0, 0};
        for (i=4;i<s->obstacle_count;i++) {
            s->obs_cfg[i] = (ObstacleCfg){0, 4, 0, 0, s->obstacles[1].y - 10, Y_MAX};
        }

        s->platform_count = 6;

        s->platforms[0] = (QUERY_DRAW){60, s->obstacles[0].y - 10,  80,  BAR_THICK, 3};
        s->platforms[1] = (QUERY_DRAW){s->obstacles[1].x, s->obstacles[1].y - 10,  80,  BAR_THICK, 3};
        s->platforms[2] = (QUERY_DRAW){s->obstacles[2].x, s->obstacles[2].y - 10,  30,  BAR_THICK, 3};
        s->platforms[3] = (QUERY_DRAW){0,   s->obstacles[0].y-10,  30,  BAR_THICK, 3};
        s->platforms[4] = (QUERY_DRAW){70,  s->platforms[2].y,     40,  BAR_THICK, 3};
        s->platforms[5] = (QUERY_DRAW){250, s->platforms[2].y,     40,  BAR_THICK, 3};
        for (i=2;i<4;i++) {
            s->plat_cfg[i] = (PlatformCfg){0, 0, 0, 0, 0, 0};
        }

        int x_min[4] = {X_MIN + 60, X_MIN+80, s->platforms[4].x, s->platforms[5].x - 60};
        int x_max[4] = {X_MAX, X_MAX, s->platforms[4].x + 100, s->platforms[5].x + 40};
        for (i = 0; i < 2; i++) {
            s->plat_cfg[i] = (PlatformCfg){3, 0, x_min[i], x_max[i], 0, 0};
        }
        for (i = 4; i < s->platform_count; i++) {
            s->plat_cfg[i] = (PlatformCfg){3, 0, x_min[i-2], x_max[i-2], 0, 0};
        }

        s->shooter_count = 0;

        s->goal = (QUERY_DRAW){ LCDW-20, s->obstacles[1].y + 20, 20, 20, 1 };

        s->char_start_x = s->platforms[2].x;
        s->char_start_y = s->platforms[2].y - CHAR_SIZE_Y;
    }

    // ───── Stage 6 ─────
    {
        StageCfg *s = &stages[5];
        
        s->obstacle_count = 4;
        s->obstacles[0] = (QUERY_DRAW){0,  LCDH-10, LCDW,      BAR_THICK, 0};
        s->obstacles[1] = (QUERY_DRAW){70, LCDH/2,  LCDW - 70, BAR_THICK, 0};
        s->obs_cfg[0] = (ObstacleCfg){0, 0, 0, 0, 0, 0};
        s->obs_cfg[1] = (ObstacleCfg){0, 0, 0, 0, 0, 0};

        int obs_x_positions5[2] = {70, LCDW-50};
        int obs_y_positions5[2] = {20, LCDH-30};
        for (i = 2; i < s->obstacle_count; ++i) {
            int px = obs_x_positions5[i-2];
            int py = obs_y_positions5[i-2];
            s->obstacles[i] = (QUERY_DRAW){ px, py, 20, 20, 0 };
            s->obs_cfg[i] = (ObstacleCfg){
                .vx    = 0, .vy = i + 1,
                .min_x = px, .max_x = px + 20,
                .min_y = Y_MIN + BAR_THICK,
                .max_y = LCDH - BAR_THICK
            };
            prev_obs_y[i] = py;
        }

        s->platform_count = 8;

        s->platforms[0] = (QUERY_DRAW){X_MAX- 20, s->obstacles[1].y + 50,  30,   BAR_THICK, 3};
        s->platforms[1] = (QUERY_DRAW){0, s->obstacles[1].y + 15,  30,   BAR_THICK, 3};
        for (i=0;i<2;i++) {
            s->plat_cfg[i] = (PlatformCfg){0, 0, 0, 0, 0, 0};
        }

        s->platforms[2] = (QUERY_DRAW){LCDW-60,  LCDH-20,  40, BAR_THICK, 3};
        s->platforms[3] = (QUERY_DRAW){LCDW-119,  LCDH-35,  40, BAR_THICK, 3};
        s->platforms[4] = (QUERY_DRAW){LCDW-240,  LCDH-65,  40, BAR_THICK, 3};
        s->platforms[5] = (QUERY_DRAW){s->obstacles[1].x,  s->obstacles[1].y - BAR_THICK,  40, BAR_THICK, 3};
        s->platforms[6] = (QUERY_DRAW){0, s->platforms[5].y-40,  40, BAR_THICK, 3};

        int x_min[5] = {LCDW-80,LCDW-180, LCDW-280, s->obstacles[1].x, 0};
        int x_max[5] = {LCDW, LCDW-70, LCDW-160, LCDW-160, LCDW-100};
        for (i = 2; i < s->platform_count - 1; i++) {
            s->plat_cfg[i] = (PlatformCfg){3, 0, x_min[i-2], x_max[i-2], 0, 0};
        }

        s->platforms[7] = (QUERY_DRAW){LCDW-100, s->platforms[6].y-40,  40, BAR_THICK, 3};
        s->plat_cfg[7] = (PlatformCfg){0, 0, 0, 0, 0, 0};

        s->shooter_count = 0;

        s->goal = (QUERY_DRAW){ LCDW-20, LCDH/2-20, 20, 20, 1 };

        s->char_start_x = X_MAX - CHAR_SIZE_X;
        s->char_start_y = s->platforms[0].y - CHAR_SIZE_Y;
    }

    // ───── Stage 7 ─────
    {
        StageCfg *s = &stages[6];
        
        s->platform_count = 3;
        s->platforms[0] = (QUERY_DRAW){0, LCDH-10, LCDW,    BAR_THICK, 6};
        s->platforms[1] = (QUERY_DRAW){40,LCDH-90, LCDW-40, BAR_THICK, 6};
        s->platforms[2] = (QUERY_DRAW){0,LCDH-170, LCDW-40, BAR_THICK, 6};

        for (i = 0; i < s->platform_count; i++) {
            s->plat_cfg[i] = (PlatformCfg){0, 0, 0, 0, 0, 0};
        }
        s->obstacle_count = 0;
    
        // Shooter  
        s->shooter_count = 3;
        s->shooters[0] = (ShooterObstacleCfg){
            .body        = {X_MAX - 20 ,s->platforms[2].y - 20, 20, 20, 7 },                                      
            .move_cfg    = { .vx=4, .vy=0, .min_x=20, .max_x=X_MAX, .min_y=0, .max_y=0 },
            // fire rate : 발사 속도
            .fire_rate   = 30,  .fire_timer  = 0,
            // burst mode 설정 (한번에 몇발 쏠 건지. 쏘고 난 후 pausing time 설정.)
            .burst_size  = 1,  .burst_fired = 0,    
            .burst_pause = 1, .pause_timer = 0,
            // 총알 정보 설정
            .bullet_vx   = 0,  .bullet_vy   = 5,
            .bullet_w    = 6,  .bullet_h    = 6, .bullet_ci =  7,
            .prev_x      = 0,  .prev_y      = 0,
            .spawn_offx  = (20 - 6)/2,
            .spawn_offy  = 6,
            .bullets     = { { {0,0,0,0,0}, 0,0,0,0 } }
        };

        s->shooters[1] = (ShooterObstacleCfg){
            .body        = {X_MIN ,s->platforms[1].y - 20, 20, 20, 7 },                                      
            .move_cfg    = { .vx=0, .vy=4, .min_x=0, .max_x=0, .min_y=s->platforms[2].y+10, .max_y=Y_MAX-10},
            // fire rate : 발사 속도
            .fire_rate   = 30,  .fire_timer  = 0,
            // burst mode 설정 (한번에 몇발 쏠 건지. 쏘고 난 후 pausing time 설정.)
            .burst_size  = 1,  .burst_fired = 0,    
            .burst_pause = 1, .pause_timer = 0,
            // 총알 정보 설정
            .bullet_vx   = 7,  .bullet_vy   = 0,
            .bullet_w    = 6,  .bullet_h    = 6, .bullet_ci =  7,
            .prev_x      = 0,  .prev_y      = 0,
            .spawn_offx  = 20,
            .spawn_offy  = (20 - 6) / 2,
            .bullets     = { { {0,0,0,0,0}, 0,0,0,0 } }
        };

        s->shooters[2] = (ShooterObstacleCfg){
            .body        = {20 ,s->platforms[0].y - 20, 20, 20, 7 },                                      
            .move_cfg    = { .vx=4, .vy=0, .min_x=20, .max_x=X_MAX, .min_y=0, .max_y=0 },
            // fire rate : 발사 속도
            .fire_rate   = 30,  .fire_timer  = 0,
            // burst mode 설정 (한번에 몇발 쏠 건지. 쏘고 난 후 pausing time 설정.)
            .burst_size  = 1,  .burst_fired = 0,    
            .burst_pause = 1, .pause_timer = 0,
            // 총알 정보 설정
            .bullet_vx   = 0,  .bullet_vy   = -5,
            .bullet_w    = 6,  .bullet_h    = 6, .bullet_ci =  7,
            .prev_x      = 0,  .prev_y      = 0,
            .spawn_offx  = (20 - 6)/2,
            .spawn_offy  = -6,
            .bullets     = { { {0,0,0,0,0}, 0,0,0,0 } }
        };
    
        s->goal         = (QUERY_DRAW){ X_MAX-20, LCDH-30, 20,20, 1 };
        s->char_start_x = 0;
        s->char_start_y = s->platforms[2].y-20;
    }

    // ───── Stage 8 ─────
    {
        StageCfg *s = &stages[7];
        s->platform_count = 9;
        s->platforms[0] = (QUERY_DRAW){ 0,  LCDH-10,  LCDW-100, BAR_THICK, 6 }; // 바닥
        s->plat_cfg[0] = (PlatformCfg){0, 0, 0, 0, 0, 0};

        s->platforms[1] = (QUERY_DRAW){30,  LCDH-50,  40,   BAR_THICK, 6};
        s->platforms[2] = (QUERY_DRAW){160, LCDH-90,  40,   BAR_THICK, 6};
        s->platforms[3] = (QUERY_DRAW){210, LCDH-130, 40,   BAR_THICK, 6};
        s->platforms[4] = (QUERY_DRAW){210, LCDH-210, 40,   BAR_THICK, 6};

        s->platforms[5] = (QUERY_DRAW){X_MAX-30, LCDH-170, 40,   BAR_THICK, 6};
        s->platforms[6] = (QUERY_DRAW){130,      LCDH-170, 60,   BAR_THICK, 6};
        s->platforms[7] = (QUERY_DRAW){30,       LCDH-170, 60,   BAR_THICK, 6};
        s->platforms[8] = (QUERY_DRAW){180,      LCDH-180, 10,   BAR_THICK, 6};
        for(i=5;i<s->platform_count;i++)
        {
            s->plat_cfg[i] = (PlatformCfg){0, 0, 0, 0, 0, 0};
        }
        

        int moving_platform_x_min[4] = {s->platforms[1].x, s->platforms[2].x-40, s->platforms[3].x, s->platforms[3].x};
        int moving_platform_x_max[4] = {s->platforms[1].x+80, s->platforms[2].x+40, s->platforms[3].x+80, s->platforms[3].x+80};
        for (i = 1; i < s->platform_count - 4; i++) {
            s->plat_cfg[i] = (PlatformCfg){
                .vx    = 2,
                .vy    = 0,
                .min_x = moving_platform_x_min[i-1],
                .max_x = moving_platform_x_max[i-1],
                .min_y = 0,
                .max_y = 0
            };
        }

        s->obstacle_count = 2;
        s->obstacles[0] = (QUERY_DRAW){LCDW/2, LCDH-190, 20, 20, 0};
        s->obstacles[1] = (QUERY_DRAW){X_MAX-40, (LCDH-140)/2,  10, 10, 0};
        for(i=0;i<s->obstacle_count;i++) {
            prev_obs_x[i] = s->obstacles[i].x;
            prev_obs_y[i] = s->obstacles[i].y;
        }

        s->obs_cfg[0] = (ObstacleCfg){
            .vx    = 4, .vy = 0,
            .min_x = 0, .max_x = X_MAX,
            .min_y = 0, .max_y = 0
        };

        s->obs_cfg[1] = (ObstacleCfg){
            .vx    = 0, .vy = 4,
            .min_x = 0, .max_x = 0,
            .min_y = 0, .max_y = LCDH-120
        };

        s->shooter_count = 2;
        s->shooters[0] = (ShooterObstacleCfg){
            .body       = {0, 0, 20, 20, 7},
            .move_cfg   = { .vx=1, .vy=0, .min_x=0, .max_x=100, .min_y=0, .max_y=0 },
            .fire_rate  = 30, .fire_timer=0,
            .burst_size = 1,  .burst_fired=0,
            .burst_pause= 1,  .pause_timer=0,
            .bullet_vx  = 3,  .bullet_vy=3,
            .bullet_w   = 6,  .bullet_h=6, .bullet_ci=7,
            .spawn_offx = (20-6)/2, .spawn_offy=(20-6)/2,
            .bullets    = {{ {0,0,0,0,0},0,0,0,0 }}
        };
        s->shooters[1] = (ShooterObstacleCfg){
            .body       = { X_MAX-20, LCDH-20, 20,20, 7 },
            .move_cfg   = { .vx=1, .vy=0, .min_x=LCDW-100, .max_x=LCDW, .min_y=0, .max_y=0 },
            .fire_rate  = 30, .fire_timer=0,
            .burst_size = 1,  .burst_fired=0,
            .burst_pause= 1,  .pause_timer=0,
            .bullet_vx  = -3, .bullet_vy=-3,
            .bullet_w   = 6,  .bullet_h=6, .bullet_ci=7,
            .spawn_offx = (20-6)/2, .spawn_offy=(20-6)/2,
            .bullets    = {{ {0,0,0,0,0},0,0,0,0 }}
        };

        s->goal         = (QUERY_DRAW){ 0, LCDH-150, 20,20, 1 };
        s->char_start_x = 0;
        s->char_start_y = LCDH-30;
    }

    // ───── Stage 9 ─────
    {
        StageCfg *s = &stages[8];

        s->platform_count = 12;
        s->platforms[0] = (QUERY_DRAW){ 0,  LCDH-10, 30, BAR_THICK-5, 6 };
        s->platforms[1] = (QUERY_DRAW){55,  LCDH-20, 30, BAR_THICK-5, 6};
        s->platforms[2] = (QUERY_DRAW){170, LCDH-20, 30, BAR_THICK-5, 6};
        s->platforms[3] = (QUERY_DRAW){225, LCDH-20, 30, BAR_THICK-5, 6};
        s->platforms[4] = (QUERY_DRAW){X_MAX - 20, LCDH-55, 30, BAR_THICK-5, 6};
        s->platforms[5] = (QUERY_DRAW){85,  LCDH-90, 30, BAR_THICK-5, 6};
        s->platforms[6] = (QUERY_DRAW){140, LCDH-90, 30, BAR_THICK-5, 6};
        s->platforms[7] = (QUERY_DRAW){255, LCDH-90, 30, BAR_THICK-5, 6};
        s->platforms[8] = (QUERY_DRAW){0, LCDH-125, 20, BAR_THICK-5, 6};
        s->platforms[9] = (QUERY_DRAW){85,  LCDH-160, 30, BAR_THICK-5, 6};
        s->platforms[10] = (QUERY_DRAW){140, LCDH-160, 30, BAR_THICK-5, 6};
        s->platforms[11] = (QUERY_DRAW){255, LCDH-160, 30, BAR_THICK-5, 6};
        
        int moving_platform_x_min[3] = {s->platforms[1].x, s->platforms[2].x-30, s->platforms[3].x};
        int moving_platform_x_max[3] = {s->platforms[1].x+60, s->platforms[2].x+30, s->platforms[3].x+60};
        for (i = 1; i < 4; i++) {
            s->plat_cfg[i] = (PlatformCfg){
                .vx    = 2,
                .vy    = 0,
                .min_x = moving_platform_x_min[i-1],
                .max_x = moving_platform_x_max[i-1],
                .min_y = 0,
                .max_y = 0
            };
        }

        for (i = 5; i < 8; i++) {
            s->plat_cfg[i] = (PlatformCfg){
                .vx    = 2,
                .vy    = 0,
                .min_x = moving_platform_x_min[i-5],
                .max_x = moving_platform_x_max[i-5],
                .min_y = 0,
                .max_y = 0
            };
        }

        for (i = 9; i < 12; i++) {
            s->plat_cfg[i] = (PlatformCfg){
                .vx    = 2,
                .vy    = 0,
                .min_x = moving_platform_x_min[i-9],
                .max_x = moving_platform_x_max[i-9],
                .min_y = 0,
                .max_y = 0
            };
        }

        s->obstacle_count = 1;
        for(i=0;i<s->obstacle_count;i++) {
            prev_obs_x[i] = s->obstacles[i].x;
            prev_obs_y[i] = s->obstacles[i].y;
        }
        s->obstacles[0] = (QUERY_DRAW){0, LCDH-5, LCDW, BAR_THICK-5, 0};

        s->shooter_count = 4;
        s->shooters[0] = (ShooterObstacleCfg){
            .body        = { 30, Y_MIN, 10,10, 7 },
            .move_cfg   = { .vx=3, .vy=0, .min_x=30, .max_x=LCDW, .min_y=0, .max_y=0 },
            .fire_rate   = 30,
            .fire_timer  = 0,
            // bullet_vx를 발사 속도로 사용.
            .bullet_vx   = 5,  
            .bullet_w    = 4, .bullet_h = 4, .bullet_ci = 7,
            .spawn_offx  = 3, .spawn_offy = 3,
            .dir_angle = 60,                    // 총알 시작 지점.
            .dir_step  = 30,                    // 발사 Step. 
            .dir_min   = 60,                    // 최소 각도
            .dir_max   = 120,                   // 최대 각도
            .dir_inc   = 1,                     // 1이면 늘어나는 방향, -1이면 감소하는 방향
            .bullets     = {{ {0,0,0,0,0},0,0,0,0 }}
        };

        s->shooters[1] = (ShooterObstacleCfg){
            .body        = { X_MAX-10, s->obstacles[0].y-10, 10,10, 7 },
            .move_cfg   = { .vx=3, .vy=0, .min_x=30, .max_x=LCDW, .min_y=0, .max_y=0 },
            .fire_rate   = 30,
            .fire_timer  = 0,
            .bullet_vx   = 5,  
            .bullet_w    = 4, .bullet_h = 4, .bullet_ci = 7,
            .spawn_offx  = 3, .spawn_offy = 3,
            .dir_angle = 300,                   // 총알 시작 지점.
            .dir_step  = 30,                    // 발사 Step. 
            .dir_min   = 240,                   // 최소 각도
            .dir_max   = 300,                   // 최대 각도
            .dir_inc   = 1,                     // 1이면 늘어나는 방향, -1이면 감소하는 방향
            .bullets     = {{ {0,0,0,0,0},0,0,0,0 }}
        };

        s->shooters[2] = (ShooterObstacleCfg){
            .body        = { 30, Y_MAX-10, 10, 10, 7 },
            .move_cfg   = { .vx=0, .vy=3, .min_x=0, .max_x=0, .min_y=0, .max_y=Y_MAX },
            .fire_rate   = 30,
            .fire_timer  = 0,
            // bullet_vx를 발사 속도로 사용.
            .bullet_vx   = 5,  
            .bullet_w    = 4, .bullet_h = 4, .bullet_ci = 7,
            .spawn_offx  = 3, .spawn_offy = 3,
            .dir_angle = 330,                   // 총알 시작 지점.
            .dir_step  = 30,                    // 발사 Step. 
            .dir_min   = 330,                   // 최소 각도
            .dir_max   = 390,                   // 최대 각도
            .dir_inc   = 1,                     // 1이면 늘어나는 방향, -1이면 감소하는 방향
            .bullets     = {{ {0,0,0,0,0},0,0,0,0 }}
        };

        s->shooters[3] = (ShooterObstacleCfg){
            .body        = { X_MAX-40, 0, 10, 10, 7 },
            .move_cfg   = { .vx=0, .vy=3, .min_x=0, .max_x=0, .min_y=0, .max_y=Y_MAX },
            .fire_rate   = 30,
            .fire_timer  = 0,
            // bullet_vx를 발사 속도 크기로 씀.
            .bullet_vx   = 5,  
            .bullet_w    = 4, .bullet_h = 4, .bullet_ci = 7,
            .spawn_offx  = 3, .spawn_offy = 3,
            .dir_angle = 150,                   // 총알 시작 지점.
            .dir_step  = 30,                    // 발사 Step. 
            .dir_min   = 150,                   // 최소 각도
            .dir_max   = 210,                   // 최대 각도
            .dir_inc   = 1,                     // 1이면 늘어나는 방향, -1이면 감소하는 방향
            .bullets     = {{ {0,0,0,0,0},0,0,0,0 }}
        };

        s->goal         = (QUERY_DRAW){X_MAX - 20, LCDH-225, 20, 20, 1};
        s->char_start_x = 0;
        s->char_start_y = s->platforms[0].y - 20;
    }
}

static void Stage_Init(int idx) {
	int i;
    StageCfg *s = &stages[idx];     
    // clear
    Lcd_Clr_Screen();
    // 캐릭터 설정
    character.x = s->char_start_x;
    character.y = s->char_start_y;
    character.w = CHAR_SIZE_X;
    character.h = CHAR_SIZE_Y;
    character.ci = CHAR_COLOR;
    Draw_Object(&character);
    char_prev_x = character.x;
    char_prev_y = character.y;
    // 플랫폼 그리기
    for(i=0; i<s->platform_count; i++) { 
        Draw_Object(&s->platforms[i]);
        prev_pf_x[i] = s->platforms[i].x;
        prev_pf_y[i] = s->platforms[i].y;
    }
    // 초기 장애물 그리기
    for(i=0; i<s->obstacle_count; i++) {
        Draw_Object(&s->obstacles[i]);
        prev_obs_x[i] = s->obstacles[i].x;
        prev_obs_y[i] = s->obstacles[i].y;
    }
    // 목표 지점 그리기
    Draw_Object(&s->goal);
    // 이동, 점프 상태 초기화
    is_jumping = 0;
    vel_y      = 0;
    Jog_key    = 0;
    Jog_key_in = 0;
}

void Physics_Update(void) {
    if (request_stop) {
        Stop_Character();
        request_stop = 0;
    }
    StageCfg *s = &stages[current_stage];
	int i, j;

    // 이전 위치 백업
    char_prev_x = character.x;
    char_prev_y = character.y;
    for (i = 0; i < s->obstacle_count; ++i) {
        prev_obs_x[i] = s->obstacles[i].x;
        prev_obs_y[i] = s->obstacles[i].y;
    }
    for (i = 0; i < s->platform_count; ++i) {
        prev_pf_x[i] = s->platforms[i].x;
        prev_pf_y[i] = s->platforms[i].y;
    }
    
    // Jump 신호 받기
    if (request_jump && !is_jumping) {
        is_jumping = 1;
        vel_y = JUMP_SPEED;
        request_jump = 0;
    }

    // ────────────────────────────────────────────
    // Auto-fall 체크: 플랫폼 위가 아니면 곧바로 낙하 모드 계산.
    // ────────────────────────────────────────────

    if (!is_jumping) {
        int on_pf = 0;
        int footY = character.y + character.h;
    
        for (i = 0; i < s->platform_count; i++) {
            QUERY_DRAW *pf = &s->platforms[i];      // pf 포인터를 통해 각 플랫폼의 위치를 검사
    
            if (footY >= pf->y - 1 && footY <= pf->y + 1) {
                // 수평 겹침 폭 계산
                int left   = character.x;
                int right  = character.x + character.w;
                int pf_l   = pf->x;
                int pf_r   = pf->x + pf->w;
    
                int overlap = 
                    (right < pf_r ? right : pf_r) 
                  - (left  > pf_l ? left  : pf_l);  // 두 구간이 실제로 겹치는 폭(픽셀 수)을 계산
    
                // 겹침 폭이 캐릭터 폭의 절반 이상일 때만 플랫폼 위로 본다
                if (overlap > character.w / 2) {
                    on_pf = 1;
                    break;
                }
            }
        }
        
        // 플랫폼 위에 있지 않으면 바로 낙하 모드
        if (!on_pf) {
            is_jumping = 1;
            vel_y      = 0;
        }
    }

    // ────────────────────────────────────────────
    // Jump 동작 물리적 계산 : 낙하 or 머리박음 or 화면 밖 나가지 않게.
    // ────────────────────────────────────────────

    if (is_jumping) {
        int currY   = character.y;
        int currTop = currY;
        int nextY   = currY + vel_y;
        int nextTop = nextY;
    
        // 1) 상승 중(vel_y<0) 머리 박음 판정
        if (vel_y < 0) {
            // 천장 충돌
            if (nextTop < Y_MIN) {
                character.y = Y_MIN;      // 맨 위로 고정
                vel_y       = GRAVITY;    // 바로 낙하 시작
            }
            else {
                int hitY = -1;
                for (i = 0; i < s->platform_count; ++i) {
                    QUERY_DRAW *pf = &s->platforms[i];
                    // 플랫폼 머리박음 검사
                    if (character.x + character.w > pf->x &&
                        character.x           < pf->x + pf->w &&
                        currTop  >= pf->y + pf->h &&
                        nextTop  <  pf->y + pf->h) {
                        hitY = pf->y + pf->h;
                        break;
                    }
                }
                if (hitY >= 0) {
                    character.y = hitY;
                    vel_y       = GRAVITY;
                }
                else {
                    character.y = nextY;
                }
            }
        }
        // 2) 낙하 중(vel_y>=0) 착지 판정
        else {
            int currBot = currY + character.h;
            int nextBot = nextY + character.h;
            int landY   = -1;
            for (i = 0; i < s->platform_count; ++i) {
                QUERY_DRAW *pf = &s->platforms[i];
                if (character.x + character.w > pf->x &&
                    character.x           < pf->x + pf->w &&
                    currBot <= pf->y &&
                    nextBot >= pf->y) {
                    if (pf->y > landY) landY = pf->y;
                }
            }
            if (landY >= 0) {
                character.y = landY - character.h;
                is_jumping  = 0;
                vel_y       = 0;
            }
            else {
                character.y = nextY;
            }
        }
    
        // 3) 중력 가속은 충돌 후에 적용
        vel_y += GRAVITY;
    
        // 4) 바닥 바깥으로 나가지 않게만 클램프
        if (character.y + character.h > Y_MAX) {
            character.y = Y_MAX - character.h;
            is_jumping  = 0;
            vel_y       = 0;
        }
    }

    // 캐릭터 좌우 이동 상태 계산.
    if(Jog_key==2||Jog_key==3) CHARICTER_Move(Jog_key);

    // 목표 지점 도착 검사
    if (IsCollide(&character, &s->goal)) {
        current_stage++;
        if (current_stage >= MAX_STAGE) {       // 모든 스테이지 클리어
            game_won = 1;                       // game_won flag 세우고 타이머 정지.
            TIM4_Repeat_Interrupt_Enable(0, 0);
            TIM2_Repeat_Interrupt_Enable(0, 0);
        } else {
            Stage_Init(current_stage);          // 다음 스테이지 바로 초기화
        }
        return; 
    }

    // platforms
    for (i = 0; i < s->platform_count; ++i) {
        PlatformCfg *pc = &s->plat_cfg[i];
        QUERY_DRAW  *pf = &s->platforms[i];

        // platforms x축 이동값 계산
        pf->x += pc->vx;
        if (pf->x < pc->min_x || pf->x + pf->w > pc->max_x) {
            pc->vx = -pc->vx;
            pf->x += pc->vx;
        }
        // platforms y축 이동값 계산
        pf->y += pc->vy;
        if (pf->y < pc->min_y || pf->y + pf->h > pc->max_y) {
            pc->vy = -pc->vy;
            pf->y += pc->vy;
        }

        if (!is_jumping) {
            // 캐릭터 발바닥 Y가 플랫폼 Y와 같고, X축이 겹치면
            int footY = character.y + character.h;
            if (footY == pf->y &&
                character.x + character.w > pf->x &&
                character.x < pf->x + pf->w)
            {
                character.x += pc->vx;
                character.y += pc->vy;
                // 화면 밖으로 밀리지 않도록 클램프
                if (character.x < X_MIN) 
                    character.x = X_MIN;
                else if (character.x + character.w > X_MAX)
                    character.x = X_MAX - character.w;
                if (character.y < Y_MIN)
                    character.y = Y_MIN;
                else if (character.y + character.h > Y_MAX)
                    character.y = Y_MAX - character.h;
            }
        }
    }

    // obstacles
    for (i = 0; i < s->obstacle_count; ++i) {
        ObstacleCfg *c = &s->obs_cfg[i];
        s->obstacles[i].x += c->vx;
        if (s->obstacles[i].x < c->min_x ||
            s->obstacles[i].x + s->obstacles[i].w > c->max_x) {
            c->vx = -c->vx;
            s->obstacles[i].x += c->vx;
        }

        s->obstacles[i].y += c->vy;
        if (s->obstacles[i].y < c->min_y ||
            s->obstacles[i].y + s->obstacles[i].h > c->max_y) {
            c->vy = -c->vy;
            s->obstacles[i].y += c->vy;
        }

        if (IsCollide(&character, &s->obstacles[i])) {
            game_over = 1;                     // 바로 플래그만
            // 타이머 정지
            TIM4_Repeat_Interrupt_Enable(0, 0);
            TIM2_Repeat_Interrupt_Enable(0, 0);
            return;                            // Physics_Update 종료
        }
    }

    // Shooter
    for (i = 0; i < s->shooter_count; ++i) {
        ShooterObstacleCfg *sh = &s->shooters[i];

        sh->prev_x = sh->body.x;
        sh->prev_y = sh->body.y;

        // (1) Shooter 본체 이동 & 바운스
        sh->body.x += sh->move_cfg.vx;
        if (sh->body.x < sh->move_cfg.min_x || sh->body.x + sh->body.w > sh->move_cfg.max_x) {
            sh->move_cfg.vx = -sh->move_cfg.vx;
            sh->body.x    += sh->move_cfg.vx;
        }
        sh->body.y += sh->move_cfg.vy;
        if (sh->body.y < sh->move_cfg.min_y || sh->body.y + sh->body.h > sh->move_cfg.max_y) {
            sh->move_cfg.vy = -sh->move_cfg.vy;
            sh->body.y    += sh->move_cfg.vy;
        }

        if (IsCollide(&character, &sh->body)) {
            game_over = 1;
            // 타이머 정지
            TIM4_Repeat_Interrupt_Enable(0, 0);
            TIM2_Repeat_Interrupt_Enable(0, 0);
            return;  // 즉시 게임 오버 처리
        }

        // (2) 발사 타이머 + 회전 분사 (Stage 9)
        if (current_stage == 8) {
            if (++sh->fire_timer >= sh->fire_rate) {
                sh->fire_timer = 0;
                for (j = 0; j < MAX_BULLETS_PER_SHOOTER; ++j) {
                    Bullet *b = &sh->bullets[j];
                    if (!b->active) {
                        float rad = sh->dir_angle * (M_PI / 180.0f);
                        b->draw.x  = sh->body.x + sh->spawn_offx;
                        b->draw.y  = sh->body.y + sh->spawn_offy;
                        b->draw.w  = sh->bullet_w;
                        b->draw.h  = sh->bullet_h;
                        b->draw.ci = sh->bullet_ci;
                        // 속도 벡터 계산
                        b->vx = (s8)roundf(cosf(rad) * sh->bullet_vx);
                        b->vy = (s8)roundf(sinf(rad) * sh->bullet_vx);
                        b->active = 1;
                        break;
                    }
                }
                // ping-pong 방식으로 각도 갱신
                sh->dir_angle += sh->dir_step * sh->dir_inc;
                if (sh->dir_angle >= sh->dir_max) {
                    sh->dir_angle = sh->dir_max;
                    sh->dir_inc   = -1;
                }
                else if (sh->dir_angle <= sh->dir_min) {
                    sh->dir_angle = sh->dir_min;
                    sh->dir_inc   = 1;
                }
            }
        }
        else {
            if (sh->pause_timer > 0) {
                if (++sh->pause_timer >= sh->burst_pause) {
                    sh->pause_timer = 0;
                    sh->burst_fired = 0;
                }
            } else {
                if (sh->burst_fired < sh->burst_size) {
                    if (++sh->fire_timer >= sh->fire_rate) {
                        sh->fire_timer = 0;
                        for (j = 0; j < MAX_BULLETS_PER_SHOOTER; ++j) {
                            if (!sh->bullets[j].active) {
                                Bullet *b = &sh->bullets[j];
                                b->draw.x  = sh->body.x + sh->spawn_offx;
                                b->draw.y  = sh->body.y + sh->spawn_offy;
                                b->draw.w  = sh->bullet_w;
                                b->draw.h  = sh->bullet_h;
                                b->draw.ci = sh->bullet_ci;
                                b->vx      = sh->bullet_vx;
                                b->vy      = sh->bullet_vy;
                                b->active  = 1;
                                sh->burst_fired++;
                                break;
                            }
                        }
                    }
                } else {
                    sh->pause_timer = 1;
                }
            }
        }

        // (3) 총알 업데이트
        for (j = 0; j < MAX_BULLETS_PER_SHOOTER; ++j) {
            Bullet *b = &sh->bullets[j];
            if (!b->active) continue;
            b->prev_x = b->draw.x;
            b->prev_y = b->draw.y;

            b->draw.x += b->vx;
            b->draw.y += b->vy;
            // 화면 밖 또는 캐릭터 충돌 시 비활성
            if (b->draw.x < 0 || b->draw.x > LCDW ||
                b->draw.y < 0 || b->draw.y > LCDH ||
                IsCollide(&b->draw, &character)) {
                b->active = 0;
                // 캐릭터 맞으면 game_over 처리
                if (IsCollide(&b->draw, &character)) {
                    game_over = 1;
                    TIM4_Repeat_Interrupt_Enable(0,0);
                    TIM2_Repeat_Interrupt_Enable(0,0);
                    return;
                }
            }
        }
    }
}

// ────────────────────────────────────────────
// Render 동작. Object를 지우고 그림.
// ────────────────────────────────────────────
void Render_Update(void) {
    StageCfg *s = &stages[current_stage];
    int i, j, k;
    int ix, iy, iw, ih;
    // 1) Obstacle delta rendering
    for (i = 0; i < s->obstacle_count; i++) {
        QUERY_DRAW *o = &s->obstacles[i];
        int ow = o->w, oh = o->h;
        int ox = prev_obs_x[i], oy = prev_obs_y[i];
        int nx = o->x,           ny = o->y;
        int ix, iy, iw, ih;

        // old_rect 중 intersection 밖 영역만 지우기
        if (intersect_rect(ox,oy,ow,oh, nx,ny,ow,oh, &ix,&iy,&iw,&ih)) {
            if (ox < ix)              Lcd_Draw_Box(ox, oy, ix-ox, oh, color[BACK_COLOR]);
            if (ox+ow > ix+iw)        Lcd_Draw_Box(ix+iw, oy, (ox+ow)-(ix+iw), oh, color[BACK_COLOR]);
            if (oy < iy)              Lcd_Draw_Box(ix, oy, iw, iy-oy, color[BACK_COLOR]);
            if (oy+oh > iy+ih)        Lcd_Draw_Box(ix, iy+ih, iw, (oy+oh)-(iy+ih), color[BACK_COLOR]);
        } else {
            // 겹침 없으면 전체 old_rect 지우기
            Lcd_Draw_Box(ox, oy, ow, oh, color[BACK_COLOR]);
        }

        // 지운 영역에 겹치는 플랫폼만 복구
        for (j = 0; j < s->platform_count; j++) {
            QUERY_DRAW *pf = &s->platforms[j];
            if (rectIntersect(ox,oy,ow,oh, pf->x,pf->y,pf->w,pf->h))
                Draw_Object(pf);
        }
        if (rectIntersect(ox,oy,ow,oh, s->goal.x,s->goal.y,s->goal.w,s->goal.h))
            Draw_Object(&s->goal);

        // 장애물 새 위치 그리기
        Draw_Object(o);
    }

    // 2) Platform delta rendering
    for (i = 0; i < s->platform_count; ++i) {
        QUERY_DRAW *pf = &s->platforms[i];
        int ox = prev_pf_x[i], oy = prev_pf_y[i];
        int ow = pf->w,       oh = pf->h;
        int nx = pf->x,       ny = pf->y;
        int ix, iy, iw, ih;

        // old_rect 중 intersection 밖 영역만 지우기
        if (intersect_rect(ox,oy,ow,oh, nx,ny,ow,oh, &ix,&iy,&iw,&ih)) {
            if (ox < ix)               Lcd_Draw_Box(ox, oy, ix-ox, oh, color[BACK_COLOR]);
            if (ox+ow > ix+iw)         Lcd_Draw_Box(ix+iw, oy, (ox+ow)-(ix+iw), oh, color[BACK_COLOR]);
            if (oy < iy)               Lcd_Draw_Box(ix, oy, iw, iy-oy, color[BACK_COLOR]);
            if (oy+oh > iy+ih)         Lcd_Draw_Box(ix, iy+ih, iw, (oy+oh)-(iy+ih), color[BACK_COLOR]);
        } else {
            // 겹침 없으면 전체 old_rect 지우기
            Lcd_Draw_Box(ox, oy, ow, oh, color[BACK_COLOR]);
        }

        // 지운 영역에 goal만 겹치면 복구
        if (rectIntersect(ox,oy,ow,oh,s->goal.x, s->goal.y, s->goal.w, s->goal.h)) {
            Draw_Object(&s->goal);
        }

        // 발판 새 위치 그리기
        Draw_Object(pf);
    }
    
    // 3) Character delta rendering
    {
        int ox = char_prev_x, oy = char_prev_y;
        int ow = character.w, oh = character.h;
        int nx = character.x, ny = character.y;
        int ix, iy, iw, ih;

        // old_rect 중 intersection 밖 영역만 지우기
        if (intersect_rect(ox,oy,ow,oh, nx,ny,ow,oh, &ix,&iy,&iw,&ih)) {
            if (ox < ix)               Lcd_Draw_Box(ox, oy, ix-ox, oh, color[BACK_COLOR]);                 // 왼쪽 조각
            if (ox+ow > ix+iw)         Lcd_Draw_Box(ix+iw, oy, (ox+ow)-(ix+iw), oh, color[BACK_COLOR]);    // 오른쪽 조각
            if (oy < iy)               Lcd_Draw_Box(ix, oy, iw, iy-oy, color[BACK_COLOR]);                 // 위쪽 조각
            if (oy+oh > iy+ih)         Lcd_Draw_Box(ix, iy+ih, iw, (oy+oh)-(iy+ih), color[BACK_COLOR]);    // 아래쪽 조각
        } else {
            // 겹침 없으면 전체 old_rect 지우기
            Lcd_Draw_Box(ox, oy, ow, oh, color[BACK_COLOR]);  
        }

        // 지운 영역에 겹치는 플랫폼만 복구
        for (j = 0; j < s->platform_count; j++) {
            QUERY_DRAW *pf = &s->platforms[j];
            if (rectIntersect(ox,oy,ow,oh, pf->x,pf->y,pf->w,pf->h))
                Draw_Object(pf);
        }
        // 지운 영역에 goal만 겹치면 복구
        if (rectIntersect(ox,oy,ow,oh, s->goal.x,s->goal.y,s->goal.w,s->goal.h))
            Draw_Object(&s->goal);

        // 캐릭터 새 위치 그리기
        Draw_Object(&character);
    }

    // 4) Shooter delta rendering
    for (i = 0; i < s->shooter_count; ++i) {
        ShooterObstacleCfg *sh = &s->shooters[i];
        int ox = sh->prev_x, oy = sh->prev_y;
        int ow = sh->body.w, oh = sh->body.h;
        int nx = sh->body.x, ny = sh->body.y;
    
        // old_rect 중 intersection 밖 영역만 지우기
        if (intersect_rect(ox,oy,ow,oh, nx,ny,ow,oh, &ix,&iy,&iw,&ih)) {
            if (ox < ix)            Lcd_Draw_Box(ox, oy, ix-ox, oh, color[BACK_COLOR]);
            if (ox+ow > ix+iw)      Lcd_Draw_Box(ix+iw, oy, (ox+ow)-(ix+iw), oh, color[BACK_COLOR]);
            if (oy < iy)            Lcd_Draw_Box(ix, oy, iw, iy-oy, color[BACK_COLOR]);
            if (oy+oh > iy+ih)      Lcd_Draw_Box(ix, iy+ih, iw, (oy+oh)-(iy+ih), color[BACK_COLOR]);
        } else {
            Lcd_Draw_Box(ox, oy, ow, oh, color[BACK_COLOR]);
        }
    
       // 지운 영역에 겹치는 플랫폼 and goal 복구
        for (j = 0; j < s->platform_count; ++j) {
            QUERY_DRAW *pf = &s->platforms[j];
            if (rectIntersect(ox,oy,ow,oh, pf->x,pf->y,pf->w,pf->h))
                Draw_Object(pf);
        }
        if (rectIntersect(ox,oy,ow,oh, s->goal.x,s->goal.y,s->goal.w,s->goal.h))
            Draw_Object(&s->goal);
    
        // 새 위치 shooter 본체 그리기
        Draw_Object(&sh->body);
    }

    // 5) Bullet delta rendering
    for (i = 0; i < s->shooter_count; ++i) {
        ShooterObstacleCfg *sh = &s->shooters[i];
        for (j = 0; j < MAX_BULLETS_PER_SHOOTER; ++j) {
            Bullet *b = &sh->bullets[j];

            // 비활성 총알 : 마지막 위치 배경으로 덮기
            if (!b->active) {
                Lcd_Draw_Box(b->prev_x, b->prev_y,
                             b->draw.w, b->draw.h,
                             color[BACK_COLOR]);
                continue;
            }

            // 활성 총알: 이전 위치의 ‘overlap 제외’ 영역만 지우기
            if (intersect_rect(
                    b->prev_x,  b->prev_y,  b->draw.w, b->draw.h,
                    b->draw.x,  b->draw.y,  b->draw.w, b->draw.h,
                    &ix, &iy, &iw, &ih)) {
                if (b->prev_x < ix)
                    Lcd_Draw_Box(b->prev_x, b->prev_y,
                                 ix - b->prev_x, b->draw.h,
                                 color[BACK_COLOR]);
                if (b->prev_x + b->draw.w > ix + iw)
                    Lcd_Draw_Box(ix + iw, b->prev_y,
                                 (b->prev_x + b->draw.w) - (ix + iw),
                                 b->draw.h,
                                 color[BACK_COLOR]);
                if (b->prev_y < iy)
                    Lcd_Draw_Box(ix, b->prev_y,
                                 iw, iy - b->prev_y,
                                 color[BACK_COLOR]);
                if (b->prev_y + b->draw.h > iy + ih)
                    Lcd_Draw_Box(ix, iy + ih,
                                 iw, (b->prev_y + b->draw.h)-(iy+ih),
                                 color[BACK_COLOR]);
            } else {
                Lcd_Draw_Box(b->prev_x, b->prev_y,
                             b->draw.w, b->draw.h,
                             color[BACK_COLOR]);
            }

            // 지운 영역 위에 platform·goal 복구
            for (k = 0; k < s->platform_count; ++k) {
                QUERY_DRAW *pf = &s->platforms[k];
                if (rectIntersect(
                        b->prev_x, b->prev_y, b->draw.w, b->draw.h,
                        pf->x, pf->y, pf->w, pf->h))
                    Draw_Object(pf);
            }
            if (rectIntersect(
                    b->prev_x, b->prev_y, b->draw.w, b->draw.h,
                    s->goal.x, s->goal.y, s->goal.w, s->goal.h))
                Draw_Object(&s->goal);

            // (2-d) 새 위치에 총알 그리기
            Draw_Object(&b->draw);
        }
    }
}

static void System_Init(void)
{
	Clock_Init();
	LED_Init();
	Key_Poll_Init();
	Jog_Poll_Init();
	Uart1_Init(115200);
	Lcd_Init(DIPLAY_MODE);
    TIM3_Out_Init();

	SCB->VTOR = 0x08003000;
	SCB->SHCSR = 7<<16;
}

static void Win_Screen(void)
{
    Lcd_Clr_Screen();
    Lcd_Printf((LCDW-20*6)/2, LCDH/2-30, WHITE, BLUE, 2, 2, "YOU WIN!");
    Lcd_Printf((LCDW-18*6)/2, LCDH/2+10, WHITE, BLACK, 1, 1, "Press Any Key");

    const int crown_w = 60;
    const int crown_h = 30;
    int cx = (LCDW - crown_w) / 2;        
    int cy = LCDH/2 - 60;                  
    Lcd_Draw_Box(cx,      cy + crown_h - 5, crown_w, 5, YELLOW);
    Lcd_Draw_Box(cx +  5, cy +  8, 10, crown_h - 8, YELLOW);
    Lcd_Draw_Box(cx + 25, cy +  0, 10, crown_h    , YELLOW);
    Lcd_Draw_Box(cx + 45, cy +  8, 10, crown_h - 8, YELLOW);

    Jog_Wait_Key_Pressed();
    Jog_Wait_Key_Released();
}

static void Game_Over_Screen(void) {
    Lcd_Clr_Screen();
    Lcd_Printf((LCDW-25*6)/2, LCDH/2-30, RED, BLACK, 2,2, "GAME OVER!");
    Lcd_Printf((LCDW-18*6)/2, LCDH/2+10, WHITE, BLACK, 1,1, "Press Any Key");
    Jog_Wait_Key_Pressed();
    Jog_Wait_Key_Released();
}

static void Game_Start_Screen(void)
{
    Lcd_Clr_Screen();
    Lcd_Draw_Back_Color(BLACK);  
    Lcd_Printf(135, 20,  WHITE, BLACK, 2, 2, "The");
    Lcd_Printf(20, 60,  WHITE, BLACK, 2, 2, "Strange Adventure");
    Lcd_Printf(70, 120, WHITE, BLACK, 1, 1, "Press any key to start");
    const int S = 20;
    int cx = (LCDW - S) / 2;
    int cy = LCDH - 40;
    Lcd_Draw_Box(cx,     cy, S, S, color[0]);   
    Lcd_Draw_Box(cx - 40, cy, S, S, color[4]);   
    Lcd_Draw_Box(cx + 40, cy, S, S, color[1]);   
    Lcd_Draw_Box(cx,     cy - 40, S, S, color[7]); 
    Jog_Wait_Key_Pressed();
    Jog_Wait_Key_Released();
}

void Main(void)
{
	System_Init();
	DefineStages();
    Game_Start_Screen();
    Stage_Init(0);

    // BGM 초기화
    bgm_idx   = 0;
    Note n0   = bgmTheme[0];
    TIM3_Out_Freq_Generation( SemitoneToFreq(n0.tone) );
    bgm_timer = n0.dur;
    bgm_idx++;

	Jog_ISR_Enable(1);
	Uart1_RX_Interrupt_Enable(1);

    SysTick_OS_Tick(1);
	TIM4_Repeat_Interrupt_Enable(1, PHYSICS_PERIOD);
    TIM2_Repeat_Interrupt_Enable(1, RENDER_PERIOD);

	for(;;)
	{
        if (USART1_rx_ready) {
            char ch = (char)USART1_rx_data;
            USART1_rx_ready = 0;
    
            if (ch == '0') {
                // 0을 누르면 강제 클리어 처리
                game_won = 1;
                // 물리·렌더 타이머 정지
                TIM4_Repeat_Interrupt_Enable(0, 0);
                TIM2_Repeat_Interrupt_Enable(0, 0);
            }
            else if (ch >= '1' && ch < '1' + MAX_STAGE) {
                int new_stage = ch - '1';
                // 스테이지 변경 및 상태 초기화
                current_stage = new_stage;
                game_over     = 0;
                game_won      = 0;
                Jog_key       = 0;
                Jog_key_in    = 0;
    
                // 타이머 재시작
                TIM4_Repeat_Interrupt_Enable(1, PHYSICS_PERIOD);
                TIM2_Repeat_Interrupt_Enable(1, RENDER_PERIOD);
                // 화면 초기화
                Stage_Init(current_stage);
            }
        }

        // 1) Render_Update 호출
        if (TIM4_Expired) {
            Physics_Update();
            TIM4_Expired = 0;
        }

        // 2) Physics_Update 호출
        if (TIM2_Expired) {
            Render_Update();
            TIM2_Expired = 0;
        }

        if (game_won) {
            Uart1_Printf("Death Count : %d\r\n", death_count);
            Uart1_Printf("Clear time : %02lu min, %02lu sec\r\n", (msTicks / 1000) / 60, (msTicks / 1000) % 60);
            while (!(USART1->SR & USART_SR_TC));
            Win_Screen();
            SysTick_OS_Tick(0);
            TIM3_Out_Stop();
            death_count = 0;
            msTicks = 0;
            Game_Start_Screen();
            bgm_idx = 0;
            {
                Note n0 = bgmTheme[0];
                TIM3_Out_Freq_Generation( SemitoneToFreq(n0.tone) );
                bgm_timer = n0.dur;
                bgm_idx++;
            }
            SysTick_OS_Tick(1);
            DefineStages();       
            current_stage = 0;
            game_won = 0;
            Stage_Init(0);
            TIM4_Repeat_Interrupt_Enable(1, PHYSICS_PERIOD);
            TIM2_Repeat_Interrupt_Enable(1, RENDER_PERIOD);
        }

		if (game_over) {
            death_count++;
            Game_Over_Screen();
            Stage_Init(current_stage);            
            game_over = 0;
            TIM4_Repeat_Interrupt_Enable(1, PHYSICS_PERIOD);
            TIM2_Repeat_Interrupt_Enable(1, RENDER_PERIOD);
        }
	}	
}