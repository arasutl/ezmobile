class ApiUrls {
  //Main URLs
  static String MainAPIUrl = 'https://eztapi.ezofis.com/api/';
  static String MainUploadUrl = 'https://eztapi.ezofis.com/Uploads';
  static String MainFileViewer = 'https://ezmtrailviewer.azurewebsites.net/web/viewer.html?';
  static String MainFileHTMLViewer = 'https://eztapi.ezofis.com/api/uploadandindex/view';
  static String MainTaskFileViewer = 'https://trial.ezofis.com/docsviewer/index.html?';
  //Folders
  static String sListFolders = 'repository/all';
  static String sBrowseFolders = '/file/browse';
  static String sGetUploadFiles = 'uploadAndIndex/upload/all';
  static String sgetIndexFiles = 'uploadAndIndex/index/all';

  static String sDeleteUploadFiles = 'uploadAndIndex/upload/deleteFiles';
  static String sPostUploadFiles = 'uploadAndIndex/upload';
  static String sPostAutoProcess = 'uploadAndIndex/Upload/setStatus';
  static String sPostOCRforUploadedFile = 'OCR/advancedOCRResult/all';
}
