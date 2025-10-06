`timescale 1ns / 1ps

module RAM (
    input  logic        clk,
    input  logic [ 1:0] we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData
);
    logic [31:0] mem[0:2**4-1];

    always_ff @(posedge clk) begin
        case (we)
            2'b01: begin
                case (addr[1:0])
                    2'b00: mem[addr[31:2]][7:0] <= wData[7:0];
                    2'b01: mem[addr[31:2]][15:8] <= wData[7:0];
                    2'b10: mem[addr[31:2]][23:16] <= wData[7:0];
                    2'b11: mem[addr[31:2]][31:24] <= wData[7:0];
                endcase
            end
            2'b10: begin
                case (addr[1:0])
                    2'b00: mem[addr[31:2]][15:0] <= wData[15:0];
                    2'b10: mem[addr[31:2]][31:16] <= wData[15:0];
                endcase
            end
            2'b11: begin
                mem[addr[31:2]] <= wData;
            end
        endcase
    end

    assign rData = mem[addr[31:2]];

endmodule
