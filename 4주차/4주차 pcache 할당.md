## pcache1Fetch()는 언제 xFetch()에 할당 되는가
pcach1Fetch()가 할당 시점 같은 경우는 처음 오픈 소스를 접한 모든 분들이 경험할 수 있는 헷갈리고 어려운 부분이므로 모르는게 정상적입니다.

### 함수 포인터를 통한 Dynamic function allocation 
다양한 환경에서 사용되는 프로젝트나 오픈소스 형태의 공개를 통해 다양한 사용자를 타겟으로 하는 프로젝트 들의 경우 **중요한 모듈이나 인터페이스**를 직접 구현하지 않고 **함수 포인터를 통한 인터페이스** 선언만을 한 뒤 나중에 해당 포인터에 필요한 함수를 할당하는 방식을 사용한다. 
이런 방식을 사용할 경우 다른 사용자가 자신만의 함수를 구현하여 소스코드를 고치기 편리하다는 장점이 있다. 
그러나 해당 코드를 처음보는 사용자들에게는 실제 구현된 함수가 어느 것인지를 찾는게 쉽지는 않은 일이다. 

### SQLite에서 pcache 관련 함수들의 할당 시점 
자세한 내용은 직접 구글링을 하면 많이 나올것이라고 생각된다. 
아래는 질문 해주신 학생분에게 보낸 메일 답변 복사본. 

간단하게 설명 드리자면 sqlite 에서 사용하는 pcache 관련 함수들은 `sqlite3_pcache_methods2` 라는 구조체에 함수 포인터로 인터페이스만 정의가 되어있습니다. 
이후 pcache를 초기화 하는 시점에 해당 구조체에 원하는 pcache 구현 함수들을 연결하여 초기화 시키게 됩니다. 
sqlite는 기본적으로 `sqlite3PCacheSetDefault()` 함수가 함수 포인터에 pcache 관련 함수들을 할당하는 역할을 담당하고, 해당 함수 내부에 보시면 pcache1Fetch를 포함한 다양한 pcache 관련 함수들이 연결되고 있음을 확인할 수 있습니다. 
pcache1.c 파일의 `sqlite3PCacheSetDefault()` 를 확인해보시면 됩니다. 기타 다양한 위치에서 pcache 를 초기화 할때 사용될 수 있습니다. 

### 함수 포인터 인터페이스에 연결된 실제 구현 함수 알아내기
실제로 어떤 함수가 인터페이스에 연결되어 있는지 알아보는 방법은 크게 2가지로 나뉘어질 수 있다. 

==소스코드 리딩을 통한 분석==
소스코드에서 xFetch 함수 인터페이스를 가진 structure가 무엇인지 검색한다. string match를 이용해도 좋고 `cscope` 나 `ctags`와 같은 유틸리티를 사용하면 더욱 좋다. 간단히 `sqlite3_pcache_methods2`라는 structure가 해당 인터페이스들을 정리하고 있음을 찾아 낼 수 있다. 
이후에는 같은 방법으로 `sqlite3_pcache_methods2` 구조체를 사용하는 코드들을 모두 검색한뒤 하나하나 살펴보면 된다. 
이러한 방식은 시간이 오래 걸리는 문제점이 있다. 

==GDB 혹은 디버거를 통한 분석==
`-O0 -g` 옵션을 통해 SQLite를 디버깅한다. (2-3주차 강의자료 참고) 
gdb 를 실행시킨후 자신이 분석하길 원하는 함수에 break point를 설정한다. 여기서는 `xFetch()` 함수이다. 이후 SQLite를 실행시키고 `xFetch()`함수에서 멈춘 이후 `step` 명령을 통해 함수 내부로 따라 들어간다. 곧바로 어떤 함수가 호출 됐는지 확인할 수 있다. 

### SQLite에서의 pcache 인터페이스
pcache 를 사용하기 위한 인터페이스 선언은 `sqlite3.h` 파일의 `sqlite3_pcache_methods2`에 있다. 
```cpp
typedef struct sqlite3_pcache_methods2 sqlite3_pcache_methods2;
struct sqlite3_pcache_methods2 {                                                    
  int iVersion;
  void *pArg;
  int (*xInit)(void*);
  void (*xShutdown)(void*);
  sqlite3_pcache *(*xCreate)(int szPage, int szExtra, int bPurgeable);
  void (*xCachesize)(sqlite3_pcache*, int nCachesize);
  int (*xPagecount)(sqlite3_pcache*);
  sqlite3_pcache_page *(*xFetch)(sqlite3_pcache*, unsigned key, int createFlag);
  void (*xUnpin)(sqlite3_pcache*, sqlite3_pcache_page*, int discard);
  void (*xRekey)(sqlite3_pcache*, sqlite3_pcache_page*,
      unsigned oldKey, unsigned newKey);
  void (*xTruncate)(sqlite3_pcache*, unsigned iLimit);
  void (*xDestroy)(sqlite3_pcache*);
  void (*xShrink)(sqlite3_pcache*);
};
```

실제 pcache 관련 함수들을 할당하는 것은 [[SQLite 간단설명]](#SQLite에서-pcache-관련-함수들의-할당-시점)에 언급한 위치에 존재한다. 
```cpp
void sqlite3PCacheSetDefault(void){
  static const sqlite3_pcache_methods2 defaultMethods = {
    1,                       /* iVersion */
    0,                       /* pArg */
    pcache1Init,             /* xInit */
    pcache1Shutdown,         /* xShutdown */
    pcache1Create,           /* xCreate */
    pcache1Cachesize,        /* xCachesize */
    pcache1Pagecount,        /* xPagecount */
    pcache1Fetch,            /* xFetch */
    pcache1Unpin,            /* xUnpin */
    pcache1Rekey,            /* xRekey */
    pcache1Truncate,         /* xTruncate */
    pcache1Destroy,          /* xDestroy */
    pcache1Shrink            /* xShrink */
  };
  sqlite3_config(SQLITE_CONFIG_PCACHE2, &defaultMethods);
}
```
