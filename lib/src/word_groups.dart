// Word groups for Odd One Out: words that clearly belong together, by
// word ID. Groups in the same family are close (birds and four-legged
// animals), so an odd one out from the same family is the harder kind.
// Words missing from the catalog are skipped when the game builds a round.

/// A set of words that belong together, and what they have in common.
class WordGroup {
  const WordGroup(this.id, this.family, this.label, this.wordIds);

  final String id;

  /// Groups in the same family are close to each other.
  final String family;

  /// What the words have in common, in English: “birds”.
  final String label;
  final List<String> wordIds;
}

const wordGroups = <WordGroup>[
  WordGroup('mammals', 'creatures', "animals with four legs", <String>[
    'word.bawng',
    'word.beram-2',
    'word.chinghne-2',
    'word.jf1011.sanghal',
    'word.jf178.chaite',
    'word.jf178.sakei',
    'word.jf300.keite',
    'word.jf300.sabengtung',
    'word.jf300.sakawr',
    'word.jf300.sazupui',
    'word.jf300.sihal',
    'word.jf300.ui',
    'word.jf300.vawk',
    'word.jf300.zawhte',
    'word.kel-2',
    'word.sai-2',
    'word.sakeibaknei',
    'word.sakhi',
    'word.savawm',
    'word.sazu',
    'word.sazuk-3',
    'word.zawng',
  ]),
  WordGroup('birds', 'creatures', "birds", <String>[
    'word.arpa',
    'word.arpui',
    'word.choak',
    'word.jf178.chawngzawng',
    'word.jf300.arawn',
    'word.jf300.chhimbuk',
    'word.jf300.parva',
    'word.jf300.sava',
    'word.jf300.varak',
    'word.mupui',
    'word.thuro',
    'word.vatawk',
    'word.vate',
  ]),
  WordGroup(
      'small_creatures', 'creatures', "insects and small creatures", <String>[
    'word.fanghmir',
    'word.jf178.chengkawl',
    'word.jf300.chukchu',
    'word.jf300.hrik',
    'word.jf300.maimawm',
    'word.jf300.tit',
    'word.jf300.uihli',
    'word.khuai',
    'word.khawimu',
    'word.pangang',
    'word.phengphehlep',
    'word.tho',
    'word.thosi',
    'word.khau',
  ]),
  WordGroup(
      'water_animals', 'creatures', "animals that live in water", <String>[
    'word.chakai',
    'word.jf300.ngharul',
    'word.jf300.sangha',
    'word.kaikuang',
    'word.awle',
    'word.satel',
  ]),
  WordGroup('fruit', 'food', "fruit", <String>[
    'word.balhla',
    'word.grep',
    'word.jf300.serthlum',
    'word.theihai',
    'word.ser',
    'word.kawlthei',
    'word.sapthei',
  ]),
  WordGroup('vegetables', 'food', "vegetables", <String>[
    'word.bawkbawn',
    'word.fanghma',
    'word.hmarcha',
    'word.jf300.alu',
    'word.jf300.zikhlum',
    'word.mai',
    'word.purun',
    'word.jf300.sawhthing',
    'word.iskut',
    'word.jf1011.bal',
  ]),
  WordGroup('drinks', 'food', "drinks", <String>[
    'word.jf178.thingpui',
    'word.jf178.tui',
    'word.bawnghnute',
  ]),
  WordGroup('meat', 'food', "meat", <String>[
    'word.arsa',
    'word.vawksa',
    'word.jf300.bawngsa',
    'word.sa',
  ]),
  WordGroup('head', 'body', "parts of the head", <String>[
    'word.beng',
    'word.ha',
    'word.hnar',
    'word.mit',
    'word.lei-2',
    'word.sam',
    'word.jf300.biang',
    'word.jf300.chal',
    'word.jf300.khabe',
    'word.jf300.mitko',
  ]),
  WordGroup('limbs', 'body', "parts of the arms and legs", <String>[
    'word.ke',
    'word.kut',
    'word.ban',
    'word.jf300.kutzungtang',
    'word.jf178.kutzungpui',
    'word.jf300.kiu',
    'word.jf300.koki',
    'word.jf300.kephah',
    'word.jf178.kezungtang',
  ]),
  WordGroup('family', 'people', "family", <String>[
    'word.jf300.nu',
    'word.jf300.pa',
    'word.jf1011.pi',
    'word.jf1011.pu',
    'word.jf1011.nau',
    'word.jf178.fapa',
    'word.jf300.fanu',
    'word.jf300.unaupa',
    'word.farnu',
    'word.nupui',
    'word.pasal',
  ]),
  WordGroup('jobs', 'people', "people's work", <String>[
    'word.daktawr',
    'word.jf300.zirtirtu',
    'word.sipai',
    'word.mistiri',
    'word.jf300.roreltu',
    'word.jf300.puithiam',
  ]),
  WordGroup('sky', 'nature', "the sky and weather", <String>[
    'word.chhum',
    'word.ruah',
    'word.ni',
    'word.thla',
    'word.jf300.arsi',
    'word.jf300.van',
    'word.thli',
    'word.jf178.vur',
    'word.jf300.rial',
    'word.jf300.kawlphe',
    'word.chhimbal',
  ]),
  WordGroup('land', 'nature', "land and water", <String>[
    'word.jf300.lui',
    'word.jf300.tlang',
    'word.tuipui',
    'word.dil',
    'word.ngaw',
    'word.lungpui',
    'word.jf300.tuifinriat',
    'word.jf178.ruam',
  ]),
  WordGroup('house', 'home', "things in a house", <String>[
    'word.jf300.khum',
    'word.jf300.kawngkhar',
    'word.jf300.tukverh',
    'word.jf300.thutthleng',
    'word.jf178.bang',
    'word.lukham',
    'word.jf300.khawnvar',
    'word.jf1011.chabi',
  ]),
  WordGroup('kitchen', 'home', "kitchen things", <String>[
    'word.bel',
    'word.no',
    'word.thleng',
    'word.fian',
    'word.jf300.thirkut',
    'word.jf300.chemte',
    'word.jf300.chawhtawlh',
    'word.jf300.ketli',
  ]),
  WordGroup('clothes', 'home', "clothes", <String>[
    'word.kawr',
    'word.jf1011.kamis',
    'word.kekawr',
    'word.pheikhawk',
    'word.lukhum',
    'word.mawza',
    'word.jf300.kawrchung',
    'word.jf178.vawthlep',
    'word.jf300.kawnghren',
  ]),
  WordGroup('school', 'school', "school things", <String>[
    'word.jf300.lehkhabu',
    'word.jf300.pensil',
    'word.lehkha',
    'word.jf300.lehkhatui',
    'word.jf300.hawrawp',
  ]),
  WordGroup('numbers', 'school', "numbers", <String>[
    'word.jf300.pakhat',
    'word.jf178.pahnih',
    'word.jf1011.pathum',
    'word.jf1011.pali',
    'word.jf1011.panga',
    'word.jf1011.paruk',
    'word.jf178.pasarih',
    'word.jf300.pariat',
    'word.jf300.pakua',
    'word.jf178.sawm',
  ]),
  WordGroup('days', 'time', "days of the week", <String>[
    'word.jf1011.thawhtanni',
    'word.jf1011.thawhlehni',
    'word.jf1011.nilaini',
    'word.jf1011.ningani',
    'word.jf1011.zirtawpni',
    'word.jf1011.inrinni',
    'word.jf1011.pathianni',
  ]),
  WordGroup('daytime', 'time', "times of day", <String>[
    'word.jf300.zing',
    'word.jf300.chhun',
    'word.jf300.tlai',
    'word.jf300.zan',
    'word.jf300.khawvar',
    'word.jf300.thimhlim',
  ]),
  WordGroup('colours', 'colours', "colours", <String>[
    'word.sen',
    'word.dum',
    'word.var',
    'word.jf300.hring',
    'word.jf300.dumpawl',
    'word.jf178.uk',
    'word.jf300.vutbuak',
    'word.buang',
  ]),
  WordGroup('music', 'music', "musical instruments", <String>[
    'word.khuang',
    'word.phenglawng',
    'word.tingtang',
    'word.darbu',
    'word.bengbung',
  ]),
  WordGroup('moving', 'actions', "ways of moving", <String>[
    'word.jf178.tlan',
    'word.zuang',
    'word.thlawk',
    'word.jf178.hleuh',
    'word.jf300.kal',
    'word.lawn',
    'word.jf300.bawkvak',
    'word.jf300.liluh'
  ]),
  WordGroup('senses', 'actions', "seeing and hearing", <String>[
    'word.jf300.en',
    'word.jf300.hmu',
    'word.jf300.ngaithla',
    'word.thlir',
    'word.enthla'
  ]),
  WordGroup('eating', 'actions', "eating and drinking", <String>[
    'word.jf300.ei',
    'word.dawlh',
    'word.jf178.lem',
    'word.jf300.thial',
    'word.jf1011.hip',
    'word.jf178.tem'
  ]),
  WordGroup('handwork', 'actions', "sewing, weaving and knitting",
      <String>['word.thui', 'word.jf178.tah', 'word.jf300.laphiar']),
  WordGroup('farming', 'actions', "farm work", <String>[
    'word.tuh',
    'word.jf300.phun',
    'word.jf300.seng',
    'word.hlothlo'
  ]),
  WordGroup('tastes', 'describing', "tastes", <String>[
    'word.jf178.thlum',
    'word.jf1011.al',
    'word.jf178.thak',
    'word.jf300.kha',
    'word.jf178.thur'
  ]),
  WordGroup('sizes', 'describing', "sizes and shapes", <String>[
    'word.jf300.lian',
    'word.jf178.te',
    'word.sei',
    'word.tawi',
    'word.sang',
    'word.jf300.hniam',
    'word.jf178.cher',
    'word.jf178.chhah'
  ]),
  WordGroup('feelings', 'describing', "feelings", <String>[
    'word.jf300.hlim',
    'word.lungngai',
    'word.jf300.thinur',
    'word.hlau',
    'word.lungawi',
    'word.jf1011.ngui'
  ]),
  WordGroup('hot_cold', 'describing', "hot, cold, wet and dry",
      <String>['word.lum', 'word.vawt', 'word.hul', 'word.huh']),
  WordGroup('nearby_days', 'time', "yesterday, today and tomorrow", <String>[
    'word.nimin',
    'word.jf178.vawiin',
    'word.jf1011.naktuk',
    'word.jf1011.hmanni'
  ]),
  WordGroup('questions', 'questions', "question words", <String>[
    'word.jf1011.tu',
    'word.jf1011.khawiah',
    'word.jf1011.engtikah',
    'word.jf1011.engvangin',
    'word.jf178.engtiangin'
  ]),
  WordGroup('plants', 'nature', "trees and plants", <String>[
    'word.jf178.thing',
    'word.hnah',
    'word.pangpar',
    'word.jf300.mau',
    'word.zung',
    'word.jf300.thingtang',
    'word.jf300.katchat'
  ]),
  WordGroup('tools', 'home', "tools", <String>[
    'word.jf300.hrei',
    'word.hreipui',
    'word.jf300.tuboh',
    'word.chem',
    'word.favah',
    'word.tuthlawh'
  ]),
];

/// Groups close enough that a word of one could seem to belong to the
/// other (a lemon is fruit, but grows on a tree), so neither is ever the
/// odd one out for the other.
const overlappingGroups = <(String, String)>{
  ('plants', 'fruit'),
  ('plants', 'vegetables'),
  ('eating', 'tastes'),
  ('eating', 'drinks'),
  ('hot_cold', 'sky'),
  ('tools', 'kitchen'),
  ('farming', 'plants'),
  ('farming', 'vegetables'),
  ('senses', 'head'),
};

bool groupsOverlap(WordGroup a, WordGroup b) =>
    overlappingGroups.contains((a.id, b.id)) ||
    overlappingGroups.contains((b.id, a.id));
