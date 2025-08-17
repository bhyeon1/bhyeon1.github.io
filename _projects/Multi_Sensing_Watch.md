---
title: Multi Sensing Watch project
order : 2
subtitle: FPGA 기반 실시간 센서 통합 감지 시스템
description: ""
layout: page
permalink: /projects/Multi_Sensing_Watch
image: /img/watch/basys3.jpg
tags : [Vivado, FPGA, Verilog]
---

<br>

<!-- ✅ 중앙 정렬된 이미지 -->
<div style="text-align: center;">
  <img src="/img/watch/title.jpg" style="max-width: 1200px; width: 80%; border-radius: 12px;" />
</div>

<br>

<h1 style="font-size: 44px; font-weight: bold;">개요</h1>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 26px; line-height: 1.4; margin-left: 10px;">
2025.05.29 ~ 2025.06.02
</p>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>센서 입력 수집 : DHT11(온·습도), HC-SR04(초음파), 버튼 동기화</li>
  <li>센서 제어·데이터 처리: 타이밍 FSM, checksum 검증</li>
  <li>디스플레이 전환 제어: 선택 센서 값 MUX → FND 다중화 출력</li>
  <li>실시간 시각화: 주기적 갱신으로 상태 모니터링</li>
</ul>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">하드웨어</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>Basys 3 (FPGA 보드)
    <ul>
      <li>클럭 입력: 100 MHz</li>
      <li>I/O 전압: 3.3 V LVCMOS</li>
    </ul>
  </li>
  <li>HC-SR04 (초음파 센서)
    <ul>
      <li>측정 거리 : 2~400cm</li>
      <li>트리거 입력 신호 : 10us TTL</li>
    </ul>
  </li>  
  <li>DHT11 (온·습도 센서)
    <ul>
      <li>온도 범위 : 0 ~ 50ºC</li>
      <li>습도 범위 : 20 ~ 90 % RH</li>
      <li>전원 공급 : 3 ~ 5.5 VDC</li>
    </ul>
  </li>  
</ul>

---
<br>
<h1 style="font-size: 44px; font-weight: bold;">개발 결과</h1>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">스테이지 구성</h2>
<p style="font-size: 26px; line-height: 1.4; margin-left: 10px;">
3개의 난이도(level 1, level 2, level 3)가 있고, 각 난이도마다 3개의 stage로 총 9개의 stage로 구성.
</p>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">주요 기능</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>물리적 계산과 렌더링(화면 갱신) 분리를 통해 60FPS 속도로 부드러운 게임 플레이 가능</li>
  <li>델타 렌더링을 통해 Jittering 현상을 제거하여 게임의 실시간성을 잘 반영</li>
</ul>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">게임 설명</h2>
<img src="/img/game_project/game_image.jpg" width="100%">

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">시연 영상</h2>

<video controls width="100%" preload="metadata" playsinline>
  <source src="{{ '/videos/The_Strange_Adventure_v2.mp4?v=2' | relative_url }}" type="video/mp4">
  <p>동영상이 재생되지 않으면 <a href="{{ '/videos/The_Strange_Adventure_v2.mp4' | relative_url }}">여기</a>를 클릭하세요.</p>
</video>

---

<br>
<h1 style="font-size: 44px; font-weight: bold;">핵심 기술 및 코드</h1>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">1. 코드 흐름 (Main) </h2>
<img src="/img/game_project/main_flow.jpg" width="100%">

<br>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">2. 점프 동작 </h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>점프를 했을 때 발생하는 모든 경우들을 미리 계산한 후, 렌더링을 통해 반영</li>
  <li>중력이 작용하는 것 처럼 초기 점프속도를 설정 후, 중력 가속도를 설정하여 속도가 점차 감소</li>
</ul>
<img src="/img/game_project/jump.jpg" width="50%">

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">3. 스테이지 구성 (구조체)</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
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

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">4. object 동작</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
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

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">5. Delta rendering</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>Jittering 문제 원인 : Physics (물리적 계산)는 매우 빠르게 진행되고, object를 그리는 rendering은 매우 느림. (Rendering은 픽셀로 큰 정보를 넘겨야 하기 때문.) </li>
  <li>해결 방법 : delta rendering 방법 고안.</li>
  <li>기존 방식인 Full render는 20 x 20 px의 캐릭터를 2px 이동시킬 때, 20 x 20 영역을 지우고 20 x 20 영역을 다시 그림. 총 400px + 400px = 800px이 소요. </li>
  <li>새로운 방식인 delta render는 20 x 20 px의 캐릭터를 2px 이동시킬 때, 겹치는 20 x 2 영역만 지우고 20 x 2 영역만큼만 다시 그림. 총 40px + 40px = 80px이 소요. 즉, 훨씬 더 빠르게 rendering 가능.</li>
</ul>
<img src="/img/game_project/rendering.jpg" width="70%">

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">6. BGM (PWM)</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
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

<br>
<h1 style="font-size: 44px; font-weight: bold;">트러블 슈팅</h1>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">1. 점프 동작 개선</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>문제 : 입력 타이머 기반 점프 -> 에어 컨트롤(점프 후 좌우이동) 부자연스러움.</li>
  <li>접근 : Systic 타이머 기반 고정 dt physics 업데이트 + FSM 으로 수직, 수평 순으로 충돌 해소. </li>
  <li>처리 : 이동 플랫폼 상대속도 반영, 천장/벽 충돌 시 속도 클램핑 + 위치 보정. </li>
  <li>결과 : 점프 중 좌우 제어 일관성·응답성 향상, 머리 박음·벽 끼임 제거, 안정적 착지. </li>
</ul>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">2. rendering 개선</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>문제 : 전체 refresh 기반 rendering -> object 증가 시 jittering 발생.</li>
  <li>접근 : Delta rendering 적용 -> 이전 / 현재 위치의 차이 영역 (Dirty Rect)만 갱신. </li>
  <li>결과 : 불필요한 지우기 / 그리기 최소화 -> jittering 해소, 프레임 안정성 개선. </li>
</ul>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">3. RAM overflow</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>문제 : C:\CodeSourcery\Sourcery G++ Lite/bin/arm-none-eabi-ld: region RAM' overflowed by 10544 bytes 오류로 bin 파일 생성 실패.
  </li>
  <li>접근 : 메모리 사용량을 줄이기 위해 구조체 타입 및 매크로 상수 최적화</li>
  <li>결과 : 동일 기능 유지 상태에서 RAM 사용량 대폭 감소 -> RAM overflow 해소 </li>
</ul>
<img src="/img/game_project/overflow.jpg" width="100%">

---

<br>
<h1 style="font-size: 44px; font-weight: bold;">결론 및 고찰</h1>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">성과</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>60 FPS를 안정적으로 유지하며 실시간 응답성을 확보함.</li>
  <li>전체 지우기 -> 다시 그리기 방식에서 delta renering으로 전환하여 jittering 해소. </li>
</ul>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">한계</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>수직 이동 플랫폼 탑승 동작은 미완성. 플랫폼 상대 속도 반영과 수직→수평 순서의 충돌 해소가 추가로 필요.</li>
  <li>시각적 완성도가 아쉬움. 배경, 스프라이트 애니메이션, 파티클/효과 등 그래픽 요소가 부족해 화면이 단조롭게 보임. </li>
</ul>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">개선 방향</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>이동 플랫폼 상호작용 고도화: 플랫폼 속도/가속도 상대좌표 적용, 머리·벽 충돌에 대한 연속 충돌 처리(continuous) 및 위치 보정 로직 보강.</li>
  <li>비주얼 업그레이드: 레이어드 배경(패럴랙스), 스프라이트 시트/프레임 애니메이션, 파티클/피드백 이펙트 추가. </li>
</ul>
