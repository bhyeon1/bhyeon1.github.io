%% compare_all_module_errors.m
% 0_0 부터 2_2 까지 9개 모듈에 대해 Fixed−Float 오차를 3×3 서브플롯으로 그립니다.

% 모듈 리스트
mods = {'0_0','0_1','0_2', ...
        '1_0','1_1','1_2', ...
        '2_0','2_1','2_2'};

%% 1) 실수부 오차
figure('Name','Real Part Error for All Modules','NumberTitle','off');
for k = 1:numel(mods)
    m = mods{k};
    fixed_file = sprintf('fixed_module%s.txt', m);
    float_file = sprintf('float_module%s.txt', m);
    
    df = load_anymatlab(fixed_file);
    dl = load_anymatlab(float_file);
    
    err_real = real(dl) - real(df);
    
    subplot(3,3,k);
    plot(1:512, err_real, '-s','MarkerSize',2);
    title(['Module ', m],'FontSize',10);
    xlabel('Index'); ylabel('Err_{real}');
    grid on;
    % 축 범위: ±최대 절대오차 *1.1
    mx = max(abs(err_real));
    ylim([-mx*1.1, mx*1.1]);
end

%% 2) 허수부 오차
figure('Name','Imag Part Error for All Modules','NumberTitle','off');
for k = 1:numel(mods)
    m = mods{k};
    fixed_file = sprintf('fixed_module%s.txt', m);
    float_file = sprintf('float_module%s.txt', m);
    
    df = load_anymatlab(fixed_file);
    dl = load_anymatlab(float_file);
    
    err_imag = imag(dl) - imag(df);
    
    subplot(3,3,k);
    plot(1:512, err_imag, '-d','MarkerSize',2);
    title(['Module ', m],'FontSize',10);
    xlabel('Index'); ylabel('Err_{imag}');
    grid on;
    % 축 범위: ±최대 절대오차 *1.1
    mx = max(abs(err_imag));
    ylim([-mx*1.1, mx*1.1]);
end

%% === Subfunction ===
function data = load_anymatlab(filename)
    fid = fopen(filename,'r');
    if fid<0
        error('파일 열기 실패: %s', filename);
    end
    data = zeros(512,1);
    expr = '\w+\((\d+)\)=([\-0-9\.]+)\+j([\-0-9\.]+)';
    while ~feof(fid)
        line = fgetl(fid);
        tok  = regexp(line, expr, 'tokens');
        if ~isempty(tok)
            idx     = str2double(tok{1}{1});
            realVal = str2double(tok{1}{2});
            imagVal = str2double(tok{1}{3});
            data(idx) = realVal + 1j*imagVal;
        end
    end
    fclose(fid);
end
