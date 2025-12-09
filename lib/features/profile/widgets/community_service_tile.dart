import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../business/community_service/entities/community_service.dart';
import '../../../core/theme/brand_colors.dart';

class CommunityServiceTile extends StatefulWidget {
  final CommunityService service;

  const CommunityServiceTile({super.key, required this.service});

  @override
  State<CommunityServiceTile> createState() => _CommunityServiceTileState();
}

class _CommunityServiceTileState extends State<CommunityServiceTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side - Title, Description, Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (bold)
                  Text(
                    widget.service.name,
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description (light grey, 2 lines or expanded)
                  if (widget.service.description.isNotEmpty)
                    Text(
                      widget.service.description,
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),

                  // Date (normal)
                  Text(
                    DateFormat('MMM d, yyyy').format(widget.service.createdAt),
                    style: t.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Right side - Hours circle
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: kHAPrimary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${widget.service.hours}',
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
