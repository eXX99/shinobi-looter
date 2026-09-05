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
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Standardowy Kunai', baseStat: 5, lore: 'Podstawowy nóż shinobi.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Składany Shuriken Fūma', baseStat: 7, lore: 'Wirujące ostrze.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Igły Senbon z Ame', baseStat: 6, lore: 'Precyzyjne igły w punkty witalne.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Krótki Miecz Tanto ANBU', baseStat: 9, lore: 'Ostrze skrytobójcy.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Kastety ze stali czakry', baseStat: 8, lore: 'Wzmacniają uderzenia wręcz.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Dmuchawka z Amegakure', baseStat: 6, lore: 'Zatrute rzutki.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Włócznia Skalnego Posterunku', baseStat: 10, lore: 'Ciężka broń drzewcowa.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Bliźniacze Tasaki Kiri', baseStat: 10, lore: 'Szermierka Ukrytej Mgły.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Łuk Pajęczej Nici', baseStat: 11, lore: 'Lepka, utwardzona nić.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Ostrza Czakry Asumy', baseStat: 12, lore: 'Przewodzą ostrą naturę wiatru.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Żelazny Wachlarz Piasku', baseStat: 11, lore: 'Generuje fale uderzeniowe.'),
  BaseGearArchetype(slot: GearSlot.weapon, baseName: 'Kościane Ostrze Yanagi', baseStat: 13, lore: 'Twardy kościec Kaguya.'),

  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Szata Treningowa Genina', baseStat: 3, lore: 'Płócienny strój.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Ochraniacz Klatki Liścia', baseStat: 5, lore: 'Podstawowa kamizelka.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Skórzana Zbroja Pustyni', baseStat: 6, lore: 'Skóra z pustynnych bestii.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Mundur Bojowy Iwagakure', baseStat: 7, lore: 'Ciężki pancerz piechoty.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Kamizelka Jonina Konohy', baseStat: 10, lore: 'Standardowy rynsztunek elity.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Elitarny Napierśnik ANBU', baseStat: 12, lore: 'Wzmocniona powłoka operacyjna.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Pancerz Bojowy Kumogakure', baseStat: 11, lore: 'Mocna płyta naramienna.'),
  BaseGearArchetype(slot: GearSlot.armor, baseName: 'Szata Pustelnika Myōboku', baseStat: 14, lore: 'Tkanina nasycona senjutsu.'),

  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Ochraniacz Czołowy Protektor', baseStat: 2, lore: 'Metalowa płytka z symbolem.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Maska Oddechowa Amegakure', baseStat: 3, lore: 'Filtruje gazy bojowe.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Porcelanowa Maska Lisa ANBU', baseStat: 7, lore: 'Ukrywa tożsamość.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Bandaże Cichego Zabójcy', baseStat: 6, lore: 'Tłumią oddech w mgle.'),
  BaseGearArchetype(slot: GearSlot.helmet, baseName: 'Tradycyjny Kapelusz Kage', baseStat: 11, lore: 'Nakrycie głowy przywódcy.'),

  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Standardowe Sandały Shinobi', baseStat: 2, lore: 'Lekkie sandały.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Wyciszone Mokasyny ANBU', baseStat: 6, lore: 'Niwelują drgania podłoża.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Ciężarki Treningowe na Kostki', baseStat: 8, lore: 'Wymagają siły nóg.'),
  BaseGearArchetype(slot: GearSlot.boots, baseName: 'Drewniane Geta Żabiego Mędrca', baseStat: 10, lore: 'Stabilność na skałach.'),
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
  LegendaryGearTemplate(name: 'Miecz Totsuka (Sakegari)', slot: GearSlot.weapon, baseStat: 48, bonusEffect: 'Pieczęć Wiecznego Snu', bonusValue: 12, lore: 'Widmowe ostrze zamykające duszę.'),
  LegendaryGearTemplate(name: 'Miecz Kusanagi Orochimaru', slot: GearSlot.weapon, baseStat: 44, bonusEffect: 'Niezniszczalna Stal', bonusValue: 10, lore: 'Mityczny oręż wysuwany z węża.'),
  LegendaryGearTemplate(name: 'Samehada (Żarłacz Kisame)', slot: GearSlot.weapon, baseStat: 46, bonusEffect: 'Pożeranie Czakry', bonusValue: 11, lore: 'Żywy miecz wysysający energię.'),
  LegendaryGearTemplate(name: 'Wojenny Wachlarz Gunbai Madary', slot: GearSlot.weapon, baseStat: 47, bonusEffect: 'Odbicie Uchihagaeshi', bonusValue: 11, lore: 'Odbija ninjutsu wroga.'),
  LegendaryGearTemplate(name: 'Miecz Nunoboko Hagoromo', slot: GearSlot.weapon, baseStat: 54, bonusEffect: 'Stworzenie Świata Rikudō', bonusValue: 15, lore: 'Spiralne ostrze z Gudōdama.'),
  LegendaryGearTemplate(name: 'Klatka Żebrowa Susanoo', slot: GearSlot.armor, baseStat: 42, bonusEffect: 'Absolutny Kościec', bonusValue: 10, lore: 'Eteryczny pancerz z czakry Sharingana.'),
  LegendaryGearTemplate(name: 'Pancerz Ostatecznego Susanoo', slot: GearSlot.armor, baseStat: 50, bonusEffect: 'Bóstwo Zniszczenia', bonusValue: 14, lore: 'Skrzydlata forma zbroi Madary.'),
  LegendaryGearTemplate(name: 'Szata Mędrca Sześciu Ścieżek', slot: GearSlot.armor, baseStat: 46, bonusEffect: 'Harmonia Yin-Yang', bonusValue: 12, lore: 'Biała szata chroniąca przed rozpadem.'),
  LegendaryGearTemplate(name: 'Maska Jednoocznego Wiru (Obito)', slot: GearSlot.helmet, baseStat: 38, bonusEffect: 'Pusta Niematerialność', bonusValue: 10, lore: 'Zniekształca przestrzeń Kamui.'),
  LegendaryGearTemplate(name: 'Korona Rogatej Bogini Kaguya', slot: GearSlot.helmet, baseStat: 42, bonusEffect: 'Wizja Byakugana', bonusValue: 12, lore: 'Boski relikt czakry.'),
  LegendaryGearTemplate(name: 'Obuwie Żółtego Błysku (Hiraishin)', slot: GearSlot.boots, baseStat: 38, bonusEffect: 'Teleportacja Błysku', bonusValue: 10, lore: 'Wyryte pieczęcie Minato.'),
  LegendaryGearTemplate(name: 'Lewitujące Płyty Rikudō', slot: GearSlot.boots, baseStat: 42, bonusEffect: 'Lot Ponad Prawami', bonusValue: 12, lore: 'Płyty unoszące się nad ziemią.'),
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
  Consumable(id: 'c_pill', name: 'Pigułka Żywnościowa', description: '+35 Czakry.', type: ConsumableType.heal, value: 35, price: 30, icon: '💊'),
  Consumable(id: 'c_dango', name: 'Słodkie Dango', description: '+20 Czakry.', type: ConsumableType.heal, value: 20, price: 18, icon: '🍡'),
  Consumable(id: 'c_ramen', name: 'Ramen Ichiraku', description: 'Odnawia czakrę i +15 Max Czakry.', type: ConsumableType.fullRestore, value: 15, price: 110, icon: '🍜'),
  Consumable(id: 'c_ointment', name: 'Balsam Ziołowy Medyka', description: '+60 Czakry natychmiast.', type: ConsumableType.heal, value: 60, price: 65, icon: '🧴'),
  Consumable(id: 'c_power_pill', name: 'Pigułka Siły', description: '+5 stałego Ataku.', type: ConsumableType.buffAtk, value: 5, price: 90, icon: '⚡'),
  Consumable(id: 'c_kibaku', name: 'Pieczęć Wybuchowa', description: 'Zadaje 35 dmg w walce.', type: ConsumableType.directDmg, value: 35, price: 50, icon: '🏷️'),
  Consumable(id: 'c_smoke', name: 'Bomba Dymna', description: 'Gwarantowana ucieczka z walki.', type: ConsumableType.smokeEscape, value: 0, price: 40, icon: '💨'),
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
        return 'Zamrożenie: Unieruchamia na $effectDuration turę';
      case JutsuEffect.stun:
        return 'Ogłuszenie: Wróg traci $effectDuration turę';
      case JutsuEffect.lifesteal:
        return 'Wyssanie: Regeneruje $effectValue% obrażeń jako czakrę';
      case JutsuEffect.shock:
        return 'Paraliż: 50% szansy na utratę tury przez wroga';
      case JutsuEffect.none:
        return 'Czyste obrażenia fizyczne/czakry';
    }
  }
}

const List<Jutsu> allJutsuPool = [
  Jutsu(id: 'j_taijutsu', name: 'Podstawowe Taijutsu', chakraCost: 0, powerMultiplier: 1, costRyo: 0, color: Colors.blueGrey),
  Jutsu(id: 'j_konoha_senpuu', name: 'Konoha Senpū', chakraCost: 8, powerMultiplier: 2, costRyo: 120, color: Colors.lightGreen, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_katon', name: 'Katon: Goukakyu', chakraCost: 14, powerMultiplier: 2, costRyo: 180, color: Colors.deepOrange, effect: JutsuEffect.burn, effectDuration: 2, effectValue: 7),
  Jutsu(id: 'j_housenka', name: 'Katon: Hōsenka', chakraCost: 18, powerMultiplier: 3, costRyo: 280, color: Colors.orangeAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 10),
  Jutsu(id: 'j_gouka_mekkyaku', name: 'Katon: Gouka Mekkyaku', chakraCost: 38, powerMultiplier: 4, costRyo: 650, color: Colors.redAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 16),
  Jutsu(id: 'j_amaterasu', name: 'Amaterasu', chakraCost: 48, powerMultiplier: 5, costRyo: 1200, color: Colors.deepPurple, effect: JutsuEffect.burn, effectDuration: 4, effectValue: 24),
  Jutsu(id: 'j_suirou', name: 'Suiton: Wodne Więzienie', chakraCost: 22, powerMultiplier: 2, costRyo: 320, color: Colors.blue, effect: JutsuEffect.freeze, effectDuration: 1),
  Jutsu(id: 'j_makyou_hyoushou', name: 'Hyōton: Lodowe Lustra Haku', chakraCost: 30, powerMultiplier: 3, costRyo: 500, color: Colors.cyanAccent, effect: JutsuEffect.freeze, effectDuration: 2),
  Jutsu(id: 'j_fuuton', name: 'Fuuton: Daitoppa', chakraCost: 12, powerMultiplier: 2, costRyo: 160, color: Colors.teal),
  Jutsu(id: 'j_rasenshuriken', name: 'Fuuton: Rasenshuriken', chakraCost: 44, powerMultiplier: 5, costRyo: 1100, color: Colors.tealAccent, effect: JutsuEffect.burn, effectDuration: 3, effectValue: 20),
  Jutsu(id: 'j_raiton', name: 'Chidori', chakraCost: 26, powerMultiplier: 3, costRyo: 420, color: Colors.cyan, effect: JutsuEffect.shock),
  Jutsu(id: 'j_kirin', name: 'Raiton: Kirin', chakraCost: 52, powerMultiplier: 6, costRyo: 1400, color: Colors.blueAccent, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_doryuheki', name: 'Doton: Błotna Ściana', chakraCost: 16, powerMultiplier: 2, costRyo: 220, color: Colors.lime, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_mokuton_drag', name: 'Mokuton: Drewniany Smok', chakraCost: 40, powerMultiplier: 4, costRyo: 850, color: Colors.greenAccent, effect: JutsuEffect.lifesteal, effectValue: 35),
  Jutsu(id: 'j_rasengan', name: 'Rasengan', chakraCost: 28, powerMultiplier: 3, costRyo: 450, color: Colors.blueAccent),
  Jutsu(id: 'j_bijuudama', name: 'Bijuudama', chakraCost: 70, powerMultiplier: 7, costRyo: 2200, color: Colors.purpleAccent, effect: JutsuEffect.stun, effectDuration: 1),
  Jutsu(id: 'j_kamui', name: 'Kamui', chakraCost: 45, powerMultiplier: 4, costRyo: 1500, color: Colors.grey, effect: JutsuEffect.freeze, effectDuration: 2),
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
  EnemyTemplate(name: 'Zabuza Momochi', title: 'Demon Ukrytej Mgły', baseHp: 85, baseAtk: 15, isBoss: true),
  EnemyTemplate(name: 'Haku', title: 'Mistrz Lodowych Luster', baseHp: 75, baseAtk: 16, isBoss: true),
  EnemyTemplate(name: 'Gaara Pustyni', title: 'Głos Shukaku', baseHp: 105, baseAtk: 14, isBoss: true),
  EnemyTemplate(name: 'Kimimaro Kaguya', title: 'Taniec Kości', baseHp: 95, baseAtk: 18, isBoss: true),
  EnemyTemplate(name: 'Orochimaru', title: 'Legendarny Wężowy Sannin', baseHp: 125, baseAtk: 20, isBoss: true),
  EnemyTemplate(name: 'Sasori', title: 'Czerwony Piasek', baseHp: 115, baseAtk: 21, isBoss: true),
  EnemyTemplate(name: 'Itachi Uchiha', title: 'Mistrz Mangekyō Sharingana', baseHp: 125, baseAtk: 24, isBoss: true),
  EnemyTemplate(name: 'Pain (Tendo)', title: 'Bóg Sześciu Ścieżek', baseHp: 165, baseAtk: 28, isBoss: true),
  EnemyTemplate(name: 'Madara Uchiha', title: 'Duch Klanu Uchiha', baseHp: 195, baseAtk: 32, isBoss: true),
];

class ShinobiMission {
  final String id;
  final String rank;
  final String title;
  final String desc;
  final int minLevelRequired;
  final int requiredKills;
  final int rewardRyo;
  final int rewardExp;

  const ShinobiMission({
    required this.id,
    required this.rank,
    required this.title,
    required this.desc,
    required this.minLevelRequired,
    required this.requiredKills,
    required this.rewardRyo,
    required this.rewardExp,
  });
}

// ZBALANSOWANE MISJE POWIĄZANE Z POZIOMEM GRACZA (Lvl Cap & Gates)
const List<ShinobiMission> allMissionsPool = [
  ShinobiMission(id: 'm_d1', rank: 'D', title: 'Odchwaszczanie Ogrodów Daimyō', desc: 'Wyeliminuj 3 szkodników w lasach Liścia.', minLevelRequired: 1, requiredKills: 3, rewardRyo: 40, rewardExp: 30),
  ShinobiMission(id: 'm_d2', rank: 'D', title: 'Poszukiwanie Kota Tora', desc: 'Przepędź 4 leśne bestie i zabezpiecz teren.', minLevelRequired: 1, requiredKills: 4, rewardRyo: 60, rewardExp: 45),
  ShinobiMission(id: 'm_d3', rank: 'D', title: 'Patrol Graniczny Wioski', desc: 'Odpędź 5 włóczęgów sprzed bramy Liścia.', minLevelRequired: 3, requiredKills: 5, rewardRyo: 80, rewardExp: 60),

  ShinobiMission(id: 'm_c1', rank: 'C', title: 'Eskorta Mostowniczego Tazuny', desc: 'Wyeliminuj 6 bandytów z Kraju Fal.', minLevelRequired: 10, requiredKills: 6, rewardRyo: 160, rewardExp: 110),
  ShinobiMission(id: 'm_c2', rank: 'C', title: 'Ochrona Karawany z Sunagakure', desc: 'Zlikwiduj 7 koczowników na pustynnym trakcie.', minLevelRequired: 12, requiredKills: 7, rewardRyo: 190, rewardExp: 130),
  ShinobiMission(id: 'm_c3', rank: 'C', title: 'Odzyskanie Skradzionego Zwoju', desc: 'Dopadnij 8 zbiegłych rzezimieszków.', minLevelRequired: 15, requiredKills: 8, rewardRyo: 230, rewardExp: 160),

  ShinobiMission(id: 'm_b1', rank: 'B', title: 'Polowanie na Szpiegów ze Skały', desc: 'Zneutralizuj 9 zwiadowców wrogiej nacji.', minLevelRequired: 20, requiredKills: 9, rewardRyo: 360, rewardExp: 240),
  ShinobiMission(id: 'm_b2', rank: 'B', title: 'Infiltracja Bazy Otogakure', desc: 'Wyeliminuj 10 eksperymentów Węża.', minLevelRequired: 24, requiredKills: 10, rewardRyo: 420, rewardExp: 280),
  ShinobiMission(id: 'm_b3', rank: 'B', title: 'Zasadzka na Czwórkę Dźwięku', desc: 'Pokonaj 11 strażników bramy dźwięku.', minLevelRequired: 28, requiredKills: 11, rewardRyo: 490, rewardExp: 320),

  ShinobiMission(id: 'm_a1', rank: 'A', title: 'Pojmanie Członków Akatsuki', desc: 'Pokonaj 12 elitarnych wojowników w chmurach.', minLevelRequired: 32, requiredKills: 12, rewardRyo: 700, rewardExp: 450),
  ShinobiMission(id: 'm_a2', rank: 'A', title: 'Obrona Konohy przed Inwazją', desc: 'Wyeliminuj 14 uderzeniowych shinobi.', minLevelRequired: 36, requiredKills: 14, rewardRyo: 820, rewardExp: 520),
  ShinobiMission(id: 'm_a3', rank: 'A', title: 'Tajne Zlecenie Korzenia ANBU', desc: 'Dokonaj egzekucji 15 zdrajców Wioski.', minLevelRequired: 40, requiredKills: 15, rewardRyo: 950, rewardExp: 600),

  ShinobiMission(id: 'm_s1', rank: 'S', title: 'Ocalenie Świata przed Shinra Tensei', desc: 'Zgładź 16 bóstw ścieżek bólu.', minLevelRequired: 45, requiredKills: 16, rewardRyo: 1400, rewardExp: 900),
  ShinobiMission(id: 'm_s2', rank: 'S', title: 'Powstrzymanie Madary Uchiha', desc: 'Pokonaj 18 wskrzeszonych legend Edo Tensei.', minLevelRequired: 48, requiredKills: 18, rewardRyo: 1800, rewardExp: 1200),
  ShinobiMission(id: 'm_s3', rank: 'S', title: 'Pojedynek z Boginią Kaguya', desc: 'Pokonaj 20 międzywymiarowych abominacji.', minLevelRequired: 50, requiredKills: 20, rewardRyo: 2500, rewardExp: 1600),
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
  int ryo = 80;
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

  // WYKŁADNICZA KRZYWA EXP (Zwalnia progres)
  static const int softCapLevel = 50;

  int get level {
    for (int lvl = 1; lvl <= softCapLevel; lvl++) {
      if (ninjaExp < expRequiredForLevel(lvl + 1)) {
        return lvl;
      }
    }
    return softCapLevel;
  }

  // Wzór: EXP = 80 * L^1.95 (Lvl 10: 7100 exp, Lvl 50: ~163 000 exp)
  static int expRequiredForLevel(int lvl) {
    if (lvl <= 1) return 0;
    return (80 * pow(lvl, 1.95)).floor();
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
      ryo = prefs.getInt('ryo') ?? 80;
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
      final newMasteryEarned = surplus ~/ 3500;
      if (newMasteryEarned > 0) {
        masteryPoints += newMasteryEarned;
        ninjaExp = capExp + (surplus % 3500);
        addLog('🎖️ Punkt Biegłości Shinobi zdobyty! (+1)');
      }
    }

    if (level > oldLvl) {
      addLog('⚡ AWANS! Awansowałeś na Poziom $level ($ninjaRank)!');
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
      addLog('💀 Porażka w walce! Medyk Konohy opatrzył twoje rany.');
    } else {
      addLog('⛩️ Powrót za bramy Wioski Liścia. Czakra zregenerowana.');
    }

    if (itemsLostInBag > 0 || lostEquippedPieces > 0) {
      addLog('⚠️ Fūinjutsu: Stracono $itemsLostInBag zapasów oraz $lostEquippedPieces niezabezpieczonych elementów rynsztunku!');
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

    final bool bossSpawnTriggered = (nextKm % 25 == 0) || (_rng.nextInt(100) < (10 + min(15, nextKm ~/ 15)));
    final roll = _rng.nextInt(100);

    if (bossSpawnTriggered && roll < 40) {
      final randomBoss = bossesPool[_rng.nextInt(bossesPool.length)];
      _startBattleWithEnemy(randomBoss);
    } else if (roll < 60) {
      final randomEnemy = standardEnemiesPool[_rng.nextInt(standardEnemiesPool.length)];
      _startBattleWithEnemy(randomEnemy);
    } else if (roll < 76) {
      _findLoot();
    } else if (roll < 86) {
      _encounterSealMaster();
    } else if (roll < 93) {
      _encounterWanderingSage();
    } else {
      addLog('Km $km: Przemieszczasz się lasami Kraju Ognia. Czysty teren.');
    }
  }

  // ZBALANSOWANY MISTRZ PIECZĘCI (Prawdziwy koszt zależy od potęgi ekwipunku)
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
                    '„Pieczęć Duszy wymaga potężnej ofiary w kruszcu. Wskaż przedmiot, który mam nierozerwalnie związać z twoją czakrą.”',
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

                      // Nowe, wyważone koszty pieczętowania
                      int cost;
                      switch (gear.rarity) {
                        case ItemRarity.common:
                          cost = 150;
                          break;
                        case ItemRarity.rare:
                          cost = 450;
                          break;
                        case ItemRarity.epic:
                          cost = 1100;
                          break;
                        case ItemRarity.legendary:
                          cost = 2500;
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

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('$slotName: ${gear.name}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gear.color)),
                          subtitle: Text('Pieczęć: $cost Ryo', style: const TextStyle(fontSize: 10, color: Colors.amberAccent)),
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
                        onPressed: chakra < maxChakra && ryo >= 25
                            ? () {
                                setState(() {
                                  ryo -= 25;
                                  chakra = maxChakra;
                                });
                                _saveGameData();
                                setMedicState(() {});
                                addLog('🩺 Medyk Konohy uleczył twoje rany (-25 Ryo).');
                              }
                            : null,
                        child: const Text('25 Ryo', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    const Divider(color: Colors.white12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text('🧬', style: TextStyle(fontSize: 24)),
                      title: const Text('Trening Obiegu Czakry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('+15 do Max Czakry', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                        onPressed: ryo >= 220
                            ? () {
                                setState(() {
                                  ryo -= 220;
                                  maxChakra += 15;
                                  chakra += 15;
                                });
                                _saveGameData();
                                setMedicState(() {});
                                addLog('✨ Poszerzono obieg Tenketsu! +15 Max Czakry (-220 Ryo).');
                              }
                            : null,
                        child: const Text('220 Ryo', style: TextStyle(fontSize: 10)),
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
                                        bonusAtk += 3;
                                      });
                                      _saveGameData();
                                      setMedicState(() {});
                                      addLog('🔥 Wykorzystano Punkt Biegłości: +3 stałego Ataku!');
                                    }
                                  : null,
                              child: const Text('+3 Ataku', style: TextStyle(fontSize: 10)),
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
                                        maxChakra += 20;
                                        chakra += 20;
                                      });
                                      _saveGameData();
                                      setMedicState(() {});
                                      addLog('💧 Wykorzystano Punkt Biegłości: +20 Max Czakry!');
                                    }
                                  : null,
                              child: const Text('+20 Czakry', style: TextStyle(fontSize: 10)),
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
                          label: const Text('Pigułka (30 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 30
                              ? () {
                                  setState(() => ryo -= 30);
                                  addConsumableToBag('c_pill', 1);
                                  setMedicState(() {});
                                }
                              : null,
                        ),
                        ActionChip(
                          avatar: const Text('🧴'),
                          label: const Text('Balsam (65 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 65
                              ? () {
                                  setState(() => ryo -= 65);
                                  addConsumableToBag('c_ointment', 1);
                                  setMedicState(() {});
                                }
                              : null,
                        ),
                        ActionChip(
                          avatar: const Text('💨'),
                          label: const Text('Dym (40 Ryo)', style: TextStyle(fontSize: 10)),
                          onPressed: ryo >= 40
                              ? () {
                                  setState(() => ryo -= 40);
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
    final kmScale = (km * 0.22).round();
    final int enemyMaxHp = template.baseHp + kmScale * (template.isBoss ? 3 : 1);
    final int enemyBaseAtk = template.baseAtk + (kmScale * 0.45).round();

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

              final rawDmg = enemyBaseAtk + _rng.nextInt(4);
              final dmg = max(2, rawDmg - (totalDefense ~/ 2));
              setState(() {
                chakra = max(0, chakra - dmg);
              });
              battleMsg = '${template.name} zadaje $dmg dmg! (Twoja Obrona: $totalDefense)';
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

              final dealt = (totalAttack * jutsu.powerMultiplier) + _rng.nextInt(5);
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
                final rewardRyo = template.isBoss ? (120 + km * 2) : (18 + km);
                final expGained = template.isBoss
                    ? (45 + (km ~/ 5) * 6)
                    : (10 + (km ~/ 5) * 2);

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
                addLog('💨 Zasłona dymna! Bezpieczna ucieczka z walki.');
                return;
              } else if (item.type == ConsumableType.directDmg) {
                enemyHp = max(0, enemyHp - item.value);
                battleMsg = 'Pieczęć Wybuchowa zadała ${item.value} dmg!';
                if (enemyHp <= 0) {
                  Navigator.pop(ctx);
                  final rewardRyo = template.isBoss ? 90 : 15;
                  final expGained = template.isBoss ? 30 : 8;
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
                        battleMsg = 'Przed bossem nie uciekniesz bez dymu!';
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

  // ZBALANSOWANY GENERATOR SPRZĘTU (Przedmioty mają realne znaczenie)
  NinjaGear _generateRandomGear({required GearSlot slot, bool guaranteedBossDrop = false}) {
    ItemRarity rarity;

    if (guaranteedBossDrop) {
      final bossRoll = _rng.nextInt(100);
      if (bossRoll < 68) {
        rarity = ItemRarity.rare;
      } else if (bossRoll < 94) {
        rarity = ItemRarity.epic;
      } else {
        rarity = ItemRarity.legendary;
      }
    } else {
      final roll = _rng.nextInt(1000);
      if (roll < 830) {
        rarity = ItemRarity.common;
      } else if (roll < 965) {
        rarity = ItemRarity.rare;
      } else if (roll < 996) {
        rarity = ItemRarity.epic;
      } else {
        rarity = ItemRarity.legendary;
      }
    }

    if (rarity == ItemRarity.legendary) {
      final legPool = legendaryArtifactsPool.where((g) => g.slot == slot).toList();
      final template = legPool[_rng.nextInt(legPool.length)];
      final statScaling = (km * 0.08).round();

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
        bonusVal = _rng.nextInt(3) + 2;
        break;
      case ItemRarity.epic:
        statMultiplier = 3;
        prefix = 'Pradawny';
        bonusAffix = 'Pieczęć Pięciu Żywiołów';
        bonusVal = _rng.nextInt(5) + 4;
        break;
      case ItemRarity.legendary:
        statMultiplier = 1;
        prefix = '';
        break;
    }

    final statScaling = (km * 0.06).round();
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

  // OBNIŻONA SZANSA NA SPRZĘT (35% zamiast 70% w zwykłych znaleziskach)
  void _findLoot({bool guaranteedBossDrop = false}) {
    final roll = _rng.nextInt(100);
    if (roll < 35 || guaranteedBossDrop) {
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
      addLog('📦 Wyprawa: Znaleziono [${item.name}]!');
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
        title: Text('Odnaleziono: $slotName!', style: const TextStyle(color: Colors.orangeAccent)),
        content: Text(
          'Nowy: [${newGear.rarityLabel}] ${newGear.name} (+${newGear.baseStat})\nStatus: Niezabezpieczony ⚠️\n\n'
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
              addLog('✨ Założono: ${newGear.name} (Wymaga pieczęci!)');
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

                          // Diminishing returns: 30% exp za powtórkę
                          final int earnedExp = isRepeat ? max(8, (m.rewardExp * 0.30).round()) : m.rewardExp;
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
                          addLog('🎖️ Sukces misji: ${m.title}! +$earnedRyo Ryo, +$earnedExp EXP ${isRepeat ? "(Powtórka: -70% EXP)" : ""}');
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
                    final bool isUnlocked = level >= m.minLevelRequired;
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
                            ? '${m.desc}\nNagroda: ${m.rewardRyo} Ryo | ${isCompleted ? "${(m.rewardExp * 0.30).round()} EXP (Powtórka)" : "+${m.rewardExp} EXP"}'
                            : 'Wymaga: Poziom ${m.minLevelRequired}',
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
                                addLog('📜 Przyjęto zlecenie: ${m.title}!');
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('Aktywna misja: Ranga ${allMissionsPool[activeMissionIndex!].rank} ($currentMissionKills/${allMissionsPool[activeMissionIndex!].requiredKills})', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                        ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Górny pasek funkcyjny w terenie
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF236B4A),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _openBagDialog,
                              icon: const Text('🎒', style: TextStyle(fontSize: 14)),
                              label: Text('Plecak ($totalItemsInBag)', style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B4D3E),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: returnToVillage,
                              icon: const Text('⛩️', style: TextStyle(fontSize: 14)),
                              label: const Text('Ucieczka', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Dolny duży przycisk pod kciuk (One-hand mode)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC44D00),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
