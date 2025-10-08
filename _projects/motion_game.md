---
title: K-Dance Motion Game
order : 2
subtitle: VGA·FPGA 기반 실시간 이미지 처리로 구현한 동작 인식 게임 설계
description: ""
layout: page
permalink: /projects/motion_game/
image: /img/motion_game/title.png
tags : [Vivado, Vitis, FPGA, SystemVerilog, Python]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.09.08 ~ 2025.09.26
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 선정 배경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>현대 사회에 지속적으로 증가하는 우울증 환자 -> 능동적 활동을 통한 우울증 해소 필요.</li>
  <li>K-POP -> 긴장감을 풀어주고 긍정적인 에너지 전달 효과.</li>
  <li>K-POP과 Dance를 누구나 쉽게 배우고 즐길 수 있도록 게임을 제작함.</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>사용 언어</strong> : SystemVerilog, Python</li>
  <li><strong>Tool</strong> : Vivado, VS Code, draw.io </li>
  <li><strong>HW</strong> : OV7670 카메라, Basys3, VGA to HDMI, USB 캡쳐 보드 </li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">Data Flow</h1>

<img src="/img/motion_game/data_flow.png" width="80%">

---

<h1 style="font-size: 36px; font-weight: bold;">동작 영상</h1>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/motion_game/game_start.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/motion_game/game_start.gif' | relative_url }}"
             alt="game_start" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">1. Game Start </div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/motion_game/music_select.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/motion_game/music_select.gif' | relative_url }}"
             alt="music_select" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">2. Music Select </div>
    </a>
  </div>
</div>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/motion_game/game_play.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/motion_game/game_play.gif' | relative_url }}"
             alt="game_play" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">3. Game play </div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/motion_game/ending.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/motion_game/ending.gif' | relative_url }}"
             alt="ending" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">4. Ending & Score </div>
    </a>
  </div>
</div>

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
  // ====== 원하는 설정만 바꿔 쓰세요 ======
  const OPEN_MODE = 'fit';      // 'fit' = 화면맞춤으로 열기, 'fixed' = 고정배율로 열기
  const INITIAL_SCALE = 1.00;   // OPEN_MODE='fixed'일 때 시작 배율 (1=원본 크기)
  const MIN_SCALE = 0.50;       // 최소 배율 (50%)
  const MAX_SCALE = 1.20;       // 최대 배율 (120%)  ← "너무 커지는 것" 제한
  const STEP = 0.10;            // 확대/축소 한 번에 변경되는 비율 (10%)
  // =====================================

  const grid = document.getElementById('demo-gifs'); // 갤러리 래퍼 id 필요
  const lb   = document.getElementById('lb');
  const img  = document.getElementById('lb-img');
  const xBtn = document.getElementById('lb-x');

  if (!grid) return;

  let natW = 0, natH = 0, scale = 1;

  function clamp(v, lo, hi){ return Math.max(lo, Math.min(hi, v)); }
  function applyScale(s){
    scale = clamp(s, MIN_SCALE, MAX_SCALE);
    img.style.width = Math.round(natW * scale) + 'px';
    img.style.height = 'auto';
  }
  function openAt(src){
    img.onload = () => {
      natW = img.naturalWidth; natH = img.naturalHeight;
      if (OPEN_MODE === 'fit'){
        const vw = window.innerWidth  * 0.92;
        const vh = window.innerHeight * 0.92;
        const fit = Math.min(vw / natW, vh / natH);
        applyScale(fit);                  // 화면맞춤(단, MAX_SCALE까지만)
      } else {
        applyScale(INITIAL_SCALE);        // 고정 배율로 시작
      }
    };
    img.src = src;
    lb.style.display = 'flex';
  }

  // 갤러리 클릭 → 라이트박스 열기
  grid.addEventListener('click', (e)=>{
    const a = e.target.closest('a');
    if (!a) return;
    e.preventDefault();
    openAt(a.getAttribute('href'));
  });

  // 닫기
  function closeLB(){ lb.style.display='none'; img.src=''; }
  lb.addEventListener('click', (e)=> { if (e.target === lb) closeLB(); });
  xBtn.addEventListener('click', closeLB);
  document.addEventListener('keydown', (e)=> { if (e.key === 'Escape') closeLB(); });

  // 키보드로 확대/축소: + / -
  document.addEventListener('keydown', (e)=>{
    if (lb.style.display !== 'flex') return;
    if (e.key === '+' || e.key === '=' ) applyScale(scale + STEP);
    if (e.key === '-' || e.key === '_' ) applyScale(scale - STEP);
    if (e.key === '0') applyScale(1.0);        // 0 = 원본 배율
  });

  // 마우스 휠로 확대/축소
  lb.addEventListener('wheel', (e)=>{
    if (lb.style.display !== 'flex') return;
    e.preventDefault();
    const dir = e.deltaY < 0 ? 1 : -1;
    applyScale(scale + dir * STEP);
  }, { passive:false });

  // 창 크기 변경 시 화면맞춤 모드일 때만 다시 맞춤
  window.addEventListener('resize', ()=>{
    if (lb.style.display !== 'flex' || !img.src || OPEN_MODE !== 'fit') return;
    openAt(img.src);
  });
})();
</script>

---

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">GitHub Source</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<strong>자세한 설계 및 구현, 트러블슈팅 등은 GitHub에서 확인할 수 있습니다.</strong> 🔗📘
</p>

<div class="has-text-centered">
  <a class="button is-dark is-rounded gh-btn"
     href="https://github.com/2735C/VGA_Motion_Recognition_Game?tab=readme-ov-file"
     target="_blank" rel="noopener"
     style="padding:10px 48px; border-radius:9999px; display:inline-flex; justify-content:center;">
    <span>GitHub</span>
  </a>
</div>