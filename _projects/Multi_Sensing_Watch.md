---
title: Multi Sensing Watch project
order : 6
subtitle: FPGA 기반 실시간 센서 통합 감지 시스템
description: ""
layout: page
permalink: /projects/Multi_Sensing_Watch/
image: /img/watch/basys3.jpg
tags : [Vivado, FPGA, Verilog]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.05.21 ~ 2025.06.02
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>UART, HC-SR04, DHT11 Controller 등 FPGA 설계 및 통합 SoC 시스템 구현 </li>
  <li>Basys 3 보드의 스위치, 버튼, UART를 통한 모드 변경을 FSM으로 구현</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">하드웨어</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
</p>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>Basys 3</strong></li>
    <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>클럭 입력 : 100MHz</li>
      <li>I/O 전압 : 3.3V LVCMOS</li>
    </ul>
  <li><strong>HC-SR04 (초음파 센서)</strong></li>
    <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>측정 거리 : 2cm ~ 400cm</li>
      <li>트리거 입력 신호 : 10us TTL</li>
    </ul>
  <li><strong>DHT11 (온습도 센서)</strong></li>
    <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>온도 범위 : 0 ~ 50℃</li>
      <li>습도 범위 : 20 ~ 90% RH</li>
      <li>전원 공급 : 3 ~ 5.5 VDC</li>
    </ul>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>사용 언어 : Verilog</li>
  <li>Tool : Vivado, draw.io </li>
  <li>editor : VS Code</li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">기본 모듈 설계</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Top Module Blockdiagram</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
버튼, 스위치, UART 입력 기반 각 센서 및 시게 기능 중심 제어
</p>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>WATCH : 시계 및 스톱워치 기능 처리</li>
  <li>UART_CNTL : 데이터 시리얼 통신 (전송 및 수신) </li>
  <li>SR04 : 초음파 센서 거리 측정</li>
  <li>DHT11 : 온습도 데이터 수신</li>
  <li>FND_CNTR : 데이터 공통 FND 표시</li>
</ul>
<img src="/img/watch/Top.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Watch/Stopwatch Module Blockdiagram</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Watch : 시간-분-초 단위 시간 카운팅</li>
  <li>Stopwatch : 시작 / 정지 / 리셋 기능 타이머</li>
  <li>FND_CNTR : 시간 데이터 FND 표시</li>
  <li>pos_sel : 시간 셋팅 시 FND 깜빡임</li>
</ul>
<img src="/img/watch/watch.jpg" width="70%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">UART Module Blockdiagram</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>UART Sender : 송신할 문자열 포맷 생성</li>
  <li>UART_Tx : 센서 측정 데이터 전송</li>
  <li>UART_Rx : 사용자 입력 (버튼, 스위치)</li>
  <li>Tx : UART 송신 라인 (FPGA -> PC)</li>
  <li>Rx : UART 수신 라인 (PC -> FPGA)</li>
</ul>
<img src="/img/watch/Uart.jpg" width="70%">

---
<h1 style="font-size: 36px; font-weight: bold;">SR04 모듈 설계</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">동작 원리</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Trigger 핀에 10us의 펄스 -> 초음파 발생</li>
  <li>8 cycle 초음파 (40kHz) 송출</li>
  <li>반사된 초음파가 Echo 핀 도달 시간 측정</li>
  <li>Distance : 시간(us) x 속도(340m/s) / 2 </li>
</ul>
<img src="/img/watch/sr04_work.png" width="60%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">FSM</h2>
<img src="/img/watch/sr04_fsm.png" width="80%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">ASM</h2>
<img src="/img/watch/sr04_asm.png" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Blockdiagram</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Start_trigger : 시작 후 Trigger 신호 10us 동안 출력</li>
  <li>Tick_gen : 1us 단위 tick 생성</li>
  <li>FND_CNTR : 계산된 거리 값 FND 표시</li>
  <li>Distance : echo 신호 펄스 폭을 측정, 거리 계산</li>
</ul>
<img src="/img/watch/sr04.jpg" width="70%">

---

<h1 style="font-size: 36px; font-weight: bold;">DHT11 모듈 설계</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">통신 흐름</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>1. MCU에서 18ms이상의 Low 신호를 DHT11 센서로 보냄</li>
  <li>2. DHT11 응답 (80us Low -> 80us HIGH)</li>
  <li>3. DHT11에서 총 40 비트의 데이터를 MCU로 전송</li>
</ul>
<img src="/img/watch/dht11_work.png" width="40%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">비트 판별 방법</h2>
<img src="/img/watch/dht11_bit.png" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">FSM</h2>
<img src="/img/watch/dht11_fsm.png" width="60%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">ASM</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>1. 초기 구동 ASM 상태</li>
  <li>2. 데이터 수신 ASM 상태</li>
  <li>3. 데이터 유효성 검사 및 ASM 종료</li>
</ul>
<img src="/img/watch/dht11_asm.png" width="60%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Blockdiagram</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>DHT11_CNTL : DHT11 센서 데이터 수신 FSM 제어</li>
  <li>FND_CNTL : 수신된 온습도 값 FND 출력</li>
</ul>
<img src="/img/watch/dht11.jpg" width="60%">

---

<h1 style="font-size: 36px; font-weight: bold;">시뮬레이션 및 검증</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">sr04 검증 결과</h2>
<img src="/img/watch/sr04_test.jpg" width="90%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">dht11 검증 결과</h2>
<img src="/img/watch/dht11_test.jpg" width="90%">

---

<h1 style="font-size: 36px; font-weight: bold;">동작 영상</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">버튼 및 스위치 제어</h2>
<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/watch_1.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/watch_1.gif' | relative_url }}" alt="Watch 1"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">초기 시작 (모든 sw off) : Watch mode</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/watch_2.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/watch_2.gif' | relative_url }}" alt="Watch 2"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">sw0를 통해 어떤 시간을 표시할지 도메인 선택</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/watch_setting_btn.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/watch_setting_btn.gif' | relative_url }}" alt="Watch_Setting_Btn"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">좌우 버튼 : 시간 도메인 이동 / 상하 버튼 : 시간 설정</div>
    </a>
  </div>
  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/stopwatch_btn.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/stopwatch_btn.gif' | relative_url }}" alt="Stopwatch_Btn"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stopwatch mode</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/sr04_btn.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/sr04_btn.gif' | relative_url }}" alt="SR04_Btn"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">SR04 sensor mode</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/dht11_btn.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/dht11_btn.gif' | relative_url }}" alt="DHT11_Btn"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">dht11 sensor mode</div>
    </a>
  </div>
</div>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Uart 제어</h2>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/watch_setting_uart.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/watch_setting_uart.gif' | relative_url }}" alt="Watch_Setting_UART"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Watch setting mode</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/stopwatch_uart.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/stopwatch_uart.gif' | relative_url }}" alt="Stopwatch_UART"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Stopwatch mode</div>
    </a>
  </div>

  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    dht11_uart<a href="{{ '/gif/watch/sr04_uart.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/sr04_uart.gif' | relative_url }}" alt="SR04_UART"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">SR04 sensor mode</div>
    </a>
  </div>
  <div class="column is-one-third-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/watch/dht11_uart.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/watch/dht11_uart.gif' | relative_url }}" alt="dht11 sensor mode"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">dht11 sensor mode</div>
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

<h1 style="font-size: 36px; font-weight: bold;">트러블 슈팅</h1>
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. 최종 merge 후 setup timing violation</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 상황 : 최종 merge 후 Negative Slack 발생. (-4.608ns)</li>
  <li>원인 분석 : SR04 CTRL에 측정된 Distance 값 -> UART_Sender로 전달.</li>
  <li>해결 방법 : Uart_Sender 단에서 불필요한 나누기 연산 축소.</li>
</ul>
<img src="/img/watch/troubleshooting1.jpg" width="70%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. DHT11 FSM 종료 타이밍 문제</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 상황 : 40개의 데이터 수신 후, DATA_SYNC 상태에서 DATA_DETECT로 전이가 안되는 현상 발생.</li>
  <li>원인 분석 : 데이터를 다 받으면 dht11_io 신호가 1로 발생하지 않아 상태가 넘어가지 않음.</li>
  <li>해결 방법 : DATA_DETECT에서 data_count == 39일 때 바로 STOP 상태 전환.</li>
</ul>
<img src="/img/watch/troubleshooting2.jpg" width="40%">

---

<h1 style="font-size: 36px; font-weight: bold;">느낀점</h1>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>FSM구조와 모듈화된 하드웨어 설계 방식에 대해 이해할 수 있었음.</li>
  <li>Timing violation과 같은 문제를 겪으면서 센서 제어를 위한 로직 구현 뿐만 아니라 하드웨어 상의 최적화 로직 및 타이밍 제어의 중요성을 깨달음.</li>
</ul>

---

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">GitHub Source</h2>
<div class="has-text-centered">
  <a class="button is-dark is-rounded gh-btn"
     href="https://github.com/bhyeon1/bhyeon1.github.io/tree/main/projects_source/Multi_Sensing_Watch"
     target="_blank" rel="noopener"
     style="padding:10px 48px; border-radius:9999px; display:inline-flex; justify-content:center;">
    <span>GitHub</span>
  </a>
</div>