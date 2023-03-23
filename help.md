Dockerfile：

FROM ubuntu:latest

# 安装必要的软件
RUN apt-get update && \
    apt-get install -y python-pip wget tar libssl1.0-dev && \
    pip install shadowsocks && \
    wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz && \
    tar xf noip-duc-linux.tar.gz && \
    cd noip-2.1.9-1/ && \
    make && \
    make install && \
    rm -rf /var/lib/apt/lists/*

# 创建libcrypto.so.1.1软链接
RUN ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1

# 复制Shadowsocks配置文件
COPY shadowsocks.json /etc/

# 复制noip配置文件
ARG noip_conf
RUN echo "${noip_conf}" > /usr/local/etc/no-ip2.conf

# 开放Shadowsocks服务端口
EXPOSE 8388

# 启动noip客户端和Shadowsocks服务端
CMD ["sh", "-c", "/usr/local/bin/noip2 && ssserver -c /etc/shadowsocks.json"]
shadowsocks.json配置文件：

{
    "server":"0.0.0.0",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"mypassword",
    "timeout":300,
    "method":"aes-256-cfb"
}
noip.conf配置文件（请将myusername、mypassword和myhostname.no-ip.biz替换为您自己的noip账户信息和主机名）：

USERNAME=myusername
PASSWORD=mypassword
HOSTNAME=myhostname.no-ip.biz
在修改后的Dockerfile中，我们添加了一个步骤，安装了libssl1.0-dev包，并创建了一个软链接，将libcrypto.so.1.0.0链接到libcrypto.so.1.1。这样，当shadowsocks使用libcrypto.so.1.1时，它将自动链接到libcrypto.so.1.0.0，从而解决了undefined symbol错误。

需要注意的是，这种解决方法可能会导致其他问题，因为libcrypto.so.1.0.0和libcrypto.so.1.1之间有一些差异。如果您遇到其他问题，请尝试升级shadowsocks或openssl库版本。

最后，为了确保安全性，您应该使用强密码和加密方法，并定期更改密码和更新noip客户端版本。