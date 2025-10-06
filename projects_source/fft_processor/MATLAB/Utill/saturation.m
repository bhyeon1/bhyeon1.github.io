function yQ = saturation(x, m, n)
  % 포화 범위 계산 (signed Qm.n integer)
  maxv =  2^(m+n-1) - 1;
  minv = -2^(m+n-1);

  % 실수부와 허수부 분리
  xr = real(x);
  xi = imag(x);

  % 각각 포화
  xr = min( max(xr, minv), maxv );  % minv 보다 작으면 minv로 올려줌.
  xi = min( max(xi, minv), maxv );  % maxv 보다 크면 maxv로 내려줌. (범위 제한 기법)

  % 다시 합쳐서 복소 정수 반환
  yQ = xr + 1i*xi;
end