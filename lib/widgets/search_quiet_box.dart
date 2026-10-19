import 'package:fitstrong_gym/src/custom_import.dart';

/// Shown in the search screen both before anything is typed and when a query
/// returns nothing. `screen == "empty"` means "searched, found nothing".
class SearchQuietBox extends StatelessWidget {
  const SearchQuietBox({super.key, this.screen});

  final String? screen;

  @override
  Widget build(BuildContext context) {
    final noResults = screen == "empty";
    return AppEmptyState(
      icon: noResults ? Icons.search_off_rounded : Icons.search_rounded,
      title: noResults ? 'No matches' : 'Search members',
      description: noResults
          ? 'Nothing matched that search. Check the spelling, or try just the first few letters of a name.'
          : 'Start typing a name to find a member instantly.',
      // Before a search there is nothing to act on — the field above is the
      // action — so the button only appears once a search came up empty.
      actionLabel: noResults ? 'Clear search' : null,
      onAction: noResults
          ? () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(screen: 'All'),
                ),
              )
          : null,
    );
  }
}
