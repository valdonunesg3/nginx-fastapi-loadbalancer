# Guia Completo: Load Balancer Nginx com FastAPI em EC2

Este guia ensina passo a passo como montar o seguinte cenário na AWS:

-   1 EC2 com Nginx em Docker (Load Balancer)
-   2 EC2 com aplicação FastAPI em Docker
-   Balanceamento de carga entre as duas instâncias

------------------------------------------------------------------------

## Arquitetura do cenário

               Internet
                   |
            EC2 - Nginx (Load Balancer)
                   |
          -----------------------
          |                     |
    EC2 docker1          EC2 docker2
     FastAPI               FastAPI

------------------------------------------------------------------------

# Parte 1 -- Preparar as duas máquinas de aplicação

Execute os passos abaixo **nas duas EC2 de aplicação**.

## 1. Docker já Instalado

As duas EC2 já vão está com o docker e o docker-compose instalado, pois tem um script user.data.sh que será executado na hora da criação das máquinas, automatizando a instalação das ferramentas necessárias, já na criação das EC2. 

------------------------------------------------------------------------

## 2. Criar estrutura do projeto

``` bash
mkdir fastapi-app
cd fastapi-app
mkdir src
```

------------------------------------------------------------------------

## 4. Criar o arquivo da aplicação - aplicação simples só pra gente testar o funcionamento do load balance

Arquivo: `src/app.py`

``` python
from fastapi import FastAPI
import socket
import os

app = FastAPI()

@app.get("/")
def read_root():
    hostname = socket.gethostname()
    instance_name = os.getenv("INSTANCE_NAME", "unknown")
    return {
        "message": "Aplicação funcionando",
        "hostname": hostname,
        "instance": instance_name
    }
```

------------------------------------------------------------------------

## 5. Criar o arquivo de dependências

Arquivo: `src/requirements.txt`

``` txt
fastapi==0.115.6
uvicorn==0.32.1
```

------------------------------------------------------------------------

## 6. Criar o Dockerfile

Arquivo: `Dockerfile`

``` dockerfile
FROM python:3.10-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

### O que esse Dockerfile faz

-   Usa uma imagem leve do Python
-   Define o diretório de trabalho
-   Instala dependências
-   Copia o código da aplicação
-   Expõe a porta 8000
-   Inicia o servidor Uvicorn

------------------------------------------------------------------------

## 7. Criar o docker-compose

Arquivo: `docker-compose.yml`

### Na máquina docker1

``` yaml
services:
  app:
    build: .
    container_name: fastapi_app
    ports:
      - "8000:8000"
    environment:
      - INSTANCE_NAME=docker1
    restart: always
```

### Na máquina docker2

Use o mesmo arquivo, mudando apenas:

    INSTANCE_NAME=docker2

------------------------------------------------------------------------

## 8. Subir a aplicação

``` bash
docker compose up -d --build
```

Testar localmente:

``` bash
curl http://localhost:8000
```

Saída esperada:

``` json
{
  "message": "Aplicação funcionando",
  "instance": "docker1"
}
```

------------------------------------------------------------------------

# Parte 2 -- Preparar a máquina do Nginx Load Balancer

Execute apenas na EC2 do load balancer.

## 1. Instalar Docker

Da mesma forma que nas duas EC2 anteriores, nessa máquina o docker também já vai está instalado, confirme rodando os seguintes comandos abaixo:

``` bash
docker --version
docker compose version
```

------------------------------------------------------------------------

## 2. Criar estrutura do Nginx

``` bash
mkdir nginx-lb
cd nginx-lb
```

------------------------------------------------------------------------

## 3. Criar configuração do Nginx

Arquivo: `nginx.conf`

Substitua pelos IPs privados das EC2 de aplicação.

``` nginx
events {}

http {
    upstream backend {
        server IP_DOCKER1:8000;
        server IP_DOCKER2:8000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
        }
    }
}
```

Exemplo real:

``` nginx
upstream backend {
    server 10.0.1.10:8000;
    server 10.0.1.11:8000;
}
```

------------------------------------------------------------------------

## 4. Criar docker-compose do Nginx

Arquivo: `docker-compose.yml`

``` yaml
services:
  nginx:
    image: nginx:stable-alpine
    container_name: nginx_lb
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    restart: always
```

------------------------------------------------------------------------

## 5. Subir o load balancer

``` bash
docker compose up -d
```

------------------------------------------------------------------------

# Parte 3 -- Configurações importantes na AWS

## Security Groups

### EC2 do Nginx

Liberar: - Porta 80 (HTTP) para o seu IP

### EC2 das aplicações

Liberar: - Porta 8000 - Origem: Security Group da EC2 do Nginx

------------------------------------------------------------------------

# Parte 4 -- Testar o balanceamento

No navegador:

    http://IP_PUBLICO_DO_NGINX

Atualize várias vezes.

Você verá alternar entre:

    "instance": "docker1"

e

    "instance": "docker2"

Isso confirma que o balanceamento está funcionando.

------------------------------------------------------------------------

Fim do guia.
