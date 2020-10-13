import 'package:photo_manager/photo_manager.dart';

class MediaOption{
  AssetEntity asset;
  bool selected = false;
  int selectedPosition;

  MediaOption({this.asset, this.selected = false});
}