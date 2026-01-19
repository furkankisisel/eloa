import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/palmistry/palmistry_data.dart';
import '../models/palmistry/palmistry_app_data.dart';
import '../models/palmistry/palmistry_ethics.dart';

class PalmistryService {
  static const String _dataPath = 'assets/data/';

  /// Loads the ethics and principles (File 34)
  Future<EthicsData?> getEthicsData() async {
    try {
      final path = '${_dataPath}34_etik_ve_kullanim_prensipleri.json';
      final content = await rootBundle.loadString(path);
      final jsonMap = json.decode(content) as Map<String, dynamic>;

      return EthicsData.fromJson(jsonMap);
    } catch (e) {
      print('Error loading ethics data: $e');
      return null;
    }
  }

  /// Loads the app category map (File 32)
  Future<AppCategoryMap?> getAppCategoryMap() async {
    try {
      final path = '${_dataPath}32_uygulama_kategori_veri_haritasi.json';
      final content = await rootBundle.loadString(path);
      final jsonMap = json.decode(content) as Map<String, dynamic>;

      return AppCategoryMap.fromJson(jsonMap);
    } catch (e) {
      print('Error loading app category map: $e');
      return null;
    }
  }

  /// Loads the reading rules and fingerprints (File 33)
  Future<ReadingRulesData?> getReadingRules() async {
    try {
      final path = '${_dataPath}33_el_okuma_usulleri_ve_parmak_izleri.json';
      final content = await rootBundle.loadString(path);
      final jsonMap = json.decode(content) as Map<String, dynamic>;

      return ReadingRulesData.fromJson(jsonMap);
    } catch (e) {
      print('Error loading reading rules: $e');
      return null;
    }
  }

  /// Loads all palmistry topics (except manual questions)
  Future<List<PalmistryTopic>> getAllTopics() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);

      final filePaths = manifest.keys
          .where((String key) =>
              key.startsWith(_dataPath) && key.endsWith('.json'))
          .where((String key) => !key.contains('31_manuel_soru_seti'))
          .where((String key) =>
              !key.contains('32_uygulama_kategori_veri_haritasi'))
          .where((String key) =>
              !key.contains('33_el_okuma_usulleri_ve_parmak_izleri'))
          .where(
              (String key) => !key.contains('34_etik_ve_kullanim_prensipleri'))
          .toList();

      // Python's os.listdir sort order might differ, so we might want to sort by number prefix if important.
      // The filenames start with numbers (01_, 02_), so standard sort should work.
      filePaths.sort();

      final List<PalmistryTopic> topics = [];

      for (final path in filePaths) {
        final content = await rootBundle.loadString(path);
        final jsonMap = json.decode(content) as Map<String, dynamic>;

        // Extract filename as ID (remove path and extension)
        final filename = path.split('/').last.replaceAll('.json', '');

        topics.add(PalmistryTopic.customFromJson(filename, jsonMap));
      }

      return topics;
    } catch (e) {
      print('Error loading palmistry topics: $e');
      return [];
    }
  }

  /// Loads the manual questions data
  Future<ManualQuestionsData?> getManualQuestions() async {
    try {
      final path = '${_dataPath}31_manuel_soru_seti.json';
      final content = await rootBundle.loadString(path);
      final jsonMap = json.decode(content) as Map<String, dynamic>;

      return ManualQuestionsData.fromJson(jsonMap);
    } catch (e) {
      print('Error loading manual questions: $e');
      return null;
    }
  }

  /// Loads the synthesis rules and conflict resolutions (File 35)
  Future<PalmistrySynthesisData?> getSynthesisData() async {
    try {
      final path = '${_dataPath}35_kombinasyon_ve_sentez_mantigi.json';
      final content = await rootBundle.loadString(path);
      final jsonMap = json.decode(content) as Map<String, dynamic>;

      return PalmistrySynthesisData.fromJson(jsonMap);
    } catch (e) {
      print('Error loading synthesis data: $e');
      return null;
    }
  }
}
