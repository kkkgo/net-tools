
FROM alpine:edge AS builder

RUN apk add --no-cache \
    curl \
    wget \
    bind-tools \
    traceroute \
    iputils \
    busybox-static

RUN mkdir -p /collect/bin /collect/lib /collect/etc /collect/app /collect/tmp

RUN cp /bin/busybox.static /collect/bin/busybox

RUN cp /usr/bin/curl       /collect/bin/curl
RUN cp /usr/bin/wget       /collect/bin/wget
RUN cp /usr/bin/dig        /collect/bin/dig
RUN cp /usr/bin/nslookup   /collect/bin/nslookup
RUN cp /usr/bin/host       /collect/bin/host
RUN cp /usr/bin/traceroute /collect/bin/traceroute
RUN cp /bin/ping           /collect/bin/ping

RUN for bin in \
    /usr/bin/curl \
    /usr/bin/wget \
    /usr/bin/dig \
    /usr/bin/nslookup \
    /usr/bin/host \
    /usr/bin/traceroute \
    /bin/ping; do \
    ldd "$bin" 2>/dev/null | grep -oE '/[^ ]+\.so[^ ]*' | while read lib; do \
    [ -f "$lib" ] && cp -n "$lib" /collect/lib/ || true; \
    done; \
    done

RUN cp /lib/ld-musl-*.so* /collect/lib/ 2>/dev/null || true

RUN printf 'nameserver 223.6.6.6\nnameserver 1.0.0.1\n' > /collect/etc/resolv.conf
RUN printf 'hosts: dns files\n'                        > /collect/etc/nsswitch.conf
RUN printf 'root:x:0:0:root:/:/bin/sh\n'              > /collect/etc/passwd
RUN printf 'root:x:0:\n'                               > /collect/etc/group

RUN cat > /collect/etc/profile << 'EOF'
echo ""
echo "┌──────────────────────────────────────────────────┐"
echo "│             net-tools  minimal image             │"
echo "├─────────────────┬────────────────────────────────┤"
echo "│  Network        │ ping  traceroute               │"
echo "│  DNS            │ dig  nslookup  host            │"
echo "│  HTTP           │ curl  wget                     │"
echo "│  Shell          │ ls  cat  cp  mv  rm  nc  vi    │"
echo "│                 │ grep  awk  sed  find  ps  top  │"
echo "├─────────────────┴────────────────────────────────┤"
echo "│  Mount dir  →  /app                              │"
echo "│  Run binary    chmod +x /app/bin && /app/bin     │"
echo "└──────────────────────────────────────────────────┘"
echo ""
EOF

FROM scratch

COPY --from=builder /collect/ /

RUN ["/bin/busybox", "--install", "-s", "/bin"]

WORKDIR /app

ENTRYPOINT ["/bin/sh", "-l"]
