class FixDocumentation {
  static const Map<String, String> fixDescriptions = {
    'memory_leaks': '''
    # Memory Leak Fixes
    
    ## Problem
    - Unclosed connections in mesh networking
    - Message queue accumulation
    - Verification cache growth
    
    ## Solution
    1. Implemented proper resource disposal
    2. Added automatic queue cleanup
    3. Introduced cache size limits
    
    ## Verification
    - Memory usage stays under 200MB
    - No connection leaks
    - Queue size remains stable
    ''',

    'race_conditions': '''
    # Race Condition Fixes
    
    ## Problem
    - Concurrent message verification issues
    - Unsynchronized message queue
    - Thread safety issues
    
    ## Solution
    1. Added proper locking mechanism
    2. Implemented queue synchronization
    3. Made verification thread-safe
    
    ## Verification
    - No more verification conflicts
    - Proper message ordering
    - Thread-safe operations
    ''',

    // Ostala dokumentacija...
  };
}
