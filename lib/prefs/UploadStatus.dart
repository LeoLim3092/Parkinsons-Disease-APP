import 'package:flutter/foundation.dart';


class UploadStatus extends ChangeNotifier {
  bool _isUploadSoundSuccessful = false;
  bool _isUploadGaitSuccessful = false;
  bool _isUploadRHSuccessful = false;
  bool _isUploadLHSuccessful = false;

  bool get isUploadSoundSuccessful => _isUploadSoundSuccessful;
  bool get isUploadGaitSuccessful => _isUploadGaitSuccessful;
  bool get isUploadRHSuccessful => _isUploadRHSuccessful;
  bool get isUploadLHSuccessful => _isUploadLHSuccessful;

  void setUploadSoundStatus(bool status) {
    _isUploadSoundSuccessful = status;
    notifyListeners(); // Notify all it's listeners about the update.
  }
  void setUploadGaitStatus(bool status) {
    _isUploadGaitSuccessful = status;
    notifyListeners(); // Notify all it's listeners about the update.
  }
  void setUploadRHStatus(bool status) {
    _isUploadRHSuccessful = status;
    notifyListeners(); // Notify all it's listeners about the update.
  }
  void setUploadLHStatus(bool status) {
    _isUploadLHSuccessful = status;
    notifyListeners(); // Notify all it's listeners about the update.
  }

// You might have more methods to handle file upload here.
}