# marketdata-websocket
Este projeto consiste no módulo mt5-dde-project do diagrama de arquitetura abaixo e tem como função disponibilizar um DDE server para fornecer as cotações de um ativo financeiro em tempo real.
O módulo publisher-marketdata está conectado a um broker através do DDE server que fornece as cotações em tempo real. 

O módulo publisher-marketdata por sua vez publica as cotações recebidas no websocket /topic/marketdata que fará broadcast dos dados recebidos para quem der subscribe no endpoint websocket.

![Alt text](dde.png?raw=true "Funcionamento DDE")

# Diagrama de Arquitetura
<a href="http://ec2-18-231-160-253.sa-east-1.compute.amazonaws.com:8082/" target="_blank">![Alt text](MarketdataWebsocket.png?raw=true "Ir para Aplicação")</a>

# Demo
<a href="http://ec2-18-231-160-253.sa-east-1.compute.amazonaws.com:8082/" target="_blank">http://ec2-18-231-160-253.sa-east-1.compute.amazonaws.com:8082</a>


# Conceitos abordados:<br/>

<ul>
  <li>Implementação de Websocket no SpringBoot</li>
  <li>Implementação de indicador em linguagem MQL5 (Subset of C++) da Metaquotes</li>
  <li>Dynamic Data Exchange - DDE</li>
</ul>
<br/>
