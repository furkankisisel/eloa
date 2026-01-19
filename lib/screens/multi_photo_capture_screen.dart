import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_camera_picker.dart';
import '../providers/analysis_provider.dart';
import '../models/analysis_category.dart';
import '../services/ai_analysis_service.dart';
import 'ai_result_screen.dart';

/// Çoklu fotoğraf çekimi için tanımlar
class PhotoSlot {
  final String id;
  final String title;
  final String description;
  final String detailedInstruction;
  final IconData icon;
  final bool isPalmInside; // true = avuç içi, false = el sırtı
  final String? guideImagePath; // Rehber görsel yolu
  File? image;

  PhotoSlot({
    required this.id,
    required this.title,
    required this.description,
    required this.detailedInstruction,
    required this.icon,
    this.isPalmInside = true,
    this.guideImagePath,
    this.image,
  });

  bool get hasImage => image != null;
}

/// Kategoriye göre fotoğraf slotlarını döndüren yardımcı sınıf
class CategoryPhotoSlots {
  static List<PhotoSlot> getSlots(AnalysisCategory category) {
    switch (category) {
      // --- AŞK VE İLİŞKİLER ---
      case AnalysisCategory.loveGeneral:
        return [
          PhotoSlot(
            id: 'heart_line',
            title: 'Kalp Çizgisi',
            description:
                'Avuç içinizin üst kısmındaki kalp çizgisine odaklanın',
            detailedInstruction:
                '📍 Avuç içinizi açın ve kameraya doğru tutun.\n💕 Serçe parmağının altından başlayıp işaret parmağına doğru uzanan kalp çizginizi net görecek şekilde yakın çekim yapın.',
            icon: Icons.favorite,
            guideImagePath: 'assets/illustrations/heart_line.png',
          ),
          PhotoSlot(
            id: 'venus_mount',
            title: 'Venüs Tepesi',
            description: 'Başparmağın altındaki yuvarlak tepe',
            detailedInstruction:
                '📍 Başparmağınızın hemen altındaki etli, yuvarlak bölgeye odaklanın.\n💗 Bu Venüs tepesidir - aşk ve tutku enerjinizi gösterir. Tepenin kabarıklığını net görecek şekilde açılı çekim yapın.',
            icon: Icons.circle,
            guideImagePath: 'assets/illustrations/venus_mount.png',
          ),
          PhotoSlot(
            id: 'marriage_lines',
            title: 'Evlilik Çizgileri',
            description: 'Serçe parmağının altındaki kısa yatay çizgiler',
            detailedInstruction:
                '📍 Serçe parmağınızın hemen altına, elin kenarına yakın çekim yapın.\n💍 Buradaki küçük yatay çizgiler evlilik ve önemli ilişkileri gösterir. Çok yakın çekim gerekir!',
            icon: Icons.linear_scale,
            guideImagePath: 'assets/illustrations/marriage_line.png',
          ),
          PhotoSlot(
            id: 'palm_full',
            title: 'Avuç İçi Genel',
            description: 'Tüm avuç içinizi görünecek şekilde',
            detailedInstruction:
                '📍 Elinizi tamamen açın ve avuç içinizin tamamını çekin.\n✨ Tüm çizgilerin birlikte görünmesi genel değerlendirme için önemlidir.',
            icon: Icons.back_hand,
            guideImagePath: 'assets/illustrations/life.png',
          ),
        ];

      case AnalysisCategory.marriage:
        return [
          PhotoSlot(
            id: 'marriage_lines_close',
            title: 'Evlilik Çizgileri (Yakın)',
            description: 'Serçe parmağı altındaki kısa yatay çizgiler',
            detailedInstruction:
                '📍 Serçe parmağınızın hemen altında, kalp çizgisi ile parmak arasındaki küçük yatay çizgilere çok yakın çekim yapın.\n💒 Bu çizgiler evlilik sayısını ve zamanlamasını gösterir.',
            icon: Icons.diamond,
            guideImagePath: 'assets/illustrations/marriage_line.png',
          ),
          PhotoSlot(
            id: 'heart_line',
            title: 'Kalp Çizgisi',
            description: 'Duygusal bağlanma stiliniz',
            detailedInstruction:
                '📍 Avuç içinizin üst kısmındaki en belirgin çizgiye odaklanın.\n💕 Kalp çizgisinin şekli, derinliği ve nerede bittiği evlilik uyumunuzu gösterir.',
            icon: Icons.favorite,
            guideImagePath: 'assets/illustrations/heart_line.png',
          ),
          PhotoSlot(
            id: 'venus_mount',
            title: 'Venüs Tepesi',
            description: 'Aşk enerjinizi gösteren tepe',
            detailedInstruction:
                '📍 Başparmağın altındaki etli bölgeyi yandan çekin.\n💗 Tepenin dolgunluğu ve üzerindeki çizgiler ilişki tutkunuzu gösterir.',
            icon: Icons.circle,
            guideImagePath: 'assets/illustrations/venus_mount.png',
          ),
          PhotoSlot(
            id: 'ring_finger_area',
            title: 'Yüzük Parmağı Bölgesi',
            description: 'Güneş tepesi ve çevresi',
            detailedInstruction:
                '📍 Yüzük parmağınızın altındaki bölgeye odaklanın.\n☀️ Bu bölge evlilikte mutluluk ve uyumu gösterir.',
            icon: Icons.sunny,
            guideImagePath: 'assets/illustrations/sun_mount.png',
          ),
        ];

      case AnalysisCategory.children:
        return [
          PhotoSlot(
            id: 'children_lines',
            title: 'Çocuk Çizgileri',
            description: 'Başparmağın altındaki yatay çizgiler',
            detailedInstruction:
                '📍 Başparmağın altına çok yakın çekim yapın.\n👶 Evlilik çizgilerinin üzerinden dikey olarak yükselen ince çizgileri arayın. Bu çizgiler çocuk potansiyelini gösterir.',
            icon: Icons.child_care,
            guideImagePath: 'assets/illustrations/children_line.png',
          ),
          PhotoSlot(
            id: 'marriage_and_children',
            title: 'Evlilik & Çocuk Bölgesi',
            description: 'Tüm bölgenin genel görünümü',
            detailedInstruction:
                '📍 Serçe parmağı altından avuç kenarına kadar olan bölgeyi çekin.\n👨‍👩‍👧 Çizgilerin birbirleriyle ilişkisini görmek için biraz uzaktan çekin.',
            icon: Icons.family_restroom,
            guideImagePath: 'assets/illustrations/marriage_line.png',
          ),
          PhotoSlot(
            id: 'venus_mount',
            title: 'Venüs Tepesi',
            description: 'Doğurganlık ve aile enerjisi',
            detailedInstruction:
                '📍 Başparmağın altındaki dolgun bölgeyi çekin.\n💗 Venüs tepesinin durumu aile kurma potansiyelinizi gösterir.',
            icon: Icons.favorite,
            guideImagePath: 'assets/illustrations/venus_mount.png',
          ),
        ];

      case AnalysisCategory.passion:
        return [
          PhotoSlot(
            id: 'venus_ring',
            title: 'Venüs Halkası',
            description: 'İşaret ve orta parmak arasındaki yay',
            detailedInstruction:
                '📍 İşaret ve orta parmağın arasından başlayan, yay şeklinde bir çizgi arayın.\n🔥 Bu nadir çizgi yoğun tutku ve çekiciliği gösterir.',
            icon: Icons.local_fire_department,
            guideImagePath: 'assets/illustrations/venus_ring.png',
          ),
          PhotoSlot(
            id: 'venus_mount_close',
            title: 'Venüs Tepesi (Yakın)',
            description: 'Tutku ve cinsellik enerjisi',
            detailedInstruction:
                '📍 Başparmağın altındaki etli bölgeye çok yakın çekim yapın.\n💋 Tepenin dolgunluğu, kırmızılığı ve üzerindeki çizgiler tutkunuzu gösterir.',
            icon: Icons.whatshot,
            guideImagePath: 'assets/illustrations/venus_mount.png',
          ),
          PhotoSlot(
            id: 'heart_line_depth',
            title: 'Kalp Çizgisi Derinliği',
            description: 'Duygusal yoğunluğunuz',
            detailedInstruction:
                '📍 Kalp çizgisine yakın çekim yaparak derinliğini ve rengini gösterin.\n❤️ Derin ve kırmızı çizgi yoğun tutkuyu gösterir.',
            icon: Icons.favorite,
            guideImagePath: 'assets/illustrations/heart_line.png',
          ),
          PhotoSlot(
            id: 'mars_mount',
            title: 'Mars Tepesi',
            description: 'Başparmak ile işaret parmağı arası',
            detailedInstruction:
                '📍 Başparmak ile işaret parmağı arasındaki bölgeye odaklanın.\n⚔️ Bu bölge cinsel enerji ve saldırganlığı gösterir.',
            icon: Icons.shield,
            guideImagePath: 'assets/illustrations/mars_mount.png',
          ),
        ];

      // --- ZENGİNLİK VE KARİYER ---
      case AnalysisCategory.wealth:
        return [
          PhotoSlot(
            id: 'money_triangle',
            title: 'Para Üçgeni',
            description: 'Kader, kafa ve sağlık çizgilerinin kesişimi',
            detailedInstruction:
                '📍 Avuç ortasına odaklanın ve çizgilerin oluşturduğu üçgeni arayın.\n💰 Kader çizgisi, kafa çizgisi ve sağlık çizgisinin oluşturduğu üçgen zenginlik potansiyelinizi gösterir.',
            icon: Icons.change_history,
            guideImagePath: 'assets/illustrations/money_triangle.png',
          ),
          PhotoSlot(
            id: 'fate_line',
            title: 'Kader Çizgisi',
            description: 'Bilekten orta parmağa uzanan dikey çizgi',
            detailedInstruction:
                '📍 Avuç içinizin ortasından dikey olarak yukarı çıkan çizgiyi bulun.\n📈 Bu çizgi kariyer başarınızı ve maddi durumunuzu gösterir.',
            icon: Icons.trending_up,
            guideImagePath: 'assets/illustrations/fate_line.png',
          ),
          PhotoSlot(
            id: 'sun_line',
            title: 'Güneş Çizgisi',
            description: 'Yüzük parmağına doğru uzanan çizgi',
            detailedInstruction:
                '📍 Yüzük parmağının altına doğru uzanan dikey çizgiyi arayın.\n☀️ Başarı ve şöhret çizgisi olarak da bilinir. Maddi bolluk getirir.',
            icon: Icons.sunny,
            guideImagePath: 'assets/illustrations/sun_line.png',
          ),
          PhotoSlot(
            id: 'jupiter_mount',
            title: 'Jüpiter Tepesi',
            description: 'İşaret parmağının altındaki tepe',
            detailedInstruction:
                '📍 İşaret parmağınızın hemen altındaki bölgeye odaklanın.\n👑 Liderlik ve başarı potansiyelinizi gösterir.',
            icon: Icons.star,
            guideImagePath: 'assets/illustrations/jupiter_mount.png',
          ),
        ];

      case AnalysisCategory.career:
        return [
          PhotoSlot(
            id: 'fate_line_full',
            title: 'Kader Çizgisi (Tam)',
            description: 'Bilekten başlayıp yukarı uzanan',
            detailedInstruction:
                '📍 Avuç içinizi tam açın ve ortadaki dikey çizgiyi net gösterin.\n🎯 Kader çizgisinin başlangıcı, gidişatı ve bitişi kariyer yolculuğunuzu anlatır.',
            icon: Icons.work,
            guideImagePath: 'assets/illustrations/fate_line.png',
          ),
          PhotoSlot(
            id: 'head_line',
            title: 'Kafa Çizgisi',
            description: 'Zeka ve iş zekası',
            detailedInstruction:
                '📍 Avuç içinizin ortasında yatay uzanan ikinci ana çizgiye odaklanın.\n🧠 Düşünce yapınız ve iş stratejilerinizi gösterir.',
            icon: Icons.psychology,
            guideImagePath: 'assets/illustrations/head_line.png',
          ),
          PhotoSlot(
            id: 'mercury_mount',
            title: 'Merkür Tepesi',
            description: 'Serçe parmağının altındaki tepe',
            detailedInstruction:
                '📍 Serçe parmağının altındaki bölgeyi çekin.\n💼 İletişim, ticaret ve iş yeteneklerinizi gösterir.',
            icon: Icons.business,
            guideImagePath: 'assets/illustrations/mercur_mount.png',
          ),
          PhotoSlot(
            id: 'palm_full',
            title: 'Avuç İçi Genel',
            description: 'Tüm kariyer çizgilerinin görünümü',
            detailedInstruction:
                '📍 Elinizi tamamen açın ve avuç içinizin tamamını çekin.\n✨ Tüm kariyer çizgilerinin birlikte değerlendirilmesi için.',
            icon: Icons.back_hand,
            guideImagePath: 'assets/illustrations/life.png',
          ),
        ];

      case AnalysisCategory.fame:
        return [
          PhotoSlot(
            id: 'sun_line_close',
            title: 'Güneş Çizgisi (Yakın)',
            description: 'Şöhret ve başarı çizgisi',
            detailedInstruction:
                '📍 Yüzük parmağının altına doğru uzanan dikey çizgiyi yakından çekin.\n⭐ Güneş çizgisi şöhret, tanınırlık ve sanatsal başarıyı gösterir.',
            icon: Icons.star,
            guideImagePath: 'assets/illustrations/sun_line.png',
          ),
          PhotoSlot(
            id: 'apollo_mount',
            title: 'Apollo (Güneş) Tepesi',
            description: 'Yüzük parmağı altındaki tepe',
            detailedInstruction:
                '📍 Yüzük parmağının hemen altındaki kabarık bölgeye odaklanın.\n🌟 Yaratıcılık, sanat ve ün potansiyelinizi gösterir.',
            icon: Icons.wb_sunny,
            guideImagePath: 'assets/illustrations/sun_mount.png',
          ),
          PhotoSlot(
            id: 'jupiter_mount',
            title: 'Jüpiter Tepesi',
            description: 'Liderlik ve hırs',
            detailedInstruction:
                '📍 İşaret parmağının altındaki tepeyi çekin.\n👑 Liderlik kabiliyetiniz ve hırsınızı gösterir.',
            icon: Icons.emoji_events,
            guideImagePath: 'assets/illustrations/jupiter_mount.png',
          ),
          PhotoSlot(
            id: 'fate_line',
            title: 'Kader Çizgisi',
            description: 'Başarıya giden yol',
            detailedInstruction:
                '📍 Avuç ortasındaki dikey çizgiyi gösterin.\n📈 Kader çizgisinin güneş tepesine ulaşması büyük başarı işaretidir.',
            icon: Icons.trending_up,
            guideImagePath: 'assets/illustrations/fate_line.png',
          ),
        ];

      // --- GİZEM VE TEHLİKE ---
      case AnalysisCategory.danger:
        return [
          PhotoSlot(
            id: 'obstacle_lines',
            title: 'Engel Çizgileri',
            description: 'Ana çizgileri kesen yatay çizgiler',
            detailedInstruction:
                '📍 Avuç içinizin tamamını kapsamaya odaklanın.\n⚠️ Bu çizgiler hayatınızdaki engelleri ve düşmanları gösterir.',
            icon: Icons.warning,
            guideImagePath: 'assets/illustrations/life.png',
          ),
          PhotoSlot(
            id: 'mars_plain',
            title: 'Mars Ovası',
            description: 'Avuç içinin orta bölgesi',
            detailedInstruction:
                '📍 Avuç içinizin tam ortasındaki çukur bölgeyi çekin.\n🛡️ Buradaki işaretler mücadele ve tehlikeleri gösterir.',
            icon: Icons.shield,
            guideImagePath: 'assets/illustrations/mars_mount.png',
          ),
          PhotoSlot(
            id: 'life_line_breaks',
            title: 'Hayat Çizgisi Detayı',
            description: 'Kırılmalar ve ada işaretleri',
            detailedInstruction:
                '📍 Başparmağı çevreleyen hayat çizgisine çok yakın çekim yapın.\n🔍 Çizgideki kırıklar, adacıklar veya kesintileri arayın.',
            icon: Icons.remove_red_eye,
            guideImagePath: 'assets/illustrations/life.png',
          ),
          PhotoSlot(
            id: 'saturn_mount',
            title: 'Satürn Tepesi',
            description: 'Orta parmağın altındaki bölge',
            detailedInstruction:
                '📍 Orta parmağın altındaki tepeyi çekin.\n🌑 Buradaki işaretler zorluklar ve sınavları gösterir.',
            icon: Icons.nights_stay,
            guideImagePath: 'assets/illustrations/saturn_mount.png',
          ),
        ];

      case AnalysisCategory.mystic:
        return [
          PhotoSlot(
            id: 'mystic_cross',
            title: 'Mistik Haç',
            description: 'Kafa ve kalp çizgisi arasındaki X işareti',
            detailedInstruction:
                '📍 Akıl çizgisi ile kalp çizgisi arasındaki bölgede X veya + şekli arayın.\n🔮 Mistik haç güçlü sezgisel yetenekleri gösterir.',
            icon: Icons.add,
            guideImagePath:
                'assets/illustrations/between_headline_and_heartline.png',
          ),
          PhotoSlot(
            id: 'intuition_line',
            title: 'Sezgi Çizgisi',
            description: 'Ay tepesinden Merkür tepesine uzanan yay',
            detailedInstruction:
                '📍 Avuç kenarında, serçe parmağı altından bileğe doğru kavisli bir çizgi arayın.\n🌙 Bu çizgi güçlü önsezi ve medyumluğu gösterir.',
            icon: Icons.visibility,
            guideImagePath: 'assets/illustrations/intuition_line.png',
          ),
          PhotoSlot(
            id: 'moon_mount',
            title: 'Ay Tepesi',
            description: 'Avuç kenarının alt kısmı',
            detailedInstruction:
                '📍 Avuç içinizin kenarında, bilek yakınındaki kabarık bölgeyi çekin.\n🌙 Hayal gücü ve ruhani yetenekleri gösterir.',
            icon: Icons.nightlight_round,
            guideImagePath: 'assets/illustrations/moon_mount.png',
          ),
          PhotoSlot(
            id: 'ring_of_solomon',
            title: 'Süleyman Yüzüğü',
            description: 'İşaret parmağını çevreleyen yarım daire',
            detailedInstruction:
                '📍 İşaret parmağının dibinde yarım daire şeklinde bir çizgi arayın.\n👁️ Bu nadir işaret güçlü sezgi ve bilgeliği gösterir.',
            icon: Icons.radio_button_unchecked,
            guideImagePath: 'assets/illustrations/jupiter_mount.png',
          ),
        ];

      case AnalysisCategory.travel:
        return [
          PhotoSlot(
            id: 'travel_lines',
            title: 'Seyahat Çizgileri',
            description: 'Hayat çizgisinden dışa uzanan çizgiler',
            detailedInstruction:
                '📍 Hayat çizgisinin alt kısmından elin kenarına doğru uzanan yatay çizgileri bulun.\n✈️ Bu çizgiler önemli seyahatleri ve yer değişikliklerini gösterir.',
            icon: Icons.flight,
            guideImagePath: 'assets/illustrations/travel_line.png',
          ),
          PhotoSlot(
            id: 'moon_mount',
            title: 'Ay Tepesi',
            description: 'Yurt dışı ve uzun yolculuklar',
            detailedInstruction:
                '📍 Avuç kenarının alt kısmındaki tepeyi çekin.\n🌍 Buradaki çizgiler yurt dışı bağlantılarını gösterir.',
            icon: Icons.public,
            guideImagePath: 'assets/illustrations/moon_mount.png',
          ),
          PhotoSlot(
            id: 'life_line_branches',
            title: 'Hayat Çizgisi Dalları',
            description: 'Çizgiden ayrılan kollar',
            detailedInstruction:
                '📍 Hayat çizgisine yakın çekim yapın ve dallanmaları gösterin.\n🗺️ Aşağı doğru dallar göç potansiyelini gösterir.',
            icon: Icons.alt_route,
            guideImagePath: 'assets/illustrations/life.png',
          ),
        ];

      // --- SAĞLIK VE KARAKTER ---
      case AnalysisCategory.health:
        return [
          PhotoSlot(
            id: 'life_line_full',
            title: 'Hayat Çizgisi (Tam)',
            description: 'Enerji ve yaşam gücünüz',
            detailedInstruction:
                '📍 Başparmağı çevreleyen büyük kavisli çizgiyi tam olarak gösterin.\n❤️ Hayat çizgisinin uzunluğu, derinliği ve rengi sağlığınızı yansıtır.',
            icon: Icons.favorite,
            guideImagePath: 'assets/illustrations/life.png',
          ),
          PhotoSlot(
            id: 'health_line',
            title: 'Sağlık Çizgisi',
            description: 'Serçe parmağından bileğe uzanan çizgi',
            detailedInstruction:
                '📍 Serçe parmağı altından bileğe doğru uzanan çizgiyi arayın.\n💊 Bu çizgi sindirim, sinir sistemi ve genel sağlığı gösterir.',
            icon: Icons.medical_services,
            guideImagePath: 'assets/illustrations/health_line.png',
          ),
          PhotoSlot(
            id: 'nails_and_fingers',
            title: 'Tırnaklar ve Parmaklar',
            description: 'El sırtından parmak uçları',
            detailedInstruction:
                '📍 EL SIRTI - Parmaklarınızı düz tutup el sırtından çekin.\n💅 Tırnak şekilleri ve renkleri sağlık göstergeleridir.',
            icon: Icons.pan_tool,
            isPalmInside: false,
            guideImagePath: null,
          ),
          PhotoSlot(
            id: 'heart_line_health',
            title: 'Kalp Çizgisi (Sağlık)',
            description: 'Kalp ve dolaşım sağlığı',
            detailedInstruction:
                '📍 Kalp çizgisine yakın çekim yapın.\n💓 Zincir şekli, adacıklar kalp-damar sağlığını gösterir.',
            icon: Icons.monitor_heart,
            guideImagePath: 'assets/illustrations/heart_line.png',
          ),
        ];

      case AnalysisCategory.character:
        return [
          PhotoSlot(
            id: 'head_line_full',
            title: 'Kafa Çizgisi (Tam)',
            description: 'Düşünce yapınız ve zekanız',
            detailedInstruction:
                '📍 Avuç ortasında yatay uzanan kafa çizgisini tam gösterin.\n🧠 Çizginin uzunluğu, eğimi ve şekli zeka tipinizi gösterir.',
            icon: Icons.psychology,
            guideImagePath: 'assets/illustrations/head_line.png',
          ),
          PhotoSlot(
            id: 'finger_shapes',
            title: 'Parmak Şekilleri',
            description: 'Parmak uçları ve boğumlar',
            detailedInstruction:
                '📍 EL SIRTI - Parmaklarınızı açık tutup el sırtından çekin.\n🖐️ Parmak şekilleri (sivri, kare, spatül) kişiliğinizi gösterir.',
            icon: Icons.back_hand,
            isPalmInside: false,
            guideImagePath: null,
          ),
          PhotoSlot(
            id: 'thumb_detail',
            title: 'Başparmak Detayı',
            description: 'İrade gücü ve mantık',
            detailedInstruction:
                '📍 Başparmağınızı yandan çekin.\n👍 Başparmağın uzunluğu, açısı ve şekli irade gücünüzü gösterir.',
            icon: Icons.thumb_up,
            guideImagePath: null,
          ),
          PhotoSlot(
            id: 'palm_shape',
            title: 'El Şekli',
            description: 'Genel el yapısı',
            detailedInstruction:
                '📍 Elinizi tamamen açın ve avuç şeklini gösterin.\n✋ Kare, dikdörtgen veya uzun avuç - temel kişiliğinizi belirler.',
            icon: Icons.pan_tool,
            guideImagePath: null,
          ),
        ];

      // --- TAM ANALİZ ---
      case AnalysisCategory.full:
        return [
          PhotoSlot(
            id: 'palm_full',
            title: 'Avuç İçi (Tam)',
            description: 'Tüm avuç içinizi net gösterin',
            detailedInstruction:
                '📍 Elinizi tamamen açın, parmakları ayırın ve avuç içinizin tamamını çekin.\n✨ İyi aydınlatmada, net ve odaklanmış bir fotoğraf çekin.',
            icon: Icons.back_hand,
            guideImagePath: null,
          ),
          PhotoSlot(
            id: 'main_lines',
            title: 'Ana Çizgiler',
            description: 'Kalp, kafa ve hayat çizgileri',
            detailedInstruction:
                '📍 Avuç içinizin ortasına yakın çekim yapın.\n📜 Üç ana çizgiyi (kalp, kafa, hayat) net görecek şekilde.',
            icon: Icons.linear_scale,
            guideImagePath: null,
          ),
          PhotoSlot(
            id: 'secondary_lines',
            title: 'İkincil Çizgiler',
            description: 'Kader, güneş ve evlilik çizgileri',
            detailedInstruction:
                '📍 Avuç ortasından parmak altlarına kadar olan bölgeyi çekin.\n🌟 Dikey çizgiler ve parmak altı bölgelere odaklanın.',
            icon: Icons.auto_awesome,
            guideImagePath: null,
          ),
          PhotoSlot(
            id: 'fingers_back',
            title: 'Parmaklar (Sırt)',
            description: 'El sırtından parmaklar',
            detailedInstruction:
                '📍 EL SIRTI - Parmaklarınızı açıp el sırtından çekin.\n🖐️ Parmak uzunlukları, boğumlar ve tırnak şekillerini gösterin.',
            icon: Icons.pan_tool,
            isPalmInside: false,
            guideImagePath: null,
          ),
        ];
    }
  }
}

/// Birden fazla fotoğraf çekip analiz eden ekran
class MultiPhotoCaptureScreen extends StatefulWidget {
  const MultiPhotoCaptureScreen({super.key});

  @override
  State<MultiPhotoCaptureScreen> createState() =>
      _MultiPhotoCaptureScreenState();
}

class _MultiPhotoCaptureScreenState extends State<MultiPhotoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  String? _errorMessage;
  int _currentStep = 0;
  bool _slotsInitialized = false;

  late List<PhotoSlot> _photoSlots;
  late AnalysisCategory _category;

  @override
  void initState() {
    super.initState();
    // Slotlar didChangeDependencies'de yüklenecek
    _photoSlots = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_slotsInitialized) {
      final analysis = context.read<AnalysisProvider>();
      _category = analysis.selectedCategory ?? AnalysisCategory.full;
      _photoSlots = CategoryPhotoSlots.getSlots(_category);
      _slotsInitialized = true;
    }
  }

  int get _completedPhotos => _photoSlots.where((s) => s.hasImage).length;
  bool get _hasMinimumPhotos =>
      _completedPhotos >= 2; // En az 2 fotoğraf gerekli
  bool get _allPhotosComplete => _completedPhotos == _photoSlots.length;

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AnalysisProvider>();
    final category = analysis.selectedCategory ?? AnalysisCategory.full;
    final handType = analysis.selectedHandIndex == 0 ? 'Sol' : 'Sağ';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.questionTitle} - Detaylı Çekim'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressBar(colorScheme),

            Expanded(
              child: _isAnalyzing
                  ? _buildAnalyzingView(colorScheme)
                  : _buildPhotoCapture(colorScheme, handType),
            ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            // Bottom actions
            if (!_isAnalyzing)
              _buildBottomActions(analysis, category, handType, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Fotoğraf: $_completedPhotos / ${_photoSlots.length}',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_hasMinimumPhotos)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ Analiz için yeterli',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _completedPhotos / _photoSlots.length,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _allPhotosComplete ? Colors.green : colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCapture(ColorScheme colorScheme, String handType) {
    final currentSlot = _photoSlots[_currentStep];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Current photo slot detailed info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Header row with icon and palm side indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentSlot.icon,
                      size: 36,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$handType El - ${currentSlot.title}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        // Palm side indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: currentSlot.isPalmInside
                                ? Colors.blue.withValues(alpha: 0.2)
                                : Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentSlot.isPalmInside
                                ? '🖐️ AVUÇ İÇİ'
                                : '✋ EL SIRTI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentSlot.isPalmInside
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Detailed instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentSlot.detailedInstruction,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Guide image if available
                if (currentSlot.guideImagePath != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        children: [
                          Transform.flip(
                            flipX: handType == 'Sol', // Sol el için yansıt
                            child: Image.asset(
                              currentSlot.guideImagePath!,
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  color: colorScheme.surface,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              color: Colors.black.withValues(alpha: 0.5),
                              child: const Text(
                                '📷 Örnek Görsel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Photo grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _photoSlots.length,
              itemBuilder: (context, index) =>
                  _buildPhotoSlotCard(index, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlotCard(int index, ColorScheme colorScheme) {
    final slot = _photoSlots[index];
    final isSelected = _currentStep == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentStep = index);
        if (!slot.hasImage) {
          _capturePhoto(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: slot.hasImage
              ? Colors.green.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.secondary
                : slot.hasImage
                    ? Colors.green
                    : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Image or placeholder
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
                child: slot.hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            slot.image!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                slot.icon,
                                size: 40,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            // Palm side indicator
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: slot.isPalmInside
                                      ? Colors.blue.withValues(alpha: 0.7)
                                      : Colors.orange.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  slot.isPalmInside ? 'İÇ' : 'SIRT',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                slot.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: slot.hasImage ? Colors.green : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingView(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Küçük resim önizlemeleri
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photoSlots
                .where((s) => s.hasImage)
                .map((s) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        s.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          CircularProgressIndicator(color: colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            '$_completedPhotos fotoğraf analiz ediliyor...',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detaylı analiz birkaç saniye sürebilir',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    AnalysisProvider analysis,
    AnalysisCategory category,
    String handType,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Capture buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _capturePhoto(_currentStep, source: ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _capturePhoto(_currentStep, source: ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Fotoğraf Çek'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Analyze button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _hasMinimumPhotos
                  ? () => _startAnalysis(analysis, category, handType)
                  : null,
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                _hasMinimumPhotos
                    ? 'Detaylı Analizi Başlat ($_completedPhotos fotoğraf)'
                    : 'En az 2 fotoğraf gerekli',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasMinimumPhotos ? Colors.green : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto(int index,
      {ImageSource source = ImageSource.camera}) async {
    setState(() => _errorMessage = null);

    try {
      XFile? image;
      if (source == ImageSource.camera) {
        image = await CustomCameraPicker.pickImage(context);
      } else {
        image = await _picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.rear,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 90,
        );
      }

      if (image != null) {
        setState(() {
          _photoSlots[index].image = File(image!.path);
          // Otomatik olarak sonraki boş slot'a geç
          _moveToNextEmptySlot(index);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fotoğraf alınamadı: $e';
      });
    }
  }

  void _moveToNextEmptySlot(int currentIndex) {
    for (int i = currentIndex + 1; i < _photoSlots.length; i++) {
      if (!_photoSlots[i].hasImage) {
        setState(() => _currentStep = i);
        return;
      }
    }
    // Eğer sonraki boş yoksa ilk boş slot'a git
    for (int i = 0; i < currentIndex; i++) {
      if (!_photoSlots[i].hasImage) {
        setState(() => _currentStep = i);
        return;
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoSlots[index].image = null;
      _currentStep = index;
    });
  }

  Future<void> _startAnalysis(
    AnalysisProvider analysis,
    AnalysisCategory category,
    String handType,
  ) async {
    // Fotoğrafları topla
    final images =
        _photoSlots.where((s) => s.hasImage).map((s) => s.image!).toList();

    if (images.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final aiService = AiAnalysisService();
      final result = await aiService.analyzeMultipleImages(
        imageFiles: images,
        category: category,
        handType: handType,
      );

      if (!mounted) return;

      if (result.hasError) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = result.errorMessage;
        });
        return;
      }

      // Sonuç ekranına git (ilk fotoğrafı önizleme olarak kullan)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AiResultScreen(
            result: result,
            category: category,
            handType: handType,
            capturedImage: images.first,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Analiz başarısız: $e';
        });
      }
    }
  }
}
