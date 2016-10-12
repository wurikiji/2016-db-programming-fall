> The I/Os are much more sequential  
> and so runtimes are greatly reduced 
> when the size of the set being sorted is larger

```cpp
case OP_SorterSort:
case OP_Sort: {
	p->aCounter[SQLITE_STMTSTATUS_SORT]++;
	// No "break;" statement
}
case OP_Rewind: {
	if (isSorter()) {
		sqlite3VdbeSorterRewind();
	} else {
		sqlite3BtreeFirst();
	}
	break;
}
```

```cpp
case OP_SorterNext: {
	sqlite3VdbeSorterNext();
}
```

```cpp
/* OP_SorterInsert */
/* Add a record to the sorter */
int sqlite3VdbeSorterWrite() {
	/* Allocate SorterRecord */
	/* Add new SorterRecord to SorterList */
}
/* OP_SorterSort */
/* In-memory merge sort */
int sqlite3VdbeSorterRewind() {
	return vdbeSorterSort();
}
```
```cpp
/* OP_SorterInsert */
/* Add a record to the sorter */
int sqlite3VdbeSorterWrite() {
	if (/* Flush memory is needed */) {
		vdbeSorterFlushPMA();
	}
	/* Allocate SorterRecord */
	/* Add new SorterRecord to SorterList */
}
int vdbeSorterFlushPMA() {
	return vdbeSorterListToPMA();
}
```
```cpp
/* Sort SorterList and make PMA */
/* Flush PMA to a temp file */
int vdbeSorterListToPMA() {
	/* Open temp file if not opened */
	/* Extend temp file size */
	vdbeSorterSort(); // Sort SorterList
	vdbePmaWriteVarint(szPMA); // total size of PMA
	for (/* SorterList */) {
		// Make Record in PMA element format
		vdbePmaWriteVarint(nVal); // size of record
		vdbePmaWriteBlob(/* record */); // real record
	}
	vdbePmaWriterFinish(); // Write PMA to a Atemp file
}
```

```cpp
/* OP_SorterSort */
int sqlite3VdbeSorterRewind () {
	vdbeSorterFlushPMA(); // flush last PMA
	vdbeSorterSetupMerge(); // Setup merge phase
}
int vdbeSorterSetupMerge() {
	// setting compare function 
	// setting MergeEngine
}
```
```cpp
/* OP_SorterNext */
int sqlite3VdbeSorterNext() {
	if (bUsePMA) {	/* Using EMS */
		vdbeMergeEndgineStep(); 
	}
}
int vdbeMergeEngineStep() {
	/* Do External Merge Sort */
	/* Refer to previous slide */
}
```