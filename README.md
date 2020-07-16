# PHP 7.3 + Apache

### Fazendo o rebuild
```sh
# fazendo o build da nova imagem
$ docker build --force-rm --no-cache -t php73-apache:latest .
# removendo a imagem local
$ docker rmi --force fococomunicacao/php73-apache:latest
# linkando a tag de nossa imagem local para a do repositório
$ docker tag php73-apache:latest fococomunicacao/php73-apache:latest
# subindo a imagem atualizada para o repositório
$ docker push fococomunicacao/php73-apache:latest
```

## Updates
- 2020-07-01 Adicionando comandos nano e vim
- 2020-07-01 Adicionando arquivo ini para configuração de erros em /usr/local/etc/php/conf.d/errors.ini
- 2020-07-16 Executando autoremove e autoclean

No dockerhub [fococomunicacao/php73-apache](https://hub.docker.com/r/fococomunicacao/php73-apache)
