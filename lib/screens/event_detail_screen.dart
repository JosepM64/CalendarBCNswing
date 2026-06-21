import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Imatge de capçalera
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: () => _launchUrl(context),
              ),
            ],
          ),

          // Contingut
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data i hora
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    title: _formatDateRange(),
                    subtitle: _formatTimeRange(),
                  ),
                  const SizedBox(height: 12),

                  // Lloc
                  if (event.venueName != null)
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      title: event.venueName!,
                      subtitle: [
                        event.venueAddress,
                        event.venueCity,
                      ].where((s) => s != null && s.isNotEmpty).join(', '),
                    ),
                  const SizedBox(height: 12),

                  // Categories
                  if (event.categories.isNotEmpty)
                    _buildInfoRow(
                      context,
                      icon: Icons.category,
                      title: 'Categories',
                      subtitle: event.categoryNames,
                    ),
                  const SizedBox(height: 12),

                  // Preu
                  if (event.cost.isNotEmpty)
                    _buildInfoRow(
                      context,
                      icon: Icons.euro,
                      title: 'Preu',
                      subtitle: event.cost,
                    ),
                  const SizedBox(height: 24),

                  // Descripció
                  Text(
                    'Descripció',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildDescription(context),

                  const SizedBox(height: 24),

                  // Botó obrir al web
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _launchUrl(context),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Obrir al web'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.pink.shade100,
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 80,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon,
      required String title,
      String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final cleanDescription = event.description
        .replaceAll(RegExp(r'<[^>]*>'), '\n')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('\n\n', '\n')
        .trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        cleanDescription,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  String _formatDateRange() {
    final start = event.startDate;
    final end = event.endDate;

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return DateFormat("d 'de' MMMM 'de' y", 'ca').format(start);
    }
    return '${DateFormat("d MMM", 'ca').format(start)} - ${DateFormat("d MMM y", 'ca').format(end)}';
  }

  String _formatTimeRange() {
    final start = event.startDate;
    final end = event.endDate;

    return '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(event.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No es pot obrir l\'enllaç')),
        );
      }
    }
  }
}
