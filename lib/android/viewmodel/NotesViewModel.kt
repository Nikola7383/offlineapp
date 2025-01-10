class NotesViewModel(
    private val noteRepository: NoteRepository
) : ViewModel() {

    private val _notes = MutableStateFlow<List<Note>>(emptyList())
    val notes: StateFlow<List<Note>> = _notes.asStateFlow()

    init {
        loadNotes()
    }

    private fun loadNotes() {
        viewModelScope.launch {
            try {
                noteRepository.getAllNotes()
                    .catch { e -> 
                        _error.emit("Failed to load notes: ${e.message}")
                    }
                    .collect { notesList ->
                        _notes.emit(notesList)
                    }
            } catch (e: Exception) {
                _error.emit("Error: ${e.message}")
            }
        }
    }
} 