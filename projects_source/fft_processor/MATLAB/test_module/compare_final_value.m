%-------------------------------------------------------------
% 비교할 파일 경로
fixed_file = 'reorder_index_fixed.txt';
float_file = 'reorder_index_float.txt';

% 함수: 파일에서 dout 값을 읽어 복소 벡터로 반환
function data = load_dout_matlab(filename)
    fid = fopen(filename, 'r');
    if fid<0, error('파일 열기 실패: %s', filename); end

    data = zeros(512,1);
    tline = fgetl(fid);
    while ischar(tline)
        % 형식: jj=xxx, kk=yyy, dout(idx)=real+jimag
        % 실수부·허수부 추출
        tokens = textscan(tline, ...
            'jj=%d, kk=%d, dout(%d)=%f+j%f', 1);
        if ~isempty(tokens{1})
            idx  = tokens{3};        % 파일에 기록된 index
            r    = tokens{4};        % real part
            imv  = tokens{5};        % imag part
            data(idx) = r + 1j*imv;
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

% 데이터 로드
d_fixed = load_dout_matlab(fixed_file);
d_float = load_dout_matlab(float_file);

% 그래프 1: 실수부 비교
figure;
plot(1:512, real(d_fixed), '-o', 'MarkerSize',3); hold on;
plot(1:512, real(d_float), '-x', 'MarkerSize',3);
xlabel('Index'); ylabel('Real Part');
title('Fixed vs Float FFT Output (Real)');
legend('Fixed','Float','Location','Best');
grid on;

% 그래프 2: 허수부 비교
figure;
plot(1:512, imag(d_fixed), '-o', 'MarkerSize',3); hold on;
plot(1:512, imag(d_float), '-x', 'MarkerSize',3);
xlabel('Index'); ylabel('Imaginary Part');
title('Fixed vs Float FFT Output (Imag)');
legend('Fixed','Float','Location','Best');
grid on;
