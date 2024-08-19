`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"
`include "vscale_hasti_constants.vh"
`include "vscale_multicore_constants.vh"
`include "rv32_opcodes.vh"

module vscale_sim_top(
                      input                        clk,
                      input                        reset,
                      input                        htif_pcr_req_valid,
                      input                        htif_pcr_req_rw,
                      input [`CSR_ADDR_WIDTH-1:0]  htif_pcr_req_addr,
                      input [`HTIF_PCR_WIDTH-1:0]  htif_pcr_req_data,
                      input                        htif_pcr_resp_ready,
                      input [`CORE_IDX_WIDTH-1:0]  arbiter_next_core,
                      input                        i_we, 
                      input [5-1:0]                i_addr,
                      input [32-1:0]               i_data,
                      output                       htif_pcr_req_ready_0,
                      output                       htif_pcr_resp_valid_0,
                      output [`HTIF_PCR_WIDTH-1:0] htif_pcr_resp_data_0,
                      output                       htif_pcr_req_ready_1,
                      output                       htif_pcr_resp_valid_1,
                      output [`HTIF_PCR_WIDTH-1:0] htif_pcr_resp_data_1
                      );

   wire                                            resetn;
   wire                                            htif_reset;

   wire [`HASTI_ADDR_WIDTH-1:0]                    imem_haddr_0;
   wire                                            imem_hwrite_0;
   wire [`HASTI_SIZE_WIDTH-1:0]                    imem_hsize_0;
   wire [`HASTI_BURST_WIDTH-1:0]                   imem_hburst_0;
   wire                                            imem_hmastlock_0;
   wire [`HASTI_PROT_WIDTH-1:0]                    imem_hprot_0;
   wire [`HASTI_TRANS_WIDTH-1:0]                   imem_htrans_0;
   wire [`HASTI_BUS_WIDTH-1:0]                     imem_hwdata_0;
   wire [`HASTI_BUS_WIDTH-1:0]                     imem_hrdata_0;
   wire                                            imem_hready_0;
   wire [`HASTI_RESP_WIDTH-1:0]                    imem_hresp_0;

   wire [`HASTI_ADDR_WIDTH-1:0]                    imem_haddr_1;
   wire                                            imem_hwrite_1;
   wire [`HASTI_SIZE_WIDTH-1:0]                    imem_hsize_1;
   wire [`HASTI_BURST_WIDTH-1:0]                   imem_hburst_1;
   wire                                            imem_hmastlock_1;
   wire [`HASTI_PROT_WIDTH-1:0]                    imem_hprot_1;
   wire [`HASTI_TRANS_WIDTH-1:0]                   imem_htrans_1;
   wire [`HASTI_BUS_WIDTH-1:0]                     imem_hwdata_1;
   wire [`HASTI_BUS_WIDTH-1:0]                     imem_hrdata_1;
   wire                                            imem_hready_1;
   wire [`HASTI_RESP_WIDTH-1:0]                    imem_hresp_1;

   wire [`HASTI_ADDR_WIDTH-1:0]                    dmem_haddr_0;
   wire                                            dmem_hwrite_0;
   wire [`HASTI_SIZE_WIDTH-1:0]                    dmem_hsize_0;
   wire [`HASTI_BURST_WIDTH-1:0]                   dmem_hburst_0;
   wire                                            dmem_hmastlock_0;
   wire [`HASTI_PROT_WIDTH-1:0]                    dmem_hprot_0;
   wire [`HASTI_TRANS_WIDTH-1:0]                   dmem_htrans_0;
   wire [`HASTI_BUS_WIDTH-1:0]                     dmem_hwdata_0;
   wire [`HASTI_BUS_WIDTH-1:0]                     dmem_hrdata_0;
   wire                                            dmem_hready_0;
   wire [`HASTI_RESP_WIDTH-1:0]                    dmem_hresp_0;

   wire [`HASTI_ADDR_WIDTH-1:0]                    dmem_haddr_1;
   wire                                            dmem_hwrite_1;
   wire [`HASTI_SIZE_WIDTH-1:0]                    dmem_hsize_1;
   wire [`HASTI_BURST_WIDTH-1:0]                   dmem_hburst_1;
   wire                                            dmem_hmastlock_1;
   wire [`HASTI_PROT_WIDTH-1:0]                    dmem_hprot_1;
   wire [`HASTI_TRANS_WIDTH-1:0]                   dmem_htrans_1;
   wire [`HASTI_BUS_WIDTH-1:0]                     dmem_hwdata_1;
   wire [`HASTI_BUS_WIDTH-1:0]                     dmem_hrdata_1;
   wire                                            dmem_hready_1;
   wire [`HASTI_RESP_WIDTH-1:0]                    dmem_hresp_1;

   wire [2+`HASTI_ADDR_WIDTH-1:0]                  arbiter_dmem_haddr;
   wire                                            arbiter_dmem_hwrite;
   wire [`HASTI_SIZE_WIDTH-1:0]                    arbiter_dmem_hsize;
   wire [`HASTI_BURST_WIDTH-1:0]                   arbiter_dmem_hburst;
   wire                                            arbiter_dmem_hmastlock;
   wire [`HASTI_PROT_WIDTH-1:0]                    arbiter_dmem_hprot;
   wire [`HASTI_TRANS_WIDTH-1:0]                   arbiter_dmem_htrans;
   wire [`HASTI_BUS_WIDTH-1:0]                     arbiter_dmem_hwdata;
   wire [`HASTI_BUS_WIDTH-1:0]                     arbiter_dmem_hrdata;
   wire                                            arbiter_dmem_hready;
   wire [`HASTI_RESP_WIDTH-1:0]                    arbiter_dmem_hresp;

   wire                                            htif_ipi_req_ready = 0;
   wire                                            htif_ipi_req_valid;
   wire                                            htif_ipi_req_data;
   wire                                            htif_ipi_resp_ready;
   wire                                            htif_ipi_resp_valid = 0;
   wire                                            htif_ipi_resp_data = 0;
   wire                                            htif_debug_stats_pcr;

   assign resetn = ~reset;
   assign htif_reset = reset;

   vscale_core vscale_0(
                          .clk(clk),
                          .core_id(0),
                          .imem_haddr(imem_haddr_0),
                          .imem_hwrite(imem_hwrite_0),
                          .imem_hsize(imem_hsize_0),
                          .imem_hburst(imem_hburst_0),
                          .imem_hmastlock(imem_hmastlock_0),
                          .imem_hprot(imem_hprot_0),
                          .imem_htrans(imem_htrans_0),
                          .imem_hwdata(imem_hwdata_0),
                          .imem_hrdata(imem_hrdata_0),
                          .imem_hready(imem_hready_0),
                          .imem_hresp(imem_hresp_0),
                          .dmem_haddr(dmem_haddr_0),
                          .dmem_hwrite(dmem_hwrite_0),
                          .dmem_hsize(dmem_hsize_0),
                          .dmem_hburst(dmem_hburst_0),
                          .dmem_hmastlock(dmem_hmastlock_0),
                          .dmem_hprot(dmem_hprot_0),
                          .dmem_htrans(dmem_htrans_0),
                          .dmem_hwdata(dmem_hwdata_0),
                          .dmem_hrdata(dmem_hrdata_0),
                          .dmem_hready(dmem_hready_0),
                          .dmem_hresp(dmem_hresp_0),
                          .htif_reset(htif_reset),
                          .htif_id(1'b0),
                          .htif_pcr_req_valid(htif_pcr_req_valid),
                          .htif_pcr_req_ready(htif_pcr_req_ready_0),
                          .htif_pcr_req_rw(htif_pcr_req_rw),
                          .htif_pcr_req_addr(htif_pcr_req_addr),
                          .htif_pcr_req_data(htif_pcr_req_data),
                          .htif_pcr_resp_valid(htif_pcr_resp_valid_0),
                          .htif_pcr_resp_ready(htif_pcr_resp_ready),
                          .htif_pcr_resp_data(htif_pcr_resp_data_0),
                          .htif_ipi_req_ready(htif_ipi_req_ready),
                          .htif_ipi_req_valid(htif_ipi_req_valid),
                          .htif_ipi_req_data(htif_ipi_req_data),
                          .htif_ipi_resp_ready(htif_ipi_resp_ready),
                          .htif_ipi_resp_valid(htif_ipi_resp_valid),
                          .htif_ipi_resp_data(htif_ipi_resp_data),
                          .htif_debug_stats_pcr(htif_debug_stats_pcr)
                          );

   vscale_core vscale_1(
                          .clk(clk),
                          .core_id(1),
                          .imem_haddr(imem_haddr_1),
                          .imem_hwrite(imem_hwrite_1),
                          .imem_hsize(imem_hsize_1),
                          .imem_hburst(imem_hburst_1),
                          .imem_hmastlock(imem_hmastlock_1),
                          .imem_hprot(imem_hprot_1),
                          .imem_htrans(imem_htrans_1),
                          .imem_hwdata(imem_hwdata_1),
                          .imem_hrdata(imem_hrdata_1),
                          .imem_hready(imem_hready_1),
                          .imem_hresp(imem_hresp_1),
                          .dmem_haddr(dmem_haddr_1),
                          .dmem_hwrite(dmem_hwrite_1),
                          .dmem_hsize(dmem_hsize_1),
                          .dmem_hburst(dmem_hburst_1),
                          .dmem_hmastlock(dmem_hmastlock_1),
                          .dmem_hprot(dmem_hprot_1),
                          .dmem_htrans(dmem_htrans_1),
                          .dmem_hwdata(dmem_hwdata_1),
                          .dmem_hrdata(dmem_hrdata_1),
                          .dmem_hready(dmem_hready_1),
                          .dmem_hresp(dmem_hresp_1),
                          .htif_reset(htif_reset),
                          .htif_id(1'b0),
                          .htif_pcr_req_valid(htif_pcr_req_valid),
                          .htif_pcr_req_ready(htif_pcr_req_ready_1),
                          .htif_pcr_req_rw(htif_pcr_req_rw),
                          .htif_pcr_req_addr(htif_pcr_req_addr),
                          .htif_pcr_req_data(htif_pcr_req_data),
                          .htif_pcr_resp_valid(htif_pcr_resp_valid_1),
                          .htif_pcr_resp_ready(htif_pcr_resp_ready),
                          .htif_pcr_resp_data(htif_pcr_resp_data_1),
                          .htif_ipi_req_ready(htif_ipi_req_ready),
                          .htif_ipi_req_valid(htif_ipi_req_valid),
                          .htif_ipi_req_data(htif_ipi_req_data),
                          .htif_ipi_resp_ready(htif_ipi_resp_ready),
                          .htif_ipi_resp_valid(htif_ipi_resp_valid),
                          .htif_ipi_resp_data(htif_ipi_resp_data),
                          .htif_debug_stats_pcr(htif_debug_stats_pcr)
                          );

vscale_arbiter arbiter(
    .clk(clk),
    .reset(reset),
    
    // Core 0 signals
    .core_haddr_0(dmem_haddr_0),
    .core_hwrite_0(dmem_hwrite_0),
    .core_hsize_0(dmem_hsize_0),
    .core_hburst_0(dmem_hburst_0),
    .core_hmastlock_0(dmem_hmastlock_0),
    .core_hprot_0(dmem_hprot_0),
    .core_htrans_0(dmem_htrans_0),
    .core_hwdata_0(dmem_hwdata_0),
    .core_hrdata_0(dmem_hrdata_0),
    .core_hready_0(dmem_hready_0),
    .core_hresp_0(dmem_hresp_0),

    // Core 1 signals
    .core_haddr_1(dmem_haddr_1),
    .core_hwrite_1(dmem_hwrite_1),
    .core_hsize_1(dmem_hsize_1),
    .core_hburst_1(dmem_hburst_1),
    .core_hmastlock_1(dmem_hmastlock_1),
    .core_hprot_1(dmem_hprot_1),
    .core_htrans_1(dmem_htrans_1),
    .core_hwdata_1(dmem_hwdata_1),
    .core_hrdata_1(dmem_hrdata_1),
    .core_hready_1(dmem_hready_1),
    .core_hresp_1(dmem_hresp_1),

    // DMEM signals
    .dmem_haddr(arbiter_dmem_haddr),
    .dmem_hwrite(arbiter_dmem_hwrite),
    .dmem_hsize(arbiter_dmem_hsize),
    .dmem_hburst(arbiter_dmem_hburst),
    .dmem_hmastlock(arbiter_dmem_hmastlock),
    .dmem_hprot(arbiter_dmem_hprot),
    .dmem_htrans(arbiter_dmem_htrans),
    .dmem_hwdata(arbiter_dmem_hwdata),
    .dmem_hrdata(arbiter_dmem_hrdata),
    .dmem_hready(arbiter_dmem_hready),
    .dmem_hresp(arbiter_dmem_hresp),

    // Core selection
    .next_core(arbiter_next_core)
);

endmodule
