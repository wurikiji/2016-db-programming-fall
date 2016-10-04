## 첨부된 데이터베이스
database.db : 4KB 페이지를 기준으로 생성된 테스트용 데이터베이스
## 쿼리 종류
`test_query`폴더 내부에 존재
`sync숫자_저널모드.sql` 혹은 `sync숫자_저널모드_cp체크포인트.sql`
- 숫자 -> sync/commit 주기 (1, 10, 20)
- 저널모드 -> 저널 종류 (delete, persist, truncate, wal)
- 체크포인트 -> WAL 저널 모드의 autocheckpoint 주기 (100, 1000)

## 성능 측정을 위한 쿼리 수행 방법
*** 쿼리파일 실행 전 항상 `cp` 명령을 통해 복사본 생성 ***
```bash
$> cp database.db test.db  # 복사본 이름은 마음대로 지정가능, 항상 수행
$> time ./sqlite3 test.db < test_query/sync1_delete.sql # 원하는 쿼리 파일 입력
```
수행 후 `real` 에 표시된 시간 기록


## btrace 측정을 위한 쿼리 수행 방법 
> 동일한 터미널에서 btrace와 sqlite3 모두 수행하는법

*** 쿼리파일 실행 전 항상 `cp` 명령을 통해 복사본 생성 ***
```bash
$> cp database.db test.db  # 복사본 이름은 마음대로 지정가능, 항상 수행
$> sync

# 실험 수행전 btrace를 redirection 모드로 동작 (Background 수행)
# /dev/sda는 자신의 장치로 변경
# sync1_delete.btrace 는 각 쿼리파일 별로 겹치지 않도록 이름 변경
# 제일 끝 & 문자 생략하지 않도록 주의 
$> sudo btrace /dev/sda &> sync1_delete.btrace &    # 백그라운드로 btrace 실행
$> ./sqlite3 test.db < test_query/sync10_wal.sql  # 쿼리 파일 수행
$> sudo killall -15 btrace blktrace # -15 빼먹지 않도록 주의
$> sudo grep "D\s\+W\|D\s\+R\|A\s\+F" sync1_delete.btrace > sync1_delete.RWF # 로그파일 가공
$> sudo rm -f sync1_delete.btrace   # 불필요한 로그파일 삭제
$> sudo chown 자신의아이디 sync1_delete.RWF # 분석을 위한 권한 설정

# 이후 sync1_delete.RWF 파일 분석
```
### grep 커맨드의 역할
IO 관련한 정보가 들어있는 btrace 로그 파일에서 write, read, fsync를 이슈한 정보만 출력
- 불필요한 로그 제거 

### btrace 로그 분석하기 
Overview 시간에 함께 소개한 **Using blktrace** 사용법 참조

#### IO 구분하기
`grep` 을 통해 가공된 RWF 로그 파일에서 ***7열*** 의 시작문자에 따라서 IO를 구분
- **W**로 시작: `Write` 요청
- **R**로 시작: `Read` 요청
- **F**로 시작: `fsync` 요청

**각 IO 별로 호출 횟수를 측정해보기**

#### IO 그래프 그리기
가공된 RWF 로그 파일에서 ***8열*** (+ 기호 이전)의 숫자가 IO 발생 주소를 의미
- 해당 정보를 활용하여 각 주소를 그림으로 나타낼 수 있다.

`gnuplot` 패키지가 필요
```bash
$> sudo apt-get install gnuplot # gnuplot 설치
```
첨부된 `trace_analysis.sh` 를 원하는 로그 파일과 함께 실행
```bash
# 그리길 원하는 로그파일을 나열
$> bash trace_analysis.sh sync1_delete.RWF sync10_delete.RWF
```
plot 폴더 내부의 그림파일 확인하기 
- 파일이름_write.jpeg : write 만 그린 파일
- 파일이름_read.jpeg  : Read 만 그린 파일
- 파일이름_fsync.jpeg : fsync 만 그린 파일
- 파일이름.jpeg       : 모든 IO를 한 파일에 그린 파일

#### IO 양 측정하기
가공된 RWF 로그 파일에서 ***10열*** (+ 기호 이후)의 숫자가 read/write 양을 의미
- IO 요청한 양(bytes) = 10열의 숫자 * 512 

양을 구하는 스크립트나 엑셀파일은 직접 작성해보길 권장
- `trace_analysis.sh` 스크립트 내부를 참조
