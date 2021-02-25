// TODO: Atualizar e traduzir para inglês
final String markdownHelp = """
# Manual da Aplicação

Este aplicativo tem como intenção facilitar a locomoção dos usuários de transporte coletivo criando uma maior correlação entre demanda dos passageiros e oferta dos motoristas.

## Marcadores do mapa

|Icone do Marcador                      |Significado                          |
|---------------------------------------|-------------------------------------|
|Parada de ônibus                       |Partida ou Garagem                   |
|Bandeira Vermelha                      |Chegada                              |
|Sino amarelo                           |Ponto de atenção                     |

## Como fazer um novo pedido?

Selecione um ponto de `Partida` e de `Chegada` no mapa, pressionando no local do mapa até que apareçam a parada de ônibus e após a bandeira vermelha ou preenchendo os campos de pesquisa referentes a partida e destino, conforme a tabela acima. Em seguida pressione o botão flutuante verde que aparecerá `Adicionar Pedido`. Na tela que será mostrada preencha o formulário e pressione `adicionar`.

## Como criar um novo expediente?

Selecione um ponto onde será a `Garagem` no mapa, pressionando no local do mapa até que apareça uma parada de ônibus ou preencha apénas ao campo de pesquisa referente a partida. Em seguida pressione o botão flutuante verde que aparecerá `Adicionar Expediente`. Na tela que aparecerá preencha o formulário e pressione `adicionar`.

## Como centralizar o mapa para o local onde estou?

Basta tocar em qualquer local do mapa e ele centralizará na sua posição.

## Como remover um marcador que esta no mapa?

Basta tocar no marcador que se deseja remover do mapa, com exceção dos `Pontos de Atenção` que não podem ser removidos até que um ponto mais relevante seja computado ou que o momento ao qual este ponto foi reservado tenha passado.

## Quando devo fazer meus pedidos?

Os pedidos devem ser feitos com no minimo um dia de antecedência, para que todos os pedidos sejam organizados da melhor forma para todos os envolvidos (motoristas e passageiros).

## Como iniciar uma rota?

Quando você possuir uma rota calculada pelo perna ela aparecerá no seu mapa com um botão flutante `Navegar`, você poderá pressioná-lo para iniciar a rota indicada.

## Como posso ver meu histórico de pedidos e expedientes?

Basta abrir o menu e clicar no item `Histórico` ele lhe levará para uma tela indicando todas as operações (pedidos e expedientes) feitas por você no app.

""";