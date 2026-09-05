import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ShinobiLooterApp());

enum ItemRarity { common, rare, epic, legendary }
enum ConsumableType { healHp, healChakra, buffAtk, maxStats, directDmg, smokeEscape, fullRestore }
enum GearSlot { weapon, armor, helmet, boots }
enum JutsuEffect { none, burn, freeze, stun, lifesteal, shock }
enum EnemyPrefix { weak, normal, strong }

// Materiały do kucia
const String matIronOre = 'mat_iron_ore';
const String matSteel = 'mat_steel';
const String matCrystal = 'mat_crystal';

class CraftingMaterialInfo {
  final String id;
  final String name;
  final String icon;
  final String desc;

  const CraftingMaterialInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.desc,
  });
}

const Map<String, CraftingMaterialInfo> craftingMaterials = {
  matIronOre: CraftingMaterialInfo(id: matIronOre, name: 'Ruda Żelaza Czakry', icon: '🪨', desc: 'Ruda do kucia rynsztunku (+1 do +3).'),
  matSteel: CraftingMaterialInfo(id: matSteel, name: 'Sztaba Tamahagane', icon: '🧱', desc: 'Wzmocniona stal (+4 do +6).'),
  matCrystal: CraftingMaterialInfo(id: matCrystal, name: 'Kryształ Esencji Czakry', icon: '💎', desc: 'Mityczny minerał mistrzowskiego kucia (+7 do +9).'),
};

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
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Standardowy Kunai', baseStat: 4, lore: 'Podstawowe narzędzie każdego ninja.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Składany Shuriken Fūma', baseStat: 6, lore: 'Wirujące ostrza.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Igły Senbon z Ame', baseStat: 5, lore: 'Precyzyjnie paraliżują punkty tenketsu.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Krótki Miecz Tanto ANBU', baseStat: 8, lore: 'Ostrze skrytobójców z Korzenia.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Kastety ze stali czakry', baseStat: 7, lore: 'Wzmacniają ciosy taijutsu.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Dmuchawka z Amegakure', baseStat: 5, lore: 'Miotacz zatrutych igieł.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Włócznia Skalnego Posterunku', baseStat: 9, lore: 'Ciężka broń drzewcowa z Iwagakure.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Bliźniacze Tasaki Kiri', baseStat: 9, lore: 'Agresywny oręż sieczny z Mgły.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Łuk Pajęczej Nici', baseStat: 10, lore: 'Naciąg z utwardzonej nici z czakrą.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Ostrza Czakry Asumy', baseStat: 11, lore: 'Przewodzą ostrą naturę wiatru.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Żelazny Wachlarz Piasku', baseStat: 10, lore: 'Wzbudza gwałtowne fale uderzeniowe.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Kościane Ostrze Yanagi', baseStat: 12, lore: 'Wyjątkowo twardy kościec klanu Kaguya.'),

  // PANCERZE
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Szata Treningowa Genina', baseStat: 3, lore: 'Lekki płócienny strój.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Ochraniacz Klatki Liścia', baseStat: 4, lore: 'Podstawowa kamizelka ochronna.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Skórzana Zbroja Pustyni', baseStat: 5, lore: 'Odporna na piasek i ostre cięcia.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Mundur Bojowy Iwagakure', baseStat: 6, lore: 'Pancerz ciężkiej piechoty ze Skały.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Kamizelka Jonina Konohy', baseStat: 9, lore: 'Oficjalny pancerz taktyczny z kieszeniami na zwoje.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Elitarny Napierśnik ANBU', baseStat: 11, lore: 'Wzmocniona powłoka operacyjna.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Pancerz Bojowy Kumogakure', baseStat: 10, lore: 'Płyta naramienna z elastycznym splotem.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Szata Pustelnika Myōboku', baseStat: 13, lore: 'Szata nasycona energią natury senjutsu.'),

  // GŁOWA
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Ochraniacz Czołowy Protektor', baseStat: 2, lore: 'Metalowa płytka z symbolem wioski.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Maska Oddechowa Amegakure', baseStat: 3, lore: 'Filtruje gazy i trujące opary.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Porcelanowa Maska Lisa ANBU', baseStat: 6, lore: 'Zaciera tożsamość i aurę czakry.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Bandaże Cichego Zabójcy', baseStat: 5, lore: 'Tłumią odgłosy oddechu w gęstej mgle.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Tradycyjny Kapelusz Kage', baseStat: 10, lore: 'Rytualne nakrycie głowy przywódcy.'),

  // BUTY
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Standardowe Sandały Shinobi', baseStat: 2, lore: 'Dobre oparcie stóp na pniach drzew.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Wyciszone Mokasyny ANBU', baseStat: 5, lore: 'Tłumią odgłos kroków przy skradaniu.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Ciężarki Treningowe na Kostki', baseStat: 7, lore: 'Hartują nogi pod kątem natychmiastowego zrywu.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Drewniane Geta Żabiego Mędrca', baseStat: 9, lore: 'Idealny balans na śliskich skałach.'),
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
  LegendaryGearTemplate(name: 'Miecz Totsuka (Sakegari)', slot: GearSlot.weapon, baseStat: 36, bonusEffect: 'Pieczęć Wiecznego Snu', bonusValue: 8, lore: 'Widmowe ostrze pieczętujące w tykwie.'),
  LegendaryGearTemplate(name: 'Miecz Kusanagi Orochimaru', slot: GearSlot.weapon, baseStat: 33, bonusEffect: 'Niezniszczalna Stal', bonusValue: 7, lore: 'Ostrze zdolne przeciąć diament.'),
  LegendaryGearTemplate(name: 'Samehada (Żarłacz Kisame)', slot: GearSlot.weapon, baseStat: 34, bonusEffect: 'Pożeranie Czakry', bonusValue: 8, lore: 'Żywy miecz wysysający energię przeciwnika.'),
  LegendaryGearTemplate(name: 'Wojenny Wachlarz Gunbai Madary', slot: GearSlot.weapon, baseStat: 35, bonusEffect: 'Odbicie Uchihagaeshi', bonusValue: 8, lore: 'Odbija techniki ninjutsu w napastnika.'),
  LegendaryGearTemplate(name: 'Miecz Nunoboko Hagoromo', slot: GearSlot.weapon, baseStat: 42, bonusEffect: 'Stworzenie Świata Rikudō', bonusValue: 10, lore: 'Spiralna broń z czarnych kul Gudōdama.'),
  LegendaryGearTemplate(name: 'Klatka Żebrowa Susanoo', slot: GearSlot.armor, baseStat: 31, bonusEffect: 'Absolutny Kościec', bonusValue: 7, lore: 'Eteryczny pancerz z płomieni czakry.'),
  LegendaryGearTemplate(name: 'Pancerz Ostatecznego Susanoo', slot: GearSlot.armor, baseStat: 38, bonusEffect: 'Bóstwo Zniszczenia', bonusValue: 10, lore: 'Skrzydlata zbroja niszcząca góry.'),
  LegendaryGearTemplate(name: 'Szata Mędrca Sześciu Ścieżek', slot: GearSlot.armor, baseStat: 35, bonusEffect: 'Harmonia Yin-Yang', bonusValue: 9, lore: 'Biała szata z motywem magatama.'),
  LegendaryGearTemplate(name: 'Maska Jednoocznego Wiru (Obito)', slot: GearSlot.helmet, baseStat: 29, bonusEffect: 'Pusta Niematerialność', bonusValue: 7, lore: 'Ułatwia manipulację wymiarem Kamui.'),
  LegendaryGearTemplate(name: 'Korona Rogatej Bogini Kaguya', slot: GearSlot.helmet, baseStat: 32, bonusEffect: 'Wizja Byakugana', bonusValue: 8, lore: 'Relikt Świętego Drzewa.'),
  LegendaryGearTemplate(name: 'Obuwie Żółtego Błysku (Hiraishin)', slot: GearSlot.boots, baseStat: 29, bonusEffect: 'Teleportacja Błysku', bonusValue: 7, lore: 'Sandały Minato z wyrytą formułą pieczęci.'),
  LegendaryGearTemplate(name: 'Lewitujące Płyty Rikudō', slot: GearSlot.boots, baseStat: 33, bonusEffect: 'Lot Ponad Prawami Świata', bonusValue: 8, lore: 'Płyty unoszące shinobi nad ziemią.'),
];

class NinjaGear {
  final String name;
  final ItemRarity rarity;
  final int baseStat;
  final String bonusEffect;
  final int bonusValue;
  final bool isSoulbound;
  final int upgradeLevel; // 0..9

  const NinjaGear({
    required this.name,
    required this.rarity,
    required this.baseStat,
    required this.bonusEffect,
    required this.bonusValue,
    this.isSoulbound = false,
    this.upgradeLevel = 0,
  });

  NinjaGear copyWith({
    String? name,
    ItemRarity? rarity,
    int? baseStat,
    String? bonusEffect,
    int? bonusValue,
    bool? isSoulbound,
    int? upgradeLevel,
  }) {
    return NinjaGear(
      name: name ?? this.name,
      rarity: rarity ?? this.rarity,
      baseStat: baseStat ?? this.baseStat,
      bonusEffect: bonusEffect ?? this.bonusEffect,
      bonusValue: bonusValue ?? this.bonusValue,
      isSoulbound: isSoulbound ?? this.isSoulbound,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
    );
  }

  int get effectiveStat {
    // Każdy poziom ulepszenia daje bonus do statystyki
    return baseStat + (upgradeLevel * (2 + rarity.index));
  }

  String get displayName => upgradeLevel > 0 ? '$name +$upgradeLevel' : name;

  Map<String, dynamic> toJson() => {
        'name': name,
        'rarity': rarity.index,
        'baseStat': baseStat,
        'bonusEffect': bonusEffect,
        'bonusValue': bonusValue,
        'isSoulbound': isSoulbound,
        'upgradeLevel': upgradeLevel,
      };

  factory NinjaGear.fromJson(Map<String, dynamic> json) => NinjaGear(
        name: json['name'],
        rarity: ItemRarity.values[json['rarity']],
        baseStat: json['baseStat'],
        bonusEffect: json['bonusEffect'],
        bonusValue: json['bonusValue'],
        isSoulbound: json['isSoulbound'] ?? false,
        upgradeLevel: json['upgradeLevel'] ?? 0,
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
        return 'Mistrzowski';
      case ItemRarity.epic:
        return 'Pradawny';
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
  Consumable(id: 'c_pill', name: 'Pigułka Żywnościowa', description: '+35 Czakry (CP).', type: ConsumableType.healChakra, value: 35, price: 25, icon: '💊'),
  Consumable(id: 'c_dango', name: 'Słodkie Dango', description: '+20 Zdrowia (HP).', type: ConsumableType.healHp, value: 20, price: 18, icon: '🍡'),
  Consumable(id: 'c_ointment', name: 'Balsam Ziołowy Medyka', description: '+50 Zdrowia (HP).', type: ConsumableType.healHp, value: 50, price: 45, icon: '🧴'),
  Consumable(id: 'c_ramen', name: 'Ramen Ichiraku', description: 'Pełne leczenie HP i CP oraz +10 Max statystyk.', type: ConsumableType.fullRestore, value: 10, price: 130, icon: '🍜'),
  Consumable(id: 'c_power_pill', name: 'Pigułka Siły', description: '+3 do stałego Ataku.', type: ConsumableType.buffAtk, value: 3, price: 110, icon: '⚡'),
  Consumable(id: 'c_kibaku', name: 'Pieczęć Wybuchowa', description: 'Zadaje 30 dmg w walce.', type: ConsumableType.directDmg, value: 30, price: 45, icon: '🏷️'),
  Consumable(id: 'c_smoke', name: 'Bomba Dymna', description: 'Gwarantowana ucieczka z walki.', type: ConsumableType.smokeEscape, value: 0, price: 35, icon: '💨'),
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
        return 'Zamrożenie: Unieruchamia wroga na $effectDuration turę';
      case JutsuEffect.stun:
        return 'Ogłuszenie: Wróg traci $effectDuration turę';
      case JutsuEffect.lifesteal:
        return 'Wyssanie: Leczy HP o $effectValue% zadanych obrażeń';
      case JutsuEffect.shock:
        return 'Paraliż: 50% szansy na utratę tury przez wroga';
      case JutsuEffect.none:
        return 'Czyste obrażenia fizyczne/czakry';
    }
  }
}

const List<Jutsu> allJutsuPool = [
  Jutsu(id: 'j_taijutsu', name: 'Podstawowe Taijutsu', chakraCost: 0, powerMultiplier: 1, costRyo: 0, color: Colors.blueGrey),
  Jutsu(id: 'j_konoha_senpuu', name: 'Konoha Senpū', chakraCost: 10, powerMultiplier: 2, costRyo: 150, color: Colors.lightGreen, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_katon', name: 'Katon: Goukakyu', chakraCost: 16, powerMultiplier: 2, costRyo: 220, color: Colors.deepOrange, effect: JutsuEffect.burn, effectDuration: 2, effectValue: 6),
  Jutsu(id: 'j_housenka', name: 'Katon: Hōsenka', chakraCost: 22, powerMultiplier: 3, costRyo: 350, color: Colors.orangeAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 9),
  Jutsu(id: 'j_gouka_mekkyaku', name: 'Katon: Gouka Mekkyaku', chakraCost: 42, powerMultiplier: 4, costRyo: 800, color: Colors.redAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 14),
  Jutsu(id: 'j_amaterasu', name: 'Amaterasu', chakraCost: 55, powerMultiplier: 5, costRyo: 1500, color: Colors.deepPurple, effect: JutsuEffect.burn, effectDuration: 4, effectValue: 20),
  Jutsu(id: 'j_suirou', name: 'Suiton: Wodne Więzienie', chakraCost: 24, powerMultiplier: 2, costRyo: 380, color: Colors.blue, effect: JutsuEffect.freeze, effectDuration: 1),
  Jutsu(id: 'j_makyou_hyoushou', name: 'Hyōton: Lodowe Lustra Haku', chakraCost: 34, powerMultiplier: 3, costRyo: 600, color: Colors.cyanAccent, effect: JutsuEffect.freeze, effectDuration: 2),
  Jutsu(id: 'j_fuuton', name: 'Fuuton: Daitoppa', chakraCost: 14, powerMultiplier: 2, costRyo: 200, color: Colors.teal),
  Jutsu(id: 'j_rasenshuriken', name: 'Fuuton: Rasenshuriken', chakraCost: 50, powerMultiplier: 5, costRyo: 1350, color: Colors.tealAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 18),
  Jutsu(id: 'j_raiton', name: 'Chidori', chakraCost: 30, powerMultiplier: 3, costRyo: 500, color: Colors.cyan, effect: JutsuEffect.shock),
  Jutsu(id: 'j_kirin', name: 'Raiton: Kirin', chakraCost: 60, powerMultiplier: 6, costRyo: 1700, color: Colors.blueAccent, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_doryuheki', name: 'Doton: Błotna Ściana', chakraCost: 18, powerMultiplier: 2, costRyo: 260, color: Colors.lime, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_mokuton_drag', name: 'Mokuton: Drewniany Smok', chakraCost: 46, powerMultiplier: 4, costRyo: 1050, color: Colors.greenAccent, effect: JutsuEffect.lifesteal, effectValue: 30),
  Jutsu(id: 'j_rasengan', name: 'Rasengan', chakraCost: 32, powerMultiplier: 3, costRyo: 550, color: Colors.blueAccent),
  Jutsu(id: 'j_bijuudama', name: 'Bijuudama', chakraCost: 80, powerMultiplier: 7, costRyo: 2600, color: Colors.purpleAccent, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_kamui', name: 'Kamui', chakraCost: 50, powerMultiplier: 4, costRyo: 1800, color: Colors.grey, effect: JutsuEffect.freeze, effectDuration: 2),
];

class EnemyTemplate {
  final String name;
  final String title;
  final int baseHp;
  final int baseAtk;
  final bool isBoss;
  final bool isBeast;

  const EnemyTemplate({
    required this.name,
    required this.title,
    required this.baseHp,
    required this.baseAtk,
    this.isBoss = false,
    this.isBeast = false,
  });
}

// BAZA WROGÓW (LUDZIE + ZWIERZĘTA)
const List<EnemyTemplate> standardEnemiesPool = [
  // Zwierzęta leśne
  EnemyTemplate(name: 'Dziki Ninja-Pies', title: 'Zdziczały Ninken', baseHp: 20, baseAtk: 6, isBeast: true),
  EnemyTemplate(name: 'Leśny Odyniec Kraju Ognia', title: 'Szarżująca Bestia', baseHp: 28, baseAtk: 7, isBeast: true),
  EnemyTemplate(name: 'Gigantyczny Pająk z Mgły', title: 'Drapieżnik Pajęczyn', baseHp: 24, baseAtk: 8, isBeast: true),
  EnemyTemplate(name: 'Niedźwiedź z Lasu Śmierci', title: 'Monstrum z Puszczy', baseHp: 38, baseAtk: 9, isBeast: true),
  EnemyTemplate(name: 'Święty Jeleń Klanu Nara', title: 'Zwinny Strażnik Boru', baseHp: 26, baseAtk: 7, isBeast: true),

  // Ludzie / Shinobi
  EnemyTemplate(name: 'Bandyta z Kraju Fal', title: 'Pospolity Rabuś', baseHp: 24, baseAtk: 6),
  EnemyTemplate(name: 'Zbuntowany Ninja Deszczu', title: 'Nuke-nin z Amegakure', baseHp: 28, baseAtk: 7),
  EnemyTemplate(name: 'Szpieg z Iwagakure', title: 'Zwiadowca Skały', baseHp: 32, baseAtk: 8),
  EnemyTemplate(name: 'Kukiełkarz z Sunagakure', title: 'Mistrz Drewnianych Ostrzy', baseHp: 30, baseAtk: 9),
  EnemyTemplate(name: 'Klon Białego Zetsu', title: 'Infiltrator Mokuton', baseHp: 34, baseAtk: 8),
  EnemyTemplate(name: 'Zabójca z Mgły (Kiri)', title: 'Skrytobójca Cichego Zabijania', baseHp: 38, baseAtk: 10),
  EnemyTemplate(name: 'Cień Korzenia ANBU', title: 'Wojownik Bez Emocji', baseHp: 42, baseAtk: 11),
  EnemyTemplate(name: 'Jirōbō', title: 'Strażnik Bramy Dźwięku', baseHp: 46, baseAtk: 10),
  EnemyTemplate(name: 'Tayuya', title: 'Iluzjonistka Dźwięku', baseHp: 36, baseAtk: 12),
];

const List<EnemyTemplate> bossesPool = [
  EnemyTemplate(name: 'Zabuza Momochi', title: 'Demon Ukrytej Mgły', baseHp: 90, baseAtk: 15, isBoss: true),
  EnemyTemplate(name: 'Haku', title: 'Mistrz Lodowych Luster Hyōton', baseHp: 80, baseAtk: 16, isBoss: true),
  EnemyTemplate(name: 'Gaara Pustyni', title: 'Głos Shukaku', baseHp: 110, baseAtk: 14, isBoss: true),
  EnemyTemplate(name: 'Kimimaro Kaguya', title: 'Taniec Kości', baseHp: 100, baseAtk: 18, isBoss: true),
  EnemyTemplate(name: 'Orochimaru', title: 'Legendarny Wężowy Sannin', baseHp: 135, baseAtk: 20, isBoss: true),
  EnemyTemplate(name: 'Sasori', title: 'Czerwony Piasek', baseHp: 125, baseAtk: 21, isBoss: true),
  EnemyTemplate(name: 'Itachi Uchiha', title: 'Mistrz Mangekyō Sharingana', baseHp: 135, baseAtk: 24, isBoss: true),
  EnemyTemplate(name: 'Pain (Tendo)', title: 'Bóg Sześciu Ścieżek', baseHp: 175, baseAtk: 28, isBoss: true),
  EnemyTemplate(name: 'Madara Uchiha', title: 'Duch Klanu Uchiha', baseHp: 210, baseAtk: 32, isBoss: true),
];

// EGZAMINATORZY NA ARENIE KONOHY
class ExamStage {
  final int targetRankIndex; // 1: Genin, 2: Chunin, 3: Tokubetsu Jonin, 4: Jonin, 5: Sannin
  final String rankTitle;
  final int requiredLevel;
  final String examinerName;
  final String examinerTitle;
  final int hp;
  final int atk;
  final String lore;

  const ExamStage({
    required this.targetRankIndex,
    required this.rankTitle,
    required this.requiredLevel,
    required this.examinerName,
    required this.examinerTitle,
    required this.hp,
    required this.atk,
    required this.lore,
  });
}

const List<ExamStage> shinobiExams = [
  ExamStage(
    targetRankIndex: 1,
    rankTitle: 'Genin',
    requiredLevel: 4,
    examinerName: 'Iruka Umino',
    examinerTitle: 'Instruktor Akademii Ninja',
    hp: 45,
    atk: 8,
    lore: '„Pokaż mi, że potrafisz skupić czakrę i władać podstawowym orężem!”',
  ),
  ExamStage(
    targetRankIndex: 2,
    rankTitle: 'Chūnin',
    requiredLevel: 12,
    examinerName: 'Ibiki Morino',
    examinerTitle: 'Dowódca Wydziału Śledczego ANBU',
    hp: 95,
    atk: 14,
    lore: '„Egzamin Chūnina to nie zabawa. Sprawdzę twoją determinację w obliczu bólu!”',
  ),
  ExamStage(
    targetRankIndex: 3,
    rankTitle: 'Tokubetsu Jōnin',
    requiredLevel: 22,
    examinerName: 'Anko Mitarashi',
    examinerTitle: 'Egzaminatorka Lasu Śmierci',
    hp: 145,
    atk: 19,
    lore: '„Pora sprawdzić twój refleks przeciwko wężom i morderczemu tempu!”',
  ),
  ExamStage(
    targetRankIndex: 4,
    rankTitle: 'Jōnin Bojowy',
    requiredLevel: 34,
    examinerName: 'Kakashi Hatake',
    examinerTitle: 'Kopiujący Ninja z Konohy',
    hp: 210,
    atk: 25,
    lore: '„Test dwóch dzwonków to przeszłość. Pora na prawdziwy pojedynek shinobi.”',
  ),
  ExamStage(
    targetRankIndex: 5,
    rankTitle: 'Legendarny Sannin',
    requiredLevel: 46,
    examinerName: 'Jiraiya (Żabi Mędrzec)',
    examinerTitle: 'Legendarny Sannin z Góry Myōboku',
    hp: 285,
    atk: 31,
    lore: '„Ha! Udowodnij, że płonie w tobie wola ognia godna miana legendy!”',
  ),
];

class ShinobiMission {
  final String id;
  final String rank;
  final int minRankIndex; // Wymagana zdana ranga egzaminacyjna (0..5)
  final String title;
  final String desc;
  final int requiredKills;
  final int rewardRyo;
  final int rewardExp;

  const ShinobiMission({
    required this.id,
    required this.rank,
    required this.minRankIndex,
    required this.title,
    required this.desc,
    required this.requiredKills,
    required this.rewardRyo,
    required this.rewardExp,
  });
}

// ZWIĘKSZONE WYMAGANIA MISJI
const List<ShinobiMission> allMissionsPool = [
  ShinobiMission(id: 'm_d1', rank: 'D', minRankIndex: 0, title: 'Odchwaszczanie Ogrodów Daimyō', desc: 'Wyeliminuj 4 szkodniki w lasach Liścia.', requiredKills: 4, rewardRyo: 45, rewardExp: 22),
  ShinobiMission(id: 'm_d2', rank: 'D', minRankIndex: 0, title: 'Poszukiwanie Kota Tora', desc: 'Przepędź 5 leśnych bestii i zabezpiecz teren.', requiredKills: 5, rewardRyo: 65, rewardExp: 28),
  ShinobiMission(id: 'm_d3', rank: 'D', minRankIndex: 1, title: 'Patrol Graniczny Wioski', desc: 'Odpędź 7 włóczęgów sprzed bram Liścia.', requiredKills: 7, rewardRyo: 85, rewardExp: 38),

  ShinobiMission(id: 'm_c1', rank: 'C', minRankIndex: 2, title: 'Eskorta Mostowniczego Tazuny', desc: 'Wyeliminuj 8 bandytów z Kraju Fal.', requiredKills: 8, rewardRyo: 170, rewardExp: 75),
  ShinobiMission(id: 'm_c2', rank: 'C', minRankIndex: 2, title: 'Ochrona Karawany z Suny', desc: 'Zlikwiduj 9 pustynnych koczowników na szlaku.', requiredKills: 9, rewardRyo: 210, rewardExp: 90),
  ShinobiMission(id: 'm_c3', rank: 'C', minRankIndex: 2, title: 'Odzyskanie Skradzionego Zwoju', desc: 'Dopadnij 10 zbiegłych rzezimieszków.', requiredKills: 10, rewardRyo: 250, rewardExp: 110),

  ShinobiMission(id: 'm_b1', rank: 'B', minRankIndex: 3, title: 'Polowanie na Szpiegów ze Skały', desc: 'Zneutralizuj 12 zwiadowców wrogiej nacji.', requiredKills: 12, rewardRyo: 380, rewardExp: 160),
  ShinobiMission(id: 'm_b2', rank: 'B', minRankIndex: 3, title: 'Infiltracja Bazy Otogakure', desc: 'Wyeliminuj 13 eksperymentów Węża.', requiredKills: 13, rewardRyo: 440, rewardExp: 190),
  ShinobiMission(id: 'm_b3', rank: 'B', minRankIndex: 3, title: 'Zasadzka na Czwórkę Dźwięku', desc: 'Pokonaj 14 strażników bramy dźwięku.', requiredKills: 14, rewardRyo: 500, rewardExp: 220),

  ShinobiMission(id: 'm_a1', rank: 'A', minRankIndex: 4, title: 'Pojmanie Członków Akatsuki', desc: 'Pokonaj 16 elitarnych wojowników w chmurach.', requiredKills: 16, rewardRyo: 720, rewardExp: 310),
  ShinobiMission(id: 'm_a2', rank: 'A', minRankIndex: 4, title: 'Obrona Konohy przed Inwazją', desc: 'Wyeliminuj 18 uderzeniowych shinobi wrogich wiosek.', requiredKills: 18, rewardRyo: 850, rewardExp: 370),
  ShinobiMission(id: 'm_a3', rank: 'A', minRankIndex: 4, title: 'Tajne Zlecenie Korzenia ANBU', desc: 'Dokonaj egzekucji 20 zdrajców Wioski.', requiredKills: 20, rewardRyo: 1000, rewardExp: 430),

  ShinobiMission(id: 'm_s1', rank: 'S', minRankIndex: 5, title: 'Ocalenie Świata przed Shinra Tensei', desc: 'Zgładź 22 bóstwa ścieżek bólu.', requiredKills: 22, rewardRyo: 1500, rewardExp: 650),
  ShinobiMission(id: 'm_s2', rank: 'S', minRankIndex: 5, title: 'Powstrzymanie Madary Uchiha', desc: 'Pokonaj 25 wskrzeszonych legend Edo Tensei.', requiredKills: 25, rewardRyo: 2000, rewardExp: 850),
  ShinobiMission(id: 'm_s3', rank: 'S', minRankIndex: 5, title: 'Pojedynek z Boginią Kaguya', desc: 'Pokonaj 28 międzywymiarowych abominacji.', requiredKills: 28, rewardRyo: 2800, rewardExp: 1200),
];

const NinjaGear defaultStarterWeapon = NinjaGear(name: 'Podstawowy Kunai', rarity: ItemRarity.common, baseStat: 4, bonusEffect: 'Brak', bonusValue: 0, isSoulbound: true);
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

  // SYSTEM HP I CZAKRY
  int hp = 100;
  int maxHp = 100;
  int chakra = 80;
  int maxChakra = 80;

  int bonusAtk = 0;
  int ryo = 60;
  int ninjaExp = 0;
  int masteryPoints = 0;
  int passedRankIndex = 0; // 0: Nowicjusz, 1: Genin, 2: Chunin, 3: Tokubetsu, 4: Jonin, 5: Sannin
  bool isLoading = true;

  int? activeMissionIndex;
  int currentMissionKills = 0;
  Set<String> completedMissionsHistory = {};

  // PLECAK ZWYKŁY I ZAPROCIEWIONY (DUAL-STACK)
  Map<String, int> bag = {'c_pill': 2, 'c_dango': 1, 'c_kibaku': 1, 'c_smoke': 1};
  Map<String, int> sealedBag = {};

  // MATERIAŁY RZEMIEŚLNICZE
  Map<String, int> craftingBag = {matIronOre: 2};

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

  // Wzór: EXP = 130 * L^2.15
  static int expRequiredForLevel(int lvl) {
    if (lvl <= 1) return 0;
    return (130 * pow(lvl, 2.15)).floor();
  }

  int get expForNextLevel => level >= softCapLevel ? expRequiredForLevel(softCapLevel) : expRequiredForLevel(level + 1);

  String get ninjaRank {
    switch (passedRankIndex) {
      case 5:
        return 'Legendarny Sannin / Kage';
      case 4:
        return 'Jōnin Bojowy';
      case 3:
        return 'Tokubetsu Jōnin';
      case 2:
        return 'Chūnin';
      case 1:
        return 'Genin';
      default:
        return 'Nowicjusz Akademii';
    }
  }

  Color get rankColor {
    switch (passedRankIndex) {
      case 5:
        return Colors.amber;
      case 4:
        return Colors.redAccent;
      case 3:
        return Colors.purpleAccent;
      case 2:
        return Colors.blueAccent;
      case 1:
        return Colors.greenAccent;
      default:
        return Colors.white60;
    }
  }

  int get totalAttack => currentWeapon.effectiveStat + currentWeapon.bonusValue + bonusAtk + (level * 2);
  int get totalDefense => currentArmor.effectiveStat + currentArmor.bonusValue + currentHelmet.effectiveStat + currentHelmet.bonusValue + currentBoots.effectiveStat + currentBoots.bonusValue;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      km = prefs.getInt('km') ?? 0;
      hp = prefs.getInt('hp') ?? 100;
      maxHp = prefs.getInt('maxHp') ?? 100;
      chakra = prefs.getInt('chakra') ?? 80;
      maxChakra = prefs.getInt('maxChakra') ?? 80;
      bonusAtk = prefs.getInt('bonusAtk') ?? 0;
      ryo = prefs.getInt('ryo') ?? 60;
      ninjaExp = prefs.getInt('ninjaExp') ?? 0;
      masteryPoints = prefs.getInt('masteryPoints') ?? 0;
      passedRankIndex = prefs.getInt('passedRankIndex') ?? 0;
      inVillage = prefs.getBool('inVillage') ?? true;
      activeMissionIndex = prefs.getInt('activeMissionIndex');
      currentMissionKills = prefs.getInt('currentMissionKills') ?? 0;

      final completedList = prefs.getStringList('completedMissionsHistory');
      if (completedList != null) completedMissionsHistory = completedList.toSet();

      final bagJson = prefs.getString('ninjaBag');
      if (bagJson != null) bag = Map<String, int>.from(jsonDecode(bagJson));

      final sealedBagJson = prefs.getString('sealedBag');
      if (sealedBagJson != null) sealedBag = Map<String, int>.from(jsonDecode(sealedBagJson));

      final craftJson = prefs.getString('craftingBag');
      if (craftJson != null) craftingBag = Map<String, int>.from(jsonDecode(craftJson));

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
    await prefs.setInt('hp', hp);
    await prefs.setInt('maxHp', maxHp);
    await prefs.setInt('chakra', chakra);
    await prefs.setInt('maxChakra', maxChakra);
    await prefs.setInt('bonusAtk', bonusAtk);
    await prefs.setInt('ryo', ryo);
    await prefs.setInt('ninjaExp', ninjaExp);
    await prefs.setInt('masteryPoints', masteryPoints);
    await prefs.setInt('passedRankIndex', passedRankIndex);
    await prefs.setBool('inVillage', inVillage);
    await prefs.setStringList('completedMissionsHistory', completedMissionsHistory.toList());

    if (activeMissionIndex != null) {
      await prefs.setInt('activeMissionIndex', activeMissionIndex!);
    } else {
      await prefs.remove('activeMissionIndex');
    }
    await prefs.setInt('currentMissionKills', currentMissionKills);
    await prefs.setString('ninjaBag', jsonEncode(bag));
    await prefs.setString('sealedBag', jsonEncode(sealedBag));
    await prefs.setString('craftingBag', jsonEncode(craftingBag));
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
      final newMasteryEarned = surplus ~/ 5000;
      if (newMasteryEarned > 0) {
        masteryPoints += newMasteryEarned;
        ninjaExp = capExp + (surplus % 5000);
        addLog('🎖️ Osiągnięto Biegłość Shinobi! (+1 pkt)');
      }
    }

    if (level > oldLvl) {
      addLog('⚡ AWANS! Osiągnięto Poziom $level!');
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
    final unsealedLostCount = bag.values.fold(0, (a, b) => a + b);
    int lostEquippedPieces = 0;

    setState(() {
      inVillage = true;
      km = 0;
      hp = maxHp;
      chakra = maxChakra;
      bag.clear(); // Przepadają tylko niezapieczętowane!

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
      addLog('💀 Porażka w terenie! Medyk Konohy z trudem odratował twoje życie.');
    } else {
      addLog('⛩️ Bezpieczny powrót za bramy Wioski Liścia. Zdrowie i Czakra odnowione.');
    }

    if (unsealedLostCount > 0 || lostEquippedPieces > 0) {
      addLog('⚠️ Fūinjutsu: Utracono $unsealedLostCount niezabezpieczonych zapasów oraz $lostEquippedPieces elementów ekwipunku!');
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

  void addCraftingMaterial(String matId, [int count = 1]) {
    craftingBag[matId] = (craftingBag[matId] ?? 0) + count;
    _saveGameData();
  }

  bool useConsumable(Consumable item) {
    // W pierwszej kolejności zużywamy zwykłe zapasy, by chronić zapieczętowane
    bool fromUnsealed = (bag[item.id] ?? 0) > 0;
    bool fromSealed = (sealedBag[item.id] ?? 0) > 0;

    if (!fromUnsealed && !fromSealed) return false;

    setState(() {
      if (fromUnsealed) {
        bag[item.id] = bag[item.id]! - 1;
        if (bag[item.id] == 0) bag.remove(item.id);
      } else {
        sealedBag[item.id] = sealedBag[item.id]! - 1;
        if (sealedBag[item.id] == 0) sealedBag.remove(item.id);
      }

      switch (item.type) {
        case ConsumableType.healHp:
          hp = min(maxHp, hp + item.value);
          addLog('${item.icon} Użyto [${item.name}]: +${item.value} HP.');
          break;
        case ConsumableType.healChakra:
          chakra = min(maxChakra, chakra + item.value);
          addLog('${item.icon} Użyto [${item.name}]: +${item.value} CP.');
          break;
        case ConsumableType.fullRestore:
          maxHp += item.value;
          maxChakra += item.value;
          hp = maxHp;
          chakra = maxChakra;
          addLog('${item.icon} Zjedzono [${item.name}]! Pełne leczenie i +${item.value} limitów HP/CP.');
          break;
        case ConsumableType.buffAtk:
          bonusAtk += item.value;
          addLog('${item.icon} Użyto [${item.name}]: +${item.value} Ataku.');
          break;
        case ConsumableType.maxStats:
          maxHp += item.value;
          hp += item.value;
          addLog('${item.icon} Użyto [${item.name}]: +${item.value} limitu HP.');
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
    if (hp <= 0) return;

    final nextKm = km + 5;
    setState(() => km = nextKm);
    _saveGameData();

    final bool bossSpawnTriggered = (nextKm % 25 == 0) || (_rng.nextInt(100) < (10 + min(12, nextKm ~/ 20)));
    final roll = _rng.nextInt(100);

    if (bossSpawnTriggered && roll < 38) {
      final randomBoss = bossesPool[_rng.nextInt(bossesPool.length)];
      _startBattleWithEnemy(randomBoss, forcePrefix: EnemyPrefix.normal);
    } else if (roll < 62) {
      final randomEnemy = standardEnemiesPool[_rng.nextInt(standardEnemiesPool.length)];
      // Losujemy prefiks przeciwnika
      final pRoll = _rng.nextInt(100);
      EnemyPrefix p = pRoll < 30 ? EnemyPrefix.weak : (pRoll < 80 ? EnemyPrefix.normal : EnemyPrefix.strong);
      _startBattleWithEnemy(randomEnemy, forcePrefix: p);
    } else if (roll < 76) {
      _findLoot();
    } else if (roll < 86) {
      _encounterSealMaster();
    } else if (roll < 93) {
      _encounterWanderingSage();
    } else {
      addLog('Km $km: Przemieszczasz się przez gęste lasy Kraju Ognia.');
    }
  }

  // MISTRZ PIECZĘCI (SPRZĘT + POJEDYNCZE ZAPASY)
  void _encounterSealMaster() {
    final unsealedSlots = <GearSlot, NinjaGear>{};
    if (!currentWeapon.isSoulbound) unsealedSlots[GearSlot.weapon] = currentWeapon;
    if (!currentArmor.isSoulbound) unsealedSlots[GearSlot.armor] = currentArmor;
    if (!currentHelmet.isSoulbound) unsealedSlots[GearSlot.helmet] = currentHelmet;
    if (!currentBoots.isSoulbound) unsealedSlots[GearSlot.boots] = currentBoots;

    // Przedmioty w plecaku, które można zapieczętować (tylko 1 sztuka danego typu w sealedBag!)
    final sealableBagItems = bag.keys.where((id) => (sealedBag[id] ?? 0) == 0).toList();

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '„Zabezpieczę twój oręż lub pojedynczą sztukę zapasu przed utratą po powrocie do wioski!”',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    const Text('Pieczętowanie rynsztunku:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    if (unsealedSlots.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Cały założony sprzęt jest zabezpieczony!', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                      )
                    else
                      ...unsealedSlots.entries.map((entry) {
                        final slot = entry.key;
                        final gear = entry.value;

                        int cost;
                        switch (gear.rarity) {
                          case ItemRarity.common:
                            cost = 180;
                            break;
                          case ItemRarity.rare:
                            cost = 550;
                            break;
                          case ItemRarity.epic:
                            cost = 1400;
                            break;
                          case ItemRarity.legendary:
                            cost = 3200;
                            break;
                        }

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

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('$slotName: ${gear.displayName}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gear.color)),
                          subtitle: Text('Koszt: $cost Ryo', style: const TextStyle(fontSize: 9, color: Colors.amberAccent)),
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
                                    addLog('🈴 Zapieczętowano trwale: ${gear.name} (-$cost Ryo)!');
                                  }
                                : null,
                            child: const Text('Zapieczętuj', style: TextStyle(fontSize: 9)),
                          ),
                        );
                      }),
                    const Divider(color: Colors.white12),
                    const Text('Zabezpieczenie zapasów (max 1 szt. danego typu):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                    const SizedBox(height: 4),
                    if (sealableBagItems.isEmpty)
                      const Text('Brak zapasów kwalifikujących się do pieczęci.', style: TextStyle(fontSize: 10, color: Colors.white54))
                    else
                      ...sealableBagItems.map((id) {
                        final item = allConsumables.firstWhere((c) => c.id == id);
                        final cost = 40 + (item.price * 0.7).round();

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(item.icon, style: const TextStyle(fontSize: 18)),
                          title: Text(item.name, style: const TextStyle(fontSize: 11)),
                          subtitle: Text('Pieczęć: $cost Ryo', style: const TextStyle(fontSize: 9, color: Colors.amberAccent)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade900),
                            onPressed: ryo >= cost
                                ? () {
                                    setState(() {
                                      ryo -= cost;
                                      bag[id] = bag[id]! - 1;
                                      if (bag[id] == 0) bag.remove(id);
                                      sealedBag[id] = 1;
                                    });
                                    _saveGameData();
                                    Navigator.pop(ctx);
                                    addLog('🈴 Bezpieczny Prowiant: Zapieczętowano 1x [${item.name}] (-$cost Ryo)!');
                                  }
                                : null,
                            child: const Text('Zabezpiecz', style: TextStyle(fontSize: 9)),
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    Text('Posiadasz: $ryo Ryo', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  addLog('Km $km: Zrezygnowano z pieczętowania.');
                },
                child: const Text('Odejdź', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }

  // KOWAL WIOSKI KONOHA (ULEPSZENIA +1 DO +9)
  void _openBlacksmithDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSmithState) {
          final items = [
            {'slot': 'Broń', 'gear': currentWeapon, 'slotEnum': GearSlot.weapon},
            {'slot': 'Pancerz', 'gear': currentArmor, 'slotEnum': GearSlot.armor},
            {'slot': 'Głowa', 'gear': currentHelmet, 'slotEnum': GearSlot.helmet},
            {'slot': 'Buty', 'gear': currentBoots, 'slotEnum': GearSlot.boots},
          ];

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1712),
            title: const Row(
              children: [
                Text('🔨 ', style: TextStyle(fontSize: 22)),
                Expanded(child: Text('Zbrojmistrz Konohy (Kowal)', style: TextStyle(color: Colors.orangeAccent))),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '„Przekuj rynsztunek na wyższy poziom (+1..+9)! Do ulepszeń potrzebujesz odpowiednich rud czakry i Ryo.”',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('🪨 Ruda: ${craftingBag[matIronOre] ?? 0}', style: const TextStyle(fontSize: 10)),
                        Text('🧱 Stal: ${craftingBag[matSteel] ?? 0}', style: const TextStyle(fontSize: 10)),
                        Text('💎 Kryształ: ${craftingBag[matCrystal] ?? 0}', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    ...items.map((entry) {
                      final slotLabel = entry['slot'] as String;
                      final gear = entry['gear'] as NinjaGear;
                      final slotEnum = entry['slotEnum'] as GearSlot;

                      final int curLvl = gear.upgradeLevel;
                      final bool isMax = curLvl >= 9;

                      String neededMatId = matIronOre;
                      int neededMatCount = 1;
                      int ryoCost = 50 + (curLvl * 35) + (gear.rarity.index * 40);

                      if (curLvl >= 6) {
                        neededMatId = matCrystal;
                        neededMatCount = 1;
                        ryoCost += 180;
                      } else if (curLvl >= 3) {
                        neededMatId = matSteel;
                        neededMatCount = 1;
                        ryoCost += 70;
                      }

                      final matInfo = craftingMaterials[neededMatId]!;
                      final bool hasMats = (craftingBag[neededMatId] ?? 0) >= neededMatCount;
                      final bool canUpgrade = !isMax && ryo >= ryoCost && hasMats;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: gear.color.withAlpha(90)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$slotLabel: ${gear.displayName}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: gear.color)),
                                Text('Moc: +${gear.effectiveStat}', style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            if (isMax)
                              const Text('Maksymalny poziom kuźniczy (+9)!', style: TextStyle(color: Colors.amberAccent, fontSize: 10))
                            else ...[
                              Text('Wymaga: ${matInfo.icon} 1x ${matInfo.name} oraz $ryoCost Ryo', style: const TextStyle(fontSize: 9, color: Colors.white60)),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                  onPressed: canUpgrade
                                      ? () {
                                          setState(() {
                                            ryo -= ryoCost;
                                            craftingBag[neededMatId] = craftingBag[neededMatId]! - neededMatCount;

                                            // Szansa na powodzenie kucia: 100% do +3, 80% do +6, 60% wyżej
                                            int successRate = curLvl < 3 ? 100 : (curLvl < 6 ? 80 : 60);
                                            bool success = _rng.nextInt(100) < successRate;

                                            NinjaGear upgraded;
                                            if (success) {
                                              upgraded = gear.copyWith(upgradeLevel: curLvl + 1);
                                              addLog('🔨 Sukces kucia! ${gear.name} ulepszono na +${curLvl + 1}!');
                                            } else {
                                              upgraded = gear;
                                              addLog('⚠️ Kucie nie powiodło się! Materiały przepadły.');
                                            }

                                            switch (slotEnum) {
                                              case GearSlot.weapon:
                                                currentWeapon = upgraded;
                                                break;
                                              case GearSlot.armor:
                                                currentArmor = upgraded;
                                                break;
                                              case GearSlot.helmet:
                                                currentHelmet = upgraded;
                                                break;
                                              case GearSlot.boots:
                                                currentBoots = upgraded;
                                                break;
                                            }
                                          });
                                          _saveGameData();
                                          setSmithState(() {});
                                        }
                                      : null,
                                  child: Text('Kuj na +${curLvl + 1}', style: const TextStyle(fontSize: 10)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    Text('Twoje Ryo: $ryo', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Odejdź', style: TextStyle(color: Colors.grey))),
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
                    const Text('„Leczenie ran i regeneracja sieci czakry to podstawa przeżycia.”',
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text('💚', style: TextStyle(fontSize: 24)),
                      title: const Text('Pełne Leczenie (HP + CP)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Odnawia Zdrowie i Czakrę do 100%', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                        onPressed: (hp < maxHp || chakra < maxChakra) && ryo >= 30
                            ? () {
                                setState(() {
                                  ryo -= 30;
                                  hp = maxHp;
                                  chakra = maxChakra;
                                });
                                _saveGameData();
                                setMedicState(() {});
                                addLog('🩺 Medyk Konohy opatrzył twoje rany (-30 Ryo).');
                              }
                            : null,
                        child: const Text('30 Ryo', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    const Divider(color: Colors.white12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text('🧬', style: TextStyle(fontSize: 24)),
                      title: const Text('Trening Witalności i Obiegu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('+10 Max HP i +10 Max CP', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                        onPressed: ryo >= 260
                            ? () {
                                setState(() {
                                  ryo -= 260;
                                  maxHp += 10;
                                  maxChakra += 10;
                                  hp += 10;
                                  chakra += 10;
                                });
                                _saveGameData();
                                setMedicState(() {});
                                addLog('✨ Poszerzono obieg! +10 Max HP i +10 Max CP (-260 Ryo).');
                              }
                            : null,
                        child: const Text('260 Ryo', style: TextStyle(fontSize: 10)),
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
                                        bonusAtk += 2;
                                      });
                                      _saveGameData();
                                      setMedicState(() {});
                                      addLog('🔥 Punkt Biegłości: +2 stałego Ataku!');
                                    }
                                  : null,
                              child: const Text('+2 Atak', style: TextStyle(fontSize: 10)),
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
                                        maxHp += 12;
                                        maxChakra += 12;
                                        hp += 12;
                                        chakra += 12;
                                      });
                                      _saveGameData();
                                      setMedicState(() {});
                                      addLog('💧 Punkt Biegłości: +12 HP i +12 CP!');
                                    }
                                  : null,
                              child: const Text('+12 HP/CP', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(color: Colors.white12),
                    const Text('Zapasy na rajd:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        ActionChip(
                          avatar: const Text('💊'),
                          label: const Text('Pigułka (+35 CP, 25 Ryo)', style: TextStyle(fontSize: 10)),
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
                          label: const Text('Balsam (+50 HP, 45 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 45
                              ? () {
                                  setState(() => ryo -= 45);
                                  addConsumableToBag('c_ointment', 1);
                                  setMedicState(() {});
                                }
                              : null,
                        ),
                        ActionChip(
                          avatar: const Text('💨'),
                          label: const Text('Dym (35 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 35
                              ? () {
                                  setState(() => ryo -= 35);
                                  addConsumableToBag('c_smoke', 1);
                                  setMedicState(() {});
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Twoje Ryo: $ryo | HP: $hp/$maxHp | CP: $chakra/$maxChakra', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                  Text('Koszt CP: ${offeredJutsu.chakraCost} | Siła: x${offeredJutsu.powerMultiplier}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
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

  // WALKA (W TRAKCIE RAJDU LUB NA ARENIE EGZAMINACYJNEJ)
  void _startBattleWithEnemy(
    EnemyTemplate template, {
    EnemyPrefix forcePrefix = EnemyPrefix.normal,
    bool isExamFight = false,
    int? examTargetRank,
  }) {
    final kmScale = (km * 0.20).round();

    double hpMult = 1.0;
    double atkMult = 1.0;
    String prefixTitle = '';
    Color prefixColor = Colors.orangeAccent;

    if (!template.isBoss && !isExamFight) {
      switch (forcePrefix) {
        case EnemyPrefix.weak:
          hpMult = 0.75;
          atkMult = 0.8;
          prefixTitle = 'Słaby ';
          prefixColor = Colors.white70;
          break;
        case EnemyPrefix.normal:
          hpMult = 1.0;
          atkMult = 1.0;
          prefixTitle = '';
          prefixColor = Colors.orangeAccent;
          break;
        case EnemyPrefix.strong:
          hpMult = 1.45;
          atkMult = 1.3;
          prefixTitle = 'Silny ⚠️ ';
          prefixColor = Colors.redAccent;
          break;
      }
    }

    final int enemyMaxHp = ((template.baseHp + kmScale * (template.isBoss ? 3 : 1)) * hpMult).round();
    final int enemyBaseAtk = ((template.baseAtk + (kmScale * 0.40).round()) * atkMult).round();

    int enemyHp = enemyMaxHp;
    String battleMsg = isExamFight
        ? '🥋 EGZAMIN: Twój egzaminator ${template.name} wkracza na arenę!'
        : template.isBoss
            ? '⚠️ BOSS: Pojawia się ${template.name}!'
            : 'Z cienia atakuje $prefixTitle${template.name}!';

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

              final rawDmg = enemyBaseAtk + _rng.nextInt(4);
              final dmg = max(2, rawDmg - (totalDefense ~/ 2));

              setState(() {
                hp = max(0, hp - dmg);
              });
              battleMsg = '${template.name} zadaje $dmg dmg witalnych! (Twoja Obrona: $totalDefense)';
              _saveGameData();

              if (hp <= 0) {
                Navigator.pop(ctx);
                if (isExamFight) {
                  // Porażka na egzaminie w wiosce nie niszczy ekwipunku!
                  setState(() {
                    hp = 1;
                  });
                  addLog('❌ Egzamin oblany! Medyk wioskowy opatrzył twoje stłuczenia.');
                } else {
                  returnToVillage(fallenInBattle: true);
                }
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

              final dealt = (totalAttack * jutsu.powerMultiplier) + _rng.nextInt(4);
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
                  if (_rng.nextInt(100) < 50) {
                    frozenTurns = 1;
                    battleMsg += '\n⚡ Paraliż! Wróg traci turę!';
                  }
                  break;
                case JutsuEffect.lifesteal:
                  final healed = ((dealt * jutsu.effectValue) / 100).round();
                  setState(() {
                    hp = min(maxHp, hp + healed);
                  });
                  battleMsg += '\n💚 Wyssano $healed Zdrowia!';
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

                if (isExamFight) {
                  setState(() {
                    passedRankIndex = examTargetRank!;
                  });
                  addExperience(150 + examTargetRank! * 50);
                  _saveGameData();
                  addLog('🏆 ZDANO EGZAMIN! Otrzymano awans na oficjalną rangę: $ninjaRank!');
                  return;
                }

                final rewardRyo = template.isBoss
                    ? (80 + km * 2)
                    : ((12 + km) * (forcePrefix == EnemyPrefix.strong ? 1.6 : (forcePrefix == EnemyPrefix.weak ? 0.8 : 1.0))).round();
                final expGained = template.isBoss
                    ? (18 + (km ~/ 5) * 4)
                    : ((4 + (km ~/ 5) * 1) * (forcePrefix == EnemyPrefix.strong ? 1.6 : (forcePrefix == EnemyPrefix.weak ? 0.8 : 1.0))).round();

                setState(() {
                  ryo += rewardRyo;
                  if (activeMissionIndex != null) currentMissionKills++;
                });
                addExperience(expGained);
                addLog('🏆 Pokonano: $prefixTitle${template.name}! Zdobyto $rewardRyo Ryo i +$expGained EXP.');

                // Szansa na rudę z pokonanego wroga
                if (template.isBoss || forcePrefix == EnemyPrefix.strong || _rng.nextInt(100) < 25) {
                  final mRoll = _rng.nextInt(100);
                  String droppedMat = mRoll < 60 ? matIronOre : (mRoll < 90 ? matSteel : matCrystal);
                  addCraftingMaterial(droppedMat, 1);
                  addLog('🪨 Zdobyto materiał kuźniczy: [${craftingMaterials[droppedMat]!.name}]!');
                }

                _findLoot(guaranteedBossDrop: template.isBoss);
              } else {
                enemyTurn();
                setBattleState(() {});
              }
            }

            void useBattleItem(Consumable item) {
              int totalAvailable = (bag[item.id] ?? 0) + (sealedBag[item.id] ?? 0);
              if (totalAvailable <= 0) return;

              // Zużycie przedmiotu
              if ((bag[item.id] ?? 0) > 0) {
                bag[item.id] = bag[item.id]! - 1;
                if (bag[item.id] == 0) bag.remove(item.id);
              } else {
                sealedBag[item.id] = sealedBag[item.id]! - 1;
                if (sealedBag[item.id] == 0) sealedBag.remove(item.id);
              }
              _saveGameData();

              if (item.type == ConsumableType.smokeEscape) {
                Navigator.pop(ctx);
                addLog('💨 Zasłona dymna! Bezpieczny odwrót.');
                return;
              } else if (item.type == ConsumableType.directDmg) {
                enemyHp = max(0, enemyHp - item.value);
                battleMsg = 'Pieczęć Wybuchowa zadała ${item.value} dmg!';
                if (enemyHp <= 0) {
                  Navigator.pop(ctx);
                  final rewardRyo = template.isBoss ? 60 : 10;
                  final expGained = template.isBoss ? 15 : 4;
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

            final int kibakuCount = (bag['c_kibaku'] ?? 0) + (sealedBag['c_kibaku'] ?? 0);
            final int smokeCount = (bag['c_smoke'] ?? 0) + (sealedBag['c_smoke'] ?? 0);

            return Container(
              padding: const EdgeInsets.all(16),
              height: 490,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$prefixTitle${template.name}', style: TextStyle(color: template.isBoss ? Colors.redAccent : prefixColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(template.title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                      Text('$enemyHp / $enemyMaxHp HP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: enemyHp / enemyMaxHp,
                    color: template.isBoss ? Colors.purpleAccent : Colors.redAccent,
                    backgroundColor: Colors.white12,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  // Paski gracza w walce
                  Row(
                    children: [
                      const Text('❤️ HP: ', style: TextStyle(fontSize: 10, color: Colors.redAccent)),
                      Expanded(child: LinearProgressIndicator(value: (hp / maxHp).clamp(0.0, 1.0), color: Colors.redAccent, backgroundColor: Colors.white12, minHeight: 5)),
                      const SizedBox(width: 4),
                      Text('$hp/$maxHp', style: const TextStyle(fontSize: 9)),
                      const SizedBox(width: 8),
                      const Text('🌀 CP: ', style: TextStyle(fontSize: 10, color: Colors.cyanAccent)),
                      Expanded(child: LinearProgressIndicator(value: (chakra / maxChakra).clamp(0.0, 1.0), color: Colors.cyanAccent, backgroundColor: Colors.white12, minHeight: 5)),
                      const SizedBox(width: 4),
                      Text('$chakra/$maxChakra', style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                                Text('(${jutsu.chakraCost} CP)', style: const TextStyle(fontSize: 9, color: Colors.white70)),
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
                      if (kibakuCount > 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade800),
                          icon: const Text('🏷️'),
                          label: Text('Wybuch ($kibakuCount)'),
                          onPressed: () => useBattleItem(allConsumables.firstWhere((c) => c.id == 'c_kibaku')),
                        ),
                      const SizedBox(width: 8),
                      if (smokeCount > 0 && !template.isBoss && !isExamFight)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700),
                          icon: const Text('💨'),
                          label: Text('Dym ($smokeCount)'),
                          onPressed: () => useBattleItem(allConsumables.firstWhere((c) => c.id == 'c_smoke')),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      if (template.isBoss || isExamFight) {
                        battleMsg = 'Z tej walki nie można uciec bez dymu!';
                        setBattleState(() {});
                        return;
                      }
                      Navigator.pop(ctx);
                      addLog('💨 Wycofano się ze starcia!');
                    },
                    child: Text(template.isBoss || isExamFight ? 'Brak odwrotu' : 'Ucieczka pieszo', style: TextStyle(color: template.isBoss || isExamFight ? Colors.red : Colors.grey)),
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
      if (bossRoll < 75) {
        rarity = ItemRarity.rare;
      } else if (bossRoll < 97) {
        rarity = ItemRarity.epic;
      } else {
        rarity = ItemRarity.legendary;
      }
    } else {
      final roll = _rng.nextInt(1000);
      if (roll < 880) {
        rarity = ItemRarity.common;
      } else if (roll < 985) {
        rarity = ItemRarity.rare;
      } else if (roll < 998) {
        rarity = ItemRarity.epic;
      } else {
        rarity = ItemRarity.legendary;
      }
    }

    if (rarity == ItemRarity.legendary) {
      final legPool = legendaryArtifactsPool.where((g) => g.slot == slot).toList();
      final template = legPool[_rng.nextInt(legPool.length)];
      final statScaling = (km * 0.05).round();

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
        bonusVal = _rng.nextInt(2) + 2;
        break;
      case ItemRarity.epic:
        statMultiplier = 3;
        prefix = 'Pradawny';
        bonusAffix = 'Pieczęć Pięciu Żywiołów';
        bonusVal = _rng.nextInt(3) + 3;
        break;
      case ItemRarity.legendary:
        statMultiplier = 1;
        prefix = '';
        break;
    }

    final statScaling = (km * 0.04).round();
    final calculatedStat = (baseArch.baseStat * statMultiplier) + statScaling + _rng.nextInt(2);
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
    if (roll < 18 || guaranteedBossDrop) {
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
    } else if (roll < 45) {
      // Znalezienie surowca kuźniczego
      final mRoll = _rng.nextInt(100);
      String droppedMat = mRoll < 65 ? matIronOre : (mRoll < 92 ? matSteel : matCrystal);
      addCraftingMaterial(droppedMat, 1);
      addLog('🪨 Wyprawa: Wykopano [${craftingMaterials[droppedMat]!.name}]!');
    } else {
      final item = allConsumables[_rng.nextInt(allConsumables.length)];
      addConsumableToBag(item.id, 1);
      addLog('📦 Wyprawa: Znaleziono [${item.name}]!');
    }
  }

  // ZAAWANSOWANY POPUP PORÓWNANIA ZE STAT DELTA & RZADKOŚCIĄ
  void _showEquipDialog({required NinjaGear newGear, required NinjaGear currentGear, required GearSlot slot}) {
    String slotName;
    String statType;
    switch (slot) {
      case GearSlot.weapon:
        slotName = 'Broń';
        statType = 'Atak';
        break;
      case GearSlot.armor:
        slotName = 'Pancerz';
        statType = 'Obrona';
        break;
      case GearSlot.helmet:
        slotName = 'Głowa';
        statType = 'Obrona';
        break;
      case GearSlot.boots:
        slotName = 'Buty';
        statType = 'Obrona';
        break;
    }

    final int diff = newGear.effectiveStat - currentGear.effectiveStat;
    final String diffSign = diff > 0 ? '+$diff' : '$diff';
    final Color diffColor = diff > 0 ? Colors.greenAccent : (diff < 0 ? Colors.redAccent : Colors.grey);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C1A),
        title: Text('Odnaleziono: $slotName!', style: const TextStyle(color: Colors.orangeAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOWY PRZEDMIOT
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: newGear.color.withAlpha(150), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NOWY PRZEDMIOT', style: TextStyle(fontSize: 9, color: newGear.color, fontWeight: FontWeight.bold)),
                      Text(newGear.rarityLabel, style: TextStyle(fontSize: 9, color: newGear.color)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(newGear.displayName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: newGear.color)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('$statType: +${newGear.effectiveStat} ', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      Text('($diffSign)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: diffColor)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Status: ⚠️ Niezabezpieczony (Przepada!)', style: TextStyle(fontSize: 9, color: Colors.redAccent)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // AKTUALNY PRZEDMIOT
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: currentGear.isSoulbound ? Colors.amberAccent : currentGear.color.withAlpha(100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('AKTUALNIE ZAŁOŻONY', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
                      Text(currentGear.rarityLabel, style: TextStyle(fontSize: 9, color: currentGear.color)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(currentGear.displayName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentGear.color)),
                  const SizedBox(height: 4),
                  Text('$statType: +${currentGear.effectiveStat}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(
                    currentGear.isSoulbound ? 'Status: 📜 Zapieczętowany (Bezpieczny)' : 'Status: ⚠️ Niezabezpieczony',
                    style: TextStyle(fontSize: 9, color: currentGear.isSoulbound ? Colors.greenAccent : Colors.redAccent),
                  ),
                ],
              ),
            ),
          ],
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
              addLog('✨ Założono: ${newGear.name} (Wymaga pieczęci!)');
            },
            child: const Text('Załóż nowy'),
          ),
        ],
      ),
    );
  }

  // BIURO MISJI W WIOSCE (PRZYJMOWANIE ZLECEŃ + EGZAMINY)
  void _openVillageMissionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setMissionState) {
          // Szukamy następnego egzaminu do zdania
          final nextExam = shinobiExams.firstWhere(
            (e) => e.targetRankIndex == passedRankIndex + 1,
            orElse: () => shinobiExams.last,
          );
          final bool hasPendingExam = passedRankIndex < 5 && level >= nextExam.requiredLevel;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1A16),
            title: const Text('📜 Biuro Misji i Egzaminów', style: TextStyle(color: Colors.orangeAccent)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEKCJA EGZAMINU KWALIFIKACYJNEGO
                    if (passedRankIndex < 5) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasPendingExam ? const Color(0xFF332005) : Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: hasPendingExam ? Colors.amberAccent : Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('🥋 Egzamin na ${nextExam.rankTitle}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: hasPendingExam ? Colors.amberAccent : Colors.white70)),
                                Text('Wymaga: Lvl ${nextExam.requiredLevel}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('Egzaminator: ${nextExam.examinerName} (${nextExam.examinerTitle})', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                            Text(nextExam.lore, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 9, color: Colors.white54)),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasPendingExam ? Colors.amber.shade900 : Colors.grey.shade800,
                                minimumSize: const Size(double.infinity, 30),
                              ),
                              onPressed: hasPendingExam
                                  ? () {
                                      Navigator.pop(ctx);
                                      _startBattleWithEnemy(
                                        EnemyTemplate(
                                          name: nextExam.examinerName,
                                          title: nextExam.examinerTitle,
                                          baseHp: nextExam.hp,
                                          baseAtk: nextExam.atk,
                                          isBoss: true,
                                        ),
                                        isExamFight: true,
                                        examTargetRank: nextExam.targetRankIndex,
                                      );
                                    }
                                  : null,
                              child: Text(hasPendingExam ? 'Rozpocznij Egzamin!' : 'Osiągnij Lvl ${nextExam.requiredLevel}', style: const TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    const Text('Dostępne Zlecenia Hokage:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orangeAccent)),
                    const SizedBox(height: 6),

                    if (activeMissionIndex != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.withAlpha(120))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Aktywna Misja: Ranga ${allMissionsPool[activeMissionIndex!].rank}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber)),
                            Text(allMissionsPool[activeMissionIndex!].title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: currentMissionKills / allMissionsPool[activeMissionIndex!].requiredKills,
                              color: Colors.greenAccent,
                              backgroundColor: Colors.white12,
                            ),
                            const SizedBox(height: 2),
                            Text('Postęp: $currentMissionKills / ${allMissionsPool[activeMissionIndex!].requiredKills}', style: const TextStyle(fontSize: 10)),
                            const SizedBox(height: 6),
                            if (currentMissionKills >= allMissionsPool[activeMissionIndex!].requiredKills)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, minimumSize: const Size(double.infinity, 28)),
                                onPressed: () {
                                  final m = allMissionsPool[activeMissionIndex!];
                                  final bool isRepeat = completedMissionsHistory.contains(m.id);
                                  final int earnedExp = isRepeat ? max(5, (m.rewardExp * 0.25).round()) : m.rewardExp;
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
                                  addLog('🎖️ Sukces misji: ${m.title}! +$earnedRyo Ryo, +$earnedExp EXP');
                                },
                                child: const Text('Odbierz Nagrodę! 🎁', style: TextStyle(fontSize: 10)),
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
                                child: const Text('Porzuć misję', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                              ),
                          ],
                        ),
                      )
                    else
                      ...allMissionsPool.map((m) {
                        final bool isUnlocked = passedRankIndex >= m.minRankIndex;
                        final bool isCompleted = completedMissionsHistory.contains(m.id);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: isUnlocked ? Colors.orange.shade900 : Colors.grey.shade800,
                              child: Text(m.rank, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isUnlocked ? Colors.white : Colors.white38)),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(m.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.white : Colors.white38))),
                                if (isCompleted) const Text('✓', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                              ],
                            ),
                            subtitle: Text(
                              isUnlocked
                                  ? '${m.desc}\nNagroda: ${m.rewardRyo} Ryo | ${isCompleted ? "${(m.rewardExp * 0.25).round()} EXP" : "+${m.rewardExp} EXP"}'
                                  : 'Wymaga zdania egzaminu rangi: ${m.rank}',
                              style: TextStyle(fontSize: 9, color: isUnlocked ? Colors.white60 : Colors.redAccent.withAlpha(150)),
                            ),
                            trailing: isUnlocked
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.blueGrey.shade800 : Colors.orange.shade900, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                    onPressed: () {
                                      setState(() {
                                        activeMissionIndex = allMissionsPool.indexOf(m);
                                        currentMissionKills = 0;
                                      });
                                      _saveGameData();
                                      Navigator.pop(ctx);
                                      addLog('📜 Przyjęto zlecenie: ${m.title}!');
                                    },
                                    child: Text(isCompleted ? 'Powtórz' : 'Przyjmij', style: const TextStyle(fontSize: 9)),
                                  )
                                : const Icon(Icons.lock, size: 16, color: Colors.grey),
                          ),
                        );
                      }),
                  ],
                ),
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

  // W TERENIE: TYLKO PODGLĄD AKTYWNEJ MISJI
  void _openFieldMissionStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A16),
        title: const Row(
          children: [
            Text('📜 ', style: TextStyle(fontSize: 20)),
            Text('Cel Wyprawy', style: TextStyle(color: Colors.orangeAccent)),
          ],
        ),
        content: activeMissionIndex == null
            ? const Text('Wyruszyłeś bez aktywnego zlecenia z Wioski!\nNowe misje można przyjmować wyłącznie w Biurze Hokage.', style: TextStyle(fontSize: 12, color: Colors.white70))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Misja Rangi ${allMissionsPool[activeMissionIndex!].rank}:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber)),
                  const SizedBox(height: 2),
                  Text(allMissionsPool[activeMissionIndex!].title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(allMissionsPool[activeMissionIndex!].desc, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: currentMissionKills / allMissionsPool[activeMissionIndex!].requiredKills,
                    color: Colors.greenAccent,
                    backgroundColor: Colors.white12,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text('Zneutralizowano celów: $currentMissionKills / ${allMissionsPool[activeMissionIndex!].requiredKills}', style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 8),
                  const Text('Nagrodę odbierzesz po bezpiecznym powrocie do wioski.', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: Colors.white54)),
                ],
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Wróć do drogi', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  // PLECAK RAJDU Z PODZIAŁEM NA ZABEZPIECZONE I RYZYKOWNE
  void _openBagDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setBagState) {
          final allConsumableIds = {...bag.keys, ...sealedBag.keys}.toList();

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1C1A),
            title: const Text('🎒 Plecak Rajdu', style: TextStyle(color: Colors.orangeAccent, fontSize: 16)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Przedmioty użytkowe:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 4),
                    if (allConsumableIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Brak prowiantu!', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      )
                    else
                      ...allConsumableIds.map((id) {
                        final item = allConsumables.firstWhere((c) => c.id == id);
                        final int unsealedQty = bag[id] ?? 0;
                        final int sealedQty = sealedBag[id] ?? 0;
                        final bool isCombatOnly = item.type == ConsumableType.directDmg || item.type == ConsumableType.smokeEscape;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            children: [
                              Text(item.icon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    Row(
                                      children: [
                                        if (unsealedQty > 0) Text('$unsealedQty szt. ⚠️  ', style: const TextStyle(fontSize: 9, color: Colors.redAccent)),
                                        if (sealedQty > 0) Text('$sealedQty szt. 📜', style: const TextStyle(fontSize: 9, color: Colors.greenAccent)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: isCombatOnly ? Colors.grey.shade800 : Colors.teal.shade800, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                onPressed: isCombatOnly
                                    ? null
                                    : () {
                                        useConsumable(item);
                                        setBagState(() {});
                                      },
                                child: Text(isCombatOnly ? 'Walka' : 'Użyj', style: const TextStyle(fontSize: 10)),
                              ),
                            ],
                          ),
                        );
                      }),
                    const Divider(color: Colors.white12),
                    const Text('Materiały rzemieślnicze (bezpieczne):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amberAccent)),
                    const SizedBox(height: 4),
                    ...craftingMaterials.values.map((mat) {
                      final count = craftingBag[mat.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${mat.icon} ${mat.name}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                            Text('$count szt.', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
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
                      'Koszt: ${jutsu.chakraCost} CP | Siła: x${jutsu.powerMultiplier}\n${jutsu.effectDescription}',
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

    final totalItemsInBag = bag.values.fold(0, (a, b) => a + b) + sealedBag.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text(inVillage ? 'Konohagakure (Baza)' : 'Eksploracja: $km km'),
        centerTitle: true,
        backgroundColor: inVillage ? const Color(0xFF1B4D3E) : const Color(0xFFC44D00),
      ),
      body: Column(
        children: [
          // PANEL STATYSTYK GRACZA
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF1C1A18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _badge('Ranga', 'Lvl $level ($ninjaRank)', rankColor),
                    _badge('EXP', '$ninjaExp / $expForNextLevel', Colors.cyanAccent),
                    _badge('Zdrowie (HP)', '$hp / $maxHp', hp < 30 ? Colors.redAccent : Colors.greenAccent),
                    _badge('Czakra (CP)', '$chakra / $maxChakra', Colors.lightBlueAccent),
                    _badge('Ryo', '$ryo', Colors.amberAccent),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _itemCard('Broń', currentWeapon, 'Atak: +$totalAttack'),
                    const SizedBox(width: 6),
                    _itemCard('Pancerz', currentArmor, 'Obr: +${currentArmor.effectiveStat}'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _itemCard('Głowa', currentHelmet, 'Obr: +${currentHelmet.effectiveStat}'),
                    const SizedBox(width: 6),
                    _itemCard('Buty', currentBoots, 'Obr: +${currentBoots.effectiveStat} (Suma: $totalDefense)'),
                  ],
                ),
              ],
            ),
          ),

          // PRZYCISKI MENU WIOSKI (TYLKO W WIOSCE)
          if (inVillage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC44D00), padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: leaveVillage,
                          child: const Text('Wyrusz w Las 🌲', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8D5B4C), padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: _openVillageMissionsDialog,
                          child: const Text('📜 Biuro Misji'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4500), padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: _openBlacksmithDialog,
                          child: const Text('🔨 Kowal'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4B35), padding: const EdgeInsets.symmetric(vertical: 10)),
                          onPressed: _openMedicDialog,
                          child: const Text('🩺 Medyk'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF236B4A), padding: const EdgeInsets.symmetric(vertical: 10)),
                          onPressed: _openBagDialog,
                          child: Text('🎒 ($totalItemsInBag)'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3B54), padding: const EdgeInsets.symmetric(vertical: 10)),
                          onPressed: _openScrollsDialog,
                          child: Text('📜 (${equippedJutsu.length}/3)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Align(alignment: Alignment.centerLeft, child: Text('Dziennik:', style: TextStyle(color: Colors.grey, fontSize: 11))),
          ),

          // DZIENNIK ZDARZEŃ
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF0C0B0A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
              child: ListView.builder(
                itemCount: log.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(log[index], style: TextStyle(fontFamily: 'monospace', color: index == 0 ? const Color(0xFFFFD59E) : Colors.white60, fontSize: 11)),
                ),
              ),
            ),
          ),

          // ERGONOMICZNA STREFA DOLNA DLA JEDNEJ RĘKI (W TRAKCIE RAJDU)
          if (!inVillage)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pasek pomocniczy: Plecak, Podgląd Misji (Tylko status!), Ucieczka
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF236B4A),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _openBagDialog,
                          icon: const Text('🎒', style: TextStyle(fontSize: 13)),
                          label: Text('($totalItemsInBag)', style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D5B4C),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _openFieldMissionStatusDialog,
                          icon: const Text('📜', style: TextStyle(fontSize: 13)),
                          label: Text(
                            activeMissionIndex != null ? '$currentMissionKills/${allMissionsPool[activeMissionIndex!].requiredKills}' : 'Zadanie',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4D3E),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: returnToVillage,
                          icon: const Text('⛩️', style: TextStyle(fontSize: 13)),
                          label: const Text('Ucieczka', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // GŁÓWNY PRZYCISK DALEJ NA SAMYM DOLE (ONE-HAND MODE)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC44D00),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFFFF8C00), width: 1.2),
                        ),
                      ),
                      onPressed: proceedMission,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Idź naprzód', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                          SizedBox(width: 8),
                          Text('🌲', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _itemCard(String slot, NinjaGear item, String statText) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
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
                    '$slot: ${item.displayName}',
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
