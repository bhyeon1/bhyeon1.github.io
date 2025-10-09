---
title: AI Smart Parking Lot
order : 9
subtitle: Raspberry Pi 5 기반 AI 모델을 활용하여 차량 번호판 인식 및 주차 안내 / 관리 시스템
description: ""
layout: page
permalink: /projects/AI_OnDevice/
image: /img/AI_OnDevice/title.jpg
tags : [Colab, Linux, Python]
---

<h1 style="font-size: 36px; font-weight: bold;">개요</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">프로젝트 기간</h2>
<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
2025.07.01 ~ 2025.07.10
</p>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">목적</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>번호판 인식 기반 실시간 차량 식별로 출입 자동화</li>
  <li>빈자리 탐지를 통해 주차 효율을 높이고 안전한 동선을 보장</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">개발 환경</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>Raspberry Pi 5</strong> : 64-bit Arm Cortex</li>
  <li><strong>WebCam w210</strong> : 최대 해상도 1280 x 720</li>
  <li><strong>Python 3.10+</strong> : PyTorch, EasyOCR, TensorFlow, numpy, TorchVision, CUDAToolkit</li>
  <li><strong>Google Colab</strong></li>
</ul>

---

<h1 style="font-size: 36px; font-weight: bold;">상세 설계</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">주요 기능</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>입차 시 차량 인식 : 카메라로 차량 감지 및 번호판 인식</li>
  <li>등록 차량 확인 : 등록 차량 여부 확인</li>
  <li>주차 공간 탐지 : 빈 자리 주차 공간 탐색</li>
  <li>빈 자리 안내 : 사용자에게 가장 가까운 빈 자리 안내</li>
  <li>잘못된 주차 안내 : 지정된 영역 내 정상 주차 여부 확인</li>
  <li>차량 출차 인식 : 차량 감지 해제 시, 해당 주차 공간을 빈 자리로 갱신</li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">시스템 아키텍처</h2>
<img src="/img/AI_OnDevice/system.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">AI 모델 설계</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li>YOLO v5 : 이미지 전체에서 번호판 위치를 박스 형태로 정의하여 인식</li>
  <li>YOLO v8 : 주차 공간 탐색(객체 탐지) 및 주차 상태 체크(BBOX 기울기 계산, 중심점 판단)</li>
  <li>CRNN : CNN + RNN + CTC Loss 구조로 문자 분할 없이 전체 문자열 인식</li>
  <li>EasyOCR : Detection + Recognition 통합 OCR로 미리 학습된 PyTorch 모델</li>
</ul>

<img src="/img/AI_OnDevice/YOLO+EasyOCR.jpg" width="80%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">온디바이스</h2>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<br>
<strong>1. OCR_GPIO_Entrace.py</strong>
</p>

<img src="/img/AI_OnDevice/OCR_GPIO.jpg" width="80%">

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<br>
<strong>2. find_empty_place.py</strong>
</p>

<img src="/img/AI_OnDevice/Find_Empty_Place.jpg" width="40%">
<img src="/img/AI_OnDevice/Find_Empty_Place2.jpg" width="80%">

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<br>
<strong>3. GPIO 핀을 통한 라즈베리파이 통신</strong>
</p>
<ul style="font-size:18px; line-height:1.6; margin-left:30px;">
  <li><strong>RPI A</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>GPIO 0 (입력): 2초 동안 HIGH 검출 시 등록된 차량 진입으로 인식</li>
      <li>GPIO 1 (출력): 빈 자리가 없을 시 HIGH</li>
    </ul>
  </li>

  <li style="margin-top:8px;"><strong>RPI B</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>GPIO 0 (출력): 등록된 차량 진입 시 3초 동안 HIGH</li>
      <li>GPIO 1 (입력): HIGH → 빈 자리가 없다고 판단</li>
    </ul>
  </li>
</ul>

<p style="font-size: 18px; line-height: 1.4; margin-left: 10px;">
<br>
<strong>3. GPIO 핀을 통한 라즈베리파이 통신</strong>
</p>
<ul style="font-size:18px; line-height:1.6; margin-left:30px;">
  <li><strong>RPI A</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>GPIO 0 (입력): 2초 동안 HIGH 검출 시 등록된 차량 진입으로 인식</li>
      <li>GPIO 1 (출력): 빈 자리가 없을 시 HIGH</li>
    </ul>
  </li>

  <li style="margin-top:8px;"><strong>RPI B</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>GPIO 0 (출력): 등록된 차량 진입 시 3초 동안 HIGH</li>
      <li>GPIO 1 (입력): HIGH → 빈 자리가 없다고 판단</li>
    </ul>
  </li>
</ul>

<img src="/img/AI_OnDevice/RPI.jpg" width="40%">

---

<h1 style="font-size: 36px; font-weight: bold;">최종 결과</h1>
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. 실제 동작 환경</h2>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/AI_OnDevice/result1.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/AI_OnDevice/result1.png' | relative_url }}" alt="Result 1"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/AI_OnDevice/result2.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/AI_OnDevice/result2.png' | relative_url }}" alt="Result 2"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
    </a>
  </div>
</div>

<h2 style="font-size:22px;font-weight:bold;margin-top:1.6em;">2. 시연 영상</h2>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/AI_OnDevice/enable_1.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/AI_OnDevice/enable_1.gif' | relative_url }}"
             alt="enable_1" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">case 1. 차량 인식 10회 </div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/AI_OnDevice/enable_2.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/AI_OnDevice/enable_2.gif' | relative_url }}"
             alt="enable_2" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">case 2. 등록 차량일 시 빈 자리 안내 </div>
    </a>
  </div>
</div>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/AI_OnDevice/not_enable.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/AI_OnDevice/not_enable.gif' | relative_url }}"
             alt="not_enable" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">case 3. 미등록 차량 </div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/AI_OnDevice/full.gif' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/AI_OnDevice/full.gif' | relative_url }}"
             alt="full" loading="lazy" decoding="async"
             style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">case 4. 만차 안내 </div>
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

<h1 style="font-size: 36px; font-weight: bold;">트러블 슈팅</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. YOLO 모델 학습 실패</h2>
<ul style="font-size:18px; line-height:1.6; margin-left:30px;">
  <li><strong>원인 분석</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>YOLO는 객체의 시각적 특징을 기반으로 bounding box.</li>
      <li>학습 데이터 셋에서 번호판 전체가 모자이크 되어 있음.</li>
      <li>YOLO가 객체의 특징을 찾지 못함.</li>
    </ul>
  </li>
  <li><strong>해결 과정</strong> : 온전한 번호판이 나와있는 데이터 셋 사용. (해외)
  </li>
</ul>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. YOLO 모델 버전 호환성 문제</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>원인 분석</strong> : 라이브러리 상호 호환성 충돌.</li>
  <li><strong>해결 방법</strong> : 팀원들과의 소통 후  사용 모델 및 라이브러리 호환성 체크.</li>
</ul>
<img src="/img/AI_OnDevice/troubleshooting1.png" width="60%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">3. CRNN</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>문제 상황</strong> : YOLOv5는 번호판 영역을 정확하게 탐지했지만, 우분투 환경 내 CRNN 한글 폰트 깨짐 현상 발견.</li>
  <li><strong>원인 분석</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>charset.json에 한글 미포함 → CRNN이 index 탐색 불가.</li>
      <li>디코딩 과정에서 해당 문자 자리에 □ 출력.</li>
    </ul>
  </li>
  <li><strong>해결 과정</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>charset.json에 한글이 있는지 확인.</li>
      <li>ImageFont에 한글 폰트 경로 지정.</li>
      <li>CRNN 모델이 한글을 인식할 수 있는지 테스트.</li>
    </ul>
  </li>
</ul>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/AI_OnDevice/troubleshooting2_1.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/AI_OnDevice/troubleshooting2_1.png' | relative_url }}" alt="troubleshooting2_1"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">Before </div>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/AI_OnDevice/troubleshooting2_2.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/AI_OnDevice/troubleshooting2_2.png' | relative_url }}" alt="troubleshooting2_2"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:18px;margin-top:.4em;text-align:center;">After </div>
    </a>
  </div>
</div>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">4. OCR</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>문제 상황</strong> : OCR 동작의 신뢰성 문제.</li>
  <li><strong>원인 분석</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>Raspberrypi5 내에서 OCR동작 느리고 부정확.</li>
      <li>한번의 OCR 동작으로 정확히 인식할 확률 매우 낮음.</li>
      <li>여러 번의 동작 결과 중 어떤 문자열이 정확한지 판별 X.</li>
    </ul>
  </li>
  <li><strong>해결 과정</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>번호판 detect시 1초 간격으로 10번의 OCR동작.</li>
      <li>동작 중 가장 많이 인식된 문자열을 최종 선택.</li>
      <li>일정 길이 이하의 문자열은 제외.</li>
    </ul>
  </li>
</ul>

<div id="demo-gifs" class="columns is-multiline is-mobile">
  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/AI_OnDevice/troubleshooting3_1.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/AI_OnDevice/troubleshooting3_1.png' | relative_url }}" alt="troubleshooting3_1"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
    </a>
  </div>

  <div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/img/AI_OnDevice/troubleshooting3_2.png' | relative_url }}" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/img/AI_OnDevice/troubleshooting3_2.png' | relative_url }}" alt="troubleshooting3_2"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
    </a>
  </div>
</div>

---

<h1 style="font-size: 36px; font-weight: bold;">고찰</h1>

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">1. 온디바이스 실행 성능 한계</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>딥러닝 연산의 높은 연산 부하</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>OCR/YOLOv8 연산은 CPU 사용이 높아 동작 속도 느림.</li>
      <li>Raspberry Pi 5에서도 실시간 프레임 처리에 한계.</li>
    </ul>
  </li>
  <li><strong>PyTorch 기반 YOLOv8</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>Ultralytics 라이브러리 기반 → GPU 가속 필요.</li>
      <li>Pi 환경에선 CPU-only 추론 → FPS 저하 불가피.</li>
    </ul>
  </li>
  <li><strong>차량 입차 탐지 모델 (YOLOv8)</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>YOLO 기반 차량 탐지 / 입차 여부 판단은 실시간 수준은 0.3초 정도로 충분.
      </li>
    </ul>
  </li>
</ul>

<img src="/img/AI_OnDevice/cpu_use.png" width="50%">

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">2. CRNN vs EasyOCR 모델 학습 과정에서 느낀 점</h2>
<ul style="font-size: 18px; line-height: 1.4; margin-left: 30px;">
  <li><strong>프로젝트 목적</strong> : 대한민국 차량 번호판 문자 (한글 포함)를 정확히 인식하는 OCR 모델 개발.
  </li>
  <li><strong>CRNN 학습 성능과 한계</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>학습 데이터 : 5000장 이상 실제 번호판 이미지.</li>
      <li>문제점 : 웹캠 인식 이미지 문자열 정확도 낮음.</li>
    </ul>
  </li>
  <li><strong>EasyOCR 전환 및 비교 분석</strong>
    <ul style="margin-top:6px; margin-left:18px;">
      <li>학습 데이터 : 100만장 이상의 대규모 학습 모델.</li>
      <li>성능 : 웹캠 인식 이미지 문자열 정확도 높음.</li>
    </ul>
  </li>
</ul>

---

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">GitHub Source</h2>
<div class="has-text-centered">
  <a class="button is-dark is-rounded gh-btn"
     href="https://github.com/bhyeon1/Project_AI_Parking_Lot"
     target="_blank" rel="noopener"
     style="padding:10px 48px; border-radius:9999px; display:inline-flex; justify-content:center;">
    <span>GitHub</span>
  </a>
</div>