


## Usage


before use disable server default dns server

```bash
systemctl stop systemd-resolved && systemctl mask systemd-resolved
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```


to use run the following commands

```bash
git clone https://github.com/darrenoshan/dnsproxy.git && cd dnsproxy/
./run.sh

```
