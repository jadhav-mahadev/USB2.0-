//Module Name:Transmitter
//File Name:Transmitter.v
//Purpose:UTMI Transmitter Implementation
//Designer :Verilog Course Team
//Web:www.verilogcourseteam.com.www.vlsiprojects.blogspot.com
//Email:info@verilogcourseteam.com


module Transmitter (
                        clk,
                        rst,
                        SIE,
                        NRZI_OPER_tx,
                        STUFF_OPER_tx,
                        sync_data,
                        
                        data_in,
                        SYNC_pattern,
                        encoded_dataout,
                        txready,
						      opcode
                        );
                        
 //port declartions                       
                        
 input clk;
 input rst;
 input SIE;
 input STUFF_OPER_tx;
 input NRZI_OPER_tx;
 input [7:0]sync_data;
 
 input [15:0]data_in;
 output encoded_dataout;
 output txready;
 output  SYNC_pattern;
 output [3:0]opcode;
 
 
 reg encoded_dataout;
 reg txready;
 wire SYNC_pattern;
 
 
 //temp registers
 
 reg[15:0]hold_data;
 reg temp_out;
 reg [2:0]PS,NS;
 reg [3:0]opcode;
 reg [2:0]count;
 
 reg x1,x2,x3,x4,x5,x6,x7,x8;
 

 wire Bit_stuff;
 wire data;
 
 
 //parameter definations
 parameter IDLE=3'b000;
 parameter START=3'b001;
 parameter TWO=3'b010;
 parameter THIRD=3'b011;
 parameter FOUR=3'b100;
 parameter FIVE=3'b101;
 parameter BITSTUFF=3'b110;


                       
//coding starts here                

always@(posedge clk)
begin
    if(rst)
    begin
        hold_data<=16'b0000_0000_0000_0000;
        opcode<=4'b0000;
        //txready<=1'b0;
    end
    else if(SIE&&~Bit_stuff&&SYNC_pattern)
       begin
       hold_data<=data_in;
       opcode<=opcode+1'b1;
       end
    else
    opcode<=opcode;
end


//Serial to Parallel Converstion

always@( posedge clk)
begin
    case(opcode)
       4'b0000:temp_out=hold_data[15];
       4'b0001:temp_out=hold_data[0];
       4'b0010:temp_out=hold_data[1];
       4'b0011:temp_out=hold_data[2];
       4'b0100:temp_out=hold_data[3];
       4'b0101:temp_out=hold_data[4];
       4'b0110:temp_out=hold_data[5];
       4'b0111:temp_out=hold_data[6];
       4'b1000:temp_out=hold_data[7];
       4'b1001:temp_out=hold_data[8];
       4'b1010:temp_out=hold_data[9];
       4'b1011:temp_out=hold_data[10];
       4'b1100:temp_out=hold_data[11];
       4'b1101:temp_out=hold_data[12];
       4'b1110:temp_out=hold_data[13];
       4'b1111:temp_out=hold_data[14];
    endcase

 end
 
//Bit stuff Logic
 always@(posedge clk)
 begin
     if(rst)
     begin
          PS<=IDLE;
          //count=3'b000;
      end
     else
          PS<=NS;
end

always@(PS or temp_out)
begin
    case(PS)
        IDLE:if(temp_out&&STUFF_OPER_tx)
                begin
                    count=3'b001;//count+1'b1;
                    NS=START;
                end
                else
                begin
                NS=IDLE;
                count=3'b000;
            end
                
        START:if(temp_out)
        begin
             count=3'b010;
             NS=TWO;
         end
         else
            begin
               //count=3'b000;
               NS=IDLE;
           end
           
        TWO:if(temp_out)
        begin
             count=3'b011;
             NS=THIRD;
        end   
         else
            begin
               //count=3'b000;
               NS=IDLE;
           end
           
        THIRD:if(temp_out)
        begin
             count=3'b100;
             NS=FOUR;
        end   
         else
            begin
               //count=3'b000;
               NS=IDLE;
           end
           
        FOUR:if(temp_out)
        begin
             count=3'b101;
             NS=FIVE;
        end   
         else
            begin
               //count=3'b000;
               NS=IDLE;
           end
        
        FIVE:if(temp_out)
        begin
             count=3'b110;
             NS=BITSTUFF;
        end   
         else
            begin
               count=3'b000;
               NS=IDLE;
           end
       BITSTUFF://if(temp_out)
               begin
                   count=3'b111;
                   NS=IDLE;
               end
               
                 
   endcase
   
   end
  
   
   assign Bit_stuff=(count==3'b111)?1'b1:1'b0;
   
   assign data=Bit_stuff?0:temp_out;
   
   assign SYNC_pattern=(sync_data==8'b0111_1110)?1'b1:1'b0;//SYNC PATTERN CHECKING
      
 

 
 
endmodule

              
                                      
