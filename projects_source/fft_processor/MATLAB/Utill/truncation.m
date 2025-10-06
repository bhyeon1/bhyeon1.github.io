function yQ = truncation(x, n)
  % truncation(x, n)
  % - 입력 x는 복소수 또는 실수 벡터
  % - n: 소수부 비트 수 (하위 n비트 버림)

  % 실수부와 허수부 분리
  xr = real(x);
  xi = imag(x);

  % truncation: 하위 n비트 버림 (2^n으로 나눈 뒤 floor → 다시 정수로 복원)
  scale = 2^n;
  xr = round(xr / scale);
  xi = round(xi / scale);

  % 복소수로 다시 결합
  yQ = xr + 1i*xi;
end