---
title: RRC Filter
order : 7
subtitle: ASIC 기반 RRC Filter 설계 및 검증
description: ""
layout: page
permalink: /projects/rrc_filter/
image: /img/rrc_filter/title.png
tags : [ASIC, VCS/Verdi, Verilog, Systemverilog, MATLAB]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.07.16 ~ 2025.07.18
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
  <strong>Root-Raised-Cosine 필터 RTL 설계 · 타이밍 검증 · Welch PSD 평가</strong>
</p>

<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>1. floating-point -> fixed-point modeling</li>
  <li>2. RTL 설계 후, 입력(테스트) 벡터로 기능 검증</li>
  <li>3. MATLAB을 통한 Welch PSD로 주파수 특성 검증</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>사용 언어 : Verilog, Systemverilog, MATLAB</li>
  <li>Tool : VCS, Verdi</li>
  <li>editor : vi editor </li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">RRC Filter 핵심 원리</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개념</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">디지털 통신 시스템에서 심볼 간 간섭 (ISI)을 최소화하고 신호의 전송 대역폭을 효율적으로 사용하기 위해 활용되는 펄스 성형 필터</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">주요 특징</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><b>심볼 간 간섭(ISI) 감소</b> : 신호의 꼬리 부분을 줄여 서로 섞이는 현상을 감소시켜 신호의 정확성을 높임.</li>
  <li><b>펄스 성형 (Pulse Shaping)</b> : 디지털 통신에서 비트를 심볼로 변환한 후, 효율적인 전송을 위해 신호의 모양을 최적화하는 펄스 성형 과정에 사용.</li>
  <li><b>수신부 처리</b> : 송신부에서 RRC filter를 통과한 신호는 수신부에서 다시 RRC 필터를 통과하여 원래의 신호 파형으로 복원.</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">FIR vs IIR (구현 구조)</h2>

<!-- 갤러리 #1 -->
<div class="demo-imgs columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/rrc_filter/fir_filter.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/rrc_filter/fir_filter.png' | relative_url }}"
             alt="fir_filter" loading="lazy" decoding="async"
             style="display:block;margin:0 auto;width:90%;max-width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">FIR Filter</div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/rrc_filter/iir_filter.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/rrc_filter/iir_filter.png' | relative_url }}"
             alt="iir_filter" loading="lazy" decoding="async"
             style="display:block;margin:0 auto;width:70%;max-width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">IIR Filter</div>
    </a>
  </div>
</div>

<div class="table-container" style="margin-left: 10px; font-size: 16px;">
  <table class="table is-striped is-fullwidth">
    <thead>
      <tr>
        <th style="width: 18%;">항목</th>
        <th>FIR (Finite Impulse Response)</th>
        <th>IIR (Infinite Impulse Response)</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>구조</td>
        <td>피드백 없음(비재귀), 유한 탭</td>
        <td>피드백 있음(재귀), 무한 임펄스 응답</td>
      </tr>
      <tr>
        <td>위상</td>
        <td><b>선형 위상</b> 용이(대칭 계수)</td>
        <td>일반적으로 <b>비선형 위상</b></td>
      </tr>
      <tr>
        <td>안정성</td>
        <td><b>항상 안정</b> (피드백 없음)</td>
        <td>극(pole) 배치에 따라 불안정 가능 → 설계/양자화 민감</td>
      </tr>
      <tr>
        <td>차수 대비 응답</td>
        <td>급경사/좁은 전이대역엔 탭 수 요구↑</td>
        <td>낮은 차수로도 급경사 구현 가능(효율↑)</td>
      </tr>
      <tr>
        <td>지연</td>
        <td>그룹지연 일정 = (탭수−1)/2</td>
        <td>주파수 의존적인 그룹지연(왜곡 가능)</td>
      </tr>
      <tr>
        <td>고정소수점</td>
        <td>양자화/스케일링에 비교적 강함</td>
        <td>피드백 경로로 민감, 오버플로/발산 주의</td>
      </tr>
    </tbody>
  </table>
</div>

<!-- RRC 선택 이유 요약 -->
<div class="notification is-link is-light" style="margin-left: 10px; font-size: 16px;">
  <strong>왜 RRC는 FIR로 구현할까?</strong>
  <ul style="margin-top: 6px; margin-bottom: 0; padding-left: 18px; line-height: 1.5;">
    <li><b>선형 위상</b>으로 심볼 샘플 시점의 위상 왜곡 최소화</li>
    <li><b>심볼 간섭(ISI) 억제</b>에 맞는 모양을 탭 계수로 정확히 만들기 쉬움</li>
    <li><b>항상 안정</b> + 고정소수점/FPGA 구현 시 예측 가능</li>
    <li><b>폴리페이즈</b> 구조와 결합해 업/다운샘플링 연산 효율↑</li>
  </ul>
</div>

---

<h1 style="font-size: 36px; font-weight: bold;">상세 설계</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Fixed Point 모델링</h2>

<img src="/img/rrc_filter/fixed_point.png" width="70%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Timing 만족을 위한 Pipe 방식 설계</h2>

<img src="/img/rrc_filter/pipe.png" width="70%">

---

<h1 style="font-size: 36px; font-weight: bold;">시뮬레이션 및 검증</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">Timingdiagram</h2>

<img src="/img/rrc_filter/Timing.png" width="100%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">입력(테스트) 벡터를 통한 검증</h2>

```verilog
// Input vector test
initial begin
	fd_adc_di = $fopen("./rrc_din.txt", "r");
	fd_rrc_do = $fopen("./rrc_dout_rtl.txt", "w");
	i = 0;
	while (!$feof(fd_adc_di)) begin
		void($fscanf(fd_adc_di, "%d\n", data));
		adc_data_in[i] = data;
		//adc_data_in[i] = $signed(data[6:0]);
		i = i + 1;
	end
	#800000 $finish;
	$fclose(fd_rrc_do);
end
```
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
입력 벡터에 따른 출력 벡터 확인 -> <b>MATLAB결과와 RTL 시뮬레이션 결과가 일치하는 것을 확인</b>
</p>
<img src="/img/rrc_filter/matlab_vs_rtl.png" width="60%">



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