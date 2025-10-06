---
title: RV32I CPU Architecture
order : 2
subtitle: FPGA 기반 RISC-V 32bit multi cycle CPU 설계
description: ""
layout: page
permalink: /projects/RV32I_CPU/
image: /img/RV32I_CPU/RISC-V.jpg
tags : [Vivado, FPGA, VCS / Verdi ,SystemVerilog]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.08.14 ~ 2025.08.25
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>RV32I instruction Set 구현, 각 Type별 명령어 구동 </li>
  <li>DataPath와 ControlUnit을 분리하여 FSM 기반의 타이밍 제어</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>사용 언어 : SystemVerilog, C</li>
  <li>Tool : Vivado, VCS, Verdi, draw.io </li>
  <li>editor : VS Code, Gvim </li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">상세 설계</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">RISC-V Architecture (Single cycle / Multi cycle / Pipeline)</h2>
<img src="/img/RV32I_CPU/Architecture.jpg" width="70%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">RV32I (Multi Cycle) Blockdiagram</h2>
<img src="/img/RV32I_CPU/Multi_Cycle.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">RV32I (Multi Cycle) FSM</h2>
<img src="/img/RV32I_CPU/FSM.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">설계 결과</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>PC, ROM, ALU, RegFile, RAM, LoadUnit, ControlUnit 등 핵심 모듈을 MCU에 통합.</li>
  <li>RV32I의 9가지 명령어 타입(R, I, S, L, B, LU, AU, J, JL)을 구현. </li>
  <li>Multi Cycle로 각 명령어를 여러 State로 나누어 동작함으로서 클럭 사이클 시간을 단축함. </li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">시뮬레이션 및 검증</h1>
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">R-Type 검증 결과</h2>
<img src="/img/RV32I_CPU/RType.jpg" width="80%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">L-Type 검증 결과</h2>
<img src="/img/RV32I_CPU/LType.jpg" width="80%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">I-Type 검증 결과</h2>
<img src="/img/RV32I_CPU/IType.jpg" width="80%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">S-Type 검증 결과</h2>
<img src="/img/RV32I_CPU/SType.jpg" width="60%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">B-Type 검증 결과</h2>
<img src="/img/RV32I_CPU/RType.jpg" width="80%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">LU / AU / J / JL-Type 검증 결과</h2>
<img src="/img/RV32I_CPU/L_JType.jpg" width="100%">
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">머신 코드 검증</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>설계한 CPU test를 위해 간단한 C 코드를 작성. (1+2+...+n을 할때 n 이상이 되는 마지막 정수 찾기) </li>
  <li>Compiler Explorer를 통해 작성한 C 코드를 어셈블리어로 변환. </li>
  <li>RISC-V Online Assembler를 통해 어셈블리어를 머신코드로 바꿔 Vivado에 code.mem 파일로 넣어서 테스트 진행. </li>
  <img src="/img/RV32I_CPU/machine.jpg" width="80%">
  <li>출력값 : output1 = Solve(50) = 10,  output2 = Solve(100) = 14로 의도된 동작이 RAM에 잘 저장되는 것을 확인.</li>
  <img src="/img/RV32I_CPU/waveform.jpg" width="100%">
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">트러블슈팅</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. Load Byte 시 x value 발생</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 상황 : LB 명령 실행 시 기대값 대신 x 값이 읽히는 현상 발생.</li>
  <li>원인 분석 : LoadUnit 동작 이상 x, ROM 머신 코드에서 잘못된 주소 (rs1 + 0x0b)로 메모리 접근.</li>
  <li>해결 방법 : ROM 명령어의 Load 주소 수정. (RAM에 값이 존재하는 rs0 + 0x08로 수정)</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. 머신 코드 동작 X</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 상황 : 머신 코드 동작 x. (의도한 출력 값이 RAM에 저장되지 않음)</li>
  <li>원인 분석 : 컴파일된 C코드가 얼마나 깊은 스택을 쓰는지에 따라 RAM의 크기가 충분히 커야 함. <br> 따라서, 코드에서 쓸 최대 프레임 크기 + 함수 호출 깊이를 예측하여 그만큼 RAM의 크기를 넉넉히 잡아야 함.</li>
  <li>해결 방법 : 기존 RAM [0:15], SP = 0x40 -> RAM [0:31], SP = 0x80 으로 RAM의 크기 확장.</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">3. VCS Simulation Error</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 상황 : Vivado에서는 돌아갔던 코드가 VCS 환경에서 컴파일 실패.</li>
  <li>원인 분석 : 현재 코드에서는 mem[ ]을 always_ff, initial 두 블록에서 쓰고 있음. <br> Systemverilog 규칙에 의해 always_ff는 그 블록 안에서만 절차적 대입이 가능. (다중 procedural driver 위반)</li>
  <li>해결 방법 : Ralways_ff 대신 더 유연한 always 문을 사용하여 단일 드라이버의 제약을 피함.</li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">느낀점</h1>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Load / Store 이해 : 어디서 시작할지(addr[1:0]) 얼마나 가져올지(func3)을 통해 원하는 데이터 조각을 얻을 수 있음.</li>
  <li>Block diagram의 중요성 : 그림이 코드의 길을 안내함. (모듈 경계 / Path / 레지스터 위치 명확화)</li>
  <li>디버깅 방식 : 문제가 된 State를 찍고, 그 안에서 제어 신호, 데이터의 흐름을 확인.</li>
</ul>

---

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">GitHub Source</h2>
<div class="has-text-centered">
  <a class="button is-dark is-rounded gh-btn"
     href="https://github.com/bhyeon1/bhyeon1.github.io/tree/main/projects_source/RV32I_CPU"
     target="_blank" rel="noopener"
     style="padding:10px 48px; border-radius:9999px; display:inline-flex; justify-content:center;">
    <span>GitHub</span>
  </a>
</div>