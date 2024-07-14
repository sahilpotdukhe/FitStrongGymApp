import 'package:fitstrong_gym/src/custom_import.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<MemberModel> memberList = [];
  String query = "";
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    memberProvider.getAllMembers().then((list) {
      setState(() {
        memberList = list;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(searchFocusNode);
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: UniversalVariables.appThemeColor,
        title: TextField(
          style: TextStyle(color: Colors.white),
          controller: searchController,
          focusNode: searchFocusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          onChanged: (val) {
            setState(() {
              query = val;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => searchController.clear());
              setState(() {
                query = "";
              });
            },
          ),
        ],
      ),
      body: query.isEmpty
          ? SearchQuietBox(
              screen: "search",
            )
          : buildSuggestions(query),
    );
  }

  buildSuggestions(String query) {
    final List<MemberModel> suggestionList = query.isEmpty
        ? []
        : memberList.where((MemberModel member) {
            String getName = member.name.toLowerCase();
            String queryLower = query.toLowerCase();
            return getName.contains(queryLower);
          }).toList();

    return suggestionList.isEmpty
        ? SearchQuietBox(
            screen: "empty",
          )
        : ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              MemberModel searchedMember = suggestionList[index];
              return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MemberDetailsPage(member: searchedMember)));
                  },
                  child: MemberCard(member: searchedMember));
            },
          );
  }
}
