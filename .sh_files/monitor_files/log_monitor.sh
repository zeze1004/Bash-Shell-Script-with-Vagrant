#!/bin/bash

# 용량 감시 스크립트
# 1. 로그 디렉토리의 크기를 확인
# 2. 크기가 1기가 이상일 경우 관리자에게 알림
# 3. 1기가 미만일 경우 아무 것도 안함

# 감시할 디렉토리가 바뀌면 DIR 변수 수정
DIR="/var/log/nginx"
# 디스크 사이즈를 SIZE에 저장
SIZE="$(du -m ${DIR} | awk '{print $1}')"
HOST="${HOSTNAME}"

# SIZE가 1024 메가바이트 보다 크면 then 작으면 else 출력
if [ ${SIZE} -ge 1024 ]
then
	TEXT="${DIR} 사용량이 1기가가 넘었습니다."
	/vagrant/SHELL/bot.sh "${HOST}" "${TEXT}"
else
        echo "1기가를 넘지 않았습니다."
fi