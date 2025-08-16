---
title: The Strange Adventure
subtitle: STM32 기반 장애물 회피 2D 게임 프로젝트
description: ""
layout: page
permalink: /projects/game_project
image: /img/game_project/game_project_image.jpg
---

<br>

<!-- ✅ 중앙 정렬된 이미지 -->
<div style="text-align: center;">
  <img src="/img/game_project/game_project_image.jpg" alt="게임 이미지" style="max-width: 600px; width: 90%; border-radius: 12px;" />
</div>

<br>

<h1 style="font-size: 44px; font-weight: bold;">개요</h1>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 26px; line-height: 1.4; margin-left: 10px;">
2024.11.22 ~ 2024.11.26
</p>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<p style="font-size: 26px; line-height: 1.4; margin-left: 10px;">
STM32 M3 코어 기반 2D 플랫폼 게임을 설계·구현하여 UART 통신 및 GPIO 포트 활용 능력을 향상시키고, 타이머 인터럽트 기반 게임 루프 제어 및 사용자 입력 처리로 Event-Driven 프로그래밍 설계 역량을 강화하는 것을 목표로 함.
</p>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">하드웨어</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>MCU : 72MHz ARM Cortex-M3 프로세서</li>
  <li>디스플레이 : 320x240 해상도 컬러 LCD 디스플레이</li>
  <li>입력 장치 : Jog 키, push button (KEY0, KEY1)</li>
  <li>통신 방식 : UART (보드 <-> 데스크탑)</li>
</ul>

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">주요 기능</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>Jog키를 사용하여 플레이어 이동 기능 구현</li>
  <li>button을 사용하여 플레이어의 점프 기능 구현 (플랫폼 올라타기, 머리 박음 판정)</li>
  <li>움직이는 장애물 및 총알 발사 기능 구현</li>
  <li>UART를 통해 Clear time, Death count를 Display</li>
</ul> <br>

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

<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">2. 점프 동작 </h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>점프를 했을 때 발생하는 모든 경우들을 미리 계산한 후, 렌더링을 통해 반영</li>
  <li>중력이 작용하는 것 처럼 초기 점프속도를 설정 후, 중력 가속도를 설정하여 속도가 점차 감소</li>
</ul>
<img src="/img/game_project/jump.jpg" width="50%">


<h2 style="font-size: 30px; font-weight: bold; margin-top: 1.6em;">3. 오브젝트 동작</h2>
<ul style="font-size: 26px; line-height: 1.4; margin-left: 30px;">
  <li>X축과 Y축으로 이동하는 속도를 반영하여 계산. 최대 범위를 만났을 때는 반전.</li>
  <li>디스플레이 : 320x240 해상도 컬러 LCD 디스플레이</li>
  <li>입력 장치 : Jog 키, push button (KEY0, KEY1)</li>
  <li>통신 방식 : UART (보드 <-> 데스크탑)</li>
</ul>

{% highlight c linenos %}
static void gpioLedSet(long val) {
    for (int i = 0; i < GPIOCNT; i++) {
        gpio_set_value(gpioLed[i], (val & (0x01 << i)));
    }
}
{% endhighlight %}