#!/bin/bash
## 변수 설정, 
## HOST =${hostname}으로 할 시 크론탭이 hostname 못 읽을 수 있어 hostname 파일이 있는 절대 경로의 path로 지정해야함

HOST="$(/usr/bin/hostname)"
LOG="/tmp/backup.log"
PUSH="/vagrant/SHELL/monitor/bot.sh"
DATE="$(/bin/date +%Y.%m.%d)" ## 년.월.일
## 백업할 디렉토리/파일 지정
BAK_LIST="/etc/nginx /usr/share/nginx/html/www"
## 백업 디렉토리
BAK_PATH="/mnt/BACKUP/${HOST}"
## 백업 파일명
BAK_FILE="${BAK_PATH}/${DATE}_${HOST}.tgz"

## 스토리지에 마운트, 필요할 때마다 접속해서 마운트&언마운트 하기
/usr/bin/mount /mnt

## 로그 파일 생성
/usr/bin/touch "${LOG}"

## 백업 디렉토리 확인 (없으면 에러 날 수 있으니 에러 예방)
if [ -e "${BAK_PATH}" ]
then
	## 백업 디렉토리 존재
	/bin/echo "백업 디렉토리 있습니다. 문제 없음."
else
	## 백업 디렉토리 없으니 생성
	/usr/bin/mkdir -p "${BAK_PATH}"
fi

## ****** 로그 기록 시작 - 중과호 안의 내용이 LOG 파일로 저장
{	
	## 백업 시작 시각
	/bin/echo
	/bin/echo "=== 백업 시작 시각: "
	/bin/date
	/bin/echo
    
	## 백업✨✨✨
	/usr/bin/tar czpPf "${BAK_FILE}" ${BAK_LIST}
	
	## 백업 파일 정보
	NAME="$(/usr/bin/ls -al "${BAK_FILE}" | awk '{print $9}')"
	SIZE="$(/usr/bin/ls -al "${BAK_FILE}" | awk '{print $5}')"
	/bin/echo "=== 백업 파일 정보 :"
	/bin/echo " | 파일명: ${NAME}"
	/bin/echo " | 파일크기: ${SIZE}Byte" ## ls로 출력할 때 byte로 뜸
	/bin/echo
	
	## 백업 종료 시각
	/bin/echo
	/bin/echo "=== 백업 종료 시각: "
	/bin/date
	/bin/echo

} >|"${LOG}"
## ***** 로그 기록 끝

## 스토리지에 언마운트
/usr/bin/umount /mnt

## 텔레그램으로 백업 로그를 전송
"${PUSH}" "${HOST}" "$(/usr/bin/cat "${LOG}")"

## 로그 파일 삭제
/usr/bin/rm -f "${LOG}"