This will also copy your ~/.ssh/id_rsa.pub over (in `authorized_keys`):

```bash
docker-compose up --build --scale srv=3
```

To see ips:

```bash
docker inspect $(docker ps -q -f name=fakebuntu) -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```
