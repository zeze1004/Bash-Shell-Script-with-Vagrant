#!/bin/bash
# telegram bot으로 메세지를 보내는 쉘 스크립트
# 2개의 파라미터가 필요 "1. 서버 호스트 이름" "2. 메세지"
# 실행 결과는 현재 날짜/시각, 서버 이름, 메세지를 텔레그램으로 전송



# 파라미터 2개보다 적다면 아래 사용법 출력 후 종료
if [ $# -ne 2 ]
then
        echo
        echo "Usage "
        echo "$0 {HOSTNAME} {MESSAGES}"
        echo
        echo "example) "
        echo "$0 \"cent1\" \"/var/log/nginx 파티션을 확인하세요\""
        echo
        exit 0
fi

# 텔레그램 봇 관련 정보
ID="..."
API_TOKEN="..."
URL="https://api.telegram.org/bot${API_TOKEN}/sendMessage"

#날짜
DATE="$(date "+%Y-%m-%d %H:%M")"

# 보낼 메세지 작성
TEXT="${DATE} [$1] $2"

#메세지 보내기
curl -s -d "chat_id=${ID}&text=${TEXT}" ${URL} > /dev/null