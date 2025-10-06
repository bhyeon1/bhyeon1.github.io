`timescale 1ns / 1ps

module fft_reorder (
    input  logic        clk,
    input  logic        rstn,
    input  logic        valid_in,
    input  logic signed [12:0] in_data  [ 15:0],  // 16개 입력 데이터 [0]~[15]
    output logic signed [12:0] dout_mem [511:0],
    output logic        valid_out
);
    logic [4:0] cnt;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt <= 0;
        end else begin
            if (valid_in) cnt <= cnt + 1;
            else cnt <= 0;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        integer i;
        if (!rstn) begin
            for (i = 0; i < 512; i++) begin
                dout_mem[i] <= '0;
                valid_out   <= '0;
            end
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                case (cnt)
                    5'd0: begin
                        dout_mem[0]   <= in_data[0];
                        dout_mem[256] <= in_data[1];
                        dout_mem[128] <= in_data[2];
                        dout_mem[384] <= in_data[3];
                        dout_mem[64]  <= in_data[4];
                        dout_mem[320] <= in_data[5];
                        dout_mem[192] <= in_data[6];
                        dout_mem[448] <= in_data[7];
                        dout_mem[32]  <= in_data[8];
                        dout_mem[288] <= in_data[9];
                        dout_mem[160] <= in_data[10];
                        dout_mem[416] <= in_data[11];
                        dout_mem[96]  <= in_data[12];
                        dout_mem[352] <= in_data[13];
                        dout_mem[224] <= in_data[14];
                        dout_mem[480] <= in_data[15];
                    end

                    5'd1: begin
                        dout_mem[16]  <= in_data[0];
                        dout_mem[272] <= in_data[1];
                        dout_mem[144] <= in_data[2];
                        dout_mem[400] <= in_data[3];
                        dout_mem[80]  <= in_data[4];
                        dout_mem[336] <= in_data[5];
                        dout_mem[208] <= in_data[6];
                        dout_mem[464] <= in_data[7];
                        dout_mem[48]  <= in_data[8];
                        dout_mem[304] <= in_data[9];
                        dout_mem[176] <= in_data[10];
                        dout_mem[432] <= in_data[11];
                        dout_mem[112] <= in_data[12];
                        dout_mem[368] <= in_data[13];
                        dout_mem[240] <= in_data[14];
                        dout_mem[496] <= in_data[15];
                    end

                    5'd2: begin
                        dout_mem[8]   <= in_data[0];
                        dout_mem[264] <= in_data[1];
                        dout_mem[136] <= in_data[2];
                        dout_mem[392] <= in_data[3];
                        dout_mem[72]  <= in_data[4];
                        dout_mem[328] <= in_data[5];
                        dout_mem[200] <= in_data[6];
                        dout_mem[456] <= in_data[7];
                        dout_mem[40]  <= in_data[8];
                        dout_mem[296] <= in_data[9];
                        dout_mem[168] <= in_data[10];
                        dout_mem[424] <= in_data[11];
                        dout_mem[104] <= in_data[12];
                        dout_mem[360] <= in_data[13];
                        dout_mem[232] <= in_data[14];
                        dout_mem[488] <= in_data[15];
                    end

                    5'd3: begin
                        dout_mem[24]  <= in_data[0];
                        dout_mem[280] <= in_data[1];
                        dout_mem[152] <= in_data[2];
                        dout_mem[408] <= in_data[3];
                        dout_mem[88]  <= in_data[4];
                        dout_mem[344] <= in_data[5];
                        dout_mem[216] <= in_data[6];
                        dout_mem[472] <= in_data[7];
                        dout_mem[56]  <= in_data[8];
                        dout_mem[312] <= in_data[9];
                        dout_mem[184] <= in_data[10];
                        dout_mem[440] <= in_data[11];
                        dout_mem[120] <= in_data[12];
                        dout_mem[376] <= in_data[13];
                        dout_mem[248] <= in_data[14];
                        dout_mem[504] <= in_data[15];
                    end

                    5'd4: begin
                        dout_mem[4]   <= in_data[0];
                        dout_mem[260] <= in_data[1];
                        dout_mem[132] <= in_data[2];
                        dout_mem[388] <= in_data[3];
                        dout_mem[68]  <= in_data[4];
                        dout_mem[324] <= in_data[5];
                        dout_mem[196] <= in_data[6];
                        dout_mem[452] <= in_data[7];
                        dout_mem[36]  <= in_data[8];
                        dout_mem[292] <= in_data[9];
                        dout_mem[164] <= in_data[10];
                        dout_mem[420] <= in_data[11];
                        dout_mem[100] <= in_data[12];
                        dout_mem[356] <= in_data[13];
                        dout_mem[228] <= in_data[14];
                        dout_mem[484] <= in_data[15];
                    end

                    5'd5: begin
                        dout_mem[20]  <= in_data[0];
                        dout_mem[276] <= in_data[1];
                        dout_mem[148] <= in_data[2];
                        dout_mem[404] <= in_data[3];
                        dout_mem[84]  <= in_data[4];
                        dout_mem[340] <= in_data[5];
                        dout_mem[212] <= in_data[6];
                        dout_mem[468] <= in_data[7];
                        dout_mem[52]  <= in_data[8];
                        dout_mem[308] <= in_data[9];
                        dout_mem[180] <= in_data[10];
                        dout_mem[436] <= in_data[11];
                        dout_mem[116] <= in_data[12];
                        dout_mem[372] <= in_data[13];
                        dout_mem[244] <= in_data[14];
                        dout_mem[500] <= in_data[15];
                    end

                    5'd6: begin
                        dout_mem[12]  <= in_data[0];
                        dout_mem[268] <= in_data[1];
                        dout_mem[140] <= in_data[2];
                        dout_mem[396] <= in_data[3];
                        dout_mem[76]  <= in_data[4];
                        dout_mem[332] <= in_data[5];
                        dout_mem[204] <= in_data[6];
                        dout_mem[460] <= in_data[7];
                        dout_mem[44]  <= in_data[8];
                        dout_mem[300] <= in_data[9];
                        dout_mem[172] <= in_data[10];
                        dout_mem[428] <= in_data[11];
                        dout_mem[108] <= in_data[12];
                        dout_mem[364] <= in_data[13];
                        dout_mem[236] <= in_data[14];
                        dout_mem[492] <= in_data[15];
                    end

                    5'd7: begin
                        dout_mem[28]  <= in_data[0];
                        dout_mem[284] <= in_data[1];
                        dout_mem[156] <= in_data[2];
                        dout_mem[412] <= in_data[3];
                        dout_mem[92]  <= in_data[4];
                        dout_mem[348] <= in_data[5];
                        dout_mem[220] <= in_data[6];
                        dout_mem[476] <= in_data[7];
                        dout_mem[60]  <= in_data[8];
                        dout_mem[316] <= in_data[9];
                        dout_mem[188] <= in_data[10];
                        dout_mem[444] <= in_data[11];
                        dout_mem[124] <= in_data[12];
                        dout_mem[380] <= in_data[13];
                        dout_mem[252] <= in_data[14];
                        dout_mem[508] <= in_data[15];
                    end

                    5'd8: begin
                        dout_mem[2]   <= in_data[0];
                        dout_mem[258] <= in_data[1];
                        dout_mem[130] <= in_data[2];
                        dout_mem[386] <= in_data[3];
                        dout_mem[66]  <= in_data[4];
                        dout_mem[322] <= in_data[5];
                        dout_mem[194] <= in_data[6];
                        dout_mem[450] <= in_data[7];
                        dout_mem[34]  <= in_data[8];
                        dout_mem[290] <= in_data[9];
                        dout_mem[162] <= in_data[10];
                        dout_mem[418] <= in_data[11];
                        dout_mem[98]  <= in_data[12];
                        dout_mem[354] <= in_data[13];
                        dout_mem[226] <= in_data[14];
                        dout_mem[482] <= in_data[15];
                    end

                    5'd9: begin
                        dout_mem[18]  <= in_data[0];
                        dout_mem[274] <= in_data[1];
                        dout_mem[146] <= in_data[2];
                        dout_mem[402] <= in_data[3];
                        dout_mem[82]  <= in_data[4];
                        dout_mem[338] <= in_data[5];
                        dout_mem[210] <= in_data[6];
                        dout_mem[466] <= in_data[7];
                        dout_mem[50]  <= in_data[8];
                        dout_mem[306] <= in_data[9];
                        dout_mem[178] <= in_data[10];
                        dout_mem[434] <= in_data[11];
                        dout_mem[114] <= in_data[12];
                        dout_mem[370] <= in_data[13];
                        dout_mem[242] <= in_data[14];
                        dout_mem[498] <= in_data[15];
                    end

                    5'd10: begin
                        dout_mem[10]  <= in_data[0];
                        dout_mem[266] <= in_data[1];
                        dout_mem[138] <= in_data[2];
                        dout_mem[394] <= in_data[3];
                        dout_mem[74]  <= in_data[4];
                        dout_mem[330] <= in_data[5];
                        dout_mem[202] <= in_data[6];
                        dout_mem[458] <= in_data[7];
                        dout_mem[42]  <= in_data[8];
                        dout_mem[298] <= in_data[9];
                        dout_mem[170] <= in_data[10];
                        dout_mem[426] <= in_data[11];
                        dout_mem[106] <= in_data[12];
                        dout_mem[362] <= in_data[13];
                        dout_mem[234] <= in_data[14];
                        dout_mem[490] <= in_data[15];
                    end

                    5'd11: begin
                        dout_mem[26]  <= in_data[0];
                        dout_mem[282] <= in_data[1];
                        dout_mem[154] <= in_data[2];
                        dout_mem[410] <= in_data[3];
                        dout_mem[90]  <= in_data[4];
                        dout_mem[346] <= in_data[5];
                        dout_mem[218] <= in_data[6];
                        dout_mem[474] <= in_data[7];
                        dout_mem[58]  <= in_data[8];
                        dout_mem[314] <= in_data[9];
                        dout_mem[186] <= in_data[10];
                        dout_mem[442] <= in_data[11];
                        dout_mem[122] <= in_data[12];
                        dout_mem[378] <= in_data[13];
                        dout_mem[250] <= in_data[14];
                        dout_mem[506] <= in_data[15];
                    end

                    5'd12: begin
                        dout_mem[6]   <= in_data[0];
                        dout_mem[262] <= in_data[1];
                        dout_mem[134] <= in_data[2];
                        dout_mem[390] <= in_data[3];
                        dout_mem[70]  <= in_data[4];
                        dout_mem[326] <= in_data[5];
                        dout_mem[198] <= in_data[6];
                        dout_mem[454] <= in_data[7];
                        dout_mem[38]  <= in_data[8];
                        dout_mem[294] <= in_data[9];
                        dout_mem[166] <= in_data[10];
                        dout_mem[422] <= in_data[11];
                        dout_mem[102] <= in_data[12];
                        dout_mem[358] <= in_data[13];
                        dout_mem[230] <= in_data[14];
                        dout_mem[486] <= in_data[15];
                    end

                    5'd13: begin
                        dout_mem[22]  <= in_data[0];
                        dout_mem[278] <= in_data[1];
                        dout_mem[150] <= in_data[2];
                        dout_mem[406] <= in_data[3];
                        dout_mem[86]  <= in_data[4];
                        dout_mem[342] <= in_data[5];
                        dout_mem[214] <= in_data[6];
                        dout_mem[470] <= in_data[7];
                        dout_mem[54]  <= in_data[8];
                        dout_mem[310] <= in_data[9];
                        dout_mem[182] <= in_data[10];
                        dout_mem[438] <= in_data[11];
                        dout_mem[118] <= in_data[12];
                        dout_mem[374] <= in_data[13];
                        dout_mem[246] <= in_data[14];
                        dout_mem[502] <= in_data[15];
                    end

                    5'd14: begin
                        dout_mem[14]  <= in_data[0];
                        dout_mem[270] <= in_data[1];
                        dout_mem[142] <= in_data[2];
                        dout_mem[398] <= in_data[3];
                        dout_mem[78]  <= in_data[4];
                        dout_mem[334] <= in_data[5];
                        dout_mem[206] <= in_data[6];
                        dout_mem[462] <= in_data[7];
                        dout_mem[46]  <= in_data[8];
                        dout_mem[302] <= in_data[9];
                        dout_mem[174] <= in_data[10];
                        dout_mem[430] <= in_data[11];
                        dout_mem[110] <= in_data[12];
                        dout_mem[366] <= in_data[13];
                        dout_mem[238] <= in_data[14];
                        dout_mem[494] <= in_data[15];
                    end

                    5'd15: begin
                        dout_mem[30]  <= in_data[0];
                        dout_mem[286] <= in_data[1];
                        dout_mem[158] <= in_data[2];
                        dout_mem[414] <= in_data[3];
                        dout_mem[94]  <= in_data[4];
                        dout_mem[350] <= in_data[5];
                        dout_mem[222] <= in_data[6];
                        dout_mem[478] <= in_data[7];
                        dout_mem[62]  <= in_data[8];
                        dout_mem[318] <= in_data[9];
                        dout_mem[190] <= in_data[10];
                        dout_mem[446] <= in_data[11];
                        dout_mem[126] <= in_data[12];
                        dout_mem[382] <= in_data[13];
                        dout_mem[254] <= in_data[14];
                        dout_mem[510] <= in_data[15];
                    end

                    5'd16: begin
                        dout_mem[1]   <= in_data[0];
                        dout_mem[257] <= in_data[1];
                        dout_mem[129] <= in_data[2];
                        dout_mem[385] <= in_data[3];
                        dout_mem[65]  <= in_data[4];
                        dout_mem[321] <= in_data[5];
                        dout_mem[193] <= in_data[6];
                        dout_mem[449] <= in_data[7];
                        dout_mem[33]  <= in_data[8];
                        dout_mem[289] <= in_data[9];
                        dout_mem[161] <= in_data[10];
                        dout_mem[417] <= in_data[11];
                        dout_mem[97]  <= in_data[12];
                        dout_mem[353] <= in_data[13];
                        dout_mem[225] <= in_data[14];
                        dout_mem[481] <= in_data[15];
                    end

                    5'd17: begin
                        dout_mem[17]  <= in_data[0];
                        dout_mem[273] <= in_data[1];
                        dout_mem[145] <= in_data[2];
                        dout_mem[401] <= in_data[3];
                        dout_mem[81]  <= in_data[4];
                        dout_mem[337] <= in_data[5];
                        dout_mem[209] <= in_data[6];
                        dout_mem[465] <= in_data[7];
                        dout_mem[49]  <= in_data[8];
                        dout_mem[305] <= in_data[9];
                        dout_mem[177] <= in_data[10];
                        dout_mem[433] <= in_data[11];
                        dout_mem[113] <= in_data[12];
                        dout_mem[369] <= in_data[13];
                        dout_mem[241] <= in_data[14];
                        dout_mem[497] <= in_data[15];
                    end

                    5'd18: begin
                        dout_mem[9]   <= in_data[0];
                        dout_mem[265] <= in_data[1];
                        dout_mem[137] <= in_data[2];
                        dout_mem[393] <= in_data[3];
                        dout_mem[73]  <= in_data[4];
                        dout_mem[329] <= in_data[5];
                        dout_mem[201] <= in_data[6];
                        dout_mem[457] <= in_data[7];
                        dout_mem[41]  <= in_data[8];
                        dout_mem[297] <= in_data[9];
                        dout_mem[169] <= in_data[10];
                        dout_mem[425] <= in_data[11];
                        dout_mem[105] <= in_data[12];
                        dout_mem[361] <= in_data[13];
                        dout_mem[233] <= in_data[14];
                        dout_mem[489] <= in_data[15];
                    end

                    5'd19: begin
                        dout_mem[25]  <= in_data[0];
                        dout_mem[281] <= in_data[1];
                        dout_mem[153] <= in_data[2];
                        dout_mem[409] <= in_data[3];
                        dout_mem[89]  <= in_data[4];
                        dout_mem[345] <= in_data[5];
                        dout_mem[217] <= in_data[6];
                        dout_mem[473] <= in_data[7];
                        dout_mem[57]  <= in_data[8];
                        dout_mem[313] <= in_data[9];
                        dout_mem[185] <= in_data[10];
                        dout_mem[441] <= in_data[11];
                        dout_mem[121] <= in_data[12];
                        dout_mem[377] <= in_data[13];
                        dout_mem[249] <= in_data[14];
                        dout_mem[505] <= in_data[15];
                    end

                    5'd20: begin
                        dout_mem[5]   <= in_data[0];
                        dout_mem[261] <= in_data[1];
                        dout_mem[133] <= in_data[2];
                        dout_mem[389] <= in_data[3];
                        dout_mem[69]  <= in_data[4];
                        dout_mem[325] <= in_data[5];
                        dout_mem[197] <= in_data[6];
                        dout_mem[453] <= in_data[7];
                        dout_mem[37]  <= in_data[8];
                        dout_mem[293] <= in_data[9];
                        dout_mem[165] <= in_data[10];
                        dout_mem[421] <= in_data[11];
                        dout_mem[101] <= in_data[12];
                        dout_mem[357] <= in_data[13];
                        dout_mem[229] <= in_data[14];
                        dout_mem[485] <= in_data[15];
                    end

                    5'd21: begin
                        dout_mem[21]  <= in_data[0];
                        dout_mem[277] <= in_data[1];
                        dout_mem[149] <= in_data[2];
                        dout_mem[405] <= in_data[3];
                        dout_mem[85]  <= in_data[4];
                        dout_mem[341] <= in_data[5];
                        dout_mem[213] <= in_data[6];
                        dout_mem[469] <= in_data[7];
                        dout_mem[53]  <= in_data[8];
                        dout_mem[309] <= in_data[9];
                        dout_mem[181] <= in_data[10];
                        dout_mem[437] <= in_data[11];
                        dout_mem[117] <= in_data[12];
                        dout_mem[373] <= in_data[13];
                        dout_mem[245] <= in_data[14];
                        dout_mem[501] <= in_data[15];
                    end

                    5'd22: begin
                        dout_mem[13]  <= in_data[0];
                        dout_mem[269] <= in_data[1];
                        dout_mem[141] <= in_data[2];
                        dout_mem[397] <= in_data[3];
                        dout_mem[77]  <= in_data[4];
                        dout_mem[333] <= in_data[5];
                        dout_mem[205] <= in_data[6];
                        dout_mem[461] <= in_data[7];
                        dout_mem[45]  <= in_data[8];
                        dout_mem[301] <= in_data[9];
                        dout_mem[173] <= in_data[10];
                        dout_mem[429] <= in_data[11];
                        dout_mem[109] <= in_data[12];
                        dout_mem[365] <= in_data[13];
                        dout_mem[237] <= in_data[14];
                        dout_mem[493] <= in_data[15];
                    end

                    5'd23: begin
                        dout_mem[29]  <= in_data[0];
                        dout_mem[285] <= in_data[1];
                        dout_mem[157] <= in_data[2];
                        dout_mem[413] <= in_data[3];
                        dout_mem[93]  <= in_data[4];
                        dout_mem[349] <= in_data[5];
                        dout_mem[221] <= in_data[6];
                        dout_mem[477] <= in_data[7];
                        dout_mem[61]  <= in_data[8];
                        dout_mem[317] <= in_data[9];
                        dout_mem[189] <= in_data[10];
                        dout_mem[445] <= in_data[11];
                        dout_mem[125] <= in_data[12];
                        dout_mem[381] <= in_data[13];
                        dout_mem[253] <= in_data[14];
                        dout_mem[509] <= in_data[15];
                    end

                    5'd24: begin
                        dout_mem[3]   <= in_data[0];
                        dout_mem[259] <= in_data[1];
                        dout_mem[131] <= in_data[2];
                        dout_mem[387] <= in_data[3];
                        dout_mem[67]  <= in_data[4];
                        dout_mem[323] <= in_data[5];
                        dout_mem[195] <= in_data[6];
                        dout_mem[451] <= in_data[7];
                        dout_mem[35]  <= in_data[8];
                        dout_mem[291] <= in_data[9];
                        dout_mem[163] <= in_data[10];
                        dout_mem[419] <= in_data[11];
                        dout_mem[99]  <= in_data[12];
                        dout_mem[355] <= in_data[13];
                        dout_mem[227] <= in_data[14];
                        dout_mem[483] <= in_data[15];
                    end

                    5'd25: begin
                        dout_mem[19]  <= in_data[0];
                        dout_mem[275] <= in_data[1];
                        dout_mem[147] <= in_data[2];
                        dout_mem[403] <= in_data[3];
                        dout_mem[83]  <= in_data[4];
                        dout_mem[339] <= in_data[5];
                        dout_mem[211] <= in_data[6];
                        dout_mem[467] <= in_data[7];
                        dout_mem[51]  <= in_data[8];
                        dout_mem[307] <= in_data[9];
                        dout_mem[179] <= in_data[10];
                        dout_mem[435] <= in_data[11];
                        dout_mem[115] <= in_data[12];
                        dout_mem[371] <= in_data[13];
                        dout_mem[243] <= in_data[14];
                        dout_mem[499] <= in_data[15];
                    end

                    5'd26: begin
                        dout_mem[11]  <= in_data[0];
                        dout_mem[267] <= in_data[1];
                        dout_mem[139] <= in_data[2];
                        dout_mem[395] <= in_data[3];
                        dout_mem[75]  <= in_data[4];
                        dout_mem[331] <= in_data[5];
                        dout_mem[203] <= in_data[6];
                        dout_mem[459] <= in_data[7];
                        dout_mem[43]  <= in_data[8];
                        dout_mem[299] <= in_data[9];
                        dout_mem[171] <= in_data[10];
                        dout_mem[427] <= in_data[11];
                        dout_mem[107] <= in_data[12];
                        dout_mem[363] <= in_data[13];
                        dout_mem[235] <= in_data[14];
                        dout_mem[491] <= in_data[15];
                    end

                    5'd27: begin
                        dout_mem[27]  <= in_data[0];
                        dout_mem[283] <= in_data[1];
                        dout_mem[155] <= in_data[2];
                        dout_mem[411] <= in_data[3];
                        dout_mem[91]  <= in_data[4];
                        dout_mem[347] <= in_data[5];
                        dout_mem[219] <= in_data[6];
                        dout_mem[475] <= in_data[7];
                        dout_mem[59]  <= in_data[8];
                        dout_mem[315] <= in_data[9];
                        dout_mem[187] <= in_data[10];
                        dout_mem[443] <= in_data[11];
                        dout_mem[123] <= in_data[12];
                        dout_mem[379] <= in_data[13];
                        dout_mem[251] <= in_data[14];
                        dout_mem[507] <= in_data[15];
                    end

                    5'd28: begin
                        dout_mem[7]   <= in_data[0];
                        dout_mem[263] <= in_data[1];
                        dout_mem[135] <= in_data[2];
                        dout_mem[391] <= in_data[3];
                        dout_mem[71]  <= in_data[4];
                        dout_mem[327] <= in_data[5];
                        dout_mem[199] <= in_data[6];
                        dout_mem[455] <= in_data[7];
                        dout_mem[39]  <= in_data[8];
                        dout_mem[295] <= in_data[9];
                        dout_mem[167] <= in_data[10];
                        dout_mem[423] <= in_data[11];
                        dout_mem[103] <= in_data[12];
                        dout_mem[359] <= in_data[13];
                        dout_mem[231] <= in_data[14];
                        dout_mem[487] <= in_data[15];
                    end

                    5'd29: begin
                        dout_mem[23]  <= in_data[0];
                        dout_mem[279] <= in_data[1];
                        dout_mem[151] <= in_data[2];
                        dout_mem[407] <= in_data[3];
                        dout_mem[87]  <= in_data[4];
                        dout_mem[343] <= in_data[5];
                        dout_mem[215] <= in_data[6];
                        dout_mem[471] <= in_data[7];
                        dout_mem[55]  <= in_data[8];
                        dout_mem[311] <= in_data[9];
                        dout_mem[183] <= in_data[10];
                        dout_mem[439] <= in_data[11];
                        dout_mem[119] <= in_data[12];
                        dout_mem[375] <= in_data[13];
                        dout_mem[247] <= in_data[14];
                        dout_mem[503] <= in_data[15];
                    end

                    5'd30: begin
                        dout_mem[15]  <= in_data[0];
                        dout_mem[271] <= in_data[1];
                        dout_mem[143] <= in_data[2];
                        dout_mem[399] <= in_data[3];
                        dout_mem[79]  <= in_data[4];
                        dout_mem[335] <= in_data[5];
                        dout_mem[207] <= in_data[6];
                        dout_mem[463] <= in_data[7];
                        dout_mem[47]  <= in_data[8];
                        dout_mem[303] <= in_data[9];
                        dout_mem[175] <= in_data[10];
                        dout_mem[431] <= in_data[11];
                        dout_mem[111] <= in_data[12];
                        dout_mem[367] <= in_data[13];
                        dout_mem[239] <= in_data[14];
                        dout_mem[495] <= in_data[15];
                    end

                    5'd31: begin
                        dout_mem[31]  <= in_data[0];
                        dout_mem[287] <= in_data[1];
                        dout_mem[159] <= in_data[2];
                        dout_mem[415] <= in_data[3];
                        dout_mem[95]  <= in_data[4];
                        dout_mem[351] <= in_data[5];
                        dout_mem[223] <= in_data[6];
                        dout_mem[479] <= in_data[7];
                        dout_mem[63]  <= in_data[8];
                        dout_mem[319] <= in_data[9];
                        dout_mem[191] <= in_data[10];
                        dout_mem[447] <= in_data[11];
                        dout_mem[127] <= in_data[12];
                        dout_mem[383] <= in_data[13];
                        dout_mem[255] <= in_data[14];
                        dout_mem[511] <= in_data[15];
                    end

                    default: begin
                        for (i = 0; i < 512; i++) begin
                            dout_mem[i] <= '0;
                        end
                    end
                endcase
			end else begin
				for (i = 0; i < 512; i++) begin
					dout_mem[i] <= '0;
					valid_out   <= '0;
				end
			end
        end
    end
endmodule

