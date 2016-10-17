Before run `py-tpcc`, **you should re-compile and install python** by yourself. Do samething for original SQLite test and your own SQLite test.  
Please follow this descriptions. 

>(원본 SQLite 테스트 전에도 아래 작업을 먼저 수행해야 하고, 수정된 SQLite 테스트 시에도 아래 작업을 먼저 수행해야 합니다. )

### How To Install SQLite for python

First, install SQLite.
```bash
# on your SQLite source directory
$> make && sudo make install
```

Second download python source codes from [python 2.7](https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz).
And compile and install python

```bash
$> wget https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz
$> tar xvf Python-2.7.12.tgz
$> cd Python-2.7.12
$> ./configure
$> make clean && make && sudo make install
```

If you see the same result through the same command below, then it's done. Version number should be your sqlite version. 
```bash
$> python
>>> import sqlite3
>>> sqlite3.sqlite_version
'3.13.0'
```

Then run `py-tpcc`. Do this installation from `sqlite install` to `python install` for original SQLite test and your SQLite test. 
