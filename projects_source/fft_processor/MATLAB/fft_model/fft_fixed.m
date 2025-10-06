% Added on 2025/07/01 by jihan 
function [fft_out, module2_out] = fft_fixed(fft_mode, fft_in)

 %shift = 0;
 %SIM_FIX = 0; % 0: float, 1: fixed

 if (fft_mode==1) % fft
	din = fft_in;
 else % ifft
	din = conj(fft_in);
 end

 % twiddle factor
 fac8_0 = [1, 1, 1, -1i];
 fac8_1 = [1, 1, 1, -1i, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j];
 fac8_1_fixed = round(fac8_1 * 2^7);

 %-----------------------------------------------------------------------------
 % Module 0
 %-----------------------------------------------------------------------------
 % step0_0
 bfly00_out0 = din(1:256) + din(257:512);
 bfly00_out1 = din(1:256) - din(257:512);

 bfly00_tmp = [bfly00_out0, bfly00_out1];

 for nn=1:512
	bfly00(nn) = bfly00_tmp(nn)*fac8_0(ceil(nn/128));
 end

 bfly00_cut = saturation(bfly00, 4, 6);

 fp=fopen('fft_cos_matlab_00.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly00(%d)=%f+j%f\n', nn, real(bfly00_cut(nn)) / 2^6 ,imag(bfly00_cut(nn)) / 2^6);
 end
 fclose(fp);
  
 % step0_1
 for kk=1:2
  for nn=1:128
	bfly01_tmp((kk-1)*256+nn) = bfly00_cut((kk-1)*256+nn) + bfly00_cut((kk-1)*256+128+nn);
	bfly01_tmp((kk-1)*256+128+nn) = bfly00_cut((kk-1)*256+nn) - bfly00_cut((kk-1)*256+128+nn);
  end
 end

 for nn=1:512
	bfly01(nn) = bfly01_tmp(nn)*fac8_1_fixed(ceil(nn/64));
 end

 bfly01_cut0 = truncation(bfly01, 7);
 bfly01_cut1 = saturation(bfly01_cut0, 6, 6);

 fp=fopen('fft_cos_matlab_01.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly01(%d)=%f+j%f\n', nn, real(bfly01_cut1(nn)) / 2^6,imag(bfly01_cut1(nn)) / 2^6);
 end
 fclose(fp);
 
 % step0_2
 for kk=1:4
  for nn=1:64
	bfly02_tmp((kk-1)*128+nn) = bfly01_cut1((kk-1)*128+nn) + bfly01_cut1((kk-1)*128+64+nn);
	bfly02_tmp((kk-1)*128+64+nn) = bfly01_cut1((kk-1)*128+nn) - bfly01_cut1((kk-1)*128+64+nn);
  end
 end

 % Data rearrangement
 K3 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:64
	twf_m0((kk-1)*64+nn) = exp(-j*2*pi*(nn-1)*(K3(kk))/512);
  end
 end
 
 twf_m0_fixed = round(twf_m0 * 2^7);

 for nn=1:512
	bfly02(nn) = bfly02_tmp(nn)*twf_m0_fixed(nn);
 end

 bfly02_cut0 = truncation(bfly02, 7);
 bfly02_cut1 = saturation(bfly02_cut0, 5, 6);

 fp=fopen('fft_cos_matlab_02.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly02(%d)=%f+j%f\n', nn, real(bfly02_cut1(nn)) / 2^6,imag(bfly02_cut1(nn)) / 2^6);
 end
 fclose(fp);

 %-----------------------------------------------------------------------------
 % Module 1
 %-----------------------------------------------------------------------------
 % step1_0
 for kk=1:8
  for nn=1:32
	bfly10_tmp((kk-1)*64+nn) = bfly02_cut1((kk-1)*64+nn) + bfly02_cut1((kk-1)*64+32+nn);
	bfly10_tmp((kk-1)*64+32+nn) = bfly02_cut1((kk-1)*64+nn) - bfly02_cut1((kk-1)*64+32+nn);
  end
 end

 for kk=1:8
  for nn=1:64
	bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn)*fac8_0(ceil(nn/16));
  end
 end
 
 bfly10_cut = saturation(bfly10, 6, 6);

 fp=fopen('fft_cos_matlab_10.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly10(%d)=%f+j%f\n', nn, real(bfly10_cut(nn)) / 2^6,imag(bfly10_cut(nn)) / 2^6);
 end
 fclose(fp);

 % step1_1
 for kk=1:16
  for nn=1:16
	bfly11_tmp((kk-1)*32+nn) = bfly10_cut((kk-1)*32+nn) + bfly10_cut((kk-1)*32+16+nn);
	bfly11_tmp((kk-1)*32+16+nn) = bfly10_cut((kk-1)*32+nn) - bfly10_cut((kk-1)*32+16+nn);
  end
 end

 for kk=1:8
  for nn=1:64
	bfly11((kk-1)*64+nn) = bfly11_tmp((kk-1)*64+nn)*fac8_1_fixed(ceil(nn/8));
  end
 end
 
 bfly11_cut0 = truncation(bfly11, 7);
 bfly11_cut1 = saturation(bfly11_cut0, 7, 6);

 fp=fopen('fft_cos_matlab_11.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly11(%d)=%f+j%f\n', nn, real(bfly11_cut1(nn)) / 2^6,imag(bfly11_cut1(nn)) / 2^6);
 end
 fclose(fp);
 
 % step1_2
 for kk=1:32
  for nn=1:8
	bfly12_tmp((kk-1)*16+nn) = bfly11_cut1((kk-1)*16+nn) + bfly11_cut1((kk-1)*16+8+nn);
	bfly12_tmp((kk-1)*16+8+nn) = bfly11_cut1((kk-1)*16+nn) - bfly11_cut1((kk-1)*16+8+nn);
  end
 end

 % Data rearrangement
 K2 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:8
	twf_m1((kk-1)*8+nn) = exp(-j*2*pi*(nn-1)*(K2(kk))/64);
  end
 end

 twf_m1_fixed = round(twf_m1 * 2^7);

 for kk=1:8
  for nn=1:64
	bfly12((kk-1)*64+nn) = bfly12_tmp((kk-1)*64+nn)*twf_m1_fixed(nn);
  end
 end

 bfly12_cut0 = truncation(bfly12, 7);
 bfly12_cut1 = saturation(bfly12_cut0, 6, 6);

 fp=fopen('fft_cos_matlab_12.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly12(%d)=%f+j%f\n', nn, real(bfly12_cut1(nn)) / 2^6,imag(bfly12_cut1(nn)) / 2^6);
 end
 fclose(fp);

 %-----------------------------------------------------------------------------
 % Module 2
 %-----------------------------------------------------------------------------
 % step2_0
 for kk=1:64
  for nn=1:4
	bfly20_tmp((kk-1)*8+nn) = bfly12_cut1((kk-1)*8+nn) + bfly12_cut1((kk-1)*8+4+nn);
	bfly20_tmp((kk-1)*8+4+nn) = bfly12_cut1((kk-1)*8+nn) - bfly12_cut1((kk-1)*8+4+nn);
  end
 end

 for kk=1:64
  for nn=1:8
	bfly20((kk-1)*8+nn) = bfly20_tmp((kk-1)*8+nn)*fac8_0(ceil(nn/2));
  end
 end

 bfly20_cut = saturation(bfly20, 7, 6);

 fp=fopen('fft_cos_matlab_20.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly20(%d)=%f+j%f\n', nn, real(bfly20_cut(nn)) / 2^6,imag(bfly20_cut(nn)) / 2^6);
 end
 fclose(fp);

 % step2_1
 for kk=1:128
  for nn=1:2
	bfly21_tmp((kk-1)*4+nn) = bfly20_cut((kk-1)*4+nn) + bfly20_cut((kk-1)*4+2+nn);
	bfly21_tmp((kk-1)*4+2+nn) = bfly20_cut((kk-1)*4+nn) - bfly20_cut((kk-1)*4+2+nn);
  end
 end

 for kk=1:64
  for nn=1:8
	bfly21((kk-1)*8+nn) = bfly21_tmp((kk-1)*8+nn)*fac8_1_fixed(nn);
  end
 end

 bfly21_cut0 = truncation(bfly21, 7);
 bfly21_cut1 = saturation(bfly21_cut0, 8, 6);

 fp=fopen('fft_cos_matlab_21.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly21(%d)=%f+j%f\n', nn, real(bfly21_cut1(nn)) / 2^6,imag(bfly21_cut1(nn)) / 2^6);
 end
 fclose(fp);

 % step2_2
 for kk=1:256
	bfly22_tmp((kk-1)*2+1) = bfly21_cut1((kk-1)*2+1) + bfly21_cut1((kk-1)*2+2);
	bfly22_tmp((kk-1)*2+2) = bfly21_cut1((kk-1)*2+1) - bfly21_cut1((kk-1)*2+2);
 end

 bfly22 = bfly22_tmp;

 bfly22_cut = truncation(bfly22, 2);

 fp=fopen('fft_cos_matlab_22.txt','w');
 for nn=1:512
    fprintf(fp, 'bfly22(%d)=%f+j%f\n', nn, real(bfly22_cut(nn)) / 2^4 ,imag(bfly22_cut(nn)) / 2^4);
 end
 fclose(fp);

 %-----------------------------------------------------------------------------
 % Index 
 %-----------------------------------------------------------------------------
 fp=fopen('reorder_index_fixed.txt','w');
 for jj=1:512
	%kk = bitget(jj-1,9)*(2^0) + bitget(jj-1,8)*(2^1) + bitget(jj-1,7)*(2^2) + bitget(jj-1,6)*(2^3) + bitget(jj-1,5)*(2^4) + bitget(jj-1,4)*(2^5) + bitget(jj-1,3)*(2^6) + bitget(jj-1,2)*(2^7) + bitget(jj-1,1)*(2^8);
	kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + bitget(jj-1,6)*8 + bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + bitget(jj-1,3)*64 + bitget(jj-1,2)*128 + bitget(jj-1,1)*256;
	dout(kk+1) = bfly22_cut(jj); % With reorder
	fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%f+j%f\n',jj, kk,(kk+1),real(dout(kk+1)) / 2^4,imag(dout(kk+1)) / 2^4);
 end
 fclose(fp);

 if (fft_mode==1) % fft
	fft_out = dout;
	module2_out = bfly22_cut;
 else % ifft
	fft_out = conj(dout)/512; 
	module2_out = conj(bfly22_cut)/512;
 end

end
