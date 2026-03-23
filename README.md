# net-tools

一个基于 `scratch` 构建的极简网络调试镜像，内置常用网络工具，体积极小。

## 使用方式

```bash
docker run --rm -it sliamb/tool
```

> 如遇网络问题无法拉取，可使用备用地址：
> ```bash
> docker run --rm -it public.ecr.aws/sliamb/tool
> ```

## 内置工具

| 类别 | 工具 |
|------|------|
| 网络 | `ping` `traceroute` |
| DNS  | `dig` `nslookup` `host` |
| HTTP | `curl` `wget` |
| Shell | `ls` `cat` `cp` `mv` `rm` `nc` `vi` `grep` `awk` `sed` `find` `ps` `top` 等 |

## 挂载与运行自定义二进制

工作目录为 `/app`，可将本地目录挂载进去：

```bash
docker run --rm -it -v $(pwd):/app sliamb/tool
```

运行挂载的可执行文件：

```bash
chmod +x /app/bin && /app/bin
```
