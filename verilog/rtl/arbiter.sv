`timescale 1ns/1ps

module arbiter(
  input logic clk,
  input logic rst_n,
  input logic [3:0][15:0] req_i,
  input logic [3:0]       req_valid_i,

  output logic [3:0]      grant_o,
  output logic [15:0]     req_o,
  output logic            req_valid_o 
);
   logic [NUM_GROUP-1:0][BG_W-1:0] port;
  logic [NUM_GROUP-1:0] valid_reqs;
  /* 
    Arbiter state
    port[0] is winner port. Initially, it points to bank machine 0.
    If it is selected (GM0, for example), port[Banks-1] will be port[0], and all others will be shifted. 
  */
  always_ff @(posedge clk) begin
    if(~rst_n) begin
      //port <= {2'b11, 2'b10, 2'b01, 2'b00};
      for(int i=0; i<NUM_GROUP; i++) port[i] <= 2'(i);
      req_valid_o <= 1'b0;
    end else begin
      // TODO: Make this parametric
      if(req_valid_i[port[0]]) begin
        port        <= {port[0], port[3], port[2], port[1]};
        req_valid_o <= 1'b1;
      end else if(req_valid_i[port[1]]) begin
        port        <= {port[1], port[3], port[2], port[0]};
        req_valid_o <= 1'b1;
      end else if(req_valid_i[port[2]]) begin
        port        <= {port[2], port[3], port[1], port[0]};
        req_valid_o <= 1'b1;
      end else if(req_valid_i[port[3]]) begin
        port        <= {port[3], port[2], port[1], port[0]};
        req_valid_o <= 1'b1;
      end else begin
        req_valid_o <= 1'b0;
      end
    end
  end

  always_comb begin
    grant_o = '0;
    grant_o[port[0]] = 1'b1;

    req_o = req_i[port[0]];
  end

endmodule