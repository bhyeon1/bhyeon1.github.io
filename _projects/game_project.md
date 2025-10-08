---
title: The Strange Adventure
order : 5
subtitle: STM32 기반 장애물 회피 2D 게임 프로젝트
description: ""
layout: page
permalink: /projects/game_project/
image: /img/game_project/game_project_image.jpg
tags : [STM32, C]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.04.25 ~ 2025.05.04
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
STM32 M3 코어 기반 2D 플랫폼 게임을 설계·구현하여 UART 통신 및 GPIO 포트 활용 능력을 향상시키고, <br> 타이머 인터럽트 기반 게임 루프 제어 및 사용자 입력 처리로 Event-Driven 프로그래밍 설계 역량을 강화하는 것을 목표로 함.
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">하드웨어</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>MCU : 72MHz ARM Cortex-M3 프로세서</li>
  <li>디스플레이 : 320x240 해상도 컬러 LCD 디스플레이</li>
  <li>입력 장치 : Jog 키, push button (KEY0, KEY1)</li>
  <li>통신 방식 : UART (보드 <-> 데스크탑)</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">주요 기능</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Jog키를 사용하여 플레이어 이동 기능 구현</li>
  <li>button을 사용하여 플레이어의 점프 기능 구현 (플랫폼 올라타기, 머리 박음 판정)</li>
  <li>움직이는 장애물 및 총알 발사 기능 구현</li>
  <li>UART를 통해 Clear time, Death count를 Display</li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">개발 결과</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">스테이지 구성</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
3개의 난이도(level 1, level 2, level 3)가 있고, 각 난이도마다 3개의 stage로 총 9개의 stage로 구성.
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">성능</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>물리적 계산과 렌더링(화면 갱신) 분리를 통해 60FPS 속도로 부드러운 게임 플레이 가능</li>
  <li>델타 렌더링을 통해 Jittering 현상을 제거하여 게임의 실시간성을 잘 반영</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">게임 설명</h2>
<img src="/img/game_project/game_image.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">시연 영상</h2>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage1.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage1.gif' | relative_url }}" alt="Stage 1"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 1</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage2.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage2.gif' | relative_url }}" alt="Stage 2"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 2</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage3.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage3.gif' | relative_url }}" alt="Stage 3"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 3</div>
    </a>
  </div>
  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage4.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage4.gif' | relative_url }}" alt="Stage 4"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 4</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage5_6.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage5_6.gif' | relative_url }}" alt="stage 5, 6"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 5, 6</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage7.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage7.gif' | relative_url }}" alt="Stage 7"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 7</div>
    </a>
  </div>
  
  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage8.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage8.gif' | relative_url }}" alt="Stage 8"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 8</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage9.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage9.gif' | relative_url }}" alt="Stage 9"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stage 9</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/game_over.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/game_over.gif' | relative_url }}" alt="Game over"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Game over Screen</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/win.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/win.gif' | relative_url }}" alt="Win"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Win Screen</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/game_project/score.jpg' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/game_project/score.jpg' | relative_url }}" alt="Death Count & Clear Time"
            loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Death Count 및 Clear time</div>
    </a>
  </div>
</div>

<div id="lb" style="display:none;position:fixed;inset:0;z-index:9999;
  background:rgba(0,0,0,.82);backdrop-filter:saturate(120%) blur(2px);
  align-items:center;justify-content:center;padding:8px;
  overflow:auto;"> 
  <img id="lb-img" alt="preview"
       style="max-width:98vw;max-height:96vh;  
              width:auto;height:auto;display:block;
              border-radius:14px;box-shadow:0 10px 30px rgba(0,0,0,.4)">
  <button id="lb-x" aria-label="닫기" title="닫기"
          style="position:absolute;top:10px;right:14px;border:0;background:transparent;
                 color:#fff;font-size:34px;cursor:pointer;line-height:1;">×</button>
</div>

<script>
(function(){
  const grid = document.getElementById('demo-gifs');
  const lb   = document.getElementById('lb');
  const img  = document.getElementById('lb-img');
  const xBtn = document.getElementById('lb-x');

  grid.addEventListener('click', function (e) {
    const a = e.target.closest('a');
    if (!a) return;
    e.preventDefault();
    img.src = a.getAttribute('href'); // 클릭한 카드의 href = 원본 GIF
    lb.style.display = 'flex';
  });

  function closeLB(){ lb.style.display='none'; img.src=''; }
  lb.addEventListener('click', (e)=> { if (e.target === lb) closeLB(); });
  xBtn.addEventListener('click', closeLB);
  document.addEventListener('keydown', (e)=> { if (e.key === 'Escape') closeLB(); });
})();
</script>

---

<h1 style="font-size: 36px; font-weight: bold;">핵심 기술 및 코드</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. 코드 흐름 (Main) </h2>
<img src="/img/game_project/main_flow.jpg" width="100%">

<br>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. 점프 동작 </h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>점프를 했을 때 발생하는 모든 경우들을 미리 계산한 후, 렌더링을 통해 반영</li>
  <li>중력이 작용하는 것 처럼 초기 점프속도를 설정 후, 중력 가속도를 설정하여 속도가 점차 감소</li>
</ul>
<img src="/img/game_project/jump.jpg" width="40%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">3. 스테이지 구성 (구조체)</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>데이터 코드 분리 : 스테이지는 StageCfg 데이터만 바꾸면 생성·동작. 엔진 코드를 수정하지 않고도 레벨을 추가/수정 가능.</li>
  <li>일관된 업데이트 파이프라인 : 플랫폼/장애물/발사체(슈터) 이동·충돌·렌더링을 공통 루프에서 처리.</li>
  <li>확장 용이성 : PlatformCfg, ObstacleCfg, ShooterObstacleCfg로 개별 행동 규칙을 주입.</li>
</ul>

```c
typedef struct {
    u8           	       platform_count;                // 발판 개수
    QUERY_DRAW    	       platforms[MAX_PLATFORMS];      // 발판 정보 배열
    PlatformCfg                plat_cfg[MAX_PLATFORMS];       // 발판 이동 정보

    u8           	       obstacle_count;                // 장애물 개수
    QUERY_DRAW    	       obstacles[MAX_OBSTACLES];      // 장애물 정보 배열
    ObstacleCfg   	       obs_cfg[MAX_OBSTACLES];        // 장애물별 이동 설정 배열

    u8                         shooter_count;
    ShooterObstacleCfg         shooters[MAX_SHOOTERS];

    QUERY_DRAW                 goal;                          // 목표 위치 추가

    s16                        char_start_x, char_start_y;    // 캐릭터 x, y축 위치
} StageCfg;
```
<br>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">4. object 동작</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>platform, obstacle 동작 : x축과 y축으로 이동하는 속도를 반영하여 계산. 최대 범위를 만났을 때는 반전.</li>
  <li>bullet 동작 : 화면 밖으로 나가거나 캐릭터에 맞았을 때 총알 비활성화. cos, sin함수를 사용하여 발사 각도 계산</li>
  <li>충돌 감지 함수 : 박스가 겹치면 1을 return.</li>
</ul>

```c
static int IsCollide(QUERY_DRAW *a, QUERY_DRAW *b) { 	
    return (a->x < b->x + b->w) &&						
           (a->x + a->w > b->x) &&						
           (a->y < b->y + b->h) &&						
           (a->y + a->h > b->y);						
}
```
<br>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">5. Delta rendering</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Jittering 문제 원인 : Physics (물리적 계산)는 매우 빠르게 진행되고, object를 그리는 rendering은 매우 느림. (Rendering은 픽셀로 큰 정보를 넘겨야 하기 때문.) </li>
  <li>해결 방법 : delta rendering 방법 고안.</li>
  <li>기존 방식인 Full render는 20 x 20 px의 캐릭터를 2px 이동시킬 때, 20 x 20 영역을 지우고 20 x 20 영역을 다시 그림. 총 400px + 400px = 800px이 소요. </li>
  <li>새로운 방식인 delta render는 20 x 20 px의 캐릭터를 2px 이동시킬 때, 겹치는 20 x 2 영역만 지우고 20 x 2 영역만큼만 다시 그림. 총 40px + 40px = 80px이 소요. 즉, 훨씬 더 빠르게 rendering 가능.</li>
</ul>
<img src="/img/game_project/rendering.jpg" width="70%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">6. BGM (PWM)</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>원리: TIM3 PWM 주파수로 버저 음 생성, 음계는 12평균율 f = 130 × 2^(st/12)로 변환. </li>
  <li>구현: bgmTheme[(tone,dur)] 테이블을 SysTick에서 순환 → 타이머가 0되면 ARR만 갱신(PSC 고정, duty 50%)하여 다음 음 재생.</li>
  <li>결과: 게임 루프와 논블로킹으로 동작, 반복 재생 안정적. 음계 / 템포 변경은 테이블 교체만으로 처리. </li>
</ul>

```c
unsigned short SemitoneToFreq(unsigned char st) {       // 주파수 계산 함수
    float f = 130.0f * powf(2.0f, st/12.0f);
    return (unsigned short)(f + 0.5f);
}

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
```


---

<h1 style="font-size: 36px; font-weight: bold;">트러블 슈팅</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. 점프 동작 개선</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 : 입력 타이머 기반 점프 -> 에어 컨트롤(점프 후 좌우이동) 부자연스러움.</li>
  <li>접근 : Systic 타이머 기반 고정 dt physics 업데이트 + FSM 으로 수직, 수평 순으로 충돌 해소. </li>
  <li>처리 : 이동 플랫폼 상대속도 반영, 천장/벽 충돌 시 속도 클램핑 + 위치 보정. </li>
  <li>결과 : 점프 중 좌우 제어 일관성·응답성 향상, 머리 박음·벽 끼임 제거, 안정적 착지. </li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. rendering 개선</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 : 전체 refresh 기반 rendering -> object 증가 시 jittering 발생.</li>
  <li>접근 : Delta rendering 적용 -> 이전 / 현재 위치의 차이 영역 (Dirty Rect)만 갱신. </li>
  <li>결과 : 불필요한 지우기 / 그리기 최소화 -> jittering 해소, 프레임 안정성 개선. </li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">3. RAM overflow</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 : C:\CodeSourcery\Sourcery G++ Lite/bin/arm-none-eabi-ld: region RAM' overflowed by 10544 bytes 오류로 bin 파일 생성 실패.
  </li>
  <li>접근 : 메모리 사용량을 줄이기 위해 구조체 타입 및 매크로 상수 최적화</li>
  <li>결과 : 동일 기능 유지 상태에서 RAM 사용량 대폭 감소 -> RAM overflow 해소 </li>
</ul>

```c
// 매크로 상수 최적화
#define MAX_STAGE               (9)
#define MAX_PLATFORMS           (11)
#define MAX_OBSTACLES           (6)
#define MAX_SHOOTERS            (1)
#define MAX_BULLETS_PER_SHOOTER (5)

// 구조체 타입 최적화
typedef signed char s8; typedef unsigned char u8; typedef signed short u8; typedef unsigned short u16;

typedef struct {
  u16 x, y;
  u16 w, h;
  u8 ci;
} QUERY_DRAW;

typedef struct {
  s8  vx, vy;
  s16 min_x, max_x;
  s16 min_y, max_y;
} PlatformCfg;
```
---

<h1 style="font-size: 36px; font-weight: bold;">결론 및 고찰</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">성과</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>60 FPS를 안정적으로 유지하며 실시간 응답성을 확보함.</li>
  <li>전체 지우기 -> 다시 그리기 방식에서 delta renering으로 전환하여 jittering 해소. </li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">한계</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>수직 이동하는 플랫폼 탑승 동작은 미완성. 플랫폼 상대 속도 반영과 수직→수평 순서의 충돌 해소가 추가로 필요.</li>
  <li>시각적 완성도가 아쉬움. 배경, 스프라이트 애니메이션, 파티클/효과 등 그래픽 요소가 부족해 화면이 단조롭게 보임. </li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개선 방향</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>이동 플랫폼 상호작용 고도화: 플랫폼 속도/가속도 상대좌표 적용, 머리·벽 충돌에 대한 연속 충돌 처리(continuous) 및 위치 보정 로직 보강.</li>
  <li>비주얼 업그레이드: 레이어드 배경(패럴랙스), 스프라이트 시트/프레임 애니메이션, 파티클/피드백 이펙트 추가. </li>
</ul>

---

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">GitHub Source</h2>
<div class="has-text-centered">
  <a class="button is-dark is-rounded gh-btn"
     href="https://github.com/bhyeon1/bhyeon1.github.io/tree/main/projects_source/game_project"
     target="_blank" rel="noopener"
     style="padding:10px 48px; border-radius:9999px; display:inline-flex; justify-content:center;">
    <span>GitHub</span>
  </a>
</div>