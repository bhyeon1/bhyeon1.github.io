---
title: Multi Sensing Watch project
order : 5
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

<h1 style="font-size: 36px; font-weight: bold;">상세 설계</h1>

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

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">SR04 Module Blockdiagram</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Start_trigger : 시작 후 Trigger 신호 10us 동안 출력</li>
  <li>Tick_gen : 1us 단위 tick 생성</li>
  <li>FND_CNTR : 계산된 거리 값 FND 표시</li>
  <li>Distance : echo 신호 펄스 폭을 측정, 거리 계산</li>
</ul>
<img src="/img/watch/sr04.jpg" width="70%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">DHT11 Module Blockdiagram</h2>
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