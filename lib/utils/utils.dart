import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No Image Selected');
}

// for displaying snackbars
showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

Widget showUsersImage(
  bool isAsset, {
  String picUrl = "assets/user.png",
  double size = 25,
}) {
  if (picUrl == "") {
    picUrl = "assets/user.png";
  }
  return CircleAvatar(
    radius: size,
    backgroundImage: isAsset
        ? AssetImage(picUrl)
        : CachedNetworkImageProvider(picUrl) as ImageProvider,
  );
}
