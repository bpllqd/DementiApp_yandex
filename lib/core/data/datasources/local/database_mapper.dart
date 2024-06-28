class DBMapConverter {
  static Map<String, dynamic> convertTaskForDB(Map<String, dynamic> taskMap) {
    Map<String, dynamic> convertedMap = {};

    taskMap.forEach((key, value) {
      if (value is bool) {
        convertedMap[key] = value ? 1 : 0;
      } else {
        convertedMap[key] = value;
      }
    });

    return convertedMap;
  }

  static Map<String, dynamic> convertTaskFromDB(Map<String, dynamic> taskMap) {
    Map<String, dynamic> convertedMap = {};

    taskMap.forEach((key, value) {
      if (value is int && (value == 0 || value == 1)) {
        convertedMap[key] = value == 1;
      } else {
        convertedMap[key] = value;
      }
    });

    return convertedMap;
  }
}