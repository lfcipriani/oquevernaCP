# @oquevernaCP

É um bot de Twitter que responde aos tweets com a programação da Campus Party Brasil 7. Mais detalhes sobre o funcionamento em: 

[http://lfcipriani.github.io/oquevernaCP/](http://lfcipriani.github.io/oquevernaCP/)

## Tecnologias utilizadas

* ruby 2.0.0
* [API de Streaming do Twitter (GET user)](https://dev.twitter.com/docs/api/1.1/get/user)
* [Redis](http://redis.io/)
* gem tweetstream

## Como instalar

### Dados do Google Calendar

Existem dois executáveis no diretório `data`:

* `crawlendar.rb`: Captura cada calendário da Campus Party e converte para um representação json.
* `calendorganizer.rb`: Otimiza essas representações  e index para que o bot responda rápido uma requisição.

Execute esses arquivos em ordem para obter o arquivo `the_data_you_need_to_make_magic.json` :-)

### Execução do bot

1. Clone esse repositório
2. Copie e renomeie o arquivo `config/credentials.yml.sample` para `config/credentials.yml`
3. Coloque os tokens de acesso obtidos em [dev.twitter.com](http://dev.twitter.com/apps) no arquivo `credentials.yml`
4. Execute `bundle install`
5. Inicie o redis
6. Execute `foreman start`

Divirta-se!

## Colaborando com o projeto

Se você acha que o bot está fraquinho, colabore! Envie o pull request para mim que eu integro e faço o deploy do bot. Algumas ideias do que pode ser feito:

* Aceitar perguntas com horários, dias ou períodos como manhã, tarde.
* Permitir pesquisa nas palestras como por exemplo: @oquevernaCP o que vai rolar de front end?
* Enviar uma ajuda de como usar o bot para quem enviar: @oquevernaCP #comofas
* ...insira sua sugestão aqui...

_obs.: tem um easter egg no código, você consegue encontrar? #tafacil_



