class MainActivity : AppCompatActivity() {
    private val viewModel: NotesViewModel by viewModels()
    private val adapter = NotesAdapter()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setupRecyclerView()
        observeNotes()
    }

    private fun setupRecyclerView() {
        recyclerView.apply {
            adapter = this@MainActivity.adapter
            layoutManager = LinearLayoutManager(this@MainActivity)
        }
    }

    private fun observeNotes() {
        lifecycleScope.launch {
            viewModel.notes.collect { notes ->
                adapter.submitList(notes)
            }
        }
    }
} 