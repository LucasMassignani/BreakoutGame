# BreakoutGame

## Resumo
Este projeto tem como objetivo apresentar o jogo Breakout e mostrar o processo de implementação em assembly 8086, além de mostrar as principais dificuldades encontradas durante o processo de desenvolvimento do jogo.

## JOGO
<p>
  O jogo Breakout consiste em 3 elementos principais, a
raquete, a bola e os blocos. O objetivo é destruir a maior
quantidade de blocos que conseguir, porém sem deixar a
bola “cair no chão”.
</p>
<p>
  Na primeira tela do jogo Fig. 1, podemos ver o menu, ele é
bem simples e sua única funcionalidade é iniciar ou sair do
jogo. Com as setas do teclado para cima e para baixo
navegamos pelo menu e com a tecla Enter selecionamos a
opção que está entre colchetes.
</p>

<img src="https://i.imgur.com/RfETZyq.png"/> 
<cite>Fig. 1: Menu principal do Breakout.</cite>
<br />
<br />

<p>
  Na segunda tela Fig. 2, vemos o jogo já em execução.
Com as setas do teclado direita e esquerda controlamos a
raquete, nosso objetivo é destruir os blocos e não deixar a
bola “cair no chão”.
</p>
<p>
  Caso a bola acerte as pontas rosas da raquete ela é
direcionada para o lado contrário do que vinha.
</p>
<p>
  Na parte superior esquerda vemos nossa pontuação, para
cada bloco destruído ganhamos uma quantidade de pontos,
para os amarelos 1, para os verde 3, para os vermelhos claro
5 e para os vermelhos 7.
</p>
<p>
  Na parte superior esquerda vemos nossa quantidade de
vidas. Iniciamos o jogo com 3 vidas e perdemos elas cada
vez que a bola atinge a parte inferior da tela, caso as vidas
cheguem a zero o jogo acaba.
</p>
<p>
  Caso 4 blocos, um vermelho claro ou um vermelho, sejam
destruídos, a velocidade da bola, que inicia em 400 ms é
aumentada em 50 ms, podendo chegar até em 100 ms.
</p>

<img src="https://imgur.com/QyIUSEu.png"/> 
<cite>Fig. 2: Jogo em execução.</cite>
<br />
<br />

<p>
  Na terceira e última tela Fig. 3, temos a mensagem de
“Fim de Jogo”, ela aparece quando perdemos o jogo e temos
que voltar para o menu principal. Para isso precisamos
apertar qualquer tecla.
</p>

<img src="https://imgur.com/JlwUUBD.png"/> 
<cite>Fig. 3: Tela de fim de jogo.</cite>
<br />
<br />

<p>
  O jogo apresenta um bug conhecido, ao destruir todos os
blocos, a funcionalidade seria de recomeçar o jogo com a
mesma pontuação, porém ao iniciar o jogo novamente um
bloco, aparentemente aleatório, fica fora do lugar,
impossibilitando destruí-lo e prosseguir o jogo, este bug
pode ser visto na Fig. 4.
</p>

<img src="https://imgur.com/hzHHhcZ.png"/>
<cite>Fig. 4: Bug do bloco fora do lugar.</cite>

## SOLUÇÃO

### A - Algoritmo
<p>
  O loop principal executa de 50 em 50 ms, este tempo foi
escolhido para controlar a velocidade da bola que vai de 400
ms até 100 ms. Toda vez que o loop é executado a variável
contador_bola é incrementada e comparada com a
contador_bola_fim, seus valores iniciais são 0 e 8, quando a
contador_bola for igual a contador_bola_fim quer dizer que
a bola deve se mexer. Além disso, todas as colisões são
validadas nesse momento, caso o jogador destrua 4 blocos
ou destrua 1 bloco vermelho ou vermelhor claro a variável
contador_bola_fim é decrementada em 1 para assim
aumentar a velocidade da bola em 50 ms.
</p>
<p>
  Por fim, independente das variáveis contador_bola e
contador_bola_fim serem iguais ou não, a tela é limpada e
todos os elementos (raquete, bola e blocos) são desenhados
na tela novamente.
</p>
<p>
  O código possui 873 linhas e 4.096 bytes.
</p>
<p>
  O fluxograma do jogo pode ser visto na Fig. 5
</p>

### B - Memória
<p>
  As variáveis utilizadas para criação de menus/escritas na
tela foram: tela_menu, nome, opcoes_menu, tela_fim_jogo,
menu_jogo_score e menu_jogo_vidas, todas elas usando
DB.
</p>
<p>
  As variáveis para controlar o estado do jogo utilizando
DW foram: vidas e pontos e utilizando DB:
blocos_destruidos_dec_vel, ganhou_jogo, contador_bola,
contador_bola_fim.
</p>
<p>
  As variáveis usadas para controlar a posição dos objetos e
movimentação da bola foram: bola_x, bola_y, velocidade_x,
velocidade_y, raquete_x, blocos_vermelhos_x,
blocos_vermelhos_claro_x, blocos_verde_x,
blocos_amarelo_x, todas utilizando DB.
</p>

### C. Rotinas
<p>
  As principais rotinas se dividem em 3, as de mover, as de
colisão e as de desenhar.
</p>
<p>
  As de mover são as primeiras a serem executadas no loop
e são elas: mover_raquete e mover_bola, para essas duas
rotinas não são passados parâmetros. Elas utilizam os valores
das variáveis: raquete_x, bola_x, bola_y, para saber a
posição que precisam ser desenhadas. A validação de colisão
com as paredes do jogo também é feita nessas rotinas.
</p>
<p>
  São duas rotinas de verificação de colisão, a
verificar_colisao_raquete não recebe parâmetro e a
verificar_colisao_bloco, recebe de parâmetro o OFFSET da
lista de X dos blocos que vão ser validados, o Y em que eles
devem ser desenhados e a quantidade de pontos por
destruí-los. As duas rotinas utilizam as variáveis x e y da
bola para verificar a futura posição dela e assim saber se vão
colidir ou não.
</p>
<p>
  As rotinas de desenho são 3, a desenhar_bola e
desenhar_raquete, essas duas rotinas não recebem
parâmetros e a desenhar_bloco que precisa receber o
OFFSET dos X dos blocos, sua posição Y e sua cor. Todas
elas desenham na tela utilizando a rotina esc_char.
</p>
<p>
  A rotina de geração de números aleatórios rand_num_0_9
[1] se baseia no tempo do computador para fazer uma
divisão e obter um número entre 0 e 9, ela retorna o número
aleatório em DL. Quando utilizada ela é chamada 2 vezes
para assim aumentar a aleatoriedade para 0 até 18.
</p>

<img src="https://imgur.com/KQbogKk.png"/>
<cite>Fig. 5: Fluxograma do algoritmo</cite>
<br>

## CONCLUSÕES

<p>
  A principal dificuldade do projeto foi escrever diretamente
na memória usando o registrador DI, o objetivo no início do
trabalho foi criar a rotina esc_char com interrupções para
escrever na tela e no fim do trabalho substituir essa
interrupção para escrever diretamente na memória, como é
feito na rotina esc_char_mem. Isto foi concluído e não foi
mais utilizada a INT 10H para escrever na tela durante o
decorrer do jogo ao invés disso utiliza a própria
esc_char_mem para realizar a escrita
</p>
<p>
  A principal dificuldade do projeto foi escrever diretamente
na memória usando o registrador DI, o objetivo no início do
trabalho foi criar a rotina esc_char com interrupções para
escrever na tela e no fim do trabalho substituir essa
interrupção para escrever diretamente na memória, como é
feito na rotina esc_char_mem. Isto foi concluído e não foi
mais utilizada a INT 10H para escrever na tela durante o
decorrer do jogo ao invés disso utiliza a própria
esc_char_mem para realizar a escrita
</p>
<p>
  Outra dificuldade encontrada foi a resolução de bugs que
muitas vezes são de difícil compreensão e requerem uma
análise mais aprofundada.
</p>

## REFERÊNCIAS

<p>
[1] Tough Turtle, ““HOW TO GENERATE RANDOM NUMBER IN
8086” Code Answer”, 26 de abril 2020, Disponível em:
https://www.codegrepper.com/code-examples/whatever/HOW+TO+
GENERATE+RANDOM+NUMBER+IN+8086.
</p>
