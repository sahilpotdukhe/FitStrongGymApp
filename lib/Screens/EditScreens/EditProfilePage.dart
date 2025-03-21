import 'package:fitstrong_gym/src/custom_import.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel userModel;
  const EditProfilePage({Key? key, required this.userModel}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  File? _imageFile;
  File? _qrImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.name);
    _phoneController =
        TextEditingController(text: widget.userModel.phoneNumber);
    _addressController = TextEditingController(text: widget.userModel.address);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickQrImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _qrImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? profilePhotoUrl = widget.userModel.profilePhoto;
      String? qrImageUrl = widget.userModel.qrImageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('OwnerPhotos')
            .child(widget.userModel.name)
            .child('ProfilePic ${widget.userModel.uid}.jpg');

        await storageRef.putFile(_imageFile!);
        profilePhotoUrl = await storageRef.getDownloadURL();
      }

      if (_qrImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('OwnerPhotos')
            .child(widget.userModel.name)
            .child('QR ${widget.userModel.uid}.jpg');

        await storageRef.putFile(_qrImageFile!);
        qrImageUrl = await storageRef.getDownloadURL();
      }

      UserModel updatedUser = UserModel(
          uid: widget.userModel.uid,
          email: widget.userModel.email,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          profilePhoto: profilePhotoUrl,
          qrImageUrl: qrImageUrl,
          address: _addressController.text,
          signature: widget.userModel.signature);

      await AuthMethods().updateUser(updatedUser);

      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

      setState(() {
        _isLoading = false;
      });

      Navigator.popAndPushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScaleUtils.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.appThemeColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(children: [
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 60 * ScaleUtils.scaleFactor,
                                  child: CircleAvatar(
                                    radius: 54 * ScaleUtils.scaleFactor,
                                    backgroundImage:
                                        AssetImage('assets/user.jpg'),
                                    foregroundImage: _imageFile != null
                                        ? FileImage(_imageFile!)
                                        : NetworkImage(
                                                widget.userModel.profilePhoto)
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 84 * ScaleUtils.verticalScale,
                                  ),
                                  InkWell(
                                    onTap: _pickImage,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: 6 * ScaleUtils.horizontalScale,
                                          top: 8 * ScaleUtils.verticalScale),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: HexColor("3B82F6"),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            8.0 * ScaleUtils.scaleFactor),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 26 * ScaleUtils.scaleFactor,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ]),
                          SizedBox(
                            width: 25,
                          ),
                          Stack(children: [
                            Center(
                              child: GestureDetector(
                                onTap: _pickQrImage,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 60 * ScaleUtils.scaleFactor,
                                  child: CircleAvatar(
                                    radius: 54 * ScaleUtils.scaleFactor,
                                    backgroundImage:
                                        AssetImage('assets/user.jpg'),
                                    foregroundImage: _qrImageFile != null
                                        ? FileImage(_qrImageFile!)
                                        : NetworkImage(
                                                widget.userModel.qrImageUrl)
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 84 * ScaleUtils.verticalScale,
                                  ),
                                  InkWell(
                                    onTap: _pickQrImage,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: 6 * ScaleUtils.horizontalScale,
                                          top: 8 * ScaleUtils.verticalScale),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: HexColor("3B82F6"),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            8.0 * ScaleUtils.scaleFactor),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 26 * ScaleUtils.scaleFactor,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ]),
                        ],
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Name',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Update Your Name',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: HexColor('E5E7EB'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: HexColor('E5E7EB'), width: 2),
                          ),
                          suffixIcon: Icon(
                            Icons.person,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Mobile number',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: 'Update Phone Number',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: HexColor('E5E7EB'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: HexColor('E5E7EB'), width: 2),
                          ),
                          suffixIcon: Icon(
                            Icons.phone_android_outlined,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Address',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Update Address',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(
                            Icons.place,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: HexColor('E5E7EB'), width: 2)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: HexColor('E5E7EB'), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: _updateProfile,
                          child: Text(
                            'Update Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
