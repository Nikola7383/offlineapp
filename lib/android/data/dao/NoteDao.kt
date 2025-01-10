class NoteDao {
    private val database: SQLiteDatabase
    private val logger: LoggerService

    // Konstante
    companion object {
        const val TABLE_NOTES = "notes"
        const val COLUMN_ID = "id"
        const val COLUMN_TITLE = "title"
        const val COLUMN_CONTENT = "content"
        const val COLUMN_TIMESTAMP = "timestamp"
    }

    suspend fun getAllNotes(): Flow<List<Note>> = flow {
        try {
            val cursor = database.query(
                TABLE_NOTES,
                null,
                null,
                null,
                null,
                null,
                "$COLUMN_TIMESTAMP DESC"
            )

            cursor.use { c ->
                val notes = mutableListOf<Note>()
                while (c.moveToNext()) {
                    notes.add(Note(
                        id = c.getLong(c.getColumnIndexOrThrow(COLUMN_ID)),
                        title = c.getString(c.getColumnIndexOrThrow(COLUMN_TITLE)),
                        content = c.getString(c.getColumnIndexOrThrow(COLUMN_CONTENT)),
                        timestamp = c.getLong(c.getColumnIndexOrThrow(COLUMN_TIMESTAMP))
                    ))
                }
                emit(notes)
            }
        } catch (e: Exception) {
            logger.error("Error getting notes: $e")
            throw DatabaseException("Failed to get notes", e)
        }
    }
} 