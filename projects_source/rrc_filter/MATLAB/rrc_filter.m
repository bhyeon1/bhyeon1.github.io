% --------------------------------------------
% RRC Filter Output 분석용 Welch Power Spectrum
% --------------------------------------------

% 1. 데이터 읽기
fid = fopen('rrc_dout_matlab.txt', 'r');
data = textscan(fid, '%d');   % 정수 값으로 읽음
fclose(fid);

% 2. 데이터 변환
data = double(data{1});       % cell -> double 배열로 변환

window = 4096;                % 128,256,512 작게할수록 주파수 해상도 낮아짐. 크게할수록 노이즈에 더 민감한 파형이 나옴. 
overlap = 2048;                % 0, 128, 256 더 많을수록 스펙트럼이 부드러움. 계산량 증가. segment_length보다 작아야 함.
fft_points = 4096;            % 256, 512, 1024, 2048, 4096  작게 (빠른 처리, 낮은 해상도), 크게 (세밀한 주파수 분석, 계산량 증가)

[pxx, f] = pwelch(data, window, overlap, fft_points);

% 4. 정규화 주파수 (0~1 범위, π 기준으로 표현)
f_pi = f / max(f);      % 정규화 후 π rad/sample 단위로 표현

% 5. dB 스케일로 변환
pxx_dB = 10 * log10(pxx + eps);  % log(0) 방지를 위해 eps 추가

% 6. 그래프 출력
figure;
plot(f_pi, pxx_dB, 'y', 'LineWidth', 1.2);
xlabel('정규화 주파수 (\times\pi rad/sample)', 'FontSize', 12);
ylabel('진폭 제곱치 (dB/rad/sample)', 'FontSize', 12);
title('Welch 파워 스펙트럼 밀도 추정값', 'FontSize', 13);
grid on;

% 7. 배경 검정/글자 흰색
set(gcf, 'Color', 'k');  % Figure 배경
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');  % Plot 축 설정
