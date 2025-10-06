---
title: Microwave project
order : 6
subtitle: FPGA 기반 모터 구동형 전자레인지 기능 구현
description: ""
layout: page
permalink: /projects/Microwave/
image: /img/Microwave/title.jpg
tags : [Vivado, FPGA, Verilog]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.06.23 ~ 2025.06.26
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
FPGA 기반 PWM 제어 및 사용자 인터페이스 설계를 통해 모터 구동형 전자레인지 기능을 구현.
</p>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>PWM의 duty 비를 조절함으로서 모터의 속도를 제어.</li>
    <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>해동 모드 : 저속 회전을 위한 duty ratio = 20%</li>
      <li>일반 조리 모드 : 정상 회전을 위한 duty ratio = 70%</li>
    </ul>
  <li>사용자 입력 인터페이스 구성</li>
    <ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
      <li>sw0 off : 10초 설정 모드, sw1 on : 30초 설정 모드</li>
      <li>btnU : 시간 증가, btnD : 시간 초기화.</li>
      <li>btnL : 일반 조리 모드 시작, btnR : 해동 모드 시작.</li>
    </ul>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>사용 언어 : Verilog</li>
  <li>Tool : Vivado, draw.io </li>
  <li>editor : VS Code </li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">상세 설계</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. FSM</h2>

<img src="/img/Microwave/fsm.jpg" width="90%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. 버튼 디바운싱</h2>

```verilog
// 1ms Tick 생성
if (r_counter == 100_000 - 1) begin
    r_counter <= 0;
    r_tick <= 1;
end else begin
    r_counter <= r_counter + 1;
    r_tick <= 0;
end

// 1ms 마다 샘플링 - 버튼 상태 유지 횟수 체크
if (btn_sync2 == debounced_btn)
    tick_counter <= 0;
else begin
    tick_counter <= tick_counter + 1;
    if (tick_counter == 9) begin
        debounced_btn <= btn_sync2;
        tick_counter <= 0;
    end
end

// F/F를 통한 rising edge detect
always @(posedge clk or posedge clk) begin
    if (rst) begin
        debounced_btn_next_clk <= 0;
    end else begin
        debounced_btn_next_clk <= debounced_btn;
    end
end

assign o_btn = debounced_btn & (~debounced_btn_next_clk);
```

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">3. Time_down_counter</h2>

```verilog
// sec_tick을 기준으로 분과 초를 반영.
if (i_tick_sec) begin
    if ((sec_reg == 0) && (min_reg == 0)) begin
        state_next = DONE;
    end else if (sec_reg == 0) begin
        // 초가 0인데 분이 있다면, sec = 59로, min은 1을 빼줌.
        sec_next = 6'd59;
        min_next = min_reg - 1;
    end else begin
        sec_next = sec_reg - 1;
    end
end
```

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">4. Moter_controller</h2>

```verilog
// duty cycle 조절을 통해 모터의 속도를 조절.
if (start) begin
    r_moter_control <= 2'b10;
    r_duty_cycle <= 7;
end else if (defrost_start) begin
    r_moter_control <= 2'b10;
    r_duty_cycle <= 2;
end else begin
    r_moter_control <= 2'b11;
    r_duty_cycle <= 0;
end
```

---

<h1 style="font-size: 36px; font-weight: bold;">시뮬레이션 및 검증</h1>
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">btn_debounce 검증 결과</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">버튼이 눌리고 10ms 후에 btn_debounce의 출력이 한 tick 나가는 것을 확인. </p>
<img src="/img/Microwave/btn_sim.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">time_setting 검증 결과</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>mode 0일 때, up_btn이 눌리면 10sec씩 증가. time_rst_btn이 눌리면 시간 초기화.</li>
  <li>mode 1일 때, up_btn이 눌리면 30sec씩 증가.</li>
  <li>start_btn이 눌리면 전자레인지 시작. (시간이 줄어듦.) moter_start -> 1로 moter 시작 신호를 줌. 끝나면 done -> 1.</li>
</ul>
<img src="/img/Microwave/time_setting_sim.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">fnd_controller 검증 결과</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>sec와 min에 1분 30초 입력 -> fnd_data가 잘 출력되는 것을 확인.</li>
  <li>done이 1일 때, fnd_data가 5ms 간격으로 ff(fnd 꺼짐), c0(0값 출력)가 번갈아가면서 출력. 즉, 전자레인지 작동이 끝났음을 알려주기 위한 깜빡거림 동작 구현 성공.</li>
</ul>
<img src="/img/Microwave/fnd_sim.jpg" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">moter_controller 검증 결과</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>어떠한 신호도 없을 시, moter_setting [1:0]은 2'b11 로 break 상태로 둠.</li>
  <li>각 start 신호에 따라 pwm_out duty가 70% or 20%로 출력. moter_setting은 2'b10 로 정방향 회전.</li>
</ul>
<img src="/img/Microwave/moter_sim.jpg" width="100%">

---
<h1 style="font-size: 36px; font-weight: bold;">동작 영상</h1>


---

<h1 style="font-size: 36px; font-weight: bold;">트러블슈팅</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Down Counter 구현 과정에서 분(minute) 단위 내림 처리의 어려움.</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>문제 상황 : 기존 watch는 ms_tick을 누적하여 sec_tick을 만들고, 이를 다시 누적해 min_tick으로 넘기는 방식으로 시계를 구현했지만, Down Counter에서는 반대로 분(minute)에서 초(second)로의 감소가 필요해 기존 방식이 적용되지 않음. </li>
  <li>해결 방법 : sec tick을 기준으로 분 감소 조건을 판단하고, 분이 감소할 때 초를 59로 강제로 설정하는 로직을 도입하여 <br> min, sec Down Counter 동작을 안정적으로 구현 성공.</li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">느낀점</h1>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>PWM 신호를 통한 모터의 동작 방식 이해</li>
  <li>모드 분리를 통한 FSM 역량 강화</li>
  <li>버튼 디바운싱 및 edge detector 회로 원리 학습</li>
</ul>

---
