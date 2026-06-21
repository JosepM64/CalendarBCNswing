import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsApiService _apiService = EventsApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Event> _events = [];
  List<EventCategory> _categories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Filtres
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreEvents();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await _apiService.getCategories();
      final events = await _apiService.getEvents(
        startDate: _formatDate(_startDate ?? DateTime.now()),
        category: _selectedCategory,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _categories = categories;
        _events = events;
        _isLoading = false;
        _currentPage = 1;
        _hasMore = events.length >= 20;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final moreEvents = await _apiService.getEvents(
        startDate: _formatDate(_startDate ?? DateTime.now()),
        category: _selectedCategory,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
      );

      setState(() {
        _events.addAll(moreEvents);
        _isLoadingMore = false;
        _hasMore = moreEvents.length >= 20;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _applyFilters() {
    _currentPage = 1;
    _hasMore = true;
    _loadInitialData();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BCN Swing Events'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cercar esdeveniments...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          if (_selectedCategory != null ||
              _startDate != null ||
              _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error carregant esdeveniments',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tornar a provar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Cap esdeveniment trobat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Prova a canviar els filtres o la cerca',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _events.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _events.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final event = _events[index];
          return EventCard(
            event: event,
            onTap: () => _navigateToDetail(event),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        categories: _categories,
        selectedCategory: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        onApply: (category, start, end) {
          setState(() {
            _selectedCategory = category;
            _startDate = start;
            _endDate = end;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<EventCategory> categories;
  final String? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String?, DateTime?, DateTime?) onApply;

  const _FilterSheet({
    required this.categories,
    this.selectedCategory,
    this.startDate,
    this.endDate,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _category;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _start = widget.startDate;
    _end = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filtres',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Categoria
              Text(
                'Categoria',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Totes'),
                    selected: _category == null,
                    onSelected: (selected) {
                      setState(() => _category = null);
                    },
                  ),
                  ...widget.categories.map((cat) {
                    return FilterChip(
                      label: Text(cat.name),
                      selected: _category == cat.slug,
                      onSelected: (selected) {
                        setState(() => _category = selected ? cat.slug : null);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Dates
              Text(
                'Període',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_start != null
                          ? DateFormat('dd/MM/yyyy').format(_start!)
                          : 'Des de'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, false),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_end != null
                          ? DateFormat('dd/MM/yyyy').format(_end!)
                          : 'Fins a'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Botons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _category = null;
                          _start = null;
                          _end = null;
                        });
                      },
                      child: const Text('Netejar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => widget.onApply(_category, _start, _end),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_start ?? DateTime.now())
          : (_end ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }
}
