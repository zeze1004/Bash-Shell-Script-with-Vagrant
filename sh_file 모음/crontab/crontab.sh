# #로그 디렉토리 감시 스크립트
## 정시마다 실행
00 * * * * /vagrant/SHELL/monitor/log_monitor >/dev/null 2>&1

# #디스크 파티션 감시 스크립트
## 30분 마다 실행
30 * * * * /vagrant/SHELL/monitor/partition_monitor.sh >/dev/null
2>&1

## 웹서버 백업
## 새벽 4시마다 백업
00 04 * * * /root/vagrant/SHELL/BACKUP/web_backup.sh >/dev/null 2>&1

## TEST
## 매분마다 실행 결과를 cron_log.sh에 저장
## >>는 덮어쓰기, >만 할 시 출력할 때마다 갱신
# */1 * * * * /vagrant/SHELL/monitor/log_monitor >> /vagrant/SHELL/monitor/cron_log.sh 2>&1
