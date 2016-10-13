```cpp
int vdbeSorterFlushPMA() {
	// Below single thread code    
    for (/* all threads */) {
    	/* Using round-robin scheduling */
        if (pTask->bDone) // if the thread is not running
        	vdbeSorterJoinThread(); // finish thread and collect it
    }
    if (/* All background threads are running*/){
    	vdbeSorterListToPMA(); // Do as foreground (main)
    } else {
    	// Create a thread that is doing vdbeSorterListToPMA()
    	vdbeSorterCreateThread(); // return right after the thread creation
    }
}
```

```cpp
int sqlite3VdbeSorterRewind() {
	// Below in-memory sorting code
    vdbeSorterFlushPMA(); 	// flush last PMA
    vdbeSorterJoinAll();	// wait for all flusher
    vdbeSorterSetupMerge();
}
int vdbePmaReaderIncrInit() {
	vdbeSorterCreateThread(vdbePmaReaderBgIncrInit);
}
```
```cpp
int vdbeIncrSwat() {
	/* wait for a background reader thread */
    SorterFile f0 = aFile[0];  // exhausted file
    aFile[0] = aFile[1];  // swap old and new
    aFile[1] = f0; 	// set for background reader
    vdbeIncrBgPopulate(); // Create background read/write 
}
```