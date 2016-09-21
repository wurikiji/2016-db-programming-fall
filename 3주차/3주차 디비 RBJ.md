```java
// Attempt to start a new transaction. 
// A write-transaction is started if the second argument is nonzero, otherwise a read transaction.
// A write-transaction must be started before attempting any changes to the database.
//   sqlite3BtreeCreateTable(), sqlite3BtreeCreateIndex(), sqlite3BtreeClearTable(), sqlite3BtreeDropTable()
//   sqlite3BtreeInsert(), sqlite3BtreeDelete(), sqlite3BtreeUpdate()
int sqlite3BtreeBeginTrans(Btree *p, int wrflag){
	// Acquire a lock
}
```

```java
int sqlite3BtreeInsert(...) {
	// Check lock status
    // Write a single page to the rollback journal if database uses RBJ
    sqlite3PagerWrite(); // this function calls pagerAddPageToRollbackJournal()
    // And then change the database
    insertCell();
}n
int sqlite3PagerWrite() {
	// ... 
	return pager_write();
	// ...
}
int pager_write() {
	// open journal and mark page to be dirty
	pager_open_journal();
	sqlite3PcacheMakeDirty();
	// if the page is not a new page then write it to the journal
	pagerAddPageToRollbackJournal();
}
```

```java
// Do two phase commit for database.
// This function is called in a special case.
int sqlite3BtreeCommit(Btree *p) {
	// call phase one and two
	sqlite3BtreeCommitPhaseOne();
	// ...
	sqlite3BtreeCommitPhaseTwo();
}
```

```java
// Flush the rollback journal and flush the updated pages to the disk. 
// Still holding all locks. Transaction is not yet committed. 
int sqlite3BtreeCommitPhaseOne(...) {
	//... call pager to do the flushing
	sqlite3PagerCommitPhaseOne();
}

/* 
** Update the database file change-counter
** Sync the journal file
** Flush all dirty pages to the database file
** Sync the database file
*/
int sqlite3PagerCommitPhaseOne(...) {
	// Check the journal mode
	if ( pagerUseWal(pager) ) {
		// flush all dirty pages to the wal journal
		pagerWalFrames();
	} else {
		// Update page change counter
		pager_incr_changecounter();
		// write the master journal and sync the journal file
		writeMasterJournal();
		syncJournal();
		// flush all dirty pages and sync the database file
		pager_write_pagelist();
		sqlite3PagerSync();
	}
}
```

```java
// Second phase of a 2-phase commit. 
/*
** Delete or truncate or zero the header in the rollback journal
** Drop locks
*/
int sqlite3BtreeCommitPhaseTwo() {
	sqlite3PagerCommitPhaseTwo();
}
int sqlite3PagerCommitPhaseTwo() {
	pager_end_transaction();
}
int pager_end_transaction() {
	// finalize the journal file for each modes
	if ( /* in-memory journal */ ) {
		sqlite3OsClose();
	} else if ( /* Truncate Mode */ ){
		sqlite3OsTruncate();
	} else if ( /* PERSIST Mode */) {
		zeroJournalHdr();
	} else if ( /* Delete Mode */ ) {
		sqlite3OsDelete();
	}
	pagerUnlockDb();
}
```