# Bash Shell Script를 이용한 서버 장애 대응 실습 공부 기록 저장소😎


아래와 같이 장애를 직접 구현하거나 가정하고 트러블슈팅 과정을 공부합니다👻👻👻


[블로그로 우당탕탕 트러블슈팅 과정 더 자세히 보기](https://blog.naver.com/PostList.naver?blogId=thwjd2717&from=postList&categoryNo=55)



### 트러블슈팅 과정

##### 먼저 트러블슈팅을 위해 장애를 만들어보자!

- `dd` 파일 복사 명령어를 이용해

   `/var/log/ngnix` (웹 로그) 디렉토리가 가득차서 해당 디렉토리로 

  ​	접근이 불가능한 장애를 만드는 것이 목표

> `dd if=복사하고픈 파일 of=붙여넣기할 파일 bs=4M count=20`: 파일 복사
>
> `bs=한 번에 복사할 단위`, `count=복사 반복 횟수`
>
> 가령 2G의 파일을 4M식 20번 붙여넣기 하면 붙여넣은 파일의 용량은 80M
>
> 예시)
>
> ```shell
> [root@cent1 /]# ls -alh
> total 2.1G
> -rw-r--r--    1 root    root       9 Nov 24 13:35 dummy.log # 임의로 만든 파일
> -rw-------.   1 root    root    2.0G Dec  4  2020 swapfile
> 
> [root@cent1 /]# dd if=swapfile of=dummy.log bs=4M count=20
> 20+0 records in
> 20+0 records out
> 83886080 bytes (84 MB, 80 MiB) copied, 3.6724 s, 22.8 MB/s
> 
> [root@cent1 /]# ls -alh
> total 2.1G
> -rw-r--r--    1 root    root     80M Nov 24 13:37 dummy.log # 용량 늘어남
> -rw-------.   1 root    root    2.0G Dec  4  2020 swapfile
> 
> # 원하는건 log파일의 디스크 용량 초과니깐 루트의 dummy.log는 삭제하고 ngnix 디렉토리에 새로 만들어준다
> # 그리고 다시 swapfile 복사하기
> 
> [root@cent1 nginx]# dd if=swapfile of=/var/log/nginx/dummy.log bs=100M count=1
> 1+0 records in
> 1+0 records out
> 104857600 bytes (105 MB, 100 MiB) copied, 3.36137 s, 31.2 MB/s
> 
> [root@cent1 nginx]# ls -alh
> total 101M
> drwxrwx---.  2 nginx root   80 Nov 24 12:47 .
> drwxr-xr-x. 12 root  root 4.0K Nov 24 08:47 ..
> -rw-r--r--.  1 root  root 5.3K Nov 24 11:45 access.log
> # dummy파일이 초기화 루에 100M만큼 복사가 되는 것
> -rw-r--r--   1 root  root 100M Nov 24 13:53 dummy.log   
> -rw-r--r--.  1 root  root  512 Nov 24 11:45 error.log
> -rw-r--r--.  1 root  root    0 Nov 24 08:47 VWS.access.log
> 
> # 용량을 더 키워보자 
> [root@cent1 nginx]# dd if=/swapfile of=dummy.log bs=1G count=100
> # 터미널이 멈춰서 그냥 nginx 디렉토리가 디스크 초과 됐다고 가정하고 진행하기로 함...^ㅠ^
> 
> # *dummy.log를 지워도 디스크 용량이 줄어들지 않음...왜지...?
> [root@cent1 /]# df -h
> Filesystem      Size  Used Avail Use% Mounted on
> devtmpfs        467M     0  467M   0% /dev
> tmpfs           485M     0  485M   0% /dev/shm
> tmpfs           485M   13M  472M   3% /run
> tmpfs           485M     0  485M   0% /sys/fs/cgroup
> /dev/sda1        10G  5.6G  4.5G  56% /
> tmpfs            97M     0   97M   0% /run/user/1000
> tmpfs            97M     0   97M   0% /run/user/0
> ```
>
> - **파일을 지워도 전체 디스크 용량은 줄어들지 않는 원인**
>
>   실행 중인 프로세스에서 해당 파일을 열어놓은 상태에서 삭제하게 되면 
>
>   파일은 삭제된 것 처럼 보이지만 해당 프로세스와의 연결 남아 있는 상태(프로세스는 계속 동작 중)
>
>   파일 시스템에서 ls로 보이지는 않지만 reference count가 0이 아니기 때문에 
>
>   실제로 지워지지 않고 남아있는 경우가 더러 있음
>
>   - `lsof`: 프로세스와 연결된 파일들을 보여줌
>
>     ```shell
>     sudo lsof | grep deleted
>     
>     [root@cent1 /]# sudo lsof | grep deleted
>     COMMAND PID  USER  FD TYPE DEVICE SIZE/OFF   NODE    NAME
>     ...
>     dd       3785 root 1w  REG 8,1    2147483648 8389361 /var/log/nginx/dummy.log (deleted)
>     ```
>
>     | COMMAND | PID  | USER | FD   | TYPE | DEVICE | SIZE/OFF   | NODE    | NAME                     |
>     | ------- | ---- | ---- | ---- | ---- | ------ | ---------- | ------- | ------------------------ |
>     | dd      | 3785 | root | 1w   | REG  | 8,1    | 2147483648 | 8389361 | /var/log/nginx/dummy.log |
>
>   - 삭제된 파일(deleted)의 PID(**프로세스의 아이디**)를 찾을 수 있음
>
>     `ps aux`: 실행중인 모든 프로세스 확인(`ps -ef`도 같은 기능)
>
>   ```shell
>   [root@cent1 /]# ps aux | grep 3785
>   root        3785  3.7 59.4 1055916 590008 pts/1  T    14:19   3:31 dd if=/swapfile of=dummy.log bs=1G count=100
>   root        4173  0.0  0.1  12112  1092 pts/1    S+   15:53   0:00 grep --color=auto 3785
>   ```
>
>   > 용량을 더 키울려다가 터미널이 멈춰서 명령 취소했는데 아직 실행중이었다
>   >
>   > 프로세스를 kill하면 된다
>   >
>   > ```shell
>   > [root@cent1 /]# kill -9 3785
>   > [root@cent1 /]# ps aux | grep 3785
>   > root        4191  0.0  0.1  12112  1116 pts/1    S+   16:01   0:00 grep --color=auto 3785
>   > [2]+  Killed                  dd if=/swapfile of=dummy.log bs=1G count=100  (wd: /var/log/nginx)
>   > (wd now: /)
>   > 
>   > # 디스크 용량 확인해보니 원래 용량으로 줄어듦😁
>   > [root@cent1 /]# df -h
>   > Filesystem      Size  Used Avail Use% Mounted on
>   > devtmpfs        467M     0  467M   0% /dev
>   > tmpfs           485M     0  485M   0% /dev/shm
>   > tmpfs           485M   13M  472M   3% /run
>   > tmpfs           485M     0  485M   0% /sys/fs/cgroup
>   > /dev/sda1        10G  3.6G  6.5G  36% /
>   > tmpfs            97M     0   97M   0% /run/user/1000
>   > tmpfs            97M     0   97M   0% /run/user/0
>   > ```
>   - `kill`: 프로세스 종료
>     - `kill -9 PID`: 강제 종료
>
>     - `kill -15 PID`: 작업 종료
>
> - `dd` 와 유사하면서 다른 `truncate`
>
>   `truncate -s file_size file_name`: 아이노드를 늘려주는 거라 디스크 용량이랑 상관x
>
>   ```shell
>   # [root@cent1 nginx]# truncate -s 1GB dummy.log
>   # dummy.log 용량은 그대로
>   ```



### 에러 구현 했다치고 트러블 슈팅 시작...!

- nginx 로그를 볼려고 했는데 에러가 떴다😥 어떻게 해결해야 할까?

```shell
[root@cent1 ~]# ls -al /var/log/nginx
No space left on device
```



1. 같은 에러가 계속 발생하지 않는지 확인

2. 서버 로드가 높은가: 로드 프로세스 조사/처리

   cpu 코어 개수 보다 로드 에버리지가 높으면 서버 로드가 높은 것

   `cat /proc/cpuinfo` 로 cpu 정보 확인

   > processor 개수 확인

   `uptime`으로 로드에버리지 확인

   > load average: 0.00, 0.00, 0.00

3. 메모리를 많이 쓰는가: 메모리 사용량 조사/처리

   `free -m`: 메모리 확인

   ```shell
   [root@cent1 ~]# free -m
                 total        used        free      shared  buff/cache   available
   Mem:            968         126         621          12         221         692
   Swap:          2047           0        2047
   ```
   이 정도면 나쁘지 않다

4. 디스크를 많이 쓰는가

   `df -h`: 디스크 사용량 확인

   `-h`: 휴먼이 읽기 쉽게 보여주는 플래그

   ```shell
   [root@cent1 ~]# df -h
   Filesystem      Size  Used Avail Use% Mounted on
   devtmpfs        467M     0  467M   0% /dev
   tmpfs           485M     0  485M   0% /dev/shm
   tmpfs           485M   13M  472M   3% /run
   tmpfs           485M     0  485M   0% /sys/fs/cgroup
   /dev/sda1        10G  3.6G  6.5G  100% /              # 한 파디션에서 유독 많이 씀
   tmpfs            97M     0   97M   0% /run/user/1000
   tmpfs            97M     0   97M   0% /run/user/0
   ```

   - 해당 디스크를 조사해보자

     - 보통 짧은 시간에 디스크가 가득 찬 경우는 웹 로그가 쌓였을 가능성이 높지만

       root부터 차근차근 조사해보자

   - 각 디렉토리 별로 용량 계산 후 큰 용량을 차지하는 디렉토리를 찾자

     `du -h --max-depth=1`: 현재 위치에서 한 단계 아래의 디스크 용량 총합을 나타내는 명령어

     ```shell
     [root@cent1 /]# du -h --max-depth=1
     0       ./dev
     # /proc: 커널 프로세스를 포함하는 각 실행 중인 프로세스 정보 저장
     # 디스크에 있는게 아니라 메모리 상에 있기에 명령어 생겼다가 사라질 수 있어서 신경 안써두 댐
     du: cannot access './proc/3563/task/3563/fd/3': No such file or directory
     du: cannot access './proc/3563/task/3563/fdinfo/3': No such file or directory
     du: cannot access './proc/3563/fd/4': No such file or directory
     du: cannot access './proc/3563/fdinfo/4': No such file or directory
     0       ./proc
     13M     ./run
     0       ./sys
     22M     ./etc
     56K     ./root
     9.9G    ./var      # 찾았다 요놈 유독 큰 용량이 보임
     1.2G    ./usr		
     49M     ./boot
     16K     ./home
     0       ./media
     0       ./mnt
     0       ./opt
     0       ./srv
     4.0K    ./tmp
     7.2M    ./vagrant
     3.5G    .
     ```

     ```shell
     # G 용량인 하위 디렉토리 찾기
     [root@cent1 /]# du -h --max-depth=1 | grep G
     du: cannot access './proc/3569/task/3569/fd/3': No such file or directory
     du: cannot access './proc/3569/task/3569/fdinfo/3': No such file or directory
     du: cannot access './proc/3569/fd/4': No such file or directory
     du: cannot access './proc/3569/fdinfo/4': No such file or directory
     9.9G    ./var
     1.2G    ./usr
     3.5G    .
     ```

     `du -h --max-depth=1 | grep G` : G가 들어 있는 디렉토리 찾기

     - 파일까지 찾아야 할 경우는 `du -sh * | grep G`

       ```shell
       [root@cent1 /]# du -sh * | grep G
       du: cannot access 'proc/3573/task/3573/fd/3': No such file or directory
       du: cannot access 'proc/3573/task/3573/fdinfo/3': No such file or directory
       du: cannot access 'proc/3573/fd/3': No such file or directory
       du: cannot access 'proc/3573/fdinfo/3': No such file or directory
       9.9G    ./var
       2.0G    swapfile # 파일
       1.2G    usr
       ```

   - `2>dev/null`: 에러로그를 null 디렉토리로 redirect해서 에러로그 출력 안 되게 하는 방법

     > 1: 표준출력
     >
     > 2: 에러출력
     >
     > ```shell
     > [root@cent1 /]# du -h --max-depth=1 2>/dev/null
     > 0       ./dev
     > 0       ./proc
     > 13M     ./run
     > 0       ./sys
     > 22M     ./etc
     > 56K     ./root
     > 172M    ./var
     > 1.2G    ./usr
     > 49M     ./boot
     > 16K     ./home
     > 0       ./media
     > 0       ./mnt
     > 0       ./opt
     > 0       ./srv
     > 4.0K    ./tmp
     > 7.2M    ./vagrant
     > 3.5G    .
     > ```

   - 최종적으로 용량이 큰 log 파일이 있는 걸 확인하고 `rm -f` 로 파일 삭제해주면

     트러블슈팅 끗~~~이 아니고

     수동으로 홈페이지 이용시 발생하는 로그를 3초 간격으로 확인해서 로그가 잘 쌓이는지 검사해보자

     `watch -n 3 ls -al` 

     ```shell
     [root@cent1 /]# watch -n 3 ls -al /var/log/nginx
     
     Every 3.0s: ls -al /var/log/nginx        cent1: Wed Nov 24 16:47:15 2021
     total 20
     drwxrwx---.  2 nginx root   63 Nov 24 14:53 .
     drwxr-xr-x. 12 root  root 4096 Nov 24 08:47 ..
     -rw-r--r--.  1 root  root 9404 Nov 24 16:47 access.log # 숫자 증가
     -rw-r--r--.  1 root  root  512 Nov 24 11:45 error.log
     -rw-r--r--.  1 root  root    0 Nov 24 08:47 VWS.access.log
     ```

     http://172.18.1.91/www/index.html

     새로고침할 때 마다 3초 간격 마다 access.log의 용량이 늘어남

   - 디스크 용량 감시

     `watch -n 3 df`

     ```shell
     Every 3.0s: df                           cent1: Wed Nov 24 16:52:17 2021
     Filesystem     1K-blocks    Used Available Use% Mounted on
     devtmpfs          477680       0    477680   0% /dev
     tmpfs             496124       0    496124   0% /dev/shm
     tmpfs             496124   12828    483296   3% /run
     tmpfs             496124       0    496124   0% /sys/fs/cgroup
     /dev/sda1       10474496 3742216   6732280  36% /
     tmpfs              99224       0     99224   0% /run/user/1000
     tmpfs              99224       0     99224   0% /run/user/0
     ```

     새로고침하면 디스크 용량 증가
