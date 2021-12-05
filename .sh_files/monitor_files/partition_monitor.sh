#!/bin/bash

TEXT="$(df -h | \
        awk '{
                gsub("%","");
                USE=$5;
                MNT=$6;
                if (USE > 10)
                        print MNT,"파티션이 ",USE,"%을 사용 중입니다."}' |\
        grep -v "^[A-Z]")"
HOST="$(hostname)"

# TEXT 안의 코드가 실행되면 TEXT 사이즈가 1BYTE 이상
if [ ${#TEXT} -gt 1 ]
then
        /vagrant/SHELL/monitor/bot.sh "${HOST}" "${TEXT}"
        echo ${TEXT}
else
        echo "파티션 용량 10% 넘는 디렉토리 없음"
fi