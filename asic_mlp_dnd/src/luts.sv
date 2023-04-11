
`timescale 1ns/1ps

module luts #(N1=98, N2=10, W_K=4, W_OUT=16)(
  output wire [N2-1:0][N1/2:0][W_K-1:0] weights_n1_mag,
  output wire [N2-1:0][N1/2:0][W_K-1:0] weights_n1_pol,
  output wire [N2  :0][W_K-1:0] weights_n2,
  output wire [2**W_K-1:0][W_OUT-1:0] tanh 
);
  assign weights_n1_mag = '{
    '{  4'd4     , -4'd3     , -4'd8     , -4'd5     ,  4'd3     , -4'd5     , -4'd1     ,  4'd1     , -4'd5     , -4'd3     , -4'd6     , -4'd4     , -4'd1     , -4'd2     ,  4'd0     ,  4'd0     ,  4'd4     ,  4'd2     , -4'd7     , -4'd2     , -4'd1     , -4'd1     ,  4'd6     ,  4'd0     , -4'd7     , -4'd3     ,  4'd1     ,  4'd5     ,  4'd0     ,  4'd1     , -4'd4     , -4'd5     , -4'd8     , -4'd5     , -4'd3     ,  4'd6     , -4'd8     , -4'd6     , -4'd5     ,  4'd0     , -4'd7     , -4'd5     ,  4'd5     , -4'd5     , -4'd5     ,  4'd6     , -4'd1     , -4'd8     , -4'd7     ,  4'd1      },
    '{  4'd1     , -4'd8     ,  4'd2     , -4'd4     , -4'd1     , -4'd5     ,  4'd6     ,  4'd3     , -4'd6     , -4'd1     ,  4'd4     , -4'd6     , -4'd8     , -4'd8     , -4'd4     , -4'd3     , -4'd3     , -4'd2     ,  4'd0     , -4'd4     , -4'd7     , -4'd4     ,  4'd1     ,  4'd2     ,  4'd2     ,  4'd0     , -4'd7     , -4'd7     , -4'd1     ,  4'd1     ,  4'd1     , -4'd5     , -4'd2     , -4'd1     ,  4'd3     ,  4'd6     , -4'd6     ,  4'd3     , -4'd8     ,  4'd6     , -4'd5     , -4'd3     ,  4'd4     ,  4'd1     ,  4'd2     , -4'd4     ,  4'd3     , -4'd4     , -4'd2     , -4'd4      },
    '{ -4'd4     , -4'd5     ,  4'd4     , -4'd4     , -4'd4     ,  4'd0     ,  4'd6     , -4'd4     , -4'd5     ,  4'd2     , -4'd1     ,  4'd5     , -4'd3     , -4'd3     , -4'd8     , -4'd7     , -4'd3     ,  4'd1     , -4'd5     , -4'd8     , -4'd3     ,  4'd6     , -4'd8     , -4'd7     , -4'd6     , -4'd4     , -4'd6     , -4'd8     ,  4'd5     , -4'd5     , -4'd6     ,  4'd2     ,  4'd5     , -4'd8     , -4'd1     , -4'd3     ,  4'd1     , -4'd8     ,  4'd2     , -4'd6     ,  4'd3     ,  4'd2     , -4'd1     ,  4'd3     , -4'd6     ,  4'd1     , -4'd6     ,  4'd6     , -4'd5     ,  4'd6      },
    '{  4'd3     , -4'd5     , -4'd6     ,  4'd6     , -4'd5     , -4'd4     , -4'd7     , -4'd6     ,  4'd3     ,  4'd6     ,  4'd1     ,  4'd2     , -4'd7     , -4'd4     ,  4'd2     , -4'd2     ,  4'd3     ,  4'd0     ,  4'd3     , -4'd6     , -4'd5     , -4'd8     , -4'd8     , -4'd2     , -4'd8     , -4'd2     , -4'd5     ,  4'd6     ,  4'd2     , -4'd5     ,  4'd0     ,  4'd4     ,  4'd0     ,  4'd5     ,  4'd6     ,  4'd0     ,  4'd5     , -4'd6     , -4'd5     ,  4'd6     , -4'd6     ,  4'd3     ,  4'd5     , -4'd8     ,  4'd0     ,  4'd0     , -4'd5     ,  4'd0     ,  4'd2     , -4'd6      },
    '{  4'd0     , -4'd4     , -4'd5     ,  4'd4     ,  4'd5     ,  4'd6     , -4'd8     , -4'd4     , -4'd5     ,  4'd5     ,  4'd3     ,  4'd4     , -4'd2     ,  4'd5     ,  4'd1     ,  4'd5     ,  4'd3     ,  4'd0     , -4'd8     ,  4'd0     ,  4'd5     , -4'd3     ,  4'd6     ,  4'd1     , -4'd8     ,  4'd4     ,  4'd1     , -4'd2     , -4'd3     ,  4'd5     , -4'd5     , -4'd7     ,  4'd0     , -4'd8     , -4'd4     ,  4'd3     ,  4'd3     ,  4'd1     , -4'd2     , -4'd3     ,  4'd5     , -4'd1     ,  4'd0     ,  4'd0     ,  4'd1     , -4'd6     ,  4'd0     , -4'd2     ,  4'd3     , -4'd2      },
    '{  4'd5     ,  4'd1     , -4'd7     , -4'd2     ,  4'd4     ,  4'd0     ,  4'd5     ,  4'd0     , -4'd5     , -4'd6     , -4'd5     ,  4'd2     ,  4'd4     , -4'd2     , -4'd5     , -4'd2     ,  4'd6     ,  4'd5     , -4'd3     , -4'd1     ,  4'd3     , -4'd8     ,  4'd3     ,  4'd0     , -4'd4     ,  4'd2     , -4'd2     ,  4'd3     , -4'd3     ,  4'd5     ,  4'd4     ,  4'd0     , -4'd6     ,  4'd3     , -4'd5     ,  4'd1     , -4'd1     , -4'd3     , -4'd5     ,  4'd6     , -4'd4     , -4'd3     ,  4'd5     , -4'd5     , -4'd5     , -4'd1     ,  4'd1     ,  4'd1     ,  4'd1     , -4'd1      },
    '{ -4'd5     ,  4'd6     ,  4'd2     , -4'd6     ,  4'd4     , -4'd5     ,  4'd1     ,  4'd2     ,  4'd3     ,  4'd5     , -4'd1     , -4'd1     ,  4'd5     , -4'd3     , -4'd7     ,  4'd4     , -4'd6     , -4'd6     ,  4'd0     , -4'd7     , -4'd3     ,  4'd0     , -4'd4     , -4'd8     ,  4'd3     , -4'd6     , -4'd3     ,  4'd6     , -4'd3     ,  4'd6     , -4'd8     ,  4'd6     ,  4'd0     ,  4'd5     , -4'd7     , -4'd7     , -4'd8     , -4'd5     ,  4'd0     ,  4'd3     ,  4'd0     , -4'd4     , -4'd4     , -4'd8     ,  4'd1     , -4'd5     , -4'd1     ,  4'd4     , -4'd5     , -4'd6      },
    '{  4'd6     ,  4'd5     , -4'd7     , -4'd7     , -4'd6     , -4'd7     ,  4'd5     , -4'd4     ,  4'd5     , -4'd6     , -4'd3     , -4'd3     ,  4'd4     ,  4'd4     , -4'd3     ,  4'd5     , -4'd6     ,  4'd3     , -4'd3     , -4'd1     , -4'd1     ,  4'd3     , -4'd2     ,  4'd6     , -4'd7     , -4'd2     , -4'd1     , -4'd6     ,  4'd4     ,  4'd3     , -4'd5     , -4'd7     ,  4'd1     ,  4'd5     ,  4'd6     , -4'd3     ,  4'd1     ,  4'd1     , -4'd6     , -4'd8     ,  4'd3     ,  4'd1     ,  4'd4     ,  4'd3     , -4'd7     ,  4'd1     ,  4'd2     , -4'd8     , -4'd2     , -4'd8      },
    '{  4'd2     , -4'd4     ,  4'd6     ,  4'd0     , -4'd4     , -4'd5     , -4'd5     ,  4'd0     ,  4'd0     ,  4'd3     ,  4'd5     ,  4'd3     ,  4'd6     , -4'd1     , -4'd8     , -4'd5     ,  4'd0     , -4'd1     , -4'd1     ,  4'd5     ,  4'd2     , -4'd7     ,  4'd0     , -4'd4     , -4'd1     , -4'd8     ,  4'd3     ,  4'd4     , -4'd4     ,  4'd1     , -4'd8     ,  4'd2     ,  4'd6     , -4'd2     ,  4'd4     , -4'd4     , -4'd6     , -4'd4     , -4'd2     , -4'd5     ,  4'd2     , -4'd5     , -4'd1     ,  4'd0     ,  4'd5     ,  4'd5     , -4'd3     , -4'd8     ,  4'd0     , -4'd3      },
    '{  4'd3     , -4'd4     , -4'd1     ,  4'd4     ,  4'd5     ,  4'd2     ,  4'd2     , -4'd4     ,  4'd6     , -4'd7     ,  4'd3     , -4'd5     , -4'd5     ,  4'd1     , -4'd6     , -4'd3     , -4'd6     , -4'd5     ,  4'd6     , -4'd3     ,  4'd2     ,  4'd3     , -4'd1     ,  4'd4     ,  4'd4     , -4'd6     ,  4'd5     , -4'd1     , -4'd7     , -4'd2     ,  4'd2     , -4'd3     , -4'd8     ,  4'd6     ,  4'd3     , -4'd8     ,  4'd2     ,  4'd4     , -4'd5     ,  4'd2     , -4'd7     ,  4'd2     ,  4'd1     ,  4'd4     ,  4'd5     ,  4'd1     , -4'd2     , -4'd2     , -4'd1     ,  4'd0      }
  };

  assign weights_n1_pol = '{
    '{  4'd5     ,  4'd0     , -4'd1     , -4'd8     ,  4'd0     , -4'd2     ,  4'd0     ,  4'd1     ,  4'd0     , -4'd5     , -4'd2     , -4'd7     , -4'd1     , -4'd4     ,  4'd1     , -4'd6     ,  4'd4     , -4'd8     ,  4'd0     , -4'd6     ,  4'd5     , -4'd1     ,  4'd0     , -4'd4     , -4'd4     ,  4'd4     , -4'd7     , -4'd1     ,  4'd6     , -4'd2     ,  4'd1     , -4'd4     , -4'd7     , -4'd3     ,  4'd1     , -4'd1     ,  4'd3     ,  4'd5     , -4'd7     , -4'd5     , -4'd3     , -4'd1     , -4'd5     , -4'd2     , -4'd2     , -4'd1     ,  4'd1     , -4'd7     ,  4'd1     , -4'd2      },
    '{ -4'd8     , -4'd5     ,  4'd0     , -4'd4     , -4'd7     , -4'd4     , -4'd3     , -4'd8     , -4'd5     ,  4'd6     ,  4'd2     , -4'd7     , -4'd4     , -4'd4     , -4'd4     , -4'd8     , -4'd8     ,  4'd2     ,  4'd5     ,  4'd0     ,  4'd6     ,  4'd3     ,  4'd3     , -4'd4     , -4'd2     ,  4'd1     ,  4'd4     ,  4'd3     , -4'd5     , -4'd5     ,  4'd4     , -4'd6     , -4'd7     ,  4'd2     , -4'd6     , -4'd7     ,  4'd3     , -4'd5     ,  4'd4     , -4'd4     ,  4'd2     , -4'd7     , -4'd7     , -4'd8     , -4'd1     ,  4'd0     ,  4'd2     , -4'd4     , -4'd5     , -4'd3      },
    '{ -4'd2     , -4'd5     , -4'd6     ,  4'd1     ,  4'd0     ,  4'd4     , -4'd7     ,  4'd4     , -4'd4     ,  4'd2     , -4'd8     ,  4'd0     ,  4'd5     , -4'd5     ,  4'd1     , -4'd3     , -4'd3     , -4'd7     , -4'd1     ,  4'd5     ,  4'd6     ,  4'd0     , -4'd2     , -4'd4     , -4'd1     , -4'd5     , -4'd3     ,  4'd3     ,  4'd4     , -4'd5     , -4'd2     , -4'd4     , -4'd1     , -4'd5     , -4'd8     , -4'd3     ,  4'd3     ,  4'd3     ,  4'd6     ,  4'd1     , -4'd5     , -4'd1     , -4'd3     , -4'd3     ,  4'd4     ,  4'd0     ,  4'd3     ,  4'd6     , -4'd8     ,  4'd0      },
    '{ -4'd5     , -4'd2     ,  4'd1     ,  4'd2     , -4'd5     , -4'd6     ,  4'd3     , -4'd1     , -4'd8     , -4'd5     ,  4'd2     ,  4'd6     , -4'd8     , -4'd5     , -4'd2     , -4'd7     ,  4'd4     ,  4'd3     ,  4'd1     , -4'd6     ,  4'd5     ,  4'd1     , -4'd4     ,  4'd1     ,  4'd5     ,  4'd3     , -4'd7     , -4'd5     , -4'd6     , -4'd4     ,  4'd5     ,  4'd1     , -4'd1     , -4'd4     ,  4'd1     ,  4'd6     , -4'd4     , -4'd7     , -4'd6     ,  4'd5     ,  4'd6     ,  4'd5     , -4'd1     , -4'd6     , -4'd5     ,  4'd1     ,  4'd2     , -4'd1     ,  4'd2     , -4'd2      },
    '{ -4'd2     ,  4'd4     , -4'd6     ,  4'd2     , -4'd5     , -4'd2     ,  4'd6     , -4'd8     ,  4'd5     ,  4'd4     ,  4'd2     ,  4'd0     , -4'd8     ,  4'd2     ,  4'd3     ,  4'd5     , -4'd1     ,  4'd6     , -4'd2     ,  4'd5     , -4'd3     ,  4'd6     ,  4'd1     , -4'd2     , -4'd3     ,  4'd3     , -4'd6     , -4'd1     ,  4'd4     , -4'd7     ,  4'd1     , -4'd6     , -4'd6     ,  4'd4     ,  4'd6     , -4'd3     ,  4'd3     , -4'd2     , -4'd4     ,  4'd5     , -4'd6     ,  4'd4     ,  4'd6     ,  4'd5     , -4'd6     , -4'd7     ,  4'd4     , -4'd8     ,  4'd1     , -4'd8      },
    '{ -4'd6     ,  4'd0     , -4'd5     ,  4'd5     ,  4'd2     , -4'd8     ,  4'd2     ,  4'd3     ,  4'd0     ,  4'd0     , -4'd7     , -4'd8     , -4'd3     ,  4'd0     , -4'd6     , -4'd5     ,  4'd4     ,  4'd6     , -4'd3     ,  4'd3     , -4'd5     ,  4'd0     , -4'd2     , -4'd4     , -4'd2     ,  4'd4     , -4'd5     , -4'd2     , -4'd6     ,  4'd4     ,  4'd4     , -4'd2     , -4'd3     ,  4'd3     , -4'd3     ,  4'd5     ,  4'd1     , -4'd4     , -4'd2     ,  4'd5     , -4'd3     ,  4'd3     , -4'd7     , -4'd5     ,  4'd5     , -4'd5     ,  4'd2     ,  4'd0     ,  4'd6     ,  4'd1      },
    '{ -4'd3     ,  4'd5     , -4'd3     , -4'd2     , -4'd8     ,  4'd1     ,  4'd6     , -4'd1     , -4'd3     , -4'd7     , -4'd3     , -4'd2     ,  4'd4     ,  4'd2     ,  4'd2     ,  4'd3     , -4'd2     ,  4'd6     ,  4'd6     ,  4'd0     , -4'd1     ,  4'd5     , -4'd3     ,  4'd3     ,  4'd2     , -4'd5     ,  4'd2     , -4'd6     ,  4'd1     ,  4'd3     ,  4'd1     , -4'd5     ,  4'd5     ,  4'd6     , -4'd6     , -4'd3     ,  4'd2     , -4'd4     , -4'd7     , -4'd3     ,  4'd6     ,  4'd0     , -4'd5     , -4'd3     ,  4'd0     , -4'd4     ,  4'd2     , -4'd7     , -4'd1     ,  4'd0      },
    '{ -4'd7     , -4'd6     , -4'd7     ,  4'd6     , -4'd7     , -4'd1     , -4'd3     ,  4'd3     ,  4'd6     , -4'd8     , -4'd4     , -4'd7     , -4'd7     ,  4'd5     ,  4'd4     , -4'd2     ,  4'd6     , -4'd2     , -4'd8     , -4'd6     , -4'd5     , -4'd1     ,  4'd4     ,  4'd1     ,  4'd6     , -4'd6     ,  4'd3     , -4'd4     ,  4'd1     ,  4'd6     , -4'd8     ,  4'd4     , -4'd2     ,  4'd1     , -4'd6     , -4'd4     , -4'd1     , -4'd5     , -4'd8     ,  4'd4     , -4'd3     , -4'd4     ,  4'd5     , -4'd8     ,  4'd5     , -4'd6     , -4'd5     , -4'd7     , -4'd1     ,  4'd2      },
    '{ -4'd7     ,  4'd6     ,  4'd5     , -4'd5     ,  4'd2     , -4'd4     ,  4'd2     , -4'd7     , -4'd1     , -4'd4     , -4'd8     ,  4'd2     , -4'd6     ,  4'd4     ,  4'd2     , -4'd1     , -4'd4     , -4'd8     , -4'd6     , -4'd2     ,  4'd1     , -4'd6     , -4'd4     ,  4'd4     ,  4'd1     ,  4'd1     ,  4'd4     , -4'd3     , -4'd4     ,  4'd2     , -4'd4     ,  4'd1     ,  4'd2     ,  4'd4     ,  4'd0     , -4'd7     , -4'd3     , -4'd1     , -4'd8     ,  4'd2     , -4'd7     ,  4'd2     , -4'd5     ,  4'd1     , -4'd6     ,  4'd0     , -4'd6     , -4'd4     ,  4'd6     ,  4'd4      },
    '{  4'd0     , -4'd6     ,  4'd1     ,  4'd0     , -4'd1     ,  4'd2     ,  4'd3     ,  4'd4     ,  4'd0     , -4'd6     , -4'd5     ,  4'd4     , -4'd5     ,  4'd5     , -4'd2     , -4'd8     ,  4'd2     , -4'd5     , -4'd2     ,  4'd3     , -4'd5     ,  4'd1     , -4'd2     , -4'd5     , -4'd6     , -4'd6     , -4'd6     , -4'd2     , -4'd4     ,  4'd3     , -4'd2     , -4'd8     , -4'd4     ,  4'd5     ,  4'd1     , -4'd6     , -4'd7     ,  4'd4     , -4'd2     , -4'd7     , -4'd1     ,  4'd4     , -4'd3     , -4'd2     , -4'd7     ,  4'd2     , -4'd2     ,  4'd5     , -4'd2     , -4'd2      }
  };

  assign weights_n2 = '{
     4'd6,
     4'd11,
     4'd2,
     4'd5,
     4'd14,
     4'd2,
     4'd2,
     4'd3,
     4'd2,
     4'd12,
     4'd13
  };

  assign tanh = '{
     16'd54793,
     16'd8819,
     16'd25544,
     16'd4485,
     16'd23156,
     16'd57525,
     16'd35051,
     16'd53441,
     16'd65323,
     16'd31311,
     16'd11326,
     16'd26956,
     16'd47663,
     16'd23116,
     16'd30357,
     16'd49272
  };
endmodule
