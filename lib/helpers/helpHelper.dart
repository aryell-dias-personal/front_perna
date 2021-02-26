import 'package:flutter/material.dart';
import 'package:perna/helpers/appLocalizations.dart';
import 'package:perna/models/helpItem.dart';

//TODO: traduzir frases do helper
HelpItem getHelpRoot(context) {
  return HelpItem(
    content: "Este aplicativo tem como intenção facilitar a locomoção dos usuários de transporte coletivo criando uma maior correlação entre demanda dos passageiros e oferta dos motoristas.",
    subItems: <HelpItem>[
      HelpItem(
        smallTitle: "Marcadores",
        title: "Marcadores do mapa",
        content: "Existem alguns tipos de marcadores diferentes que podem aparecer no seu mapa aqui no Perna. Dentre esses icones existe o de `Parada de ônibus` que indica a partida do seu pedido ou a garagem do seu expediente, dependendo da operação em questão. Outro icone importante que aparecerá no seu mapa ao fazer um pedido é a `Bandeira Vermelha` que indica pra você o local selecionado para o fim do seu pedido. Por fim, temos o `Sino amarelo` que intida um ponto de atenção, lembrando você do seu próximo pedido ou expediente"
      ),
      HelpItem(
        smallTitle: "Fazer Pedido",
        title: "Como fazer um novo pedido?",
        content: "Selecione um ponto de `Partida` e de `Chegada` no mapa, pressionando no local do mapa até que apareçam a parada de ônibus e após a bandeira vermelha ou preenchendo os campos de pesquisa referentes a partida e destino, conforme a tabela acima. Em seguida pressione o botão flutuante verde que aparecerá `Adicionar Pedido`. Na tela que será mostrada preencha o formulário e pressione `adicionar`."
      ),
      HelpItem(
        smallTitle: "Criar Expediente",
        title: "Como criar um novo expediente?",
        content: "Selecione um ponto onde será a `Garagem` no mapa, pressionando no local do mapa até que apareça uma parada de ônibus ou preencha apénas ao campo de pesquisa referente a partida. Em seguida pressione o botão flutuante verde que aparecerá `Adicionar Expediente`. Na tela que aparecerá preencha o formulário e pressione `adicionar`."
      ),
      HelpItem(
        smallTitle: "Centralizar Mapa",
        title: "Como centralizar o mapa para o local onde estou?",
        content: "Basta tocar em qualquer local do mapa e ele centralizará na sua posição."
      ),
      HelpItem(
        smallTitle: "Remover Marcador",
        title: "Como remover um marcador que esta no mapa?",
        content: "Basta tocar no marcador que se deseja remover do mapa, com exceção dos `Pontos de Atenção` que não podem ser removidos até que um ponto mais relevante seja computado ou que o momento ao qual este ponto foi reservado tenha passado."
      ),
      HelpItem(
        smallTitle: "Quando Pedir",
        title: "Quando devo fazer meus pedidos?",
        content: "Os pedidos devem ser feitos com no minimo um dia de antecedência, para que todos os pedidos sejam organizados da melhor forma para todos os envolvidos (motoristas e passageiros)."
      ),
      HelpItem(
        smallTitle: "Iniciar Rota",
        title: "Como iniciar uma rota?",
        content: "Quando você possuir uma rota calculada pelo perna ela aparecerá no seu mapa com um botão flutante `Navegar`, você poderá pressioná-lo para iniciar a rota indicada."
      ),
      HelpItem(
        smallTitle: "Consultar Histórico",
        title: "Como posso ver meu histórico de pedidos e expedientes?",
        content: "Basta abrir o menu e clicar no item `Histórico` ele lhe levará para uma tela indicando todas as operações (pedidos e expedientes) feitas por você no app."
      )
    ],
    title: "Manual da Aplicação",
    smallTitle: AppLocalizations.of(context).translate("help"),
    iconData: Icons.help_outline
  );
}