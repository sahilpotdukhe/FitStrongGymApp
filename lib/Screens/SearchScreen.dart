import 'package:fitstrong_gym/src/custom_import.dart';

/// Name search over whichever member list the user came from.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.screen});

  final String screen;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<MemberModel> memberList = [];
  String query = "";
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final Future<List<MemberModel>> source = switch (widget.screen) {
      'All' => memberProvider.getAllMembers(),
      'Active' => memberProvider.fetchActiveMembers(),
      'Expired' => memberProvider.fetchExpiredMembers(),
      _ => memberProvider.fetchRecycleBinMembers(),
    };
    source.then((list) {
      if (!mounted) return;
      setState(() => memberList = list);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(searchFocusNode);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;

    return AppScaffold(
      // Expanded because the app bar lays its title out in a Row — an
      // unbounded text field there would overflow.
      titleWidget: Expanded(
        child: ShadcnInput(
          controller: searchController,
          focusNode: searchFocusNode,
          placeholder: 'Search by name',
          textInputAction: TextInputAction.search,
          leading: const Icon(Icons.search_rounded, size: 18),
          trailing: query.isEmpty
              ? null
              : GestureDetector(
                  onTap: () {
                    searchController.clear();
                    setState(() => query = "");
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: t.mutedForeground,
                  ),
                ),
          onChanged: (val) => setState(() => query = val),
        ),
      ),
      body: query.isEmpty
          ? const SearchQuietBox(screen: "search")
          : buildSuggestions(query),
    );
  }

  Widget buildSuggestions(String query) {
    final queryLower = query.toLowerCase().trim();
    final suggestionList = queryLower.isEmpty
        ? <MemberModel>[]
        : memberList
            .where((member) => member.name.toLowerCase().contains(queryLower))
            .toList();

    if (suggestionList.isEmpty) return const SearchQuietBox(screen: "empty");

    // The recycle bin needs its own card — restore/delete-forever rather than
    // edit/renew — so it keeps a separate list here.
    if (widget.screen == 'RecycleBin') {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          ShadcnSpacing.lg,
          ShadcnSpacing.md,
          ShadcnSpacing.lg,
          ShadcnSpacing.xl4,
        ),
        itemCount: suggestionList.length,
        itemBuilder: (context, index) =>
            RecycleMemberCard(recycleBinMember: suggestionList[index]),
      );
    }

    return MemberListView(
      members: suggestionList,
      empty: const SearchQuietBox(screen: "empty"),
    );
  }
}
