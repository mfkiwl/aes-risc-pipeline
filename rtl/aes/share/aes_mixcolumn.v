
//
// AES Forward MixColumn byte module
//
// - Performs forward MixColumn operation.
// - Outputs a single byte of the new column
//
module aes_mixcolumn_byte_enc (
input   wire [31:0] col_in    ,
output  wire [ 7:0] byte_out
);


//
// Multiply by 2 in GF(2^8) modulo 8'h1b
function [7:0] xt2;
    input [7:0] a;
    xt2 = (a << 1) ^ (a[7] ? 8'h1b : 8'b0) ;
endfunction

//
// Paired down multiply by X in GF(2^8)
function [7:0] xtN;
    input[7:0] a;
    input[3:0] b;
    xtN = (b[0] ?             a   : 0) ^
          (b[1] ? xt2(        a)  : 0) ^
          (b[2] ? xt2(xt2(    a)) : 0) ^
          (b[3] ? xt2(xt2(xt2(a))): 0) ;
endfunction

wire [7:0] b3 = col_in[ 7: 0];
wire [7:0] b2 = col_in[15: 8];
wire [7:0] b1 = col_in[23:16];
wire [7:0] b0 = col_in[31:24];

assign byte_out = xtN(b0,4'd2) ^ xtN(b1,4'd3) ^ b2 ^ b3 ;

endmodule

//
// AES Inverse MixColumn byte module
//
// - Outputs a single byte of the new column
//
module aes_mixcolumn_byte_dec (
input   wire [31:0] col_in    ,
output  wire [ 7:0] byte_out
);


//
// Multiply by 2 in GF(2^8) modulo 8'h1b
function [7:0] xt2;
    input [7:0] a;
    xt2 = (a << 1) ^ (a[7] ? 8'h1b : 8'b0) ;
endfunction

//
// Paired down multiply by X in GF(2^8)
function [7:0] xtN;
    input[7:0] a;
    input[3:0] b;
    xtN = (b[0] ?             a   : 0) ^
          (b[1] ? xt2(        a)  : 0) ^
          (b[2] ? xt2(xt2(    a)) : 0) ^
          (b[3] ? xt2(xt2(xt2(a))): 0) ;
endfunction

wire [7:0] b3 = col_in[ 7: 0];
wire [7:0] b2 = col_in[15: 8];
wire [7:0] b1 = col_in[23:16];
wire [7:0] b0 = col_in[31:24];

assign byte_out = xtN(b0,4'he) ^ xtN(b1,4'hb) ^ xtN(b2,4'hd) ^ xtN(b3,4'h9);

endmodule


module aes_mixcolumn_byte (
input   wire [31:0] col_in    ,
input   wire        dec       ,
output  wire [ 7:0] byte_out
);

wire [7:0] b_dec;
wire [7:0] b_enc;

aes_mixcolumn_byte_enc i_enc(.col_in(col_in),.byte_out(b_enc));
aes_mixcolumn_byte_dec i_dec(.col_in(col_in),.byte_out(b_dec));

assign byte_out = dec ? b_dec : b_enc;

endmodule

//
// AES Forward MixColumn Word module
//
// - Outputs the entire new column.
//
module aes_mixcolumn_word_enc (

input   wire [31:0] col_in    ,
output  wire [31:0] col_out

);

wire [ 7:0] b0 = col_in[ 7: 0];
wire [ 7:0] b1 = col_in[15: 8];
wire [ 7:0] b2 = col_in[23:16];
wire [ 7:0] b3 = col_in[31:24];
    
wire [31:0] mix_in_3 = {b3, b0, b1, b2};
wire [31:0] mix_in_2 = {b2, b3, b0, b1};
wire [31:0] mix_in_1 = {b1, b2, b3, b0};
wire [31:0] mix_in_0 = {b0, b1, b2, b3};

wire [ 7:0] mix_out_3;
wire [ 7:0] mix_out_2;
wire [ 7:0] mix_out_1;
wire [ 7:0] mix_out_0;

assign col_out = {mix_out_3, mix_out_2, mix_out_1, mix_out_0};

aes_mixcolumn_byte_enc i_mc_enc_0(.col_in(mix_in_0), .byte_out(mix_out_0));
aes_mixcolumn_byte_enc i_mc_enc_1(.col_in(mix_in_1), .byte_out(mix_out_1));
aes_mixcolumn_byte_enc i_mc_enc_2(.col_in(mix_in_2), .byte_out(mix_out_2));
aes_mixcolumn_byte_enc i_mc_enc_3(.col_in(mix_in_3), .byte_out(mix_out_3));

endmodule

//
// AES Inverse MixColumn Word module
//
// - Outputs the entire new column.
//
module aes_mixcolumn_word_dec (

input   wire [31:0] col_in    ,
output  wire [31:0] col_out

);

wire [ 7:0] b0 = col_in[ 7: 0];
wire [ 7:0] b1 = col_in[15: 8];
wire [ 7:0] b2 = col_in[23:16];
wire [ 7:0] b3 = col_in[31:24];
    
wire [31:0] mix_in_3 = {b3, b0, b1, b2};
wire [31:0] mix_in_2 = {b2, b3, b0, b1};
wire [31:0] mix_in_1 = {b1, b2, b3, b0};
wire [31:0] mix_in_0 = {b0, b1, b2, b3};

wire [ 7:0] mix_out_3;
wire [ 7:0] mix_out_2;
wire [ 7:0] mix_out_1;
wire [ 7:0] mix_out_0;

assign col_out = {mix_out_3, mix_out_2, mix_out_1, mix_out_0};

aes_mixcolumn_byte_dec i_mc_dec_0(.col_in(mix_in_0), .byte_out(mix_out_0));
aes_mixcolumn_byte_dec i_mc_dec_1(.col_in(mix_in_1), .byte_out(mix_out_1));
aes_mixcolumn_byte_dec i_mc_dec_2(.col_in(mix_in_2), .byte_out(mix_out_2));
aes_mixcolumn_byte_dec i_mc_dec_3(.col_in(mix_in_3), .byte_out(mix_out_3));

endmodule

//
// AES mix column module
//
// - Performs forward or Inverse MixColumn operation.
// - Outputs the entire new column.
//
module aes_mixcolumn (

input   wire [31:0] col_in    ,
input   wire        dec       ,
output  wire [31:0] col_out

);

parameter DECRYPT_EN = 1;

wire [31:0] col_enc;
wire [31:0] col_dec;

aes_mixcolumn_word_enc i_enc_word(.col_in(col_in),.col_out(col_enc));

generate if(DECRYPT_EN) begin: decrypt_enabled
aes_mixcolumn_word_dec i_dec_word(.col_in(col_in),.col_out(col_dec));
end else begin: decrypt_disabled
assign col_dec = 32'b0;
end endgenerate

assign col_out = dec && DECRYPT_EN ? col_dec : col_enc;

endmodule

