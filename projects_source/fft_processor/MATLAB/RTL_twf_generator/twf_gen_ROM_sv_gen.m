%%--------------------------------------------------------------------
% twiddle_factor_ROM_sv_gen.m
%  각 스테이지 트위들 팩터를
%  SystemVerilog "콤비네이션 ROM" 모듈 + 인스턴스 예시 형태(.txt)로 출력
%%--------------------------------------------------------------------
clear; clc;

%% (1) 파라미터 & TWIDDLE 벡터 생성
fac8_1 = [256,256,256,-256j,256,181-181j,256,-181-181j];
K3     = [0,4,2,6,1,5,3,7];
K2     = [0,4,2,6,1,5,3,7];

for nn = 1:512
    twf0_1(nn) = fac8_1(ceil(nn / 64));
end

for kk=1:8
  for nn=1:64
	flo_twf_m0((kk-1)*64+nn) = exp(-j*2*pi*(nn-1)*(K3(kk))/512);
	twf0_2((kk-1)*64+nn) = round(flo_twf_m0((kk-1)*64+nn)*128);
  end
 end

for kk=1:8
  for nn=1:64
	twf1_1((kk-1)*64+nn) = fac8_1(ceil(nn/8));
  end
 end

for kk=1:8
  for nn=1:8
	flo_twf_m1((kk-1)*8+nn) = exp(-j*2*pi*(nn-1)*(K2(kk))/64);
	twf_m1((kk-1)*8+nn) = round(flo_twf_m1((kk-1)*8+nn)*128); % twf_m0 : <2.7>
  end
 end

 for kk=1:8
  for nn=1:64
	twf1_2((kk-1)*64+nn) = twf_m1(nn); % (16bit(15+1) * 9bit = 25 bit) 
  end
 end

for kk=1:64
  for nn=1:8
	twf2_1((kk-1)*8+nn) = fac8_1(nn);
  end
 end


%% (2) 텍스트 출력 함수 정의 (assign-once, 두 개씩 병렬 출력)
function write_rom_txt(fname, stage, data, width, inst_name)
    fid = fopen(fname,'w');
    % — module header
    fprintf(fid, "module %s_rom (\n", stage);
    fprintf(fid, "  input  logic [8:0] addr,\n");
    fprintf(fid, "  output logic signed [%d:0] re,\n", width-1);
    fprintf(fid, "  output logic signed [%d:0] im\n", width-1);
    fprintf(fid, ");\n\n");
    % — ROM storage
    fprintf(fid, "  wire signed [%d:0] rom_re [0:511];\n", width-1);
    fprintf(fid, "  wire signed [%d:0] rom_im [0:511];\n\n", width-1);
    % — assign 문 (인덱스마다 두 줄씩 한 줄에 나란히)
    for idx = 0:numel(data)-1
        r   = real(data(idx+1));
        imv = imag(data(idx+1));
        fprintf(fid, "      assign rom_re[%3d] = %4d;    assign rom_im[%3d] = %4d;\n", ...
                idx, r, idx, imv);
    end
    fprintf(fid, "\n");
    % — output mapping
    fprintf(fid, "  assign re = rom_re[addr];\n");
    fprintf(fid, "  assign im = rom_im[addr];\n\n");
    fprintf(fid, "endmodule\n\n");
    % — instantiation example
    fprintf(fid, "// Example instantiation:\n");
    fprintf(fid, "%s u_%s (\n", inst_name, stage);
    fprintf(fid, "  .addr(addr), .re(re), .im(im)\n");
    fprintf(fid, ");\n");
    fclose(fid);
end

%% (3) 각 스테이지별 .txt 파일 생성
write_rom_txt('twf0_1_rom.txt','twf0_1',twf0_1,10,'twiddle_factor');
write_rom_txt('twf0_2_rom.txt','twf0_2',twf0_2,9,'twiddle_factor');
write_rom_txt('twf1_1_rom.txt','twf1_1',twf1_1,10,'twiddle_factor');
write_rom_txt('twf1_2_rom.txt','twf1_2',twf1_2,9,'twiddle_factor');
write_rom_txt('twf2_1_rom.txt','twf2_1',twf2_1,10,'twiddle_factor');
% … 다른 스테이지도 동일하게 호출 …

disp('=== ROM .txt 파일 생성 완료 ===');
