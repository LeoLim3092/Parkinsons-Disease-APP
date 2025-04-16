import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:pd_app/prefs/UploadStatus.dart';

typedef UploadFunction = Future<dynamic> Function(String filePath);

void showUploadDialog({
  required BuildContext context,
  required String filePath,
  required UploadFunction uploadFunction,
  required VoidCallback onSuccessNavigation,
  String dialogTitle = "上傳",
  String dialogContent = "請問您是否要上傳這個檔案？",
  String cancelText = "取消",
  String uploadText = "上傳",
}) {
  final uploadStatus = Provider.of<UploadStatus>(context, listen: false);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(dialogTitle, style: const TextStyle(fontSize: 28)),
        content: Text(dialogContent, style: const TextStyle(fontSize: 28)),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText, style: const TextStyle(fontSize: 28)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(uploadText, style: const TextStyle(fontSize: 28)),
            onPressed: () async {
              EasyLoading.show(status: '上傳中');
              var response = await uploadFunction(filePath);
              EasyLoading.dismiss();

              if (response.statusCode == 200) {
                uploadStatus.setUploadLHStatus(true); // Update status if needed
                Navigator.of(context).pop(); // Close the dialog
                // Show success dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("上傳成功", style: TextStyle(fontSize: 28)),
                      content: const Text("進行下一個檢測？", style: TextStyle(fontSize: 28)),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Yes", style: TextStyle(fontSize: 28)),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the success dialog
                            onSuccessNavigation(); // Navigate to the next page
                          },
                        ),
                        TextButton(
                          child: const Text("No", style: TextStyle(fontSize: 20)),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the success dialog
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("上傳失敗，請重試")),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
