`timescale 1ns / 1ps

module apb_tb ();
    // gloabal signals
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [31:0] PADDR;
    logic        PWRITE;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic        PSEL4;
    logic        PSEL5;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic [31:0] PRDATA4;
    logic [31:0] PRDATA5;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;
    logic        PREADY4;
    logic        PREADY5;
    // Internal Interface Signals
    logic        transfer;
    logic        ready;
    logic        write;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [ 7:0] gpo;
    logic [ 7:0] gpi;
    logic [ 7:0] gpio;
    logic [ 3:0] fndCom;
    logic [ 7:0] fndFont;
    logic rx;
    logic tx;

    APB_Master U_APB_Master (.*);

    RAM U_RAM (
        .*,
        .PADDR (PADDR[11:0]),
        .PSEL  (PSEL0),
        .PRDATA(PRDATA0),
        .PREADY(PREADY0)
    );

    GPO_Periph U_APB_GPO (
        .*,
        .PSEL  (PSEL1),
        .PRDATA(PRDATA1),
        .PREADY(PREADY1)
    );
    GPI_Periph U_APB_GPI (
        .*,
        .PSEL  (PSEL2),
        .PRDATA(PRDATA2),
        .PREADY(PREADY2)
    );
    /*
    GPIO_Periph U_APB_GPIO (
        .*,
        .PSEL  (PSEL3),
        .PRDATA(PRDATA3),
        .PREADY(PREADY3)
    );
    */

    fndController_Periph U_APB_FND (
        .*,
        .PSEL  (PSEL4),
        .PRDATA(PRDATA4),
        .PREADY(PREADY4)
    );

    UART_Periph U_UART_PERI (
        .*,
        .PSEL  (PSEL5),
        .PRDATA(PRDATA5),
        .PREADY(PREADY5)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        PCLK   = 0;
        PRESET = 1;
        #10;
        PRESET = 0;
    end

    task automatic apb_write(input logic [31:0] apb_addr,
                             input logic [31:0] apb_wdata);
        @(posedge PCLK);
        #1;
        write = 1;
        addr = apb_addr;
        wdata = apb_wdata;
        transfer = 1;
        @(posedge PCLK);
        #1;
        transfer = 0;
        wait (ready);
    endtask  //automatic

    task automatic apb_read(input logic [31:0] apb_addr);
        @(posedge PCLK);
        #1;
        write = 0;
        addr = apb_addr;
        transfer = 1;
        @(posedge PCLK);
        #1;
        transfer = 0;
        wait (ready);
    endtask  //automatic

    initial begin
        #10;
        /*
        @(posedge PCLK);
        #1;
        write = 1;
        addr = 32'h1000_0000;
        wdata = 32'd10;
        transfer = 1;
        @(posedge PCLK);
        #1;
        transfer = 0;
        wait (ready);
        */

        // gpo
        apb_write(32'h1000_1000, 8'b0000_0011);
        apb_write(32'h1000_1004, 8'b0000_0011);

        // gpi
        gpi = 8'b1100_0000;
        apb_write(32'h1000_2000, 8'b1100_0000);
        apb_read(32'h1000_2004);

        // fnd_controller
        apb_write(32'h1000_4000, 8'b1);  // fnd_en = 1
        apb_write(32'h1000_4004, 14'd1000);  // 

        // uart
        apb_write(32'h1000_5000, 8'b0000_0011); // uart_init

        apb_write(32'h1000_5008, 8'b0011_1010); // tx
        #1000000;
        rx = 1;
        #104000;
        rx = 0;
        #104000;
        rx = 1;
        #104000;
        rx = 0;
        #104000;
        rx = 1;
        #104000;
        rx = 0;
        #104000;
        rx = 1;
        #104000;
        rx = 0;
        #104000;
        rx = 1;
        #500000;
        
        apb_read(32'h1000_500c);

        // ram
        // write
        /*
        apb_write(32'h1000_0000, 32'd10);  // mem[0] = 10
        apb_write(32'h1000_0010, 32'd11);  // mem[4] = 11
        apb_write(32'h1000_001c, 32'd12);  // mem[7] = 12
        // read
        apb_read(32'h1000_0000);  // rdata = mem[0] = 10
        apb_read(32'h1000_0010);  // rdata = mem[4] = 11
        apb_read(32'h1000_001c);  // rdata = mem[7] = 12
        */
        /*
        @(posedge PCLK);
        #1;
        write = 0;
        addr = 32'h1000_0000;
        transfer = 1;
        @(posedge PCLK);
        #1;
        transfer = 0;
        wait (ready);
        */

        #1000000;
        $finish;
    end
endmodule
