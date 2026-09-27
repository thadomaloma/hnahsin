import 'journey_models.dart';

abstract final class JourneyContentPolicy {
  static const isProduction = bool.fromEnvironment(
    'THUMAL_QUEST_PRODUCTION',
    defaultValue: false,
  );

  static bool get releaseReady => journeyStories.isNotEmpty &&
      journeyStories.every(
        (story) => story.review == JourneyReviewState.approved,
      ) &&
      journeyNodes.every(
        (node) => node.review == JourneyReviewState.approved,
      );

  static bool playable(JourneyReviewState review) =>
      review == JourneyReviewState.approved ||
      (!isProduction && review == JourneyReviewState.reviewRequired);
}

abstract final class CultureTrailPolicy {
  static const isProduction = JourneyContentPolicy.isProduction;

  static bool get releaseReady => cultureCards.isNotEmpty &&
      cultureCards.every((card) => card.review == JourneyReviewState.approved) &&
      seasonalTrails.every(
        (trail) => trail.review == JourneyReviewState.approved,
      );

  static bool playable(JourneyReviewState review) =>
      review == JourneyReviewState.approved ||
      (!isProduction && review == JourneyReviewState.reviewRequired);
}

const journeyRegions = <JourneyRegion>[
  JourneyRegion(
    id: 'region.home',
    titleMizo: 'In leh Khawtlang',
    titleEnglish: 'Home & Community',
    subtitleMizo: 'In chhûng leh khawtlâng tawngkam zirna',
    emoji: '🏡',
    nodeIds: <String>['journey.homecoming'],
  ),
  JourneyRegion(
    id: 'region.nature',
    titleMizo: 'Ram Mawi',
    titleEnglish: 'Hills & Nature',
    subtitleMizo: 'Tlang, lui leh ram nun hriatna',
    emoji: '⛰️',
    nodeIds: <String>['journey.river_walk'],
  ),
  JourneyRegion(
    id: 'region.culture',
    titleMizo: 'Hnam Nun',
    titleEnglish: 'Living Culture',
    subtitleMizo: 'Tlawmngaihna leh Mizo nunphung',
    emoji: '🤝',
    nodeIds: <String>['journey.helping_hand'],
  ),
];

const journeyNodes = <JourneyNode>[
  JourneyNode(
    id: 'journey.homecoming',
    regionId: 'region.home',
    order: 1,
    titleMizo: 'In Lam Pan',
    titleEnglish: 'Coming Home',
    subtitleMizo: 'In chhûnga inbiakna tawngkam',
    storyId: 'story.homecoming',
    prerequisiteNodeIds: <String>[],
    minimumLevel: 0,
    rewardId: 'reward.home_scarf',
    review: JourneyReviewState.reviewRequired,
  ),
  JourneyNode(
    id: 'journey.river_walk',
    regionId: 'region.nature',
    order: 2,
    titleMizo: 'Lui Kamah',
    titleEnglish: 'By the River',
    subtitleMizo: 'Ram mawi chungchânga inbiakna',
    storyId: 'story.river_walk',
    prerequisiteNodeIds: <String>['journey.homecoming'],
    minimumLevel: 1,
    rewardId: 'reward.hill_badge',
    review: JourneyReviewState.reviewRequired,
  ),
  JourneyNode(
    id: 'journey.helping_hand',
    regionId: 'region.culture',
    order: 3,
    titleMizo: 'Kut Ṭanpui',
    titleEnglish: 'A Helping Hand',
    subtitleMizo: 'Tlawmngaihna nunpui dân',
    storyId: 'story.helping_hand',
    prerequisiteNodeIds: <String>['journey.river_walk'],
    minimumLevel: 2,
    rewardId: 'reward.tlawmngaihna_pin',
    review: JourneyReviewState.reviewRequired,
  ),
];

const journeyRewards = <JourneyReward>[
  JourneyReward(
    id: 'reward.home_scarf',
    emoji: '🧣',
    childLabel: 'Khawtlang Explorer Scarf',
    adultLabel: 'Home Conversation Mark',
  ),
  JourneyReward(
    id: 'reward.hill_badge',
    emoji: '🏔️',
    childLabel: 'Hill Explorer Badge',
    adultLabel: 'Ram Mawi Reading Mark',
  ),
  JourneyReward(
    id: 'reward.tlawmngaihna_pin',
    emoji: '🤝',
    childLabel: 'Kind Helper Pin',
    adultLabel: 'Tlawmngaihna Culture Mark',
  ),
];

const cultureCards = <CultureCard>[
  CultureCard(
    id: 'culture.tlawmngaihna',
    titleMizo: 'Tlawmngaihna',
    titleEnglish: 'Selfless care',
    shortMeaningMizo: 'Mahni hmasial lova mi dangte ngaihsak leh ṭanpui',
    contextMizo:
        'Tlawmngaihna chu Mizo khawtlâng nunah mi dangte mamawh hriatpui, ṭanpui leh mawhphurhna lâkna rilru a ni.',
    englishSupport:
        'A community value of noticing needs, helping others and accepting responsibility without seeking personal gain.',
    exampleMizo: 'Tlawmngaihna avângin khawtlâng hna kan thawh ho.',
    topic: CultureTopic.communityValues,
    emoji: '🤝',
    minimumLevel: 0,
    review: JourneyReviewState.reviewRequired,
  ),
  CultureCard(
    id: 'culture.hnatlang',
    titleMizo: 'Hnatlâng',
    titleEnglish: 'Community work',
    shortMeaningMizo: 'Khawtlâng tâna mipuite hna thawh ho',
    contextMizo:
        'Hnatlângah chuan khawtlâng mamawh, entîr nân kawng tihfai emaw hmun siamṭhat emaw, mipuite an thawh ho ṭhîn.',
    englishSupport:
        'People work together on a practical need shared by the community, such as cleaning or repairing a common place.',
    exampleMizo: 'Zîngah khawtlâng kawng tihfai hnatlâng kan nei ang.',
    topic: CultureTopic.community,
    emoji: '🧹',
    minimumLevel: 0,
    review: JourneyReviewState.reviewRequired,
  ),
  CultureCard(
    id: 'culture.zawlbuk',
    titleMizo: 'Zawlbûk',
    titleEnglish: 'Traditional bachelors’ house',
    shortMeaningMizo: 'Hmanlai Mizo khuaa tlangvalte awmkhâwmna in',
    contextMizo:
        'Zawlbûk chu hmanlai khuaa tlangvalte awmkhâwmna leh zirtîrna hmun pawimawh a ni a; mikhual thlenna atân pawh hman a ni ṭhîn.',
    englishSupport:
        'A historical community institution where young men stayed, learned responsibilities and received guests.',
    exampleMizo: 'Zawlbûk chungchâng chu Mizo history-ah kan zir.',
    topic: CultureTopic.heritage,
    emoji: '🏡',
    minimumLevel: 1,
    review: JourneyReviewState.reviewRequired,
  ),
  CultureCard(
    id: 'culture.lengkhawm',
    titleMizo: 'Lengkhâwm',
    titleEnglish: 'Singing together',
    shortMeaningMizo: 'Hla sa leh inkâwm ho tûra inkhâwm',
    contextMizo:
        'Lengkhâwm chu mipuite an inkhâwm a, hla an sa ho va, inkawmna leh inpawhna an neihna a ni.',
    englishSupport:
        'A social gathering centred on singing together, conversation and shared fellowship.',
    exampleMizo: 'Zânah ṭhiante nên lengkhâwm kan nei.',
    topic: CultureTopic.community,
    emoji: '🎶',
    minimumLevel: 1,
    review: JourneyReviewState.reviewRequired,
  ),
  CultureCard(
    id: 'culture.kut',
    titleMizo: 'Kût',
    titleEnglish: 'Festival',
    shortMeaningMizo: 'Lâwmna leh hnam nun lantîrna hunpui',
    contextMizo:
        'Mizo kûtte zînga Chapchar Kût, Mim Kût leh Pawl Kût te chuan hun leh thil thleng hrang hrang hriatrengna an keng.',
    englishSupport:
        'Mizo festivals such as Chapchar Kut, Mim Kut and Pawl Kut remember different seasons and shared traditions.',
    exampleMizo: 'Chapchar Kûtah hnam lam leh hla kan hmang.',
    topic: CultureTopic.celebration,
    emoji: '🥁',
    minimumLevel: 2,
    review: JourneyReviewState.reviewRequired,
  ),
  CultureCard(
    id: 'culture.chibai',
    titleMizo: 'Chibai',
    titleEnglish: 'Greeting',
    shortMeaningMizo: 'Inhmuh huna zahna nên inbiakna',
    contextMizo:
        '“Chibai” tih hi inhmuh huna inbiakna tawngkam a ni. Hun leh mi milin “Chibai” emaw “I dam em?” emaw kan hmang ṭhîn.',
    englishSupport:
        'Chibai is a respectful greeting. The exact greeting can change with the situation and relationship.',
    exampleMizo: 'Chibai, i dam em?',
    topic: CultureTopic.language,
    emoji: '👋',
    minimumLevel: 0,
    review: JourneyReviewState.reviewRequired,
  ),
];

const collectionMilestones = <CollectionMilestone>[
  CollectionMilestone(
    id: 'milestone.first_card',
    requiredCards: 1,
    emoji: '🌱',
    childLabel: 'Culture Trail Starter',
    adultLabel: 'First Culture Note',
  ),
  CollectionMilestone(
    id: 'milestone.three_cards',
    requiredCards: 3,
    emoji: '🧭',
    childLabel: 'Culture Explorer',
    adultLabel: 'Culture Trail Reader',
  ),
  CollectionMilestone(
    id: 'milestone.six_cards',
    requiredCards: 6,
    emoji: '🏵️',
    childLabel: 'Hnam Nun Keeper',
    adultLabel: 'Culture Trail Complete',
  ),
];

const avatarStyles = <AvatarStyle>[
  AvatarStyle(
    id: 'avatar.pathfinder',
    emoji: '🧭',
    requiredMarks: 0,
    childLabel: 'Little Pathfinder',
    adultLabel: 'Pathfinder',
  ),
  AvatarStyle(
    id: 'avatar.hill_walker',
    emoji: '⛰️',
    requiredMarks: 3,
    childLabel: 'Hill Adventurer',
    adultLabel: 'Hill Walker',
  ),
  AvatarStyle(
    id: 'avatar.culture_keeper',
    emoji: '🏵️',
    requiredMarks: 7,
    childLabel: 'Culture Star',
    adultLabel: 'Culture Keeper',
  ),
];

const seasonalTrails = <SeasonalTrail>[
  SeasonalTrail(
    id: 'season.chapchar_archive',
    title: 'Chapchar Kut Trail',
    descriptionMizo:
        'Chapchar Kût nêna inzawm hnam nun zirna; hun bi a ral hnu pawhin archive-ah zir zêl theih a ni.',
    cardIds: <String>[
      'culture.kut',
      'culture.lengkhawm',
      'culture.hnatlang',
    ],
    archiveAvailable: true,
    review: JourneyReviewState.reviewRequired,
  ),
];

const journeyStories = <StoryEpisode>[
  StoryEpisode(
    id: 'story.homecoming',
    nodeId: 'journey.homecoming',
    titleMizo: 'In Lam Pan',
    titleEnglish: 'Coming Home',
    introductionMizo:
        'Rova chu Japan aṭanga Aizawl a lo haw a. A piin lâwm takin a lo hmuak a.',
    introductionEnglish:
        'Rova returns to Aizawl from Japan. His grandmother welcomes him warmly.',
    targetWordIds: <String>['in', 'nu', 'ei'],
    beats: <StoryBeat>[
      StoryBeat(
        id: 'home.hello',
        speaker: 'Pi',
        mizo: 'Rova, lo thleng ta che aw! I dam em?',
        english: 'Rova, welcome. How are you?',
        choices: <StoryChoice>[
          StoryChoice(
            id: 'home.hello.natural',
            mizo: 'Ka dam e, Pi. Ka lawm e.',
            english: 'I am well, Grandma. Thank you.',
            replyMizo: 'A lawmawm e. Lo lût rawh.',
            isNatural: true,
          ),
          StoryChoice(
            id: 'home.hello.retry',
            mizo: 'Ka in chu tui a ni.',
            english: 'My house is water.',
            replyMizo: 'Kan inbiakna nên a inmil lo. Han thlang leh teh.',
            isNatural: false,
          ),
        ],
      ),
      StoryBeat(
        id: 'home.food',
        speaker: 'Pi',
        mizo: 'Chaw i ei tawh em?',
        english: 'Have you eaten?',
        choices: <StoryChoice>[
          StoryChoice(
            id: 'home.food.natural',
            mizo: 'Ka la ei lo. Kan ei dûn ang aw.',
            english: 'Not yet. Let us eat together.',
            replyMizo: 'Aw le, chaw ka buatsaih nghâl ang.',
            isNatural: true,
          ),
          StoryChoice(
            id: 'home.food.retry',
            mizo: 'Lehkhabu chu a thlawk.',
            english: 'The book flies.',
            replyMizo: 'Zawhna nên a inmil lo. Chaw chungchâng sawi rawh.',
            isNatural: false,
          ),
        ],
      ),
    ],
    cultureNoteMizo:
        '“Chaw i ei tawh em?” tih hi chaw ei leh ei loh zawhna mai ni lovin, ngaihsakna lantîrna pawh a ni ṭhîn.',
    cultureNoteEnglish:
        'Asking whether someone has eaten can also be a warm expression of care.',
    review: JourneyReviewState.reviewRequired,
  ),
  StoryEpisode(
    id: 'story.river_walk',
    nodeId: 'journey.river_walk',
    titleMizo: 'Lui Kamah',
    titleEnglish: 'By the River',
    introductionMizo:
        'Rova leh a ṭhian Liana chu lui kamah an kal a. Ram mawi tak an thlîr dûn a.',
    introductionEnglish:
        'Rova and his friend Liana walk beside the river and enjoy the landscape.',
    targetWordIds: <String>['lui', 'tlang', 'mawi'],
    beats: <StoryBeat>[
      StoryBeat(
        id: 'river.view',
        speaker: 'Liana',
        mizo: 'He lai ram hi a mawi hle mai, maw?',
        english: 'This place is very beautiful, is it not?',
        choices: <StoryChoice>[
          StoryChoice(
            id: 'river.view.natural',
            mizo: 'A mawi e. Tlang leh lui hi ka ngaihhlut hle.',
            english: 'It is. I really value these hills and rivers.',
            replyMizo: 'Keipawhin ka ngaihhlut ve hle.',
            isNatural: true,
          ),
          StoryChoice(
            id: 'river.view.retry',
            mizo: 'Sikul chu sangha a ni.',
            english: 'School is a fish.',
            replyMizo: 'Ram mawi chungchângin chhâng leh teh.',
            isNatural: false,
          ),
        ],
      ),
      StoryBeat(
        id: 'river.care',
        speaker: 'Liana',
        mizo: 'Lui tui hi thianghlim reng se kan duh a ni.',
        english: 'We want the river water to remain clean.',
        choices: <StoryChoice>[
          StoryChoice(
            id: 'river.care.natural',
            mizo: 'Aw, bawlhhlawh kan paih lo vang.',
            english: 'Yes, we will not throw rubbish here.',
            replyMizo: 'A ṭha e. Kan ram kan enkawl ho ang.',
            isNatural: true,
          ),
          StoryChoice(
            id: 'river.care.retry',
            mizo: 'Ni chu a ziak.',
            english: 'The sun writes.',
            replyMizo: 'Lui enkawl dân sawi rawh.',
            isNatural: false,
          ),
        ],
      ),
    ],
    cultureNoteMizo:
        'Mizo hla leh thawnthu tam takah tlang, lui leh ram mawi hi rilru leh hnam nun nên a inzawm tlat.',
    cultureNoteEnglish:
        'Hills, rivers and the land are closely woven into Mizo songs, stories and identity.',
    review: JourneyReviewState.reviewRequired,
  ),
  StoryEpisode(
    id: 'story.helping_hand',
    nodeId: 'journey.helping_hand',
    titleMizo: 'Kut Ṭanpui',
    titleEnglish: 'A Helping Hand',
    introductionMizo:
        'Khawtlâng inkhâwmah Pi Hmingi chuan thil phur a harsa a. Rova leh Liana chuan an hmu a.',
    introductionEnglish:
        'At a community gathering, Pi Hmingi struggles to carry her things. Rova and Liana notice.',
    targetWordIds: <String>['tlawmngaihna', 'hlim', 'thian'],
    beats: <StoryBeat>[
      StoryBeat(
        id: 'help.offer',
        speaker: 'Rova',
        mizo: 'Pi Hmingi, kan phurhpui ang che aw?',
        english: 'Pi Hmingi, shall we carry those for you?',
        choices: <StoryChoice>[
          StoryChoice(
            id: 'help.offer.natural',
            mizo: 'Aw, min phurhpui ula ka lâwm hle ang.',
            english: 'Yes, I would be very grateful for your help.',
            replyMizo: 'Kan phurhpui nghâl ang che.',
            isNatural: true,
          ),
          StoryChoice(
            id: 'help.offer.retry',
            mizo: 'Ka thla chu sikul a kal.',
            english: 'My moon goes to school.',
            replyMizo: 'Ṭanpuina pawm dân han thlang leh teh.',
            isNatural: false,
          ),
        ],
      ),
      StoryBeat(
        id: 'help.meaning',
        speaker: 'Liana',
        mizo: 'Hetiang taka mi dang ṭanpui hi tlawmngaihna a ni.',
        english: 'Helping another person like this is tlawmngaihna.',
        choices: <StoryChoice>[
          StoryChoice(
            id: 'help.meaning.natural',
            mizo: 'Aw, kan khawtlâng nunphung mawi tak a ni.',
            english: 'Yes, it is a beautiful part of our community life.',
            replyMizo: 'Kan nunpui zêl ang u.',
            isNatural: true,
          ),
          StoryChoice(
            id: 'help.meaning.retry',
            mizo: 'Tlawmngaihna chu ranvulh a ni.',
            english: 'Tlawmngaihna is livestock.',
            replyMizo: 'A awmzia chu mi dangte ngaihsak leh ṭanpui hi a ni.',
            isNatural: false,
          ),
        ],
      ),
    ],
    cultureNoteMizo:
        'Tlawmngaihna chu mahni hmasial lova mi dang ngaihsak, ṭanpui leh khawtlâng tâna mawhphurhna la tihna a ni.',
    cultureNoteEnglish:
        'Tlawmngaihna describes selfless care, practical help and responsibility toward the community.',
    review: JourneyReviewState.reviewRequired,
  ),
];

JourneyNode? journeyNodeById(String id) {
  for (final node in journeyNodes) {
    if (node.id == id) return node;
  }
  return null;
}

StoryEpisode? journeyStoryById(String id) {
  for (final story in journeyStories) {
    if (story.id == id) return story;
  }
  return null;
}

JourneyReward? journeyRewardById(String id) {
  for (final reward in journeyRewards) {
    if (reward.id == id) return reward;
  }
  return null;
}

CultureCard? cultureCardById(String id) {
  for (final card in cultureCards) {
    if (card.id == id) return card;
  }
  return null;
}

AvatarStyle? avatarStyleById(String id) {
  for (final avatar in avatarStyles) {
    if (avatar.id == id) return avatar;
  }
  return null;
}
