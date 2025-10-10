---
title: AMBA APB Bus & AXI4 Protocol
order : 3
subtitle: FPGA 기반 AMBA APB Bus/AXI4_Lite Protocol 및 peripheral 설계
description: ""
layout: page
permalink: /projects/amba_bus/
image: /img/amba_bus/title.jpg
tags : [Vivado, Vitis, FPGA, SystemVerilog]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.08.27 ~ 2025.09.05
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AMBA BUS 개요</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>BUS</strong> : CPU나 Memory, I/O 장치 간의 Data / 신호 교환을 위한 통로</li>

  <li><strong>AHB (Advanced High-Performance Bus)</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>여러 개의 Master가 여러 개의 Slave에 연결되어 있는 구조</li>
      <li>Burst transfer를 통한 파이프라인 구조 가능</li>
      <li>고속 데이터 전송 가능</li>
    </ul>
  </li>

  <li style="margin-top:8px;"><strong>APB (Advanced Peripheral Bus)</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>최소한의 전력 소모와 시스템의 복잡도를 줄인 저가형 인터페이스</li>
      <li>파이프라인 형태가 아님 (AHB보다 전송 속도가 느림)</li>
      <li>구현이 매우 단순</li>
    </ul>
  </li>
</ul>

<img src="/img/amba_bus/amba_bus.png" width="40%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AXI4 Protocol 개요</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>Point-to-Point</strong> : AMBA BUS와는 다르게 BUS 개념이 아닌 protocol의 개념</li>
  <li><strong>장점</strong> : 동시 통신이 가능. (write와 read의 분리 사용이 가능)</li>
  <li><strong>단점</strong> : wire 수가 많아짐 (Area 증가)</li>
</ul>

<img src="/img/amba_bus/AXI4.png" width="60%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>사용 언어 : SystemVerilog, C</li>
  <li>Tool : Vivado, Vitis, draw.io </li>
  <li>editor : VS Code</li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">AMBA APB-BUS 상세 설계</h1>
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">APB-BUS Signal</h2>

<img src="/img/amba_bus/apb_bus_signal.png" width="70%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Blockdiagram</h2>

<img src="/img/amba_bus/apb_bus_blockdiagram.png" width="90%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">FSM</h2>

<img src="/img/amba_bus/apb_bus_fsm.png" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">APB-BUS Peripheral Blockdiagram</h2> <br>

<!-- 갤러리 #1 -->
<div class="demo-imgs columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/amba_bus/apb_bus_ram.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/amba_bus/apb_bus_ram.png' | relative_url }}"
             alt="apb_bus_ram" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">APB-BUS RAM</div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/amba_bus/apb_bus_gpio.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/amba_bus/apb_bus_gpio.png' | relative_url }}"
             alt="apb_bus_gpio" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">APB-BUS GPIO</div>
    </a>
  </div>
</div>

<!-- 갤러리 #2 -->
<div class="demo-imgs columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/amba_bus/apb_bus_fnd.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/amba_bus/apb_bus_fnd.png' | relative_url }}"
             alt="apb_bus_fnd" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">APB-BUS FND_Controller</div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/amba_bus/apb_bus_uart.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/amba_bus/apb_bus_uart.png' | relative_url }}"
             alt="apb_bus_uart" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">APB-BUS UART</div>
    </a>
  </div>
</div>

---

<h1 style="font-size: 36px; font-weight: bold;">AMBA APB-BUS 시뮬레이션 및 검증</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">APB-BUS RAM (UVM 기반 systemverilog 검증)</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>Write값을 랜덤으로 생성 (0 or 1) 즉, 무작위로 읽거나 쓰는 동작 수행</li>
  <li>read 동작 수행 시 ref_mem에 저장되어 있는 값을 ref_rdata에 저장해둠</li>
  <li>ref_rdata값과 실제 RAM에서 read한 값이 일치하면 pass</li>
</ul>

<img src="/img/amba_bus/ram_tb_blockdiagram.png" width="60%">

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>만약, 내가 접근한 메모리 주소에 값이 없다면 x 값을 읽어옴</li>
  <li>이 때, ref_rdata도 동일 주소에서 값이 없을 경우 x 값을 읽어옴. 따라서, 이 두 결과가 동일하면 pass</li>
  <li>총 100000회 동작 수행. write 동작 : 49828회, read & 비교 동작 : 50172회</li>
  <li>모든 경우 pass (fail 0건)</li>
</ul>

<img src="/img/amba_bus/ram_result.png" width="40%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">APB-BUS Peripheral 검증</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<strong>GPIO test</strong>
</p>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>GPO test</strong> : CR[1:0] = 1, ODR[1:0] = 1로 설정. GPO[1:0] 핀에 1 1이 출력되는지 확인 </li>
  <li><strong>GPI test</strong> : 입력 벡터 gpi = 8'b1100_0000을 넣고, CR[7:6] = 1로 입력 활성화. h1000_2004의 idr값을 읽음</li>
</ul>

<img src="/img/amba_bus/apb_bus_gpio_test.png" width="70%">

<br>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<strong>FND_Controller test</strong>
</p>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>en = 1로 설정, fnd_data = 14'd1000로 설정</li>
  <li>fndFont에서 1(f9), 0(c0), 0(c0), 0(c0)이 반복되서 출력되는 것을 확인. 즉, 1000이 fnd로 display</li>
</ul>

<img src="/img/amba_bus/apb_bus_fnd_test.png" width="70%">

<br>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<strong>UART test</strong>
</p>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>sr[1:0] = 1 1 을 넣어서, tx, rx enable</li>
  <li>tx_Data에 8'b0011_1010을 넣어주고 tx 값 확인</li>
  <li>rx에 1 0 1 0 1 0 1 0을 104us의 주기로 강제로 넣어주고 rx_data [7:0] 값 확인</li>
  <li>rx_Done이 뜨면 rx_done에 해당하는 slv_reg[4]에 1을 띄워줌. CPU가 rx_data를 읽을 때, slv_reg[4]를 0으로 내림</li>
</ul>

<img src="/img/amba_bus/apb_bus_uart_test.png" width="80%">

---

<h1 style="font-size: 36px; font-weight: bold;">AXI4-Lite 상세 설계</h1>
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AXI4-Lite Signal</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>AW, W, B, AR, R은 채널의 개념. 각 채널은 단방향이고 분리. 즉, 이론상 같은 시간에 read, write 가능</li>
  <li>transfer는 신호 하나를 의미</li>
  <li>transaction은 한 채널의 주고 받는 신호들을 의미</li>
</ul>

<img src="/img/amba_bus/axi4_signal.png" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AXI4-Lite protocol 통신 방식</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>모든 채널에 VALID, READY handshake가 존재</li>
  <li>Source에서 Destination으로 보낼 때, VALID 신호를 HIGH로 같이 보내줌</li>
  <li>Destination 쪽에서 잘 받았으면, Source 쪽으로 Ready 신호를 High로 전송</li>
</ul>

<img src="/img/amba_bus/axi4_protocol_way.png" width="90%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AXI4-Lite protocol Blockdiagram</h2>

<img src="/img/amba_bus/axi4_blockdiagram.png" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AXI4-Lite protocol FSM</h2>

<img src="/img/amba_bus/axi4_fsm.png" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AXI4-Lite RTL Design</h2>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>MicroBlaze CPU IP 사용</li>
  <li>MicroBlaze는 200MHz clk을 사용하므로 이를 clock wizard를 통해 clk을 100MHz로 바꿔줌</li>
  <li>AXI4_Lite Peripheral IP 사용</li>
</ul>

<img src="/img/amba_bus/axi4_rtl.png" width="100%">

---

<h1 style="font-size: 36px; font-weight: bold;">AXI4-Lite 시뮬레이션 및 검증</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Vitis를 통한 검증</h2>

<img src="/img/amba_bus/axi4_vitis_1.png" width="30%">
<img src="/img/amba_bus/axi4_vitis_2.png" width="80%">
---

<div id="lb" style="display:none;position:fixed;inset:0;z-index:9999;
  background:rgba(0,0,0,.82);backdrop-filter:saturate(120%) blur(2px);
  align-items:center;justify-content:center;padding:8px;overflow:auto;">
  <img id="lb-img" alt="preview"
       style="display:block;border-radius:14px;box-shadow:0 10px 30px rgba(0,0,0,.4)">
  <div id="lb-info" style="position:absolute;left:14px;bottom:12px;
       color:#fff;font-size:12px;opacity:.85"></div>
  <button id="lb-x" aria-label="닫기" title="닫기"
          style="position:absolute;top:10px;right:14px;border:0;background:transparent;
                 color:#fff;font-size:34px;cursor:pointer;line-height:1;">×</button>
</div>

<script>
(function(){
  // ====== 원하는 설정만 바꾸세요 ======
  const OPEN_MODE = 'fit';      // 'fit' = 화면맞춤, 'fixed' = 고정배율 시작
  const INITIAL_SCALE = 1.00;   // fixed 모드 시작 배율
  const MIN_SCALE = 0.50;
  const MAX_SCALE = 1.20;
  const STEP = 0.10;
  // ===================================

  // 여러 갤러리(.demo-imgs)를 모두 잡는다
  const grids = document.querySelectorAll('.demo-imgs');

  // 라이트박스 요소 (한 개만 존재)
  const lb   = document.getElementById('lb');
  const img  = document.getElementById('lb-img');
  const xBtn = document.getElementById('lb-x');
  const info = document.getElementById('lb-info');

  if (!grids.length || !lb || !img || !xBtn) return;

  let natW = 0, natH = 0, scale = 1;

  function clamp(v, lo, hi){ return Math.max(lo, Math.min(hi, v)); }
  function applyScale(s){
    scale = clamp(s, MIN_SCALE, MAX_SCALE);
    img.style.width = Math.round(natW * scale) + 'px';
    img.style.height = 'auto';
  }
  function openAt(src, caption){
    img.onload = () => {
      natW = img.naturalWidth; natH = img.naturalHeight;
      if (OPEN_MODE === 'fit'){
        const vw = window.innerWidth  * 0.92;
        const vh = window.innerHeight * 0.92;
        const fit = Math.min(vw / natW, vh / natH);
        applyScale(fit);
      } else {
        applyScale(INITIAL_SCALE);
      }
    };
    img.src = src;
    if (info) info.textContent = caption || '';
    lb.style.display = 'flex';
  }
  function closeLB(){ lb.style.display='none'; img.src=''; }

  // 각 갤러리에 클릭 핸들러 연결 (이벤트 위임)
  grids.forEach(grid => {
    grid.addEventListener('click', (e)=>{
      const a = e.target.closest('a');
      if (!a || !grid.contains(a)) return;
      e.preventDefault();
      // 캡션은 링크 바로 아래 텍스트 div가 있으면 사용
      const caption = a.querySelector('div')?.textContent?.trim();
      openAt(a.getAttribute('href'), caption);
    });
  });

  // 닫기
  lb.addEventListener('click', (e)=> { if (e.target === lb) closeLB(); });
  xBtn.addEventListener('click', closeLB);
  document.addEventListener('keydown', (e)=> { if (e.key === 'Escape') closeLB(); });

  // 키보드 확대/축소
  document.addEventListener('keydown', (e)=>{
    if (lb.style.display !== 'flex') return;
    if (e.key === '+' || e.key === '=') applyScale(scale + STEP);
    if (e.key === '-' || e.key === '_') applyScale(scale - STEP);
    if (e.key === '0') applyScale(1.0);
  });

  // 마우스 휠 확대/축소
  lb.addEventListener('wheel', (e)=>{
    if (lb.style.display !== 'flex') return;
    e.preventDefault();
    const dir = e.deltaY < 0 ? 1 : -1;
    applyScale(scale + dir * STEP);
  }, { passive:false });

  // 창 크기 변경 시 화면맞춤 모드일 때만 다시 맞춤
  window.addEventListener('resize', ()=>{
    if (lb.style.display !== 'flex' || !img.src || OPEN_MODE !== 'fit') return;
    // 현재 이미지를 다시 fit 계산
    const tmp = img.src;
    img.src = '';     // onload 재트리거
    openAt(tmp, info?.textContent);
  });
})();
</script>