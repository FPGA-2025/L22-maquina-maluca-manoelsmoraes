`timescale 1ns/1ps

module tb();

    reg clk;
    reg rst_n;
    reg start;
    wire [3:0] state;

    integer i;

    reg [3:0] expected_state_sequence [0:10];

    maquina_maluca dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .state(state)
    );

    // Clock 10ns periodo
    initial clk = 0;
    always #5 clk = ~clk;

    // Print do estado a cada posedge para debug
    always @(posedge clk) begin
        $display("Tempo=%0t, state=%d, start=%b", $time, state, start);
    end

    initial begin
        $display("Iniciando Testbench...");

        rst_n = 0;
        start = 0;
        #20;
        rst_n = 1;

        // Timeout para evitar sim travada
        fork
            begin
                #1000;
                $display("ERRO: Timeout - simulação demorou demais");
                $finish;
            end
            begin
                // Verifica estado inicial após reset
                @(posedge clk);
                if (state !== 4'd1) begin
                    $display("ERRO: Esperado estado IDLE após reset. Obtido: %d", state);
                    $finish;
                end

                // Aciona start para iniciar, segura start por 2 ciclos
                start = 1;
                @(posedge clk);
                @(posedge clk);
                start = 0;

                // Sequência esperada a partir daqui:
                expected_state_sequence[0] = 4'd1;  // IDLE (já verificado)
                expected_state_sequence[1] = 4'd2;  // LIGAR_MAQUINA
                expected_state_sequence[2] = 4'd3;  // VERIFICAR_AGUA
                expected_state_sequence[3] = 4'd4;  // ENCHER_RESERVATORIO
                expected_state_sequence[4] = 4'd3;  // VERIFICAR_AGUA (água cheia)
                expected_state_sequence[5] = 4'd5;  // MOER_CAFE
                expected_state_sequence[6] = 4'd6;  // COLOCAR_NO_FILTRO
                expected_state_sequence[7] = 4'd7;  // PASSAR_AGITADOR
                expected_state_sequence[8] = 4'd8;  // TAMPEAR
                expected_state_sequence[9] = 4'd9;  // REALIZAR_EXTRACAO
                expected_state_sequence[10] = 4'd1; // IDLE (fim)

                // Verifica os estados sincronizados com clock
                for (i = 1; i <= 10; i = i + 1) begin
                    @(posedge clk);
                    if (state !== expected_state_sequence[i]) begin
                        $display("ERRO: Esperado estado %d, obtido %d no passo %d", expected_state_sequence[i], state, i);
                        $finish;
                    end
                end

                $display("OK: Sequência completa correta.");
                $finish;
            end
        join

    end

endmodule
