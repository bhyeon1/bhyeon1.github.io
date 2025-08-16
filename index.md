---
layout: page
title: Hyeon's Portfolio
subtitle: Welcome to my portfolio site.
show_sidebar: false
---

<p style="font-size: 26px; line-height: 1.6;">
  안녕하세요 😊 <br>
  이 페이지는 제가 지금까지 진행한 하드웨어, 임베디드, AI 시스템 프로젝트들을 정리한 포트폴리오입니다.<br>
  각 프로젝트는 아래 카드에서 확인할 수 있어요 :)
</p>

<br>

<div class="columns is-multiline">
  {% for project in site.projects %}
    <div class="column is-one-third">
      <a href="{{ project.url }}" style="text-decoration: none; color: inherit;">
        <div class="card hover-effect">
          <div class="card-image">
            <figure class="image is-4by3">
              <img src="{{ project.image }}" alt="{{ project.title }}">
            </figure>
          </div>
          <div class="card-content">
            <p class="title is-5">{{ project.title }}</p>
            <p class="subtitle is-6">{{ project.subtitle }}</p>
            <p>{{ project.description | truncate: 100 }}</p>
          </div>
        </div>
      </a>
    </div>
  {% endfor %}

</div>