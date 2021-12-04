# `scp`

`scp`(SecureCoPy): 

[출처](https://securet.tistory.com/22)

SSH 포트인 22번을 통해 네트워크가 연결되어 있는 곳에 암호화로 안전하게 데이터 전송 명령어

- 명령어 예시

  `scp [옵션] [원본서버계정@원본서버IP:복사할데이터경로] [붙여넣을 서버계정@붙여넣을 서버IP:붙여넣을 데이터경로]`

  - 원본서버나 붙여넣을 서버가 로컬일 경우 계정@IP는 입력 필요X

- 옵션

  - c : 데이터를 압축하여 전송한다. 
  - P(대) : 포트번호를 지정하여 전송한다. 
  - p(소) : 시간, 접근시간, 모드를 원본과 같도록 전송한다. 
  - r : 디렉터리를 전송한다. 
  - v : 전송과정을 상세히 출력하여 전송한다.

- 예시

  ```sh
  로컬에서 원격지로 데이터를 보낼경우 : 
  scp /home/securet/scp_test/copyfile.txt centos@192.168.137.75:/home/centos/scp_test
  
  원격지에서 데이터를 받을경우 :
  scp 192.168.137.65:/home/centos/scp_test/copyfile.txt securet@192.168.137.65:/home/centos/scp_test
  ```

  