---
title: AI Smart Parking Lot
order : 7
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

<img src="/img/AI_OnDevice/RPI.jpg" width="40%">

---

<h1 style="font-size: 36px; font-weight: bold;">최종 결과</h1>
<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">실제 동작 환경</h2>

<img src="/img/AI_OnDevice/result1.png" width="100%"> | <img src="/img/AI_OnDevice/result2.png" width="100%"> |

<h2 style="font-size: 22px; font-weight: bold; margin-top: 1.6em;">시연 영상</h2>

<div class="column is-half-desktop is-half-tablet is-full-mobile">
    <a href="{{ '/gif/game_project/stage2.gif' | relative_url }}" target="_blank" rel="noopener">
      <figure class="image" style="border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.12)">
        <img src="{{ '/gif/game_project/stage2.gif' | relative_url }}" alt="Stage 2"
             loading="lazy" decoding="async" style="width:100%;height:auto;">
      </figure>
      <div style="font-size:14px;margin-top:.4em;text-align:center;">Stage 2</div>
    </a>
  </div>