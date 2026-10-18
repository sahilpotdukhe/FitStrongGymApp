import 'dart:typed_data';

import 'package:fitstrong_gym/src/custom_import.dart';
import 'package:image/image.dart' as img;

/// Edit the gym owner's own details: their name and contact information, the
/// logo printed on invoices, their signature, and their UPI payment details.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.userModel});

  final UserModel userModel;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _merchantNameController;
  late TextEditingController _merchantUpiIdController;

  File? _imageFile;
  File? _signatureImageFile;
  bool _isLoading = false;

  /// Both images are printed at a fixed size on the invoice, so they have to
  /// be close to these dimensions or the PDF stretches them.
  static const _logoSize = Size(470, 265);
  static const _signatureSize = Size(340, 270);
  static const int _sizeTolerance = 20;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.name);
    _phoneController =
        TextEditingController(text: widget.userModel.phoneNumber);
    _addressController = TextEditingController(text: widget.userModel.address);
    _merchantNameController =
        TextEditingController(text: widget.userModel.merchantName);
    _merchantUpiIdController =
        TextEditingController(text: widget.userModel.upiId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _merchantNameController.dispose();
    _merchantUpiIdController.dispose();
    super.dispose();
  }

  /// Shared by both pickers: checks the chosen file decodes and is close
  /// enough to [expected], and returns it when it is.
  Future<File?> _pickSizedImage(Size expected) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final File file = File(pickedFile.path);
    final Uint8List imageBytes = await file.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);

    if (!mounted) return null;
    if (image == null) {
      showErrorToast(
        context,
        'Could not read that image',
        description: 'Try a different file.',
      );
      return null;
    }

    final okWidth = (image.width - expected.width).abs() <= _sizeTolerance;
    final okHeight = (image.height - expected.height).abs() <= _sizeTolerance;
    if (!okWidth || !okHeight) {
      showErrorToast(
        context,
        'Wrong image size',
        description: 'Needs to be about '
            '${expected.width.toInt()} × ${expected.height.toInt()} pixels. '
            'That one is ${image.width} × ${image.height}.',
      );
      return null;
    }

    return file;
  }

  Future<void> _pickImage() async {
    final file = await _pickSizedImage(_logoSize);
    if (file != null && mounted) setState(() => _imageFile = file);
  }

  Future<void> _pickSignatureImage() async {
    final file = await _pickSizedImage(_signatureSize);
    if (file != null && mounted) setState(() => _signatureImageFile = file);
  }

  Future<String> _uploadOwnerImage(String path, File file) async {
    final supabase = Supabase.instance.client;
    await supabase.storage.from('fitstrong photos').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    final url = supabase.storage.from('fitstrong photos').getPublicUrl(path);
    // The path is reused on every edit, so a version marker is needed or the
    // image cache keeps serving the previous picture.
    return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String profilePhotoUrl = widget.userModel.profilePhoto;
      String signatureImageUrl = widget.userModel.signatureImageUrl;

      // Keyed on uid alone. Including the owner's name published it in a
      // public URL and orphaned the old file whenever they renamed
      // themselves.
      if (_imageFile != null) {
        profilePhotoUrl = await _uploadOwnerImage(
            'uploads/OwnerPhotos/${widget.userModel.uid}.jpg', _imageFile!);
      }

      if (_signatureImageFile != null) {
        signatureImageUrl = await _uploadOwnerImage(
            'uploads/Signature/${widget.userModel.uid}.jpg',
            _signatureImageFile!);
      }

      UserModel updatedUser = UserModel(
        uid: widget.userModel.uid,
        email: widget.userModel.email,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        profilePhoto: profilePhotoUrl,
        address: _addressController.text,
        signatureImageUrl: signatureImageUrl,
        merchantName: _merchantNameController.text,
        upiId: _merchantUpiIdController.text,
      );

      await AuthMethods().updateUser(updatedUser);

      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

      setState(() => _isLoading = false);
      showSuccessToast(context, 'Profile updated');
      Navigator.popAndPushNamed(context, '/home');
    } catch (_) {
      // An upload that failed used to leave the spinner running forever.
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorDialog(
        context: context,
        title: 'Could not save profile',
        desc: 'Check your connection and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'Edit profile',
          bottomBar: ShadcnButton(
            fullWidth: true,
            size: ShadcnButtonSize.lg,
            loading: _isLoading,
            leading: const Icon(Icons.check_rounded, size: 18),
            onPressed: _updateProfile,
            child: const Text('Save profile'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                ShadcnSpacing.lg,
                ShadcnSpacing.xl,
                ShadcnSpacing.lg,
                ShadcnSpacing.xl2,
              ),
              children: [
                ShadcnText('Branding', variant: ShadcnTextVariant.h4),
                const ShadcnGap(ShadcnSpacing.sm),
                ShadcnText(
                  'These appear on the invoices you give members.',
                  variant: ShadcnTextVariant.muted,
                ),
                const ShadcnGap(ShadcnSpacing.md),
                _ImagePickerCard(
                  title: 'Gym logo',
                  requirement: 'About 470 × 265 pixels',
                  file: _imageFile,
                  currentUrl: widget.userModel.profilePhoto,
                  onPick: _pickImage,
                ),
                const ShadcnGap(ShadcnSpacing.md),
                _ImagePickerCard(
                  title: 'Signature',
                  requirement: 'About 340 × 270 pixels',
                  file: _signatureImageFile,
                  currentUrl: widget.userModel.signatureImageUrl,
                  onPick: _pickSignatureImage,
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                ShadcnText('Your details', variant: ShadcnTextVariant.h4),
                const ShadcnGap(ShadcnSpacing.md),
                ShadcnInput(
                  controller: _nameController,
                  label: 'Gym or owner name',
                  textCapitalization: TextCapitalization.words,
                  leading: const Icon(Icons.person_outline_rounded, size: 18),
                  validator: ShadcnValidators.required('Please enter a name'),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _phoneController,
                  label: 'Phone number',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  leading: const Icon(Icons.phone_outlined, size: 18),
                  validator: ShadcnValidators.combine([
                    ShadcnValidators.required('Please enter a phone number'),
                    ShadcnValidators.pattern(
                      RegExp(r'^[0-9]{10}$'),
                      'Enter a 10 digit phone number',
                    ),
                  ]),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _addressController,
                  label: 'Gym address',
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  validator:
                      ShadcnValidators.required('Please enter an address'),
                ),
                const ShadcnGap(ShadcnSpacing.xl2),
                ShadcnText('Payments', variant: ShadcnTextVariant.h4),
                const ShadcnGap(ShadcnSpacing.sm),
                ShadcnText(
                  'Used to build the UPI QR code members scan to pay you.',
                  variant: ShadcnTextVariant.muted,
                ),
                const ShadcnGap(ShadcnSpacing.md),
                ShadcnInput(
                  controller: _merchantNameController,
                  label: 'Merchant name',
                  leading: const Icon(Icons.storefront_outlined, size: 18),
                  validator: ShadcnValidators.required(
                    'Please enter the merchant name',
                  ),
                ),
                const ShadcnGap(ShadcnSpacing.lg),
                ShadcnInput(
                  controller: _merchantUpiIdController,
                  label: 'UPI ID',
                  placeholder: 'name@bank',
                  leading: const Icon(Icons.qr_code_rounded, size: 18),
                  validator: ShadcnValidators.combine([
                    ShadcnValidators.required('Please enter your UPI ID'),
                    ShadcnValidators.pattern(
                      RegExp(r'^[\w.\-]{2,}@[a-zA-Z]{2,}$'),
                      'A UPI ID looks like name@bank',
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) const AppSavingOverlay(message: 'Saving profile…'),
      ],
    );
  }
}

/// Preview of a branding image with its size requirement and a change
/// button. The requirement used to appear only as an error after picking the
/// wrong file.
class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.title,
    required this.requirement,
    required this.file,
    required this.currentUrl,
    required this.onPick,
  });

  final String title;
  final String requirement;
  final File? file;
  final String currentUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.shadcn;
    return ShadcnCard(
      child: Row(
        children: [
          Container(
            height: 56,
            width: 84,
            decoration: BoxDecoration(
              color: t.muted,
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            clipBehavior: Clip.antiAlias,
            child: file != null
                ? Image.file(file!, fit: BoxFit.cover)
                : currentUrl.trim().isEmpty
                    ? Icon(Icons.image_outlined, color: t.mutedForeground)
                    : CachedNetworkImage(
                        imageUrl: currentUrl,
                        fit: BoxFit.cover,
                        // A pulsing block the size of the thumbnail, so the
                        // row keeps its shape while the photo downloads.
                        placeholder: (context, url) => ShadcnSkeleton(
                          height: double.infinity,
                          borderRadius: BorderRadius.circular(t.radiusMd),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image_outlined,
                          color: t.mutedForeground,
                        ),
                      ),
          ),
          const ShadcnGap(ShadcnSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: t.cardForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  requirement,
                  style: TextStyle(fontSize: 12.5, color: t.mutedForeground),
                ),
              ],
            ),
          ),
          ShadcnButton(
            variant: ShadcnButtonVariant.outline,
            size: ShadcnButtonSize.sm,
            onPressed: onPick,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
