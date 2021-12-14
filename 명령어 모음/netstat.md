# netstat

- 네트워크 접속, 라우팅 테이블, 네트워크 인터페이스 통계 정보를 보여주는 도구

```sh
# netstat -nltpu
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/systemd
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      629/nginx: master p
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      606/sshd
tcp6       0      0 :::111                  :::*                    LISTEN      1/systemd
# nginx가 80 포트를 사용 중
tcp6       0      0 :::80                   :::*                    LISTEN   
```

- n: 포트 넘버 출력
- ㅣ: 연결된 상태(LISTEN)만 출력
- t: tcp
- u: udp
- p: PID/프로그램 이름
- a: 모두
- r: 라우팅 테이블
- s: 네트워크 통계



[출처](https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=ncloud24&logNo=221388026417)











