import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ShinobiLooterApp());

enum ItemRarity { common, rare, epic, legendary }
enum ConsumableType { heal, buffAtk, maxChakra, directDmg, smokeEscape, fullRestore }
enum GearSlot { weapon, armor, helmet, boots }
enum JutsuEffect { none, burn, freeze, stun, lifesteal, shock }

class BaseGearArchetype {
  final String baseName;
  final GearSlot slot;
  final int baseStat;
  final String lore;

  const BaseGearArchetype({
    required this.baseName,
    required this.slot,
    required this.baseStat,
    required this.lore,
  });
}

const List<BaseGearArchetype> standardArchetypesPool = [
  // BRONIE
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Standardowy Kunai', baseStat: 6, lore: 'Wszechstronne narzędzie każdego shinobi.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Składany Shuriken Fūma', baseStat: 8, lore: 'Czteroostrzowa wirująca śmierć.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Igły Senbon z Ame', baseStat: 7, lore: 'Precyzyjne igły paraliżujące punkty tenketsu.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Krótki Miecz Tanto ANBU', baseStat: 10, lore: 'Poręczne ostrze skrytobójców.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Kastety ze stali czakry', baseStat: 9, lore: 'Idealne do walki wręcz i taijutsu.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Dmuchawka z Amegakure', baseStat: 7, lore: 'Bezgłośna broń miotająca zatrute rzutki.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Włócznia Skalnego Posterunku', baseStat: 11, lore: 'Ciężka broń drzewcowa ze Skały.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Bliźniacze Tasaki Kiri', baseStat: 11, lore: 'Agresywny oręż sieczny z Wioski Mgły.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Łuk Pajęczej Nici', baseStat: 12, lore: 'Strzały z utwardzonej sieci nasyconej czakrą.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Ostrza Czakry Asumy', baseStat: 13, lore: 'Przewodzą ostrą naturę wiatru.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Żelazny Wachlarz Piasku', baseStat: 12, lore: 'Wywołuje potężny podmuch wiatru.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Kościane Ostrze Yanagi', baseStat: 14, lore: 'Twardsze niż najczystsza hartowana stal.'),

  // PANCERZE
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Szata Treningowa Genina', baseStat: 4, lore: 'Lekkie ubranie gwarantujące swobodę ruchów.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Ochraniacz Klatki Liścia', baseStat: 6, lore: 'Podstawowa ochrona korpusu.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Skórzana Zbroja Pustyni', baseStat: 7, lore: 'Pancerz odporny na cięcia i piasek.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Mundur Bojowy Iwagakure', baseStat: 8, lore: 'Ciężka płyta piechoty Skały.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Kamizelka Jonina Konohy', baseStat: 12, lore: 'Oficjalny pancerz z kieszeniami na zwoje.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Elitarny Napierśnik ANBU', baseStat: 14, lore: 'Wzmocniona powłoka operacyjna.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Pancerz Bojowy Kumogakure', baseStat: 13, lore: 'Jednostronny naramiennik z kamizelką.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Szata Pustelnika Myōboku', baseStat: 15, lore: 'Nasycona naturalną energią natury.'),

  // GŁOWA
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Ochraniacz Czołowy Protektor', baseStat: 3, lore: 'Stalowa płytka z symbolem wioski.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Maska Oddechowa Amegakure', baseStat: 4, lore: 'Filtruje gazy bojowe i pył.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Porcelanowa Maska Lisa ANBU', baseStat: 9, lore: 'Zaciera tożsamość i aurę czakry.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Bandaże Cichego Zabójcy', baseStat: 8, lore: 'Tłumią odgłosy oddechu w skradaniu.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Tradycyjny Kapelusz Kage', baseStat: 13, lore: 'Rytualne nakrycie głowy przywódcy.'),

  // BUTY
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Standardowe Sandały Shinobi', baseStat: 3, lore: 'Pewne oparcie stóp na gałęziach.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Wyciszone Mokasyny ANBU', baseStat: 8, lore: 'Specjalny materiał tłumi wszelki hałas.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Ciężarki Treningowe na Kostki', baseStat: 10, lore: 'Hartują nogi pod kątem zrywu.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Drewniane Geta Żabiego Mędrca', baseStat: 12, lore: 'Ułatwiają balansowanie i kumulację energii.'),
];

class LegendaryGearTemplate {
  final String name;
  final GearSlot slot;
  final int baseStat;
  final String bonusEffect;
  final int bonusValue;
  final String lore;

  const LegendaryGearTemplate({
    required this.name,
    required this.slot,
    required this.baseStat,
    required this.bonusEffect,
    required this.bonusValue,
    required this.lore,
  });
}

const List<LegendaryGearTemplate> legendaryArtifactsPool = [
  LegendaryGearTemplate(name: 'Miecz Totsuka (Sakegari)', slot: GearSlot.weapon, baseStat: 56, bonusEffect: 'Pieczęć Wiecznego Snu', bonusValue: 18, lore: 'Widmowe ostrze zamykające duszę w tykwie.'),
  LegendaryGearTemplate(name: 'Miecz Kusanagi Orochimaru', slot: GearSlot.weapon, baseStat: 50, bonusEffect: 'Niezniszczalna Stal', bonusValue: 14, lore: 'Mityczny oręż wysuwany z gardzieli węża.'),
  LegendaryGearTemplate(name: 'Samehada (Żarłacz Kisame)', slot: GearSlot.weapon, baseStat: 52, bonusEffect: 'Pożeranie Czakry', bonusValue: 16, lore: 'Żywy miecz wysysający energię przeciwnika.'),
  LegendaryGearTemplate(name: 'Wojenny Wachlarz Gunbai Madary', slot: GearSlot.weapon, baseStat: 54, bonusEffect: 'Odbicie Uchihagaeshi', bonusValue: 15, lore: 'Wachlarz z pradawnego drzewa odbijający ninjutsu.'),
  LegendaryGearTemplate(name: 'Miecz Nunoboko Hagoromo', slot: GearSlot.weapon, baseStat: 62, bonusEffect: 'Stworzenie Świata Rikudō', bonusValue: 20, lore: 'Święte spiralne ostrze DNA Mędrca.'),
  LegendaryGearTemplate(name: 'Klatka Żebrowa Susanoo', slot: GearSlot.armor, baseStat: 48, bonusEffect: 'Absolutny Kościec', bonusValue: 15, lore: 'Eteryczny szkielet z płomieni czakry Sharingana.'),
  LegendaryGearTemplate(name: 'Pancerz Ostatecznego Susanoo', slot: GearSlot.armor, baseStat: 55, bonusEffect: 'Bóstwo Zniszczenia', bonusValue: 20, lore: 'Kolosalna powłoka Madary niszcząca góry.'),
  LegendaryGearTemplate(name: 'Szata Mędrca Sześciu Ścieżek', slot: GearSlot.armor, baseStat: 52, bonusEffect: 'Harmonia Yin-Yang', bonusValue: 18, lore: 'Biała szata z magatama chroniąca przed rozpadem.'),
  LegendaryGearTemplate(name: 'Maska Jednoocznego Wiru (Obito)', slot: GearSlot.helmet, baseStat: 46, bonusEffect: 'Pusta Niematerialność', bonusValue: 15, lore: 'Ułatwia manipulację czasoprzestrzenią Kamui.'),
  LegendaryGearTemplate(name: 'Korona Rogatej Bogini Kaguya', slot: GearSlot.helmet, baseStat: 48, bonusEffect: 'Wizja Byakugana Pramatki', bonusValue: 16, lore: 'Relikt skupiający energię Świętego Drzewa.'),
  LegendaryGearTemplate(name: 'Obuwie Żółtego Błysku (Hiraishin)', slot: GearSlot.boots, baseStat: 45, bonusEffect: 'Teleportacja Błysku', bonusValue: 15, lore: 'Sandały Minato z wyrytą pieczęcią czasoprzestrzenną.'),
  LegendaryGearTemplate(name: 'Lewitujące Płyty Rikudō', slot: GearSlot.boots, baseStat: 47, bonusEffect: 'Lot Ponad Prawami Świata', bonusValue: 16, lore: 'Płyty z Gudōdama unoszące użytkownika w powietrzu.'),
];

class NinjaGear {
  final String name;
  final ItemRarity rarity;
  final int baseStat;
  final String bonusEffect;
  final int bonusValue;
  final bool isSoulbound;

  const NinjaGear({
    required this.name,
    required this.rarity,
    required this.baseStat,
    required this.bonusEffect,
    required this.bonusValue,
    this.isSoulbound = false,
  });

  NinjaGear copyWith({bool? isSoulbound}) {
    return NinjaGear(
      name: name,
      rarity: rarity,
      baseStat: baseStat,
      bonusEffect: bonusEffect,
      bonusValue: bonusValue,
      isSoulbound: isSoulbound ?? this.isSoulbound,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'rarity': rarity.index,
        'baseStat': baseStat,
        'bonusEffect': bonusEffect,
        'bonusValue': bonusValue,
        'isSoulbound': isSoulbound,
      };

  factory NinjaGear.fromJson(Map<String, dynamic> json) => NinjaGear(
        name: json['name'],
        rarity: ItemRarity.values[json['rarity']],
        baseStat: json['baseStat'],
        bonusEffect: json['bonusEffect'],
        bonusValue: json['bonusValue'],
        isSoulbound: json['isSoulbound'] ?? false,
      );

  Color get color {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.white70;
      case ItemRarity.rare:
        return Colors.blueAccent;
      case ItemRarity.epic:
        return Colors.purpleAccent;
      case ItemRarity.legendary:
        return Colors.amberAccent;
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case ItemRarity.common:
        return 'Zwykły';
      case ItemRarity.rare:
        return 'Rzadki';
      case ItemRarity.epic:
        return 'Epicki';
      case ItemRarity.legendary:
        return 'Legendarny';
    }
  }
}

class Consumable {
  final String id;
  final String name;
  final String description;
  final ConsumableType type;
  final int value;
  final int price;
  final String icon;

  const Consumable({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.price,
    required this.icon,
  });
}

const List<Consumable> allConsumables = [
  Consumable(id: 'c_pill', name: 'Pigułka Żywnościowa', description: '+45 Czakry.', type: ConsumableType.heal, value: 45, price: 25, icon: '💊'),
  Consumable(id: 'c_dango', name: 'Słodkie Dango', description: '+30 Czakry.', type: ConsumableType.heal, value: 30, price: 18, icon: '🍡'),
  Consumable(id: 'c_ramen', name: 'Ramen Ichiraku', description: 'Pełne odnowienie i +25 Max Czakry.', type: ConsumableType.fullRestore, value: 25, price: 95, icon: '🍜'),
  Consumable(id: 'c_ointment', name: 'Balsam Ziołowy Medyka', description: '+75 Czakry natychmiast.', type: ConsumableType.heal, value: 75, price: 50, icon: '🧴'),
  Consumable(id: 'c_power_pill', name: 'Pigułka Siły', description: '+10 stałego Ataku.', type: ConsumableType.buffAtk, value: 10, price: 65, icon: '⚡'),
  Consumable(id: 'c_kibaku', name: 'Pieczęć Wybuchowa', description: 'Zadaje 40 dmg w walce.', type: ConsumableType.directDmg, value: 40, price: 45, icon: '🏷️'),
  Consumable(id: 'c_smoke', name: 'Bomba Dymna', description: 'Gwarantowana ucieczka z walki.', type: ConsumableType.smokeEscape, value: 0, price: 30, icon: '💨'),
];

class Jutsu {
  final String id;
  final String name;
  final int chakraCost;
  final int powerMultiplier;
  final int costRyo;
  final Color color;
  final JutsuEffect effect;
  final int effectDuration;
  final int effectValue;

  const Jutsu({
    required this.id,
    required this.name,
    required this.chakraCost,
    required this.powerMultiplier,
    required this.costRyo,
    required this.color,
    this.effect = JutsuEffect.none,
    this.effectDuration = 0,
    this.effectValue = 0,
  });

  String get effectDescription {
    switch (effect) {
      case JutsuEffect.burn:
        return 'Podpalenie: $effectValue dmg/turę ($effectDuration tury)';
      case JutsuEffect.freeze:
        return 'Zamrożenie: Zamraża wroga na $effectDuration turę';
      case JutsuEffect.stun:
        return 'Ogłuszenie: Wróg traci $effectDuration turę';
      case JutsuEffect.lifesteal:
        return 'Wyssanie: Regeneruje $effectValue% obrażeń jako czakrę';
      case JutsuEffect.shock:
        return 'Paraliż: 60% szansy na utratę tury przez wroga';
      case JutsuEffect.none:
        return 'Czyste obrażenia fizyczne/czakry';
    }
  }
}

const List<Jutsu> allJutsuPool = [
  Jutsu(id: 'j_taijutsu', name: 'Podstawowe Taijutsu', chakraCost: 0, powerMultiplier: 1, costRyo: 0, color: Colors.blueGrey),
  Jutsu(id: 'j_konoha_senpuu', name: 'Konoha Senpū', chakraCost: 8, powerMultiplier: 2, costRyo: 80, color: Colors.lightGreen, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_katon', name: 'Katon: Goukakyu', chakraCost: 12, powerMultiplier: 2, costRyo: 100, color: Colors.deepOrange, effect: JutsuEffect.burn, effectDuration: 2, effectValue: 8),
  Jutsu(id: 'j_housenka', name: 'Katon: Hōsenka', chakraCost: 16, powerMultiplier: 3, costRyo: 160, color: Colors.orangeAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 12),
  Jutsu(id: 'j_gouka_mekkyaku', name: 'Katon: Gouka Mekkyaku', chakraCost: 35, powerMultiplier: 4, costRyo: 450, color: Colors.redAccent, effect: JutsuEffect.burn, effectDuration: 4, effectValue: 20),
  Jutsu(id: 'j_amaterasu', name: 'Amaterasu', chakraCost: 45, powerMultiplier: 5, costRyo: 750, color: Colors.deepPurple, effect: JutsuEffect.burn, effectDuration: 5, effectValue: 30),
  Jutsu(id: 'j_suirou', name: 'Suiton: Wodne Więzienie', chakraCost: 20, powerMultiplier: 2, costRyo: 220, color: Colors.blue, effect: JutsuEffect.freeze, effectDuration: 1),
  Jutsu(id: 'j_makyou_hyoushou', name: 'Hyōton: Lodowe Lustra Haku', chakraCost: 28, powerMultiplier: 3, costRyo: 340, color: Colors.cyanAccent, effect: JutsuEffect.freeze, effectDuration: 2),
  Jutsu(id: 'j_fuuton', name: 'Fuuton: Daitoppa', chakraCost: 10, powerMultiplier: 2, costRyo: 120, color: Colors.teal),
  Jutsu(id: 'j_rasenshuriken', name: 'Fuuton: Rasenshuriken', chakraCost: 42, powerMultiplier: 5, costRyo: 650, color: Colors.tealAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 25),
  Jutsu(id: 'j_raiton', name: 'Chidori', chakraCost: 24, powerMultiplier: 3, costRyo: 260, color: Colors.cyan, effect: JutsuEffect.shock),
  Jutsu(id: 'j_kirin', name: 'Raiton: Kirin', chakraCost: 50, powerMultiplier: 6, costRyo: 850, color: Colors.blueAccent, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_doryuheki', name: 'Doton: Błotna Ściana', chakraCost: 15, powerMultiplier: 2, costRyo: 140, color: Colors.lime, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_mokuton_drag', name: 'Mokuton: Drewniany Smok', chakraCost: 38, powerMultiplier: 4, costRyo: 550, color: Colors.greenAccent, effect: JutsuEffect.lifesteal, effectValue: 40),
  Jutsu(id: 'j_rasengan', name: 'Rasengan', chakraCost: 26, powerMultiplier: 3, costRyo: 300, color: Colors.blueAccent),
  Jutsu(id: 'j_bijuudama', name: 'Bijuudama', chakraCost: 65, powerMultiplier: 7, costRyo: 1200, color: Colors.purpleAccent, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_kamui', name: 'Kamui', chakraCost: 40, powerMultiplier: 4, costRyo: 800, color: Colors.grey, effect: JutsuEffect.freeze, effectDuration: 2),
];

class EnemyTemplate {
  final String name;
  final String title;
  final int baseHp;
  final int baseAtk;
  final bool isBoss;

  const EnemyTemplate({
    required this.name,
    required this.title,
    required this.baseHp,
    required this.baseAtk,
    this.isBoss = false,
  });
}

const List<EnemyTemplate> standardEnemiesPool = [
  EnemyTemplate(name: 'Bandyta z Kraju Fal', title: 'Pospolity Rabuś', baseHp: 20, baseAtk: 6),
  EnemyTemplate(name: 'Zbuntowany Ninja Deszczu', title: 'Nuke-nin z Amegakure', baseHp: 24, baseAtk: 7),
  EnemyTemplate(name: 'Szpieg z Iwagakure', title: 'Zwiadowca Skały', baseHp: 26, baseAtk: 8),
  EnemyTemplate(name: 'Kukiełkarz z Sunagakure', title: 'Mistrz Drewnianych Ostrzy', baseHp: 25, baseAtk: 9),
  EnemyTemplate(name: 'Klon Białego Zetsu', title: 'Infiltrator Mokuton', baseHp: 28, baseAtk: 7),
  EnemyTemplate(name: 'Zabójca z Mgły (Kiri)', title: 'Skrytobójca Cichego Zabijania', baseHp: 30, baseAtk: 9),
  EnemyTemplate(name: 'Cień Korzenia ANBU', title: 'Wojownik Bez Emocji', baseHp: 32, baseAtk: 10),
  EnemyTemplate(name: 'Jirōbō', title: 'Strażnik Bramy Dźwięku', baseHp: 35, baseAtk: 9),
  EnemyTemplate(name: 'Tayuya', title: 'Iluzjonistka Dźwięku', baseHp: 29, baseAtk: 11),
];

const List<EnemyTemplate> bossesPool = [
  EnemyTemplate(name: 'Zabuza Momochi', title: 'Demon Ukrytej Mgły', baseHp: 65, baseAtk: 14, isBoss: true),
  EnemyTemplate(name: 'Haku', title: 'Mistrz Lodowych Luster Hyōton', baseHp: 58, baseAtk: 15, isBoss: true),
  EnemyTemplate(name: 'Gaara Pustyni', title: 'Głos Shukaku', baseHp: 75, baseAtk: 13, isBoss: true),
  EnemyTemplate(name: 'Kimimaro Kaguya', title: 'Taniec Kości', baseHp: 70, baseAtk: 16, isBoss: true),
  EnemyTemplate(name: 'Orochimaru', title: 'Legendarny Wężowy Sannin', baseHp: 85, baseAtk: 18, isBoss: true),
  EnemyTemplate(name: 'Sasori', title: 'Czerwony Piasek', baseHp: 80, baseAtk: 19, isBoss: true),
  EnemyTemplate(name: 'Itachi Uchiha', title: 'Mistrz Mangekyō Sharingana', baseHp: 85, baseAtk: 22, isBoss: true),
  EnemyTemplate(name: 'Pain (Tendo)', title: 'Bóg Sześciu Ścieżek', baseHp: 115, baseAtk: 25, isBoss: true),
  EnemyTemplate(name: 'Madara Uchiha', title: 'Duch Klanu Uchiha', baseHp: 135, baseAtk: 28, isBoss: true),
];

class ShinobiMission {
  final String id;
  final String rank;
  final String title;
  final String desc;
  final int minExpRequired;
  final int requiredKills;
  final int rewardRyo;
  final int rewardExp;

  const ShinobiMission({
    required this.id,
    required this.rank,
    required this.title,
    required this.desc,
    required this.minExpRequired,
    required this.requiredKills,
    required this.rewardRyo,
    required this.rewardExp,
  });
}

const List<ShinobiMission> allMissionsPool = [
  ShinobiMission(id: 'm_d1', rank: 'D', title: 'Odchwaszczanie Ogrodów Daimyō', desc: 'Wyeliminuj 2 szkodników w lasach Liścia.', minExpRequired: 0, requiredKills: 2, rewardRyo: 60, rewardExp: 40),
  ShinobiMission(id: 'm_d2', rank: 'D', title: 'Poszukiwanie Zaginionej Kotki Tora', desc: 'Przepędź 3 leśne bestie i zabezpiecz teren.', minExpRequired: 0, requiredKills: 3, rewardRyo: 90, rewardExp: 55),
  ShinobiMission(id: 'm_d3', rank: 'D', title: 'Patrol Graniczny Wioski', desc: 'Odpędź 4 włóczęgów sprzed bram.', minExpRequired: 0, requiredKills: 4, rewardRyo: 120, rewardExp: 75),
  ShinobiMission(id: 'm_d4', rank: 'D', title: 'Oczyszczanie Rzeki Naka', desc: 'Zneutralizuj 3 rzecznych rabusiów.', minExpRequired: 0, requiredKills: 3, rewardRyo: 100, rewardExp: 65),

  ShinobiMission(id: 'm_c1', rank: 'C', title: 'Eskorta Mostowniczego Tazuny', desc: 'Wyeliminuj 5 bandytów z Kraju Fal.', minExpRequired: 150, requiredKills: 5, rewardRyo: 220, rewardExp: 130),
  ShinobiMission(id: 'm_c2', rank: 'C', title: 'Tłumienie Buntu w Kraju Herbaty', desc: 'Powstrzymaj 6 wrogich najemników.', minExpRequired: 150, requiredKills: 6, rewardRyo: 280, rewardExp: 160),
  ShinobiMission(id: 'm_c3', rank: 'C', title: 'Ochrona Karawany z Sunagakure', desc: 'Zlikwiduj 5 pustynnych koczowników.', minExpRequired: 150, requiredKills: 5, rewardRyo: 250, rewardExp: 145),
  ShinobiMission(id: 'm_c4', rank: 'C', title: 'Odzyskanie Skradzionego Zwoju', desc: 'Dopadnij 6 zbiegłych rzezimieszków.', minExpRequired: 150, requiredKills: 6, rewardRyo: 300, rewardExp: 175),

  ShinobiMission(id: 'm_b1', rank: 'B', title: 'Polowanie na Szpiegów z Iwagakure', desc: 'Zneutralizuj 7 zwiadowców wrogiej nacji.', minExpRequired: 400, requiredKills: 7, rewardRyo: 450, rewardExp: 260),
  ShinobiMission(id: 'm_b2', rank: 'B', title: 'Infiltracja Bazy Otogakure', desc: 'Wyeliminuj 8 eksperymentów Orochimaru.', minExpRequired: 400, requiredKills: 8, rewardRyo: 520, rewardExp: 300),
  ShinobiMission(id: 'm_b3', rank: 'B', title: 'Zasadzka na Czwórkę Dźwięku', desc: 'Pokonaj 7 zmutowanych strażników.', minExpRequired: 400, requiredKills: 7, rewardRyo: 480, rewardExp: 280),
  ShinobiMission(id: 'm_b4', rank: 'B', title: 'Czystka w Dolinie Końca', desc: 'Zlikwiduj 8 nuke-ninów wysokiej rangi.', minExpRequired: 400, requiredKills: 8, rewardRyo: 550, rewardExp: 320),

  ShinobiMission(id: 'm_a1', rank: 'A', title: 'Pojmanie Członków Akatsuki', desc: 'Pokonaj 10 elitarnych wojowników.', minExpRequired: 800, requiredKills: 10, rewardRyo: 850, rewardExp: 500),
  ShinobiMission(id: 'm_a2', rank: 'A', title: 'Obrona Konohy przed Inwazją Piasku', desc: 'Wyeliminuj 11 uderzeniowych shinobi.', minExpRequired: 800, requiredKills: 11, rewardRyo: 950, rewardExp: 550),
  ShinobiMission(id: 'm_a3', rank: 'A', title: 'Likwidacja Szermierzy z Kiri', desc: 'Zgładź 10 szermierzy z Mgły.', minExpRequired: 800, requiredKills: 10, rewardRyo: 900, rewardExp: 520),
  ShinobiMission(id: 'm_a4', rank: 'A', title: 'Tajne Zlecenie Korzenia ANBU', desc: 'Dokonaj egzekucji 12 zdrajców Wioski.', minExpRequired: 800, requiredKills: 12, rewardRyo: 1100, rewardExp: 600),

  ShinobiMission(id: 'm_s1', rank: 'S', title: 'Ocalenie Świata przed Shinra Tensei', desc: 'Zgładź 14 bóstw ścieżek bólu.', minExpRequired: 1400, requiredKills: 14, rewardRyo: 2200, rewardExp: 1100),
  ShinobiMission(id: 'm_s2', rank: 'S', title: 'Powstrzymanie Madary Uchiha', desc: 'Pokonaj 15 wskrzeszonych legend Edo Tensei.', minExpRequired: 1400, requiredKills: 15, rewardRyo: 2500, rewardExp: 1300),
  ShinobiMission(id: 'm_s3', rank: 'S', title: 'Pieczętowanie Dziesięcioogoniastego', desc: 'Zneutralizuj 16 awatarów czakry.', minExpRequired: 1400, requiredKills: 16, rewardRyo: 2800, rewardExp: 1500),
  ShinobiMission(id: 'm_s4', rank: 'S', title: 'Pojedynek z Boginią Kaguya', desc: 'Pokonaj 18 międzywymiarowych abominacji.', minExpRequired: 1400, requiredKills: 18, rewardRyo: 3500, rewardExp: 2000),
];

const NinjaGear defaultStarterWeapon = NinjaGear(name: 'Podstawowy Kunai', rarity: ItemRarity.common, baseStat: 5, bonusEffect: 'Brak', bonusValue: 0, isSoulbound: true);
const NinjaGear defaultStarterArmor = NinjaGear(name: 'Szata Treningowa Genina', rarity: ItemRarity.common, baseStat: 3, bonusEffect: 'Brak', bonusValue: 0, isSoulbound: true);
const NinjaGear defaultStarterHelmet = NinjaGear(name: 'Ochraniacz Czołowy Protektor', rarity: ItemRarity.common, baseStat: 2, bonusEffect: 'Brak', bonusValue: 0, isSoulbound: true);
const NinjaGear defaultStarterBoots = NinjaGear(name: 'Standardowe Sandały Shinobi', rarity: ItemRarity.common, baseStat: 2, bonusEffect: 'Brak', bonusValue: 0, isSoulbound: true);

class ShinobiLooterApp extends StatelessWidget {
  const ShinobiLooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121110),
      ),
      home: const ShinobiScreen(),
    );
  }
}

class ShinobiScreen extends StatefulWidget {
  const ShinobiScreen({super.key});

  @override
  State<ShinobiScreen> createState() => _ShinobiScreenState();
}

class _ShinobiScreenState extends State<ShinobiScreen> {
  final Random _rng = Random();

  bool inVillage = true;
  int km = 0;
  int chakra = 100;
  int maxChakra = 100;
  int bonusAtk = 0;
  int ryo = 120;
  int ninjaExp = 0;
  int masteryPoints = 0;
  bool isLoading = true;

  int? activeMissionIndex;
  int currentMissionKills = 0;
  Set<String> completedMissionsHistory = {};

  Map<String, int> bag = {'c_pill': 2, 'c_dango': 1, 'c_kibaku': 1, 'c_smoke': 1};
  List<Jutsu> equippedJutsu = [allJutsuPool[0]];
  List<Jutsu> knownJutsu = [allJutsuPool[0]];

  NinjaGear currentWeapon = defaultStarterWeapon;
  NinjaGear currentArmor = defaultStarterArmor;
  NinjaGear currentHelmet = defaultStarterHelmet;
  NinjaGear currentBoots = defaultStarterBoots;

  final List<String> log = ['Witaj w Konohagakure! Pamiętaj o zabezpieczaniu rynsztunku u Mistrza Pieczęci.'];

  static const int softCapLevel = 50;

  int get level {
    for (int lvl = 1; lvl <= softCapLevel; lvl++) {
      if (ninjaExp < expRequiredForLevel(lvl + 1)) {
        return lvl;
      }
    }
    return softCapLevel;
  }

  static int expRequiredForLevel(int lvl) {
    if (lvl <= 1) return 0;
    return (50 * pow(lvl, 1.6)).floor();
  }

  int get expForNextLevel => level >= softCapLevel ? expRequiredForLevel(softCapLevel) : expRequiredForLevel(level + 1);

  String get ninjaRank {
    if (level >= 50) return 'Hokage (Kage)';
    if (level >= 40) return 'Legendarny Sannin';
    if (level >= 30) return 'Jōnin Bojowy';
    if (level >= 20) return 'Tokubetsu Jōnin';
    if (level >= 10) return 'Chūnin';
    if (level >= 3) return 'Genin';
    return 'Nowicjusz Akademii';
  }

  Color get rankColor {
    if (level >= 50) return Colors.amber;
    if (level >= 40) return Colors.deepOrangeAccent;
    if (level >= 30) return Colors.redAccent;
    if (level >= 20) return Colors.purpleAccent;
    if (level >= 10) return Colors.blueAccent;
    if (level >= 3) return Colors.greenAccent;
    return Colors.white60;
  }

  int get totalAttack => currentWeapon.baseStat + currentWeapon.bonusValue + bonusAtk + (level * 2);
  int get totalDefense => currentArmor.baseStat + currentArmor.bonusValue + currentHelmet.baseStat + currentHelmet.bonusValue + currentBoots.baseStat + currentBoots.bonusValue;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      km = prefs.getInt('km') ?? 0;
      chakra = prefs.getInt('chakra') ?? 100;
      maxChakra = prefs.getInt('maxChakra') ?? 100;
      bonusAtk = prefs.getInt('bonusAtk') ?? 0;
      ryo = prefs.getInt('ryo') ?? 120;
      ninjaExp = prefs.getInt('ninjaExp') ?? 0;
      masteryPoints = prefs.getInt('masteryPoints') ?? 0;
      inVillage = prefs.getBool('inVillage') ?? true;
      activeMissionIndex = prefs.getInt('activeMissionIndex');
      currentMissionKills = prefs.getInt('currentMissionKills') ?? 0;

      final completedList = prefs.getStringList('completedMissionsHistory');
      if (completedList != null) completedMissionsHistory = completedList.toSet();

      final bagJson = prefs.getString('ninjaBag');
      if (bagJson != null) bag = Map<String, int>.from(jsonDecode(bagJson));

      final weaponStr = prefs.getString('currentWeapon');
      if (weaponStr != null) currentWeapon = NinjaGear.fromJson(jsonDecode(weaponStr));

      final armorStr = prefs.getString('currentArmor');
      if (armorStr != null) currentArmor = NinjaGear.fromJson(jsonDecode(armorStr));

      final helmetStr = prefs.getString('currentHelmet');
      if (helmetStr != null) currentHelmet = NinjaGear.fromJson(jsonDecode(helmetStr));

      final bootsStr = prefs.getString('currentBoots');
      if (bootsStr != null) currentBoots = NinjaGear.fromJson(jsonDecode(bootsStr));

      final knownIds = prefs.getStringList('knownJutsuIds');
      if (knownIds != null && knownIds.isNotEmpty) {
        knownJutsu = allJutsuPool.where((j) => knownIds.contains(j.id)).toList();
      }

      final equippedIds = prefs.getStringList('equippedJutsuIds');
      if (equippedIds != null && equippedIds.isNotEmpty) {
        equippedJutsu = allJutsuPool.where((j) => equippedIds.contains(j.id)).toList();
      }
      isLoading = false;
    });
  }

  Future<void> _saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('km', km);
    await prefs.setInt('chakra', chakra);
    await prefs.setInt('maxChakra', maxChakra);
    await prefs.setInt('bonusAtk', bonusAtk);
    await prefs.setInt('ryo', ryo);
    await prefs.setInt('ninjaExp', ninjaExp);
    await prefs.setInt('masteryPoints', masteryPoints);
    await prefs.setBool('inVillage', inVillage);
    await prefs.setStringList('completedMissionsHistory', completedMissionsHistory.toList());

    if (activeMissionIndex != null) {
      await prefs.setInt('activeMissionIndex', activeMissionIndex!);
    } else {
      await prefs.remove('activeMissionIndex');
    }
    await prefs.setInt('currentMissionKills', currentMissionKills);
    await prefs.setString('ninjaBag', jsonEncode(bag));
    await prefs.setString('currentWeapon', jsonEncode(currentWeapon.toJson()));
    await prefs.setString('currentArmor', jsonEncode(currentArmor.toJson()));
    await prefs.setString('currentHelmet', jsonEncode(currentHelmet.toJson()));
    await prefs.setString('currentBoots', jsonEncode(currentBoots.toJson()));
    await prefs.setStringList('knownJutsuIds', knownJutsu.map((j) => j.id).toList());
    await prefs.setStringList('equippedJutsuIds', equippedJutsu.map((j) => j.id).toList());
  }

  void addExperience(int amount) {
    final int oldLvl = level;
    ninjaExp += amount;

    final int capExp = expRequiredForLevel(softCapLevel);
    if (ninjaExp > capExp) {
      final surplus = ninjaExp - capExp;
      final newMasteryEarned = surplus ~/ 1500;
      if (newMasteryEarned > 0) {
        masteryPoints += newMasteryEarned;
        ninjaExp = capExp + (surplus % 1500);
        addLog('🎖️ Osiągnięto Biegłość Shinobi! Otrzymano +$newMasteryEarned Punkt(y) Biegłości!');
      }
    }

    if (level > oldLvl) {
      addLog('⚡ AWANS! Osiągnięto Poziom $level shinobi ($ninjaRank)!');
    }
    _saveGameData();
  }

  void addLog(String text) {
    setState(() {
      log.insert(0, text);
      if (log.length > 40) log.removeLast();
    });
    _saveGameData();
  }

  void returnToVillage({bool fallenInBattle = false}) {
    final itemsLostInBag = bag.values.fold(0, (a, b) => a + b);
    int lostEquippedPieces = 0;

    setState(() {
      inVillage = true;
      km = 0;
      chakra = maxChakra;
      bag.clear();

      if (!currentWeapon.isSoulbound) {
        currentWeapon = defaultStarterWeapon;
        lostEquippedPieces++;
      }
      if (!currentArmor.isSoulbound) {
        currentArmor = defaultStarterArmor;
        lostEquippedPieces++;
      }
      if (!currentHelmet.isSoulbound) {
        currentHelmet = defaultStarterHelmet;
        lostEquippedPieces++;
      }
      if (!currentBoots.isSoulbound) {
        currentBoots = defaultStarterBoots;
        lostEquippedPieces++;
      }
    });

    if (fallenInBattle) {
      addLog('💀 Zostałeś powalony! Wioskowy medyk ledwo uratował twoje życie.');
    } else {
      addLog('⛩️ Bezpieczny powrót za bramy Wioski Liścia. Czakra odnowiona.');
    }

    if (itemsLostInBag > 0 || lostEquippedPieces > 0) {
      addLog('⚠️ Fūinjutsu: Stracono $itemsLostInBag zapasów oraz $lostEquippedPieces niezapieczętowanych elementów ekwipunku!');
    }
    _saveGameData();
  }

  void leaveVillage() {
    setState(() {
      inVillage = false;
      km = 1;
    });
    addLog('🍃 Wyruszasz za bramy Konohy w nieznane!');
    _saveGameData();
  }

  void addConsumableToBag(String id, [int count = 1]) {
    bag[id] = (bag[id] ?? 0) + count;
    _saveGameData();
  }

  bool useConsumable(Consumable item) {
    final count = bag[item.id] ?? 0;
    if (count <= 0) return false;

    setState(() {
      bag[item.id] = count - 1;
      if (bag[item.id] == 0) bag.remove(item.id);

      switch (item.type) {
        case ConsumableType.heal:
          chakra = min(maxChakra, chakra + item.value);
          addLog('${item.icon} Użyto [${item.name}]: +${item.value} czakry.');
          break;
        case ConsumableType.fullRestore:
          maxChakra += item.value;
          chakra = maxChakra;
          addLog('${item.icon} Zjedzono [${item.name}]! +${item.value} Max Czakry.');
          break;
        case ConsumableType.buffAtk:
          bonusAtk += item.value;
          addLog('${item.icon} Użyto [${item.name}]: +${item.value} Ataku.');
          break;
        case ConsumableType.maxChakra:
          maxChakra += item.value;
          chakra = min(maxChakra, chakra + item.value);
          addLog('${item.icon} Użyto [${item.name}]: +${item.value} limitu czakry.');
          break;
        case ConsumableType.directDmg:
        case ConsumableType.smokeEscape:
          break;
      }
    });
    _saveGameData();
    return true;
  }

  void proceedMission() {
    if (chakra <= 0) return;

    final nextKm = km + 5;
    setState(() => km = nextKm);
    _saveGameData();

    final bool bossSpawnTriggered = (nextKm % 25 == 0) || (_rng.nextInt(100) < (15 + min(20, nextKm ~/ 10)));
    final roll = _rng.nextInt(100);

    if (bossSpawnTriggered && roll < 42) {
      final randomBoss = bossesPool[_rng.nextInt(bossesPool.length)];
      _startBattleWithEnemy(randomBoss);
    } else if (roll < 58) {
      final randomEnemy = standardEnemiesPool[_rng.nextInt(standardEnemiesPool.length)];
      _startBattleWithEnemy(randomEnemy);
    } else if (roll < 72) {
      _findLoot();
    } else if (roll < 84) {
      _encounterSealMaster();
    } else if (roll < 93) {
      _encounterWanderingSage();
    } else {
      addLog('Km $km: Przemieszczasz się lasami Kraju Ognia. Czysty teren.');
    }
  }

  void _encounterSealMaster() {
    final unsealedSlots = <GearSlot, NinjaGear>{};
    if (!currentWeapon.isSoulbound) unsealedSlots[GearSlot.weapon] = currentWeapon;
    if (!currentArmor.isSoulbound) unsealedSlots[GearSlot.armor] = currentArmor;
    if (!currentHelmet.isSoulbound) unsealedSlots[GearSlot.helmet] = currentHelmet;
    if (!currentBoots.isSoulbound) unsealedSlots[GearSlot.boots] = currentBoots;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSealState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2B1616),
            title: const Row(
              children: [
                Text('🈴 ', style: TextStyle(fontSize: 22)),
                Expanded(child: Text('Mistrz Fūinjutsu Uzumaki', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '„Wskaż przedmiot, a naniosę na niego Pieczęć Duszy, chroniąc go przed utratą po powrocie do wioski!”',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  if (unsealedSlots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Cały twój aktualny rynsztunek jest już trwale zapieczętowany!', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    )
                  else
                    ...unsealedSlots.entries.map((entry) {
                      final slot = entry.key;
                      final gear = entry.value;
                      final cost = 80 + (gear.rarity.index * 60);

                      String slotName;
                      switch (slot) {
                        case GearSlot.weapon:
                          slotName = 'Broń';
                          break;
                        case GearSlot.armor:
                          slotName = 'Pancerz';
                          break;
                        case GearSlot.helmet:
                          slotName = 'Głowa';
                          break;
                        case GearSlot.boots:
                          slotName = 'Buty';
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('$slotName: ${gear.name}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gear.color)),
                          subtitle: Text('Koszt Pieczęci: $cost Ryo', style: const TextStyle(fontSize: 10, color: Colors.amberAccent)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                            onPressed: ryo >= cost
                                ? () {
                                    setState(() {
                                      ryo -= cost;
                                      switch (slot) {
                                        case GearSlot.weapon:
                                          currentWeapon = currentWeapon.copyWith(isSoulbound: true);
                                          break;
                                        case GearSlot.armor:
                                          currentArmor = currentArmor.copyWith(isSoulbound: true);
                                          break;
                                        case GearSlot.helmet:
                                          currentHelmet = currentHelmet.copyWith(isSoulbound: true);
                                          break;
                                        case GearSlot.boots:
                                          currentBoots = currentBoots.copyWith(isSoulbound: true);
                                          break;
                                      }
                                    });
                                    _saveGameData();
                                    Navigator.pop(ctx);
                                    addLog('🈴 Zapieczętowano na stałe: ${gear.name} (-$cost Ryo)!');
                                  }
                                : null,
                            child: const Text('Zapieczętuj', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  Text('Fundusze: $ryo Ryo', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  addLog('Km $km: Zrezygnowałeś z usług Mistrza Pieczęci.');
                },
                child: const Text('Odejdź', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openMedicDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setMedicState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF14241D),
            title: const Row(
              children: [
                Text('🩺 ', style: TextStyle(fontSize: 22)),
                Expanded(child: Text('Szpital Konohy (Medyk)', style: TextStyle(color: Colors.greenAccent))),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('„Uleczymy twoje rany i pomożemy rozwinąć potencjał biegłości.”',
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text('💚', style: TextStyle(fontSize: 24)),
                      title: const Text('Pełna Regeneracja Tenketsu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Odnawia czakrę do 100%', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                        onPressed: chakra < maxChakra && ryo >= 20
                            ? () {
                                setState(() {
                                  ryo -= 20;
                                  chakra = maxChakra;
                                });
                                _saveGameData();
                                setMedicState(() {});
                                addLog('🩺 Medyk Konohy uleczył twoje rany (-20 Ryo).');
                              }
                            : null,
                        child: const Text('20 Ryo', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    const Divider(color: Colors.white12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text('🧬', style: TextStyle(fontSize: 24)),
                      title: const Text('Trening Obiegu Czakry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('+20 do Max Czakry', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                        onPressed: ryo >= 150
                            ? () {
                                setState(() {
                                  ryo -= 150;
                                  maxChakra += 20;
                                  chakra += 20;
                                });
                                _saveGameData();
                                setMedicState(() {});
                                addLog('✨ Poszerzono obieg Tenketsu! +20 Max Czakry (-150 Ryo).');
                              }
                            : null,
                        child: const Text('150 Ryo', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    if (level >= softCapLevel) ...[
                      const Divider(color: Colors.amberAccent),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Biegłość Shinobi (Soft Cap):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                          Text('$masteryPoints pkt', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900),
                              onPressed: masteryPoints > 0
                                  ? () {
                                      setState(() {
                                        masteryPoints--;
                                        bonusAtk += 4;
                                      });
                                      _saveGameData();
                                      setMedicState(() {});
                                      addLog('🔥 Wykorzystano Punkt Biegłości: +4 stałego Ataku!');
                                    }
                                  : null,
                              child: const Text('+4 Ataku', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan.shade900),
                              onPressed: masteryPoints > 0
                                  ? () {
                                      setState(() {
                                        masteryPoints--;
                                        maxChakra += 25;
                                        chakra += 25;
                                      });
                                      _saveGameData();
                                      setMedicState(() {});
                                      addLog('💧 Wykorzystano Punkt Biegłości: +25 Max Czakry!');
                                    }
                                  : null,
                              child: const Text('+25 Czakry', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(color: Colors.white12),
                    const Text('Zapasy na wyprawę (przepadają po powrocie):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        ActionChip(
                          avatar: const Text('💊'),
                          label: const Text('Pigułka (25 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 25
                              ? () {
                                  setState(() => ryo -= 25);
                                  addConsumableToBag('c_pill', 1);
                                  setMedicState(() {});
                                }
                              : null,
                        ),
                        ActionChip(
                          avatar: const Text('🧴'),
                          label: const Text('Balsam (50 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 50
                              ? () {
                                  setState(() => ryo -= 50);
                                  addConsumableToBag('c_ointment', 1);
                                  setMedicState(() {});
                                }
                              : null,
                        ),
                        ActionChip(
                          avatar: const Text('💨'),
                          label: const Text('Dym (30 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 30
                              ? () {
                                  setState(() => ryo -= 30);
                                  addConsumableToBag('c_smoke', 1);
                                  setMedicState(() {});
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Twoje Ryo: $ryo | Czakra: $chakra/$maxChakra', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Wyjdź', style: TextStyle(color: Colors.grey))),
            ],
          );
        },
      ),
    );
  }

  void _encounterWanderingSage() {
    final unlearnedJutsu = allJutsuPool.where((j) => !knownJutsu.any((k) => k.id == j.id)).toList();

    if (unlearnedJutsu.isEmpty) {
      addLog('Km $km: Spotkałeś Wędrownego Mędrca, lecz znasz już wszystkie jego techniki!');
      return;
    }

    final offeredJutsu = unlearnedJutsu[_rng.nextInt(unlearnedJutsu.length)];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1812),
        title: const Row(
          children: [
            Text('👴🏻 ', style: TextStyle(fontSize: 22)),
            Expanded(child: Text('Wędrowny Mędrzec', style: TextStyle(color: Colors.amberAccent))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '„Za odpowiednią ofiarę w Ryo chętnie przekażę ci tajemny zwój...”',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: offeredJutsu.color.withAlpha(160)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offeredJutsu.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: offeredJutsu.color)),
                  const SizedBox(height: 4),
                  Text('Koszt Czakry: ${offeredJutsu.chakraCost} | Siła: x${offeredJutsu.powerMultiplier}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  Text(offeredJutsu.effectDescription, style: const TextStyle(fontSize: 10, color: Colors.cyanAccent)),
                  const SizedBox(height: 6),
                  Text('Cena: ${offeredJutsu.costRyo} Ryo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('Posiadasz: $ryo Ryo', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              addLog('Km $km: Odrzuciłeś ofertę Mędrca.');
            },
            child: const Text('Odejdź', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900),
            onPressed: ryo >= offeredJutsu.costRyo
                ? () {
                    setState(() {
                      ryo -= offeredJutsu.costRyo;
                      knownJutsu.add(offeredJutsu);
                    });
                    _saveGameData();
                    Navigator.pop(ctx);
                    addLog('📜 Poznano nowe Jutsu: [${offeredJutsu.name}]!');
                  }
                : null,
            child: const Text('Kup Zwój'),
          ),
        ],
      ),
    );
  }

  void _startBattleWithEnemy(EnemyTemplate template) {
    final kmScale = (km * 0.25).round();
    final int enemyMaxHp = template.baseHp + kmScale * (template.isBoss ? 3 : 1);
    final int enemyBaseAtk = template.baseAtk + (kmScale * 0.5).round();

    int enemyHp = enemyMaxHp;
    String battleMsg = template.isBoss
        ? '⚠️ BOSS: Pojawia się ${template.name}!'
        : 'Z cienia atakuje ${template.name}!';

    int burnTurns = 0;
    int burnDmg = 0;
    int frozenTurns = 0;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF161514),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setBattleState) {
            void enemyTurn() {
              if (enemyHp <= 0) return;

              if (frozenTurns > 0) {
                frozenTurns--;
                battleMsg += '\n❄️ ${template.name} jest unieruchomiony!';
                setBattleState(() {});
                return;
              }

              final rawDmg = enemyBaseAtk + _rng.nextInt(5);
              final dmg = max(2, rawDmg - (totalDefense ~/ 2));
              setState(() {
                chakra = max(0, chakra - dmg);
              });
              battleMsg = '${template.name} atakuje za $dmg dmg! (Obrona: $totalDefense)';
              _saveGameData();

              if (chakra <= 0) {
                Navigator.pop(ctx);
                returnToVillage(fallenInBattle: true);
              }
            }

            void executeJutsu(Jutsu jutsu) {
              if (chakra < jutsu.chakraCost) {
                battleMsg = 'Brak czakry na ${jutsu.name}!';
                setBattleState(() {});
                return;
              }

              setState(() {
                chakra -= jutsu.chakraCost;
              });

              final dealt = (totalAttack * jutsu.powerMultiplier) + _rng.nextInt(6);
              enemyHp = max(0, enemyHp - dealt);
              battleMsg = 'Użyto ${jutsu.name}! Zadałeś $dealt obrażeń.';

              switch (jutsu.effect) {
                case JutsuEffect.burn:
                  burnTurns = jutsu.effectDuration;
                  burnDmg = jutsu.effectValue;
                  battleMsg += '\n🔥 Cel podpalony!';
                  break;
                case JutsuEffect.freeze:
                case JutsuEffect.stun:
                  frozenTurns = jutsu.effectDuration;
                  battleMsg += '\n❄️ Przeciwnik unieruchomiony!';
                  break;
                case JutsuEffect.shock:
                  if (_rng.nextInt(100) < 60) {
                    frozenTurns = 1;
                    battleMsg += '\n⚡ Porażenie prądem! Wróg traci turę!';
                  }
                  break;
                case JutsuEffect.lifesteal:
                  final healed = ((dealt * jutsu.effectValue) / 100).round();
                  setState(() {
                    chakra = min(maxChakra, chakra + healed);
                  });
                  battleMsg += '\n💚 Wyssano $healed Czakry!';
                  break;
                default:
                  break;
              }

              if (burnTurns > 0 && enemyHp > 0) {
                enemyHp = max(0, enemyHp - burnDmg);
                burnTurns--;
                battleMsg += '\n🔥 Ogień zadał $burnDmg dmg!';
              }

              if (enemyHp <= 0) {
                Navigator.pop(ctx);
                final rewardRyo = template.isBoss ? (200 + km * 2) : (30 + km);
                final expGained = template.isBoss
                    ? (80 + (km ~/ 5) * 12)
                    : (15 + (km ~/ 5) * 3);

                setState(() {
                  ryo += rewardRyo;
                  if (activeMissionIndex != null) currentMissionKills++;
                });
                addExperience(expGained);
                addLog('🏆 Pokonano: ${template.name}! Zdobyto $rewardRyo Ryo i +$expGained EXP.');
                _findLoot(guaranteedBossDrop: template.isBoss);
              } else {
                enemyTurn();
                setBattleState(() {});
              }
            }

            void useBattleItem(Consumable item) {
              final count = bag[item.id] ?? 0;
              if (count <= 0) return;

              setState(() {
                bag[item.id] = count - 1;
                if (bag[item.id] == 0) bag.remove(item.id);
              });

              if (item.type == ConsumableType.smokeEscape) {
                Navigator.pop(ctx);
                addLog('💨 Zasłona dymna! Ucieczka ze starcia.');
                return;
              } else if (item.type == ConsumableType.directDmg) {
                enemyHp = max(0, enemyHp - item.value);
                battleMsg = 'Pieczęć Wybuchowa zadała ${item.value} dmg!';
                if (enemyHp <= 0) {
                  Navigator.pop(ctx);
                  final rewardRyo = template.isBoss ? 160 : 25;
                  final expGained = template.isBoss ? 50 : 15;
                  setState(() {
                    ryo += rewardRyo;
                    if (activeMissionIndex != null) currentMissionKills++;
                  });
                  addExperience(expGained);
                  addLog('💥 Wysadzono ${template.name}! +$rewardRyo Ryo.');
                  _findLoot(guaranteedBossDrop: template.isBoss);
                  return;
                }
              }
              enemyTurn();
              setBattleState(() {});
            }

            return Container(
              padding: const EdgeInsets.all(16),
              height: 460,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(template.name, style: TextStyle(color: template.isBoss ? Colors.redAccent : Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(template.title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                      Text('$enemyHp / $enemyMaxHp HP', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: enemyHp / enemyMaxHp,
                    color: template.isBoss ? Colors.purpleAccent : Colors.redAccent,
                    backgroundColor: Colors.white12,
                    minHeight: 7,
                  ),
                  const SizedBox(height: 10),
                  Text(battleMsg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.amberAccent, fontFamily: 'monospace', fontSize: 11)),
                  const Spacer(),
                  Row(
                    children: equippedJutsu.map((jutsu) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: jutsu.color.withAlpha(90), padding: const EdgeInsets.symmetric(vertical: 8)),
                            onPressed: () => executeJutsu(jutsu),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(jutsu.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('(${jutsu.chakraCost})', style: const TextStyle(fontSize: 9, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if ((bag['c_kibaku'] ?? 0) > 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade800),
                          icon: const Text('🏷️'),
                          label: Text('Wybuch (${bag['c_kibaku']})'),
                          onPressed: () => useBattleItem(allConsumables.firstWhere((c) => c.id == 'c_kibaku')),
                        ),
                      const SizedBox(width: 8),
                      if ((bag['c_smoke'] ?? 0) > 0 && !template.isBoss)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700),
                          icon: const Text('💨'),
                          label: Text('Dym (${bag['c_smoke']})'),
                          onPressed: () => useBattleItem(allConsumables.firstWhere((c) => c.id == 'c_smoke')),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      if (template.isBoss) {
                        battleMsg = 'Przed bossem nie da się uciec bez dymu!';
                        setBattleState(() {});
                        return;
                      }
                      Navigator.pop(ctx);
                      addLog('💨 Wycofano się ze starcia!');
                    },
                    child: Text(template.isBoss ? 'Brak odwrotu' : 'Ucieczka pieszo', style: TextStyle(color: template.isBoss ? Colors.red : Colors.grey)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  NinjaGear _generateRandomGear({required GearSlot slot, bool guaranteedBossDrop = false}) {
    ItemRarity rarity;

    if (guaranteedBossDrop) {
      final bossRoll = _rng.nextInt(100);
      if (bossRoll < 55) {
        rarity = ItemRarity.rare;
      } else if (bossRoll < 90) {
        rarity = ItemRarity.epic;
      } else {
        rarity = ItemRarity.legendary;
      }
    } else {
      final roll = _rng.nextInt(1000);
      if (roll < 720) {
        rarity = ItemRarity.common;
      } else if (roll < 950) {
        rarity = ItemRarity.rare;
      } else if (roll < 995) {
        rarity = ItemRarity.epic;
      } else {
        rarity = ItemRarity.legendary;
      }
    }

    if (rarity == ItemRarity.legendary) {
      final legPool = legendaryArtifactsPool.where((g) => g.slot == slot).toList();
      final template = legPool[_rng.nextInt(legPool.length)];
      final statScaling = (km * 0.15).round();

      return NinjaGear(
        name: template.name,
        rarity: ItemRarity.legendary,
        baseStat: template.baseStat + statScaling,
        bonusEffect: template.bonusEffect,
        bonusValue: template.bonusValue,
        isSoulbound: false,
      );
    }

    final availableArchetypes = standardArchetypesPool.where((g) => g.slot == slot).toList();
    final baseArch = availableArchetypes[_rng.nextInt(availableArchetypes.length)];

    int statMultiplier;
    String prefix;
    String bonusAffix = 'Brak';
    int bonusVal = 0;

    switch (rarity) {
      case ItemRarity.common:
        statMultiplier = 1;
        prefix = 'Zwykły';
        break;
      case ItemRarity.rare:
        statMultiplier = 2;
        prefix = 'Mistrzowski';
        bonusAffix = 'Precyzja Shinobi';
        bonusVal = _rng.nextInt(4) + 2;
        break;
      case ItemRarity.epic:
        statMultiplier = 3;
        prefix = 'Pradawny';
        bonusAffix = 'Pieczęć Pięciu Żywiołów';
        bonusVal = _rng.nextInt(8) + 5;
        break;
      case ItemRarity.legendary:
        statMultiplier = 1;
        prefix = '';
        break;
    }

    final statScaling = (km * 0.12).round();
    final calculatedStat = (baseArch.baseStat * statMultiplier) + statScaling + _rng.nextInt(3);
    final fullName = rarity == ItemRarity.common ? baseArch.baseName : '$prefix ${baseArch.baseName}';

    return NinjaGear(
      name: fullName,
      rarity: rarity,
      baseStat: calculatedStat,
      bonusEffect: bonusAffix,
      bonusValue: bonusVal,
      isSoulbound: false,
    );
  }

  void _findLoot({bool guaranteedBossDrop = false}) {
    final roll = _rng.nextInt(100);
    if (roll < 70 || guaranteedBossDrop) {
      final slotIndex = _rng.nextInt(4);
      final slot = GearSlot.values[slotIndex];
      final drop = _generateRandomGear(slot: slot, guaranteedBossDrop: guaranteedBossDrop);

      NinjaGear currentGear;
      switch (slot) {
        case GearSlot.weapon:
          currentGear = currentWeapon;
          break;
        case GearSlot.armor:
          currentGear = currentArmor;
          break;
        case GearSlot.helmet:
          currentGear = currentHelmet;
          break;
        case GearSlot.boots:
          currentGear = currentBoots;
          break;
      }

      _showEquipDialog(newGear: drop, currentGear: currentGear, slot: slot);
    } else {
      final item = allConsumables[_rng.nextInt(allConsumables.length)];
      addConsumableToBag(item.id, 1);
      addLog('📦 Wyprawa: Zebrano [${item.name}]!');
    }
  }

  void _showEquipDialog({required NinjaGear newGear, required NinjaGear currentGear, required GearSlot slot}) {
    String slotName;
    switch (slot) {
      case GearSlot.weapon:
        slotName = 'Broń';
        break;
      case GearSlot.armor:
        slotName = 'Pancerz';
        break;
      case GearSlot.helmet:
        slotName = 'Głowa';
        break;
      case GearSlot.boots:
        slotName = 'Buty';
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C1A),
        title: Text('Znaleziono: $slotName!', style: const TextStyle(color: Colors.orangeAccent)),
        content: Text(
          'Nowy: [${newGear.rarityLabel}] ${newGear.name} (+${newGear.baseStat})\nStatus: Niezapieczętowany ⚠️\n\n'
          'Aktualny: [${currentGear.rarityLabel}] ${currentGear.name} (+${currentGear.baseStat})\n'
          'Status: ${currentGear.isSoulbound ? "📜 Zapieczętowany (Bezpieczny)" : "⚠️ Utracisz po powrocie!"}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Zostaw stary')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900),
            onPressed: () {
              setState(() {
                switch (slot) {
                  case GearSlot.weapon:
                    currentWeapon = newGear;
                    break;
                  case GearSlot.armor:
                    currentArmor = newGear;
                    break;
                  case GearSlot.helmet:
                    currentHelmet = newGear;
                    break;
                  case GearSlot.boots:
                    currentBoots = newGear;
                    break;
                }
              });
              _saveGameData();
              Navigator.pop(ctx);
              addLog('✨ Założono: ${newGear.name} (Wymaga pieczęci, by nie przepaść!)');
            },
            child: const Text('Załóż nowy'),
          ),
        ],
      ),
    );
  }

  void _openMissionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A16),
        title: const Text('📜 Biuro Misji Hokage', style: TextStyle(color: Colors.orangeAccent)),
        content: SizedBox(
          width: double.maxFinite,
          child: activeMissionIndex != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Aktywna Misja: Ranga ${allMissionsPool[activeMissionIndex!].rank}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 8),
                    Text(allMissionsPool[activeMissionIndex!].title, style: const TextStyle(fontSize: 14)),
                    Text(allMissionsPool[activeMissionIndex!].desc, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: currentMissionKills / allMissionsPool[activeMissionIndex!].requiredKills,
                      color: Colors.greenAccent,
                      backgroundColor: Colors.white12,
                    ),
                    const SizedBox(height: 6),
                    Text('Postęp: $currentMissionKills / ${allMissionsPool[activeMissionIndex!].requiredKills} celów', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 16),
                    if (currentMissionKills >= allMissionsPool[activeMissionIndex!].requiredKills)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                        onPressed: () {
                          final m = allMissionsPool[activeMissionIndex!];
                          final bool isRepeat = completedMissionsHistory.contains(m.id);

                          final int earnedExp = isRepeat ? max(10, (m.rewardExp * 0.35).round()) : m.rewardExp;
                          final int earnedRyo = m.rewardRyo;

                          setState(() {
                            ryo += earnedRyo;
                            completedMissionsHistory.add(m.id);
                            activeMissionIndex = null;
                            currentMissionKills = 0;
                          });
                          addExperience(earnedExp);
                          _saveGameData();
                          Navigator.pop(ctx);
                          addLog('🎖️ Sukces misji: ${m.title}! +$earnedRyo Ryo, +$earnedExp EXP ${isRepeat ? "(Powtórka: -65% EXP)" : ""}');
                        },
                        child: const Text('Odbierz Nagrodę! 🎁'),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          setState(() {
                            activeMissionIndex = null;
                            currentMissionKills = 0;
                          });
                          _saveGameData();
                          Navigator.pop(ctx);
                          addLog('❌ Porzucono zlecenie.');
                        },
                        child: const Text('Porzuć misję', style: TextStyle(color: Colors.redAccent)),
                      ),
                  ],
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: allMissionsPool.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                  itemBuilder: (context, i) {
                    final m = allMissionsPool[i];
                    final bool isUnlocked = ninjaExp >= m.minExpRequired;
                    final bool isCompleted = completedMissionsHistory.contains(m.id);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: isUnlocked ? Colors.orange.shade900 : Colors.grey.shade800,
                        child: Text(m.rank, style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? Colors.white : Colors.white38)),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(m.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.white : Colors.white38))),
                          if (isCompleted) const Text('✓ Ukończono', style: TextStyle(fontSize: 9, color: Colors.greenAccent)),
                        ],
                      ),
                      subtitle: Text(
                        isUnlocked
                            ? '${m.desc}\nNagroda: ${m.rewardRyo} Ryo | ${isCompleted ? "${(m.rewardExp * 0.35).round()} EXP (Powtórka)" : "+${m.rewardExp} EXP"}'
                            : 'Wymaga: ${m.minExpRequired} EXP',
                        style: TextStyle(fontSize: 10, color: isUnlocked ? Colors.white60 : Colors.redAccent.withAlpha(150)),
                      ),
                      trailing: isUnlocked
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.blueGrey.shade800 : Colors.orange.shade900),
                              onPressed: () {
                                setState(() {
                                  activeMissionIndex = i;
                                  currentMissionKills = 0;
                                });
                                _saveGameData();
                                Navigator.pop(ctx);
                                addLog('📜 Przyjęto ${isCompleted ? "powtórkę misji" : "misję"}: ${m.title}!');
                              },
                              child: Text(isCompleted ? 'Powtórz' : 'Przyjmij', style: const TextStyle(fontSize: 10)),
                            )
                          : const Icon(Icons.lock, size: 18, color: Colors.grey),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Zamknij', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  void _openBagDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setBagState) {
          final itemsInBag = allConsumables.where((c) => (bag[c.id] ?? 0) > 0).toList();

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1C1A),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🎒 Plecak Rajdu', style: TextStyle(color: Colors.orangeAccent, fontSize: 16)),
                Text('${bag.values.fold(0, (a, b) => a + b)} szt.', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: itemsInBag.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Plecak jest pusty!\nWszystkie zapasy przepadają po powrocie do wioski.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: itemsInBag.length,
                      separatorBuilder: (_, __) => const Divider(height: 12, color: Colors.white12),
                      itemBuilder: (context, i) {
                        final item = itemsInBag[i];
                        final qty = bag[item.id] ?? 0;
                        final isCombatOnly = item.type == ConsumableType.directDmg || item.type == ConsumableType.smokeEscape;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(item.icon, style: const TextStyle(fontSize: 24)),
                          title: Text('${item.name} (x$qty)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: Text(item.description, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: isCombatOnly ? Colors.grey.shade800 : Colors.teal.shade800, padding: const EdgeInsets.symmetric(horizontal: 10)),
                            onPressed: isCombatOnly
                                ? null
                                : () {
                                    useConsumable(item);
                                    setBagState(() {});
                                  },
                            child: Text(isCombatOnly ? 'W walce' : 'Użyj', style: const TextStyle(fontSize: 11)),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Zamknij', style: TextStyle(color: Colors.grey))),
            ],
          );
        },
      ),
    );
  }

  void _openScrollsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setScrollsState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1A16),
            title: const Text('📜 Zwoje Technik (Max 3 aktywne)', style: TextStyle(color: Colors.cyanAccent, fontSize: 15)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: knownJutsu.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                itemBuilder: (context, index) {
                  final jutsu = knownJutsu[index];
                  final isEquipped = equippedJutsu.any((j) => j.id == jutsu.id);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(jutsu.name, style: TextStyle(fontSize: 12, color: jutsu.color, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Koszt: ${jutsu.chakraCost} Czakry | Siła: x${jutsu.powerMultiplier}\n${jutsu.effectDescription}',
                      style: const TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: isEquipped ? Colors.green.shade800 : Colors.grey.shade800),
                      onPressed: () {
                        setState(() {
                          if (isEquipped) {
                            if (equippedJutsu.length > 1) {
                              equippedJutsu.removeWhere((j) => j.id == jutsu.id);
                            }
                          } else {
                            if (equippedJutsu.length >= 3) {
                              equippedJutsu.removeLast();
                            }
                            equippedJutsu.add(jutsu);
                          }
                        });
                        _saveGameData();
                        setScrollsState(() {});
                      },
                      child: Text(isEquipped ? 'Założone' : 'Załóż', style: const TextStyle(fontSize: 10)),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Zamknij', style: TextStyle(color: Colors.grey))),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)));
    }

    final totalItemsInBag = bag.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text(inVillage ? 'Konohagakure (Strefa Bezpieczna)' : 'Eksploracja: $km km'),
        centerTitle: true,
        backgroundColor: inVillage ? const Color(0xFF1B4D3E) : const Color(0xFFC44D00),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1C1A18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _badge('Poziom / Ranga', 'Lvl $level ($ninjaRank)', rankColor),
                    _badge('EXP', '$ninjaExp / $expForNextLevel', Colors.cyanAccent),
                    _badge('Czakra', '$chakra / $maxChakra', chakra < 30 ? Colors.redAccent : Colors.lightBlueAccent),
                    _badge('Ryo', '$ryo', Colors.amberAccent),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _itemCard('Broń', currentWeapon, 'Atak: +$totalAttack'),
                    const SizedBox(width: 6),
                    _itemCard('Pancerz', currentArmor, 'Obr: +${currentArmor.baseStat}'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _itemCard('Głowa', currentHelmet, 'Obr: +${currentHelmet.baseStat}'),
                    const SizedBox(width: 6),
                    _itemCard('Buty', currentBoots, 'Obr: +${currentBoots.baseStat} (Suma: $totalDefense)'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: inVillage
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC44D00), padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: leaveVillage,
                              child: const Text('Wyrusz w Las 🌲', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8D5B4C), padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: _openMissionsDialog,
                              child: const Text('📜 Biuro Misji'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4B35), padding: const EdgeInsets.symmetric(vertical: 12)),
                              onPressed: _openMedicDialog,
                              child: const Text('🩺 Medyk Konohy'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF236B4A), padding: const EdgeInsets.symmetric(vertical: 12)),
                              onPressed: _openBagDialog,
                              child: Text('🎒 ($totalItemsInBag)'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3B54), padding: const EdgeInsets.symmetric(vertical: 12)),
                              onPressed: _openScrollsDialog,
                              child: Text('📜 (${equippedJutsu.length}/3)'),
                            ),
                          ),
                        ],
                      ),
                      if (activeMissionIndex != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Aktywna misja: Ranga ${allMissionsPool[activeMissionIndex!].rank} ($currentMissionKills/${allMissionsPool[activeMissionIndex!].requiredKills})', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB33A00), padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: proceedMission,
                          child: const Text('Idź naprzód 🌲'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF236B4A), padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: _openBagDialog,
                          child: Text('🎒 ($totalItemsInBag)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: returnToVillage,
                          child: const Text('Ucieczka ⛩️'),
                        ),
                      ),
                    ],
                  ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Align(alignment: Alignment.centerLeft, child: Text('Dziennik:', style: TextStyle(color: Colors.grey, fontSize: 11))),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF0C0B0A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
              child: ListView.builder(
                itemCount: log.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Text(log[index], style: TextStyle(fontFamily: 'monospace', color: index == 0 ? const Color(0xFFFFD59E) : Colors.white60, fontSize: 12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _itemCard(String slot, NinjaGear item, String statText) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: item.isSoulbound ? Colors.amberAccent : item.color.withAlpha(120), width: item.isSoulbound ? 1.5 : 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$slot: ${item.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.color),
                  ),
                ),
                if (item.isSoulbound) const Text(' 📜', style: TextStyle(fontSize: 10)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(statText, style: const TextStyle(fontSize: 9, color: Colors.white70)),
                Text(
                  item.isSoulbound ? 'Zapieczętowany' : '⚠️ Przepada',
                  style: TextStyle(fontSize: 8, color: item.isSoulbound ? Colors.greenAccent : Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
