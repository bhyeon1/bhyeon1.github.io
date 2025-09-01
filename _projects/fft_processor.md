---
title: 512-Point Radix-8 FFT Processor
order : 4
subtitle: ASIC 기반 512-Point FFT 프로세서 설계 및 FPGA 검증
description: ""
layout: page
permalink: /projects/fft_processor
image: /img/fft/fft.jpg
tags : [ASIC, FPGA, VCS/Verdi, SystemVerilog, MATLAB]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.07.21 ~ 2025.08.05
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">목적</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  파이프라인 구조의 FFT Processor를 RTL design부터 FPGA 검증까지 수행하여 실무에 적용되는 ASIC 설계 과정을 경험.
</p>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>1. floating-point -> fixed-point modeling</li>
  <li>2. RTL 설계 후, cos, random 입력 벡터 검증</li>
  <li>3. Vivado를 통해 RTL verification (FPGA)</li>
  <li>4. Synthesis 후, Setup time 통과 및 Area 최소화</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>사용 언어 : SystemVerilog, MATLAB</li>
  <li>Tool : VCS, Verdi, Vivado, draw.io </li>
  <li>editor : vi editor </li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">Pipeline FFT의 핵심 원리</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. Decimation 전략</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  시간 분할 (DIT) 또는 주파수 분할 (DIF) 방식으로 알고리즘을 선택, 입력 데이터 순서를 적절히 재배열해 각 단계에 공급. <br>
  이번 프로젝트에서는 Radix-8 DIF 방식을 채택.
</p>

<img src="/img/fft/radix8.jpg" width="60%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. Butterfly 연산</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  Butterfly 연산은 FFT의 핵심 연산으로 덧셈·뺄셈과 twiddle factor(회전 인자) 곱셈을 수행.
</p>

<img src="/img/fft/twf.jpg" width="50%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">3. 파이프라인 스테이지</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  본 프로젝트의 FFT 프로세서는 입력을 16개 단위로 받아 총 9개 스테이지를 거치며, 각 스테이지에서 butterfly 연산과 delay 요소를 수행. <br>
  파이프라인이 채워진 이후에는 매 클럭마다 새로운 입력을 받아들이고 동시에 FFT 결과를 출력.
</p>

---

<h1 style="font-size: 36px; font-weight: bold;">Fixed-point 모델링 (MATLAB)</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. 시스템 아키텍쳐</h2>

<img src="/img/fft/system.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. 데이터 포맷</h2>

<img src="/img/fft/dataformat.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">3. CBFP</h2>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>스테이지 별로 필요한 만큼만 시프트(스케일링) 해주어 동적 범위를 넓게 확보 가능.</li>
  <li>정보 손실을 줄이고 신호 대 잡음비 (SQNR) 개선 가능.</li>
  <li>CBFP 원리
    <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
    <li>각 입력에 대한 시프트 값 계산.</li>
    <li>블록 내 가장 큰 값 기준 시프트 값 저장.</li>
    <li>저장된 시프트 값으로 블록 내 모든 입력에 대해 시프트 수행.</li>
    <li>시프트 값을 인덱스 레지스터로 출력, 연산이 끝난 후 복원.</li>
    </ul>
  </li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">4. SQNR 결과</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  SQNR : 신호 대 잡음 비로 Fixed-point 설계의 정확도 손실을 수치화할수 있는 지표
</p>

<img src="/img/fft/cos_ran.jpg" width="50%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">5. Fixed-point modeling 결과 (Cos)</h2>

<img src="/img/fft/float_fixed_result.jpg" width="100%">

---

<h1 style="font-size: 36px; font-weight: bold;">RTL 설계 및 검증</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">블록 다이아그램</h2>

<img src="/img/fft/blockdiagram.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">제어 신호 타이밍도</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  스테이지별 연산 유효 구간(valid) 길이 : 32clk -> 16clk -> 8clk -> 4clk -> 2clk -> 1clk
</p>

<img src="/img/fft/timingdiagram.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Latency 결과</h2>

<img src="/img/fft/latency.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Cos / Random vector 검증</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  Cos / Random 벡터를 입력으로 주었을 때, MATLAB 시뮬레이션 결과와 RTL 설계 결과가 일치함을 확인.
  <br> (왼쪽이 MATLAB fixed-point 결과, 오른쪽이 RTL Simulation 결과)
</p>

<img src="/img/fft/cos_ran_result.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Synthesis 결과 (Area & Timing)</h2>

<img src="/img/fft/Area_Timing_vcs.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Gate Simulation 결과 (Cos vector)</h2>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>Synthesis 결과로 나온 netlist 파일을 이용하여 gate simulation 진행.</li>
      <li>X value 없이 의도한 동작이 나오는 것을 확인.</li>
      <li>최종 출력 결과 또한 MATLAB의 결과와 일치.</li>
      </ul>

<img src="/img/fft/gate_sim_result.jpg" width="100%">

---

<h1 style="font-size: 36px; font-weight: bold;">FPGA 검증</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">FPGA 구현</h2>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>UltraZed-7EV Carrier Card 보드 Spec 사용.
    <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
    <li>클럭 입력 : 300MHz</li>
    <li>I/O 전압 : 3.3V or 1.8V</li>
    </ul>
  </li>
  <li>Clocking Wizard IP : Vivado에서 제공하는 clk generator IP.
      <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>MMCM(Mixd-Mode Clock Manager) 모드 사용.</li>
      <li>300MHz differential clock -> 100MHz single clock으로 변환.</li>
      </ul>
    </li>
  <li>VIO (Virtual Input/Output) : 특정 신호의 값을 가상으로 읽거나 쓸 수 있게 해주는 IP.
      <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>input : dour_re[15:0], dout_im[15:0], valid_out</li>
      <li>output : port 연결 X</li>
      </ul>
    </li>
  </ul>

  <h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">시뮬레이션 결과 (Timing Diagram)</h2>

  <img src="/img/fft/fpga_diagram.jpg" width="100%">

  <h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Synthesis 결과 (Area & Timing)</h2>

  <img src="/img/fft/Area_Timing_fpga.jpg" width="100%">

  ---

  <h1 style="font-size: 36px; font-weight: bold;">트러블 슈팅</h1>

  <h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">bf_cntr 모듈 구조 개선</h2>
  <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
    <li>초기 설계 : valid_in 입력 시 DELAY 후 32 클럭 연산, 완료 시 자동 리셋되는 FSM 구조</li>
    <li>문제점 : 두 번째 valid_in 입력 시 연산 결과가 의도하지 않은 값으로 달라지는 문제를 확인.</li>
    <li>원인 분석 : 기존 FSM은 순차 동작만 인식 32clk on, 8clk off가 되는 동작에서 다음 32clk이 들어올 때 <br> 기존 FSM 상태 전이가 끝나지 않아서 연산 타이밍이 꼬임.</li>
    <li>해결 방안 : 초기 delay(32clk -> 16clk -> 8clk -> ...)인 wait_cnt와 valid 신호를 32clk 동안 띄우는 region_cnt의 FSM을 분리하여 <br> 독립적으로 진행되는 방식으로 설계</li>
  </ul>

  <img src="/img/fft/troubleshooting.jpg" width="100%">
  