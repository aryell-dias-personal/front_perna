// TODO: tornar possível identificar a hora do pin na tela inicial

final String markdownHelp = """
# Manual da Aplicação

Este aplicativo tem como intenção facilitar a locomoção dos usuários de transporte coletivo criando uma maior correlação entre demanda dos passageiros e oferta dos motoristas.

## Marcadores do mapa

|Cor do Marcador                        |Significado                          |
|---------------------------------------|-------------------------------------|
|Verde                                  |Partida ou Garagem                   |
|Vermelho                               |Chegada                              |
|Amarela                                |Ponto de atenção                     |

## Como fazer um novo pedido?

Selecione um ponto de `Partida` e de `Chegada` no mapa, pressionando no local do mapa até que apareçam os marcadores verde e após o vermelho, conforme a tabela acima. Em seguida abra a gaveta lateral apertando no botão flutuante e selecione `Novo Pedido`. Na tela que aparecerá preencha o formulário e pressione `adicionar`.

## Como criar um novo expediente?

Selecione um ponto onde será a `Garagem` no mapa, pressionando no local do mapa até que apareça o marcador verde. Em seguida abra a gaveta lateral apertando no botão flutuante e selecione `Novo Expediente`. Na tela que aparecerá preencha o formulário e pressione `adicionar`.

## Como centralizar o mapa para o local onde estou?

Basta tocar em qualquer local do mapa e ele centralizará na sua posição.

## Como remover um marcador que esta no mapa?

Basta tocar no marcador que se deseja remover do mapa, com exceção dos `Pontos de Atenção` que não podem ser removidos até que um ponto mais relevante seja computado ou que o momento ao qual este ponto foi reservado tenha passado.

## Quando devo fazer meus pedidos?

Os pedidos devem ser feitos com no minimo um dia de antecedência, para que todos os pedidos sejam organizados da melhor forma para todos os envolvidos (motoristas e passageiros).

""";