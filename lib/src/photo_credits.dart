/// A word's photo from Wikimedia Commons and whom to credit, as the
/// photos' licences (mostly CC BY-SA) ask. Shown on Settings → Photo credits.
class PhotoCredit {
  const PhotoCredit(
      this.wordId, this.title, this.author, this.licence, this.url);

  final String wordId;
  final String title;
  final String author;
  final String licence;

  /// The photo's page on Wikimedia Commons.
  final String url;
}

const photoCredits = <PhotoCredit>[
  PhotoCredit("word.iskut", "Chayote 2.jpg", "Gaurav Dhwaj Khadka",
      "CC BY-SA 4.0", "https://commons.wikimedia.org/wiki/File:Chayote_2.jpg"),
  PhotoCredit(
      "word.kawlthei",
      "Goiaba vermelha.jpg",
      "Rodrigo.Argenton",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Goiaba_vermelha.jpg"),
  PhotoCredit(
      "word.sapthei",
      "Passion fruits - whole and halved.jpg",
      "Ivar Leidus",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Passion_fruits_-_whole_and_halved.jpg"),
  PhotoCredit(
      "word.jf1011.bal",
      "Colocasia esculenta dsc07801.jpg",
      "David Monniaux",
      "CC BY-SA 3.0",
      "https://commons.wikimedia.org/wiki/File:Colocasia_esculenta_dsc07801.jpg"),
  PhotoCredit(
      "word.ngun",
      "Bangle MET 35.7.38 .39 01 11 03.jpg",
      "The Metropolitan Museum of Art",
      "CC0",
      "https://commons.wikimedia.org/wiki/File:Bangle_MET_35.7.38_.39_01_11_03.jpg"),
  PhotoCredit(
      "word.tuthlawh",
      "Hoe farming tool in Taraba State.jpg",
      "Gwanki",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Hoe_farming_tool_in_Taraba_State.jpg"),
  PhotoCredit(
      "word.jf300.lungsam",
      "Dead Trunk with Moss in Fallätsche.jpg",
      "Daniel Kraft",
      "CC BY-SA 3.0",
      "https://commons.wikimedia.org/wiki/File:Dead_Trunk_with_Moss_in_Fall%C3%A4tsche.jpg"),
  PhotoCredit("word.hnapkhawn", "Arion ater RF.jpg", "Robert Flogaus-Faust",
      "CC BY 4.0", "https://commons.wikimedia.org/wiki/File:Arion_ater_RF.jpg"),
  PhotoCredit(
      "word.buhchium",
      "Butterfly's chrysalis.jpg",
      "Aruna at Malayalam Wikipedia",
      "CC BY-SA 3.0",
      "https://commons.wikimedia.org/wiki/File:Butterfly%27s_chrysalis.jpg"),
  PhotoCredit(
      "word.jf300.hrik",
      "Male human head louse.jpg",
      "Gilles San Martin",
      "CC BY-SA 2.0",
      "https://commons.wikimedia.org/wiki/File:Male_human_head_louse.jpg"),
  PhotoCredit(
      "word.jf300.uihli",
      "Ctenocephalides felis ZSM.jpg",
      "Katja ZSM",
      "CC BY-SA 3.0",
      "https://commons.wikimedia.org/wiki/File:Ctenocephalides_felis_ZSM.jpg"),
  PhotoCredit(
      "word.mu-2",
      "Roadside hawk (Rupornis magnirostris) immature 2.jpg",
      "Charles J. Sharp",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Roadside_hawk_(Rupornis_magnirostris)_immature_2.jpg"),
  PhotoCredit(
      "word.jf300.meihawl",
      "Charcoal sticks 051907.jpg",
      "Mrs Scarborough",
      "Public domain",
      "https://commons.wikimedia.org/wiki/File:Charcoal_sticks_051907.jpg"),
  PhotoCredit(
      "word.jf300.chirh",
      "Volcanes de lodo, Buzau, Rumanía, 2016-05-29, DD 34.jpg",
      "Diego Delso",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Volcanes_de_lodo,_Buzau,_Ruman%C3%ADa,_2016-05-29,_DD_34.jpg"),
  PhotoCredit(
      "word.jf300.tuikhuah",
      "Faches etang des periseaux.jpg",
      "Velvet",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Faches_etang_des_periseaux.jpg"),
  PhotoCredit(
      "word.tuikhur",
      "Natural Spring water, Aharbal Kashmir.jpg",
      "TheAutumnal",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Natural_Spring_water,_Aharbal_Kashmir.jpg"),
  PhotoCredit(
      "word.sawntlung",
      "Litchfield National Park (AU), Magnetic Termite Mounds -- 2019 -- 3729.jpg",
      "Dietmar Rabich",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:Litchfield_National_Park_(AU),_Magnetic_Termite_Mounds_--_2019_--_3729.jpg"),
  PhotoCredit(
      "word.luikuang",
      "The Wadi Ejili.jpg",
      "Alexandermcnabb",
      "CC BY-SA 4.0",
      "https://commons.wikimedia.org/wiki/File:The_Wadi_Ejili.jpg"),
  PhotoCredit(
      "word.bathlar",
      "Manor house in Bykowce veranda inside.jpg",
      "Lowdown",
      "CC BY-SA 3.0",
      "https://commons.wikimedia.org/wiki/File:Manor_house_in_Bykowce_veranda_inside.jpg"),
  PhotoCredit(
      "word.jf1011.mual",
      "Playing field at Mosney - geograph.org.uk - 224460.jpg",
      "Roger McLachlan",
      "CC BY-SA 2.0",
      "https://commons.wikimedia.org/wiki/File:Playing_field_at_Mosney_-_geograph.org.uk_-_224460.jpg"),
  PhotoCredit("word.jf300.thuk", "Murhun dutse.jpg", "Marwan Bello", "CC0",
      "https://commons.wikimedia.org/wiki/File:Murhun_dutse.jpg"),
];
