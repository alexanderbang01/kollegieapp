import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/navigation_menu.dart';
import '../services/news_service.dart';
import '../services/user_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // User data
  String _currentUserId = '';

  // UI state
  bool _showFeaturedOnly = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // News data
  List<Map<String, dynamic>> _news = [];
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Fjernet automatisk scroll-to-load
    // Nu bruger vi kun "Indlæs flere" knappen
  }

  Future<void> _initializeUser() async {
    try {
      final userId = await UserService.getUserId();
      setState(() {
        _currentUserId = userId;
      });
      await _loadNews();
    } catch (e) {
      setState(() {
        _errorMessage = 'Fejl ved indlæsning af brugerdata: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _news.clear();
      });
    }

    setState(() {
      _isLoading = refresh || _currentPage == 1;
      _errorMessage = null;
    });

    try {
      final response = await NewsService.getNews(
        userId: _currentUserId,
        featuredOnly: _showFeaturedOnly,
        page: _currentPage,
        limit: 6, // ÆNDRET: Kun 6 nyheder per side
      );

      if (response['success'] == true) {
        final List<dynamic> newsData = response['data'] ?? [];
        final pagination = response['pagination'];

        setState(() {
          if (refresh || _currentPage == 1) {
            _news = List<Map<String, dynamic>>.from(newsData);
          } else {
            _news.addAll(List<Map<String, dynamic>>.from(newsData));
          }
          _hasMore = pagination['has_next'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Fejl ved indlæsning af nyheder';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Netværksfejl: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await NewsService.getNews(
        userId: _currentUserId,
        featuredOnly: _showFeaturedOnly,
        page: _currentPage,
        limit: 6, // ÆNDRET: Kun 6 nyheder per side
      );

      if (response['success'] == true) {
        final List<dynamic> newsData = response['data'] ?? [];
        final pagination = response['pagination'];

        setState(() {
          _news.addAll(List<Map<String, dynamic>>.from(newsData));
          _hasMore = pagination['has_next'] ?? false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _currentPage--;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _markNewsAsRead(Map<String, dynamic> news) async {
    // Skip hvis allerede læst
    if (news['is_read'] == true) {
      return;
    }

    try {
      final response = await NewsService.markNewsAsRead(
        userId: _currentUserId,
        newsId: news['id'] as int,
      );

      if (response['success'] == true) {
        // Opdater lokalt state
        setState(() {
          final index = _news.indexWhere((n) => n['id'] == news['id']);
          if (index != -1) {
            _news[index]['is_read'] = true;
          }
        });
      }
    } catch (e) {
      // Silent error - fejl skal ikke forstyrre brugeroplevelsen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Nyheder',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.brightness == Brightness.light
            ? theme.colorScheme.primary
            : const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFeaturedOnly ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() {
                _showFeaturedOnly = !_showFeaturedOnly;
              });
              _loadNews(refresh: true);
            },
            tooltip: _showFeaturedOnly
                ? 'Vis alle nyheder'
                : 'Vis kun fremhævede',
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(currentRoute: newsRoute),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Indlæser nyheder...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Der opstod en fejl',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadNews(refresh: true),
              child: const Text('Prøv igen'),
            ),
          ],
        ),
      );
    }

    if (_news.isEmpty) {
      return _buildEmptyState();
    }

    return _buildNewsList();
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => _loadNews(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.newspaper,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ingen nyheder at vise',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _showFeaturedOnly
                        ? 'Ingen fremhævede nyheder findes'
                        : 'Der er ingen nyheder at vise i øjeblikket',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return RefreshIndicator(
      onRefresh: () => _loadNews(refresh: true),
      child: Column(
        children: [
          // Pagination info
          if (_news.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Side $_currentPage',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  Text(
                    '${_news.length} nyheder vist',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),

          // News list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount:
                  _news.length +
                  (_isLoadingMore ? 1 : 0) +
                  (_hasMore && !_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator
                if (index == _news.length && _isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Load more button
                if (index == _news.length && _hasMore && !_isLoadingMore) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _loadMoreNews,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Indlæs flere nyheder'),
                      ),
                    ),
                  );
                }

                final news = _news[index];
                return _buildNewsCard(context, news);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> news) {
    final theme = Theme.of(context);
    final isRead = news['is_read'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isRead
          ? theme.colorScheme.surface.withOpacity(0.5)
          : theme.colorScheme.primary.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Marker som læst FØRST
          await _markNewsAsRead(news);
          // Så vis detaljer
          if (mounted) {
            _showNewsDetails(context, news);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (news['is_featured'])
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Fremhævet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (news['is_recent'])
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // CHECK MARK IKON - kun på nyhedslisten
                  if (isRead)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                    ),
                  Text(
                    _formatDate(news['published_at']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isRead
                          ? Colors.grey.shade500
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news['title'],
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isRead ? Colors.grey.shade600 : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                news['content'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isRead ? Colors.grey.shade500 : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: isRead ? Colors.grey.shade500 : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    news['author'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isRead
                          ? Colors.grey.shade500
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewsDetails(BuildContext context, Map<String, dynamic> news) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  if (news['is_featured'])
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Fremhævet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // INGEN CHECK MARK IKON her i detalje-visningen
                  const Spacer(),
                  Text(
                    _formatDate(news['published_at']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                news['title'],
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Skrevet af ${news['author']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    news['content'],
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);

      final months = [
        'januar',
        'februar',
        'marts',
        'april',
        'maj',
        'juni',
        'juli',
        'august',
        'september',
        'oktober',
        'november',
        'december',
      ];

      return '${date.day}. ${months[date.month - 1]}';
    } catch (e) {
      return dateString;
    }
  }
}
