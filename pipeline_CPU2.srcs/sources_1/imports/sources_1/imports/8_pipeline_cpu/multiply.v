`timescale 1ns / 1ps
//*************************************************************************
//   > ?????: multiply.v
//   > ????  ?????????�??��?????????????????????????????????????
//   > ????  : LOONGSON
//   > ????  : 2016-04-14
//*************************************************************************
module multiply(              // ?????
    input         clk,        // ???
    input         mult_begin, // ?????????
    input  [31:0] mult_op1,   // ??????????1
    input  [31:0] mult_op2,   // ??????????2
    output [63:0] product,    // ???
    output        mult_end    // ??????????
);

    //?????????????????????
    reg mult_valid;
    assign mult_end = mult_valid & ~(|multiplier); //????????????????0
    always @(posedge clk)
    begin
        if (!mult_begin || mult_end)
        begin
            mult_valid <= 1'b0;
        end
        else
        begin
            mult_valid <= 1'b1;
        end
    end

    //??????????????????????????????????????????????????1
    wire        op1_sign;      //??????1?????��
    wire        op2_sign;      //??????2?????��
    wire [31:0] op1_absolute;  //??????1??????
    wire [31:0] op2_absolute;  //??????2??????
    assign op1_sign = mult_op1[31];
    assign op2_sign = mult_op2[31];
    assign op1_absolute = op1_sign ? (~mult_op1+1) : mult_op1;
    assign op2_absolute = op2_sign ? (~mult_op2+1) : mult_op2;

    //????????????????????????��
    reg  [63:0] multiplicand;
    always @ (posedge clk)
    begin
        if (mult_valid)
        begin    // ?????????��??????????????????��
            multiplicand <= {multiplicand[62:0],1'b0};
        end
        else if (mult_begin) 
        begin   // ????????????????????????1??????
            multiplicand <= {32'd0,op1_absolute};
        end
    end

    //??????????????????????��
    reg  [31:0] multiplier;
    always @ (posedge clk)
    begin
        if (mult_valid)
        begin   // ?????????��??????????????????��
            multiplier <= {1'b0,multiplier[31:1]}; 
        end
        else if (mult_begin)
        begin   // ??????????????????????2??????
            multiplier <= op2_absolute; 
        end
    end
    
    // ????????????��?1??????????????????????��?0????????0
    wire [63:0] partial_product;
    assign partial_product = multiplier[0] ? multiplicand : 64'd0;
    
    //?????
    reg [63:0] product_temp;
    always @ (posedge clk)
    begin
        if (mult_valid)
        begin
            product_temp <= product_temp + partial_product;
        end
        else if (mult_begin) 
        begin
            product_temp <= 64'd0;  // ??????????????? 
        end
    end 
     
    //???????????��???????
    reg product_sign;
    always @ (posedge clk)  // ???
    begin
        if (mult_valid)
        begin
              product_sign <= op1_sign ^ op2_sign;
        end
    end 
    //???????????????????????????+1
    assign product = product_sign ? (~product_temp+1) : product_temp;
endmodule
