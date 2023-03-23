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