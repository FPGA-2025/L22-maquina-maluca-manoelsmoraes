`timescale 1ns/1ps

module tb();

    reg clk;
    reg rst_n;
    reg start;
    wire [3:0] state;

    integer i;
    reg erro_detectado;

    // Sequência esperada de estados
    reg [3:0] expected_state [0:10];

    maquina_maluca dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .state(state)
    );

    // Clock de 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Iniciando Teste..");
       
        rst_n = 0;
        start = 0;
        erro_detectado = 0;

        // Espera estabilizar e libera reset
        #20;
        rst_n = 1;

        // Espera IDLE
        wait (state == 4'd1);

        // Envia start por 2 ciclos
        #10 start = 1;
        #10 start = 0;

        // Sequência correta
        expected_state[0]  = 4'd2; // LIGAR_MAQUINA
        expected_state[1]  = 4'd3; // VERIFICAR_AGUA
        expected_state[2]  = 4'd4; // ENCHER_RESERVATORIO
        expected_state[3]  = 4'd3; // VERIFICAR_AGUA
        expected_state[4]  = 4'd5; // MOER_CAFE
        expected_state[5]  = 4'd6; // COLOCAR_NO_FILTRO
        expected_state[6]  = 4'd7; // PASSAR_AGITADOR
        expected_state[7]  = 4'd8; // TAMPEAR
        expected_state[8]  = 4'd9; // REALIZAR_EXTRACAO
        expected_state[9]  = 4'd1; // IDLE (final)

        // Verifica transições
        for (i = 0; i <= 9; i = i + 1) begin
            wait (state == expected_state[i]);
            if (state !== expected_state[i]) begin
                $display("ERRO: Esperado estado %d, obtido %d no passo %d", expected_state[i], state, i+1);
                erro_detectado = 1;
            end
            @(posedge clk);
        end

        if (erro_detectado)
            $display("ERRO");
        else
            $display("OK");

        $finish;
    end

endmodule
