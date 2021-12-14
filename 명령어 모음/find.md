# find



- 현재 디렉토리에 있는 파일 및 디렉토리 리스트 표시

  ```sh
  # find
  .
  ./VWS.access.log
  ./access.log
  ./error.log
  ./access.log-20211202.gz
  ./error.log-20211202.gz
  ```

  - `find .`: 현재 디렉토리 하위 검색

- 특정 확장자만 찾기

  ```sh
  # find -name "*.sh"
  ```

  

- 특정 확장자와 파일 이름으로 찾기

  ```sh
  # find . -name "*.sh" | grep cron
  ./vagrant/SHELL/monitor/cron_log.sh
  ```

  











































