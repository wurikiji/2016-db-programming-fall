```cpp
/* Page Hit Routine */
static PgHdr1 *pcache1FetchNoMutex() {
	pPage = pCache->apHash[iKey % pCache->nHash];
	while (pPage && pPage->iKey != iKey) {
		pPage = pPage->pNext;
	}
	if (pPage) {
		if (!pPage->isPinned)
			return pcache1PinPage(pPage);
	}
}
static PgHdr1 *pcache1PinPage() {
	/* Pin and Remove from LRU list */
	pPage->pLruPrev->pLruNext = pPage->pLruNext;
	pPage->pLruNext->pLruPrev = pPage->pLruPrev;
	pPage->pLruNext = 0; pPage->pLruPrev = 0;
	pPage->isPinned = 1;
}
```

```cpp
/* Page Miss and Get empty page from pcache */
static PgHdr1 *pcache1FetchNoMutex() {
	return pcache1FetchStage2();
}
static SQLITE_NOINLINE PgHdr1 *pcache1FetchStage2() {
	pPage = pGroup->lru.pLruPrev;
	if (!pPage) {
		pPage = pcache1AllocPage();
	}
}
```


```cpp
/* Flush Dirty LRU */
int sqlite3PagerGet() {
	pBase = sqlite3PcacheFetch();
	if (pBase == 0) {
		sqlite3PcacheFetchStress();
	}
}
static int pagerStress() {
	pager_write_pagelist();
	sqlite3PcacheMakeClean();
}
```

```cpp
/* Pin and Remove from LRU list */
static PgHdr1 *pcache1PinPage() {
	pPage->pLruPrev->pLruNext = pPage->pLruNext;
	pPage->pLruNext->pLruPrev = pPage->pLruPrev;
	pPage->pLruNext = 0; pPage->pLruPrev = 0;
	pPage->isPinned = 1;
}

/* Unpin and Add to LRU list */
static void pcache1Unpin () {
	ppFirst = &pGroup->lru.pLruNext;
	pPage->pLruPrev = &pGroup->lru;
	(pPage->pLruNext = *ppFirst)->pLruPrev= pPage;
	*ppFirst = pPage;
	pPage->isPinned = 0;
}
```

```cpp
/* Add to Dirty LRU list */
int sqlite3PagerWrite() {
	return pager_write();
}
static int pager_write() {
	sqlite3PcacheMakeDirty();
}
SQLITE_PRIVATE void sqlite3PcacheMakeDirty() {
	pcacheManageDirtyList(PCACHE_DIRTYLIST_ADD);
}
/* Delete from Dirty LRU list */
SQLITE_PRIVATE void sqlite3PcacheMakeClean() {
	pcacheManageDirtyList(PCACHE_DIRTYLIST_REMOVE);
	if (p->nRef==0) 
		pcacheUnpin();
}
```

```cpp
static void pcacheManageDirtyList() {
	if (PCACHE_DIRTYLIST_REMOVE) {
		/*
		 * LRU list management codes for pDirty 
		 */
	}
	if (PCACHE_DIRTYLIST_ADD) {
		/*
		 * LRU list management codes for pDirty 
		 */	
	}
}
```