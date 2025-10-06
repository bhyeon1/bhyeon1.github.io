% Test fft function (fft_matlab vs. fft_manual) 
% Added on 2025/07/02 by jihan 
 N = 512;
 fft_mode = 1;
 [ran_float, ran_fixed] = ran_in_gen_stu(fft_mode, N);
 %[cos_float, cos_fixed] = cos_in_gen(fft_mode, N);

 %re_data = load('cos_i_dat_stu.txt');  % 크기: [512x1]
 %im_data = load('cos_q_dat_stu.txt');  % 크기: [512x1]
 % 크기 검증은 생략, cos_data와 sin_data가 모두 512줄이라고 가정
  
 %ran_fixed = complex(zeros(N, 1));  % 복소수 배열 초기화
 
 %for k = 1:N
 %    re = re_data(k);      % 실수부
 %    im = im_data(k);     % 음의 사인값 -> 복소수 허수부용
 %    ran_fixed(k) = re + j*im;
 %end

 mat_float_fft = fft(ran_float); % Matlab fft (Random, Floating-point)
 %mat_float_fft = fft(cos_float); % Matlab fft (Cosine, Floating-point)
 
 [fft_out_fixed, module2_out_fixed] = fft_fixed_stu(1, ran_fixed); % Fixed-point fft (Random, fft)
 %[fft_out_fixed, module2_out_fixed] = fft_fixed_stu(1, cos_fixed); % Fixed-point fft (Cosine, fft)
 fft_out_fixed = fft_out_fixed/16; % Modified on 2025/07/02 by jihan

 %fp_1=fopen('fft_ran.txt','w');
 fp_1=fopen('fft_cos.txt','w');
 for ii=1:N
     sig_pow(ii) = power(real(mat_float_fft(ii)),2) + power(imag(mat_float_fft(ii)),2);
     noise_re(ii) = real(mat_float_fft(ii)) - real(fft_out_fixed(ii));
     noise_im(ii) = imag(mat_float_fft(ii)) - imag(fft_out_fixed(ii));
     noise_pow(ii) = power(noise_re(ii),2) + power(noise_im(ii),2);
     fprintf(fp_1,'sig_pow(ii)=%f, noise_pow(ii)=%f\n', sig_pow(ii), noise_pow(ii)); 
 end
 fclose(fp_1);

 tot_sig_pow = 0.0;
 tot_noise_pow = 0.0;
 for ii=1:N
 	tot_sig_pow = tot_sig_pow + sig_pow(ii);
    tot_noise_pow = tot_noise_pow + noise_pow(ii);
 end

 snr_val = 10*log10(tot_sig_pow/tot_noise_pow);

 X=sprintf('tot_sig_pow=%f, tot_noise_pow=%f, snr_val=%f\n',tot_sig_pow, tot_noise_pow, snr_val);
 disp(X);
