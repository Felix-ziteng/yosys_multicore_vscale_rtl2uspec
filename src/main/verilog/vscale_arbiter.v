`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"
`include "vscale_hasti_constants.vh"
`include "vscale_multicore_constants.vh"

module vscale_arbiter(
                       input                                            clk,
                       input                                            reset,
                       input [`HASTI_ADDR_WIDTH-1:0]                    core_haddr_0,
                       input [`HASTI_ADDR_WIDTH-1:0]                    core_haddr_1,
                       input                                            core_hwrite_0,
                       input                                            core_hwrite_1,
                       input [`HASTI_SIZE_WIDTH-1:0]                    core_hsize_0,
                       input [`HASTI_SIZE_WIDTH-1:0]                    core_hsize_1,
                       input [`HASTI_BURST_WIDTH-1:0]                   core_hburst_0,
                       input [`HASTI_BURST_WIDTH-1:0]                   core_hburst_1,
                       input                                            core_hmastlock_0,
                       input                                            core_hmastlock_1,
                       input [`HASTI_PROT_WIDTH-1:0]                    core_hprot_0,
                       input [`HASTI_PROT_WIDTH-1:0]                    core_hprot_1,
                       input [`HASTI_TRANS_WIDTH-1:0]                   core_htrans_0,
                       input [`HASTI_TRANS_WIDTH-1:0]                   core_htrans_1,
                       input [`HASTI_BUS_WIDTH-1:0]                     core_hwdata_0,
                       input [`HASTI_BUS_WIDTH-1:0]                     core_hwdata_1,
                       output reg [`HASTI_BUS_WIDTH-1:0]                core_hrdata_0,
                       output reg [`HASTI_BUS_WIDTH-1:0]                core_hrdata_1,
                       output reg                                       core_hready_0,
                       output reg                                       core_hready_1,
                       output reg [`HASTI_RESP_WIDTH-1:0]               core_hresp_0,
                       output reg [`HASTI_RESP_WIDTH-1:0]               core_hresp_1,
                       output reg [2+`HASTI_ADDR_WIDTH-1:0]             dmem_haddr,
                       output reg                                       dmem_hwrite,
                       output reg [`HASTI_SIZE_WIDTH-1:0]               dmem_hsize,
                       output reg [`HASTI_BURST_WIDTH-1:0]              dmem_hburst,
                       output reg                                       dmem_hmastlock,
                       output reg [`HASTI_PROT_WIDTH-1:0]               dmem_hprot,
                       output reg [`HASTI_TRANS_WIDTH-1:0]              dmem_htrans,
                       output reg [`HASTI_BUS_WIDTH-1:0]                dmem_hwdata,
                       input [`HASTI_BUS_WIDTH-1:0]                     dmem_hrdata,
                       input                                            dmem_hready,
                       input [`HASTI_RESP_WIDTH-1:0]                    dmem_hresp,
                       input [`CORE_IDX_WIDTH-1:0]                      next_core
                     );

    // Current and previous core registers.
    reg [`CORE_IDX_WIDTH-1:0]     cur_core;
    reg [`CORE_IDX_WIDTH-1:0]     prev_core;

    // Update current and previous core on clock edge.
    always @(posedge clk) begin
        cur_core <= next_core;
        prev_core <= cur_core;
    end

    // Combinational logic for DMEM signals.
    always @(*) begin
        case (cur_core)
            0: begin
                dmem_haddr = {cur_core, core_haddr_0};
                dmem_hwrite = core_hwrite_0;
                dmem_hsize = core_hsize_0;
                dmem_hburst = core_hburst_0;
                dmem_hmastlock = core_hmastlock_0;
                dmem_hprot = core_hprot_0;
                dmem_htrans = core_htrans_0;
            end
            1: begin
                dmem_haddr = {cur_core, core_haddr_1};
                dmem_hwrite = core_hwrite_1;
                dmem_hsize = core_hsize_1;
                dmem_hburst = core_hburst_1;
                dmem_hmastlock = core_hmastlock_1;
                dmem_hprot = core_hprot_1;
                dmem_htrans = core_htrans_1;
            end
            default: begin
                dmem_haddr = 0;
                dmem_hwrite = 0;
                dmem_hsize = 0;
                dmem_hburst = 0;
                dmem_hmastlock = 0;
                dmem_hprot = 0;
                dmem_htrans = 0;
            end
        endcase

        // Write data must come from the previous core.
        case (prev_core)
            0: dmem_hwdata = core_hwdata_0;
            1: dmem_hwdata = core_hwdata_1;
            default: dmem_hwdata = 0;
        endcase
    end

    // Generate block to handle core responses.
    always @(*) begin
        case (cur_core)
            0: begin
                core_hready_0 = dmem_hready;
                core_hrdata_0 = dmem_hrdata;
                core_hresp_0 = `HASTI_RESP_OKAY;
                core_hready_1 = 1'b0;
                core_hrdata_1 = dmem_hrdata;
                core_hresp_1 = dmem_hresp;
            end
            1: begin
                core_hready_1 = dmem_hready;
                core_hrdata_1 = dmem_hrdata;
                core_hresp_1 = `HASTI_RESP_OKAY;
                core_hready_0 = 1'b0;
                core_hrdata_0 = dmem_hrdata;
                core_hresp_0 = dmem_hresp;
            end
            default: begin
                core_hready_0 = 1'b0;
                core_hrdata_0 = 0;
                core_hresp_0 = 0;
                core_hready_1 = 1'b0;
                core_hrdata_1 = 0;
                core_hresp_1 = 0;
            end
        endcase
    end
endmodule
