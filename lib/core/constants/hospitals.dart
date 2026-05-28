// lib/core/constants/hospitals.dart

enum HospitalSpecialty {
  multiSpecialty,
  trauma,
  cardiac,
  oncology,
  maternity,
  pediatrics,
  neurology,
  orthopedics,
  general,
}

extension HospitalSpecialtyLabel on HospitalSpecialty {
  String get label {
    switch (this) {
      case HospitalSpecialty.multiSpecialty: return 'Multi-Specialty';
      case HospitalSpecialty.trauma:         return 'Accident & Trauma';
      case HospitalSpecialty.cardiac:        return 'Cardiac Care';
      case HospitalSpecialty.oncology:       return 'Cancer / Oncology';
      case HospitalSpecialty.maternity:      return 'Maternity & Women';
      case HospitalSpecialty.pediatrics:     return 'Pediatrics';
      case HospitalSpecialty.neurology:      return 'Neurology / Psychiatry';
      case HospitalSpecialty.orthopedics:    return 'Orthopedics';
      case HospitalSpecialty.general:        return 'General Medicine';
    }
  }
}

class Hospital {
  final String name;
  final String city;       // e.g. "Bengaluru"
  final String area;       // e.g. "Indiranagar"
  final String address;
  final String phone;
  final String mapsUrl;
  final List<HospitalSpecialty> specialties;

  const Hospital({
    required this.name,
    required this.city,
    required this.area,
    required this.address,
    required this.phone,
    required this.mapsUrl,
    required this.specialties,
  });
}

class Hospitals {
  Hospitals._();

  static const all = <Hospital>[

    // ════════════════════════════════════════════════
    //  BENGALURU  (22 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'Victoria Hospital',
      city: 'Bengaluru',
      area: 'KR Market / City Market',
      address: 'Fort Road, Krishna Rajendra Market, Bengaluru – 560002',
      phone: '08022975001',
      mapsUrl: 'https://maps.app.goo.gl/1QvXm9VgGzFkbP9x6',
      specialties: [HospitalSpecialty.trauma, HospitalSpecialty.general],
    ),
    Hospital(
      name: 'BMS Hospital',
      city: 'Bengaluru',
      area: 'Basavanagudi',
      address: 'No. 6, Bull Temple Road, Basavanagudi, Bengaluru – 560004',
      phone: '08026613700',
      mapsUrl: 'https://maps.app.goo.gl/bms1',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Bowring & Lady Curzon Hospital',
      city: 'Bengaluru',
      area: 'Shivajinagar',
      address: 'Shivajinagar, Bengaluru – 560001',
      phone: '08025320701',
      mapsUrl: 'https://maps.app.goo.gl/N5C4PH3HqNM7XtcR6',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Manipal Hospital (Old Airport Road)',
      city: 'Bengaluru',
      area: 'HAL / Kodihalli',
      address: '98, HAL Airport Road, Kodihalli, Bengaluru – 560017',
      phone: '08025023000',
      mapsUrl: 'https://maps.app.goo.gl/5Yd5Rz7zQ6PUAaNC9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Fortis Hospital Bannerghatta Road',
      city: 'Bengaluru',
      area: 'Bannerghatta Road',
      address: '154/9, Bannerghatta Road, Opposite IIM-B, Bengaluru – 560076',
      phone: '08066214444',
      mapsUrl: 'https://maps.app.goo.gl/LvBckBphHHNSoRqV9',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.oncology, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'St. John\'s Medical College Hospital',
      city: 'Bengaluru',
      area: 'Koramangala / Sarjapur Road',
      address: 'Sarjapur Road, Koramangala, Bengaluru – 560034',
      phone: '08049467777',
      mapsUrl: 'https://maps.app.goo.gl/b3fW7RfR93pThgCb7',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Narayana Health City',
      city: 'Bengaluru',
      area: 'Bommasandra / Electronic City',
      address: '258/A, Bommasandra Industrial Area, Anekal Taluk, Bengaluru – 560099',
      phone: '08071222222',
      mapsUrl: 'https://maps.app.goo.gl/dW1oTMjzENx3b8Hg8',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Sakra World Hospital',
      city: 'Bengaluru',
      area: 'Marathahalli / Bellandur',
      address: 'SY No. 52/2 & 52/3, Devarabeesanahalli, Marathahalli, Bengaluru – 560103',
      phone: '08049690000',
      mapsUrl: 'https://maps.app.goo.gl/V2hhVSQmL8g3q5AR8',
      specialties: [HospitalSpecialty.trauma, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Columbia Asia Referral Hospital',
      city: 'Bengaluru',
      area: 'Hebbal',
      address: 'Kirloskar Business Park, Bellary Road, Hebbal, Bengaluru – 560024',
      phone: '08061989898',
      mapsUrl: 'https://maps.app.goo.gl/bz6c64qFSmLMg1oo6',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Apollo Hospital Bannerghatta Road',
      city: 'Bengaluru',
      area: 'Bannerghatta Road',
      address: '154/11, Bannerghatta Road, Opp. IIM, Bengaluru – 560076',
      phone: '08026304050',
      mapsUrl: 'https://maps.app.goo.gl/vNZh1rfmqG5mhYq89',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'MS Ramaiah Memorial Hospital',
      city: 'Bengaluru',
      area: 'Mathikere / MSRIT Road',
      address: 'MSR Nagar, Mathikere, Bengaluru – 560054',
      phone: '08023600888',
      mapsUrl: 'https://maps.app.goo.gl/xLf9z3e87DuLvbxv9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'BGS Gleneagles Global Hospital',
      city: 'Bengaluru',
      area: 'Kengeri',
      address: 'No. 67, Uttarahalli Road, Kengeri, Bengaluru – 560060',
      phone: '08026424242',
      mapsUrl: 'https://maps.app.goo.gl/K1aJ3vQfGDJkZyVt7',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Sparsh Hospital',
      city: 'Bengaluru',
      area: 'Infantry Road / Palace Road',
      address: '29, Infantry Road, Shivajinagar, Bengaluru – 560001',
      phone: '08039253000',
      mapsUrl: 'https://maps.app.goo.gl/y5NpBPnM6f9vxkxS6',
      specialties: [HospitalSpecialty.orthopedics, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'NIMHANS (National Institute of Mental Health)',
      city: 'Bengaluru',
      area: 'Lakkasandra / Hosur Road',
      address: 'Hosur Road, Lakkasandra, Bengaluru – 560029',
      phone: '08046110007',
      mapsUrl: 'https://maps.app.goo.gl/MpqpVFBNqABVxMEt9',
      specialties: [HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Kidwai Memorial Institute of Oncology',
      city: 'Bengaluru',
      area: 'Dairy Circle / BSK 2nd Stage',
      address: 'Dr. M. H. Marigowda Road, Bengaluru – 560029',
      phone: '08026094000',
      mapsUrl: 'https://maps.app.goo.gl/2U8nrtRbGHUC2rdV7',
      specialties: [HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'Bangalore Baptist Hospital',
      city: 'Bengaluru',
      area: 'Hebbal / Bellary Road',
      address: 'Bellary Road, Hebbal, Bengaluru – 560024',
      phone: '08022024700',
      mapsUrl: 'https://maps.app.goo.gl/RiAoNiJDjU1KMDvw9',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Sanjay Gandhi Accident Hospital & Research Institute',
      city: 'Bengaluru',
      area: 'Jayanagar',
      address: 'Jayanagar 1st Block, Bengaluru – 560011',
      phone: '08026564551',
      mapsUrl: 'https://maps.app.goo.gl/7P3nHpnK1VxxkrGq8',
      specialties: [HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Mallya Hospital',
      city: 'Bengaluru',
      area: 'Vittal Mallya Road / Cubbon Park',
      address: '2, Vittal Mallya Road, Bengaluru – 560001',
      phone: '08022277979',
      mapsUrl: 'https://maps.app.goo.gl/bPNEKGBaVPvAtYXU6',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'HCG Cancer Centre',
      city: 'Bengaluru',
      area: 'Kalyan Nagar',
      address: 'No. 8, P. Kalinga Rao Road, Sadashivanagar, Bengaluru – 560080',
      phone: '08040206040',
      mapsUrl: 'https://maps.app.goo.gl/p8aJfktLCR3v1UfM8',
      specialties: [HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'Aster CMI Hospital',
      city: 'Bengaluru',
      area: 'Hebbal',
      address: '43/2, New Airport Road, NH-7, Hebbal, Bengaluru – 560092',
      phone: '08061996969',
      mapsUrl: 'https://maps.app.goo.gl/g6jFWjFfgE2ZcQrS8',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Cloudnine Hospital',
      city: 'Bengaluru',
      area: 'Indiranagar',
      address: '1533, 19th Main Road, Sector 3, HSR Layout, Bengaluru – 560102',
      phone: '08049021000',
      mapsUrl: 'https://maps.app.goo.gl/v2eDGUkamSKTqVMGA',
      specialties: [HospitalSpecialty.maternity, HospitalSpecialty.pediatrics],
    ),
    Hospital(
      name: 'Fortis La Femme',
      city: 'Bengaluru',
      area: 'Richmond Road',
      address: '154, 9th Cross, Richmond Road, Bengaluru – 560025',
      phone: '08041899898',
      mapsUrl: 'https://maps.app.goo.gl/XFMoJMxPkrNuMxJK7',
      specialties: [HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Vikram Hospital',
      city: 'Bengaluru',
      area: 'Millers Road / Shivajinagar',
      address: '71/1, Millers Road, Bengaluru – 560052',
      phone: '08040206000',
      mapsUrl: 'https://maps.app.goo.gl/PKJ7MJjQLQosmhgf9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),

    // ── South Bengaluru additions ──

    Hospital(
      name: 'Basavangudi Poly Clinic & General Hospital',
      city: 'Bengaluru',
      area: 'Basavanagudi',
      address: '6, DVG Road, Basavanagudi, Bengaluru – 560004',
      phone: '08026607878',
      mapsUrl: 'https://maps.app.goo.gl/basavanagudi1',
      specialties: [HospitalSpecialty.general],
    ),
    Hospital(
      name: 'S.S. Sparsh Hospital (Banashankari)',
      city: 'Bengaluru',
      area: 'Basavanagudi / Banashankari',
      address: '4/1, 8th Cross, Gavipuram Extension, Kempegowda Nagar, Bengaluru – 560019',
      phone: '08026609999',
      mapsUrl: 'https://maps.app.goo.gl/basavanagudi2',
      specialties: [HospitalSpecialty.orthopedics, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Ramakrishna Hospital',
      city: 'Bengaluru',
      area: 'Jayanagar',
      address: '2/1, 8th Main, 3rd Block, Jayanagar, Bengaluru – 560011',
      phone: '08026630077',
      mapsUrl: 'https://maps.app.goo.gl/jayanagar1',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Sri Sathya Sai General Hospital',
      city: 'Bengaluru',
      area: 'Jayanagar',
      address: '4th T Block, Jayanagar, Bengaluru – 560041',
      phone: '08026631234',
      mapsUrl: 'https://maps.app.goo.gl/jayanagar2',
      specialties: [HospitalSpecialty.general],
    ),
    Hospital(
      name: 'Manipal Hospital (Jayanagar)',
      city: 'Bengaluru',
      area: 'Jayanagar',
      address: '5th Block, 8th Main, Jayanagar, Bengaluru – 560041',
      phone: '08066666900',
      mapsUrl: 'https://maps.app.goo.gl/jayanagar3',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Aster RV Hospital',
      city: 'Bengaluru',
      area: 'JP Nagar',
      address: 'CA 37, 24th Main, JP Nagar Phase 1, Bengaluru – 560078',
      phone: '08061122334',
      mapsUrl: 'https://maps.app.goo.gl/jpnagar1',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Sagar Hospitals',
      city: 'Bengaluru',
      area: 'JP Nagar / Kumaraswamy Layout',
      address: 'Shavige Malleshwara Hills, Kumaraswamy Layout, Bengaluru – 560078',
      phone: '08026422222',
      mapsUrl: 'https://maps.app.goo.gl/jpnagar2',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Sri Jayadeva Institute of Cardiovascular Sciences',
      city: 'Bengaluru',
      area: 'Banashankari',
      address: 'Jayadeva Hospital Road, Banashankari 2nd Stage, Bengaluru – 560070',
      phone: '08026961610',
      mapsUrl: 'https://maps.app.goo.gl/banashankari1',
      specialties: [HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Nethradhama Superspeciality Eye Hospital',
      city: 'Bengaluru',
      area: 'BTM Layout / Madiwala',
      address: 'No. 256/14, Kanakapura Road, Padmanabhanagar, Bengaluru – 560061',
      phone: '08026438875',
      mapsUrl: 'https://maps.app.goo.gl/btmlayout1',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Apollo BGS Hospital',
      city: 'Bengaluru',
      area: 'Mysore Road / Kengeri',
      address: 'No. 154, 11th Main Road, Mysore Road, Bengaluru – 560026',
      phone: '08022963600',
      mapsUrl: 'https://maps.app.goo.gl/mysoreroad1',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.trauma],
    ),

    // ════════════════════════════════════════════════
    //  CHENNAI  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'Government General Hospital',
      city: 'Chennai',
      area: 'Park Town',
      address: 'Park Town, Chennai – 600003',
      phone: '04425305000',
      mapsUrl: 'https://maps.app.goo.gl/2PqUaZJVZfmktq8A6',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Apollo Hospitals (Greams Road)',
      city: 'Chennai',
      area: 'Greams Road / Thousand Lights',
      address: '21, Greams Lane, Thousand Lights, Chennai – 600006',
      phone: '04428296000',
      mapsUrl: 'https://maps.app.goo.gl/VjnJryjHsEF9gCPS8',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'MIOT International Hospital',
      city: 'Chennai',
      area: 'Manapakkam / Mount Poonamallee Road',
      address: '4/112, Mount Poonamallee Road, Manapakkam, Chennai – 600089',
      phone: '04422492288',
      mapsUrl: 'https://maps.app.goo.gl/UqVh29cJ9njPB8cM7',
      specialties: [HospitalSpecialty.orthopedics, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Rajiv Gandhi Government General Hospital',
      city: 'Chennai',
      area: 'Park Town',
      address: 'Park Town, Chennai – 600003',
      phone: '04425305000',
      mapsUrl: 'https://maps.app.goo.gl/KBhA2vxrDxoR5NpDA',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Fortis Malar Hospital',
      city: 'Chennai',
      area: 'Adyar',
      address: '52, 1st Main Road, Gandhi Nagar, Adyar, Chennai – 600020',
      phone: '04442892222',
      mapsUrl: 'https://maps.app.goo.gl/rU5FGmYTpLMHnq4N7',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Vijaya Hospital',
      city: 'Chennai',
      area: 'Vadapalani',
      address: '434, N.S.K. Salai, Vadapalani, Chennai – 600026',
      phone: '04424802288',
      mapsUrl: 'https://maps.app.goo.gl/kS2JbkN8kv4aw2fq9',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Sri Ramachandra Medical Centre',
      city: 'Chennai',
      area: 'Porur',
      address: '1, Ramachandra Nagar, Porur, Chennai – 600116',
      phone: '04445928888',
      mapsUrl: 'https://maps.app.goo.gl/dWsEJjP2GBQ6Upbt9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Kanchi Kamakoti CHILDS Trust Hospital',
      city: 'Chennai',
      area: 'Nungambakkam',
      address: '12-A, Nageswara Road, Nungambakkam, Chennai – 600034',
      phone: '04428251860',
      mapsUrl: 'https://maps.app.goo.gl/TQiAa3HZkm8GWNtZ7',
      specialties: [HospitalSpecialty.pediatrics],
    ),
    Hospital(
      name: 'Gleneagles Global Health City',
      city: 'Chennai',
      area: 'Perumbakkam',
      address: '439, Cheran Nagar, Perumbakkam, Chennai – 600100',
      phone: '04444777000',
      mapsUrl: 'https://maps.app.goo.gl/pB7gC2ycQBVxdnhK9',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Mehta Multispeciality Hospital',
      city: 'Chennai',
      area: 'Chetpet',
      address: '2, McNichols Road, Chetpet, Chennai – 600031',
      phone: '04442200000',
      mapsUrl: 'https://maps.app.goo.gl/DqF4Bq9KuvPtFLTCA',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.orthopedics],
    ),

    // ════════════════════════════════════════════════
    //  MUMBAI  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'KEM Hospital',
      city: 'Mumbai',
      area: 'Parel',
      address: 'Acharya Donde Marg, Parel, Mumbai – 400012',
      phone: '02224107000',
      mapsUrl: 'https://maps.app.goo.gl/UKf7kNR6aW7XBvnf9',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Lilavati Hospital & Research Centre',
      city: 'Mumbai',
      area: 'Bandra West',
      address: 'A-791, Bandra Reclamation, Bandra West, Mumbai – 400050',
      phone: '02226751000',
      mapsUrl: 'https://maps.app.goo.gl/uGWEBFf3h7Rrbn7M6',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Tata Memorial Hospital',
      city: 'Mumbai',
      area: 'Parel',
      address: 'Dr. E. Borges Road, Parel, Mumbai – 400012',
      phone: '02224177000',
      mapsUrl: 'https://maps.app.goo.gl/QRNt5qmtJZCFujzt8',
      specialties: [HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'P.D. Hinduja National Hospital',
      city: 'Mumbai',
      area: 'Mahim',
      address: 'Veer Savarkar Marg, Mahim, Mumbai – 400016',
      phone: '02224452222',
      mapsUrl: 'https://maps.app.goo.gl/NyPRBvjmZUyv3a8W6',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Kokilaben Dhirubhai Ambani Hospital',
      city: 'Mumbai',
      area: 'Andheri West / Four Bungalows',
      address: 'Rao Saheb Achutrao Patwardhan Marg, Four Bungalows, Andheri West, Mumbai – 400053',
      phone: '02230999999',
      mapsUrl: 'https://maps.app.goo.gl/7zuwHhkwcEZeR9XNA',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Jaslok Hospital & Research Centre',
      city: 'Mumbai',
      area: 'Pedder Road',
      address: '15, Dr. G. Deshmukh Marg, Pedder Road, Mumbai – 400026',
      phone: '02266573333',
      mapsUrl: 'https://maps.app.goo.gl/XH3oNqfJ9Vk2CFPZ9',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Breach Candy Hospital',
      city: 'Mumbai',
      area: 'Breach Candy / Cumballa Hill',
      address: '60-A, Bhulabhai Desai Road, Breach Candy, Mumbai – 400026',
      phone: '02223667888',
      mapsUrl: 'https://maps.app.goo.gl/K2jULiUfKvyq3BZCA',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Wockhardt Hospital',
      city: 'Mumbai',
      area: 'Mira Road',
      address: '1877, Dr. Anandrao Nair Marg, Mumbai Central, Mumbai – 400011',
      phone: '02261784444',
      mapsUrl: 'https://maps.app.goo.gl/wW12dDrLT7SYzHnF9',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Nanavati Max Super Speciality Hospital',
      city: 'Mumbai',
      area: 'Vile Parle West',
      address: 'SV Road, Vile Parle West, Mumbai – 400056',
      phone: '02226186666',
      mapsUrl: 'https://maps.app.goo.gl/j2JHarscjCLCFGnN8',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'Seven Hills Hospital',
      city: 'Mumbai',
      area: 'Marol / Andheri East',
      address: 'Marol Maroshi Road, Andheri East, Mumbai – 400059',
      phone: '02267676767',
      mapsUrl: 'https://maps.app.goo.gl/eAHfMTYtujw4EHB47',
      specialties: [HospitalSpecialty.trauma, HospitalSpecialty.multiSpecialty],
    ),

    // ════════════════════════════════════════════════
    //  HYDERABAD  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'Osmania General Hospital',
      city: 'Hyderabad',
      area: 'Afzalgunj',
      address: 'Afzalgunj, Hyderabad – 500012',
      phone: '04024600124',
      mapsUrl: 'https://maps.app.goo.gl/ZSyKDMVHoKekzXAX8',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'NIMS (Nizam\'s Institute of Medical Sciences)',
      city: 'Hyderabad',
      area: 'Punjagutta',
      address: 'Punjagutta, Hyderabad – 500082',
      phone: '04023489000',
      mapsUrl: 'https://maps.app.goo.gl/c4MPHZ7u8K7XVXZX9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Apollo Hospitals Jubilee Hills',
      city: 'Hyderabad',
      area: 'Jubilee Hills',
      address: 'Film Nagar, Jubilee Hills, Hyderabad – 500033',
      phone: '04023607777',
      mapsUrl: 'https://maps.app.goo.gl/nBkuuA8sGX8apQ988',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Yashoda Hospitals',
      city: 'Hyderabad',
      area: 'Somajiguda',
      address: 'Raj Bhavan Road, Somajiguda, Hyderabad – 500082',
      phone: '04027777777',
      mapsUrl: 'https://maps.app.goo.gl/y1s9EWkpGmBJuHzT7',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Care Hospital',
      city: 'Hyderabad',
      area: 'Banjara Hills',
      address: 'Road No. 1, Banjara Hills, Hyderabad – 500034',
      phone: '04030418888',
      mapsUrl: 'https://maps.app.goo.gl/jL9CbkVJ4n7V4pgM7',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Kamineni Hospitals',
      city: 'Hyderabad',
      area: 'LB Nagar',
      address: 'L.B. Nagar, Hyderabad – 500074',
      phone: '04039876543',
      mapsUrl: 'https://maps.app.goo.gl/r8aPDLF4W6GKVBt99',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Citizens Hospital',
      city: 'Hyderabad',
      area: 'Nallagandla / Serilingampally',
      address: '8-9-2/14, Nallagandla, Serilingampally, Hyderabad – 500019',
      phone: '04067191919',
      mapsUrl: 'https://maps.app.goo.gl/nGsZA8DkHqN7gfuHA',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Sunshine Hospital',
      city: 'Hyderabad',
      area: 'Secunderabad / Paradise',
      address: '1-7-201 to 205, PG Road, Secunderabad – 500003',
      phone: '04027555000',
      mapsUrl: 'https://maps.app.goo.gl/YGJShmYo4eEdDNxM7',
      specialties: [HospitalSpecialty.orthopedics, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'AIG Hospitals',
      city: 'Hyderabad',
      area: 'Gachibowli',
      address: 'Survey No. 1/1, Mindspace Road, Gachibowli, Hyderabad – 500032',
      phone: '04071772222',
      mapsUrl: 'https://maps.app.goo.gl/aGbFyiJjMBFgHZJq9',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Global Hospitals',
      city: 'Hyderabad',
      area: 'Lakdi-ka-Pul',
      address: '6-1-1070/1 to 4, Lakdi-ka-Pul, Hyderabad – 500004',
      phone: '04030244444',
      mapsUrl: 'https://maps.app.goo.gl/KFQM1s5iBxrLdPGdA',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.oncology],
    ),

    // ════════════════════════════════════════════════
    //  DELHI  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'AIIMS (All India Institute of Medical Sciences)',
      city: 'Delhi',
      area: 'Ansari Nagar / South Delhi',
      address: 'Ansari Nagar, New Delhi – 110029',
      phone: '01126588500',
      mapsUrl: 'https://maps.app.goo.gl/kCUrUf8tZSMQfz1n6',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Safdarjung Hospital',
      city: 'Delhi',
      area: 'Ansari Nagar West',
      address: 'Ansari Nagar West, New Delhi – 110029',
      phone: '01126165060',
      mapsUrl: 'https://maps.app.goo.gl/EhYnVi3MiuGR9C3X6',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Max Super Speciality Hospital Saket',
      city: 'Delhi',
      area: 'Saket',
      address: '1, 2, Press Enclave Road, Saket, New Delhi – 110017',
      phone: '01171062345',
      mapsUrl: 'https://maps.app.goo.gl/SEKzRcR5VEBa5vr79',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'Indraprastha Apollo Hospital',
      city: 'Delhi',
      area: 'Sarita Vihar',
      address: 'Delhi Mathura Road, Sarita Vihar, New Delhi – 110076',
      phone: '01126925858',
      mapsUrl: 'https://maps.app.goo.gl/kFGE2KXsN3tGo7UR9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Sir Ganga Ram Hospital',
      city: 'Delhi',
      area: 'Rajinder Nagar',
      address: 'Rajinder Nagar, New Delhi – 110060',
      phone: '01125750000',
      mapsUrl: 'https://maps.app.goo.gl/TJiH3MRdNGa6WoZr9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Lok Nayak Hospital',
      city: 'Delhi',
      area: 'Daryaganj',
      address: 'Jawahar Lal Nehru Marg, Daryaganj, Delhi – 110002',
      phone: '01123232400',
      mapsUrl: 'https://maps.app.goo.gl/5jdCxDKQ1kHJzW5N6',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Fortis Memorial Research Institute',
      city: 'Delhi',
      area: 'Gurugram (NCR)',
      address: 'Sector 44, Opposite HUDA City Centre Metro, Gurugram – 122002',
      phone: '01244962200',
      mapsUrl: 'https://maps.app.goo.gl/jXSbkz2FnnX2wfbH8',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'BLK-Max Super Speciality Hospital',
      city: 'Delhi',
      area: 'Pusa Road / Rajendra Place',
      address: '5, Pusa Road, Rajendra Place, New Delhi – 110005',
      phone: '01130403040',
      mapsUrl: 'https://maps.app.goo.gl/ZvHFP6KBVdkFBEFo7',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'Moolchand Hospital',
      city: 'Delhi',
      area: 'Lajpat Nagar',
      address: 'Lala Lajpat Rai Marg, Lajpat Nagar III, New Delhi – 110024',
      phone: '01142000000',
      mapsUrl: 'https://maps.app.goo.gl/tBLQ7r8xP2SKEt498',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Medanta The Medicity',
      city: 'Delhi',
      area: 'Gurugram (NCR)',
      address: 'CH Baktawar Singh Road, Sector 38, Gurugram – 122001',
      phone: '01244141414',
      mapsUrl: 'https://maps.app.goo.gl/BM1nT3X9YehU3bfDA',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),

    // ════════════════════════════════════════════════
    //  PUNE  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'Sassoon General Hospital',
      city: 'Pune',
      area: 'Shivajinagar',
      address: 'Jai Prakash Narayan Road, Shivajinagar, Pune – 411001',
      phone: '02026128000',
      mapsUrl: 'https://maps.app.goo.gl/iNZF6mLWBFemvkp56',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Ruby Hall Clinic',
      city: 'Pune',
      area: 'Camp / Sassoon Road',
      address: '40, Sassoon Road, Camp, Pune – 411001',
      phone: '02026163391',
      mapsUrl: 'https://maps.app.goo.gl/bj9H6t3UdE3bpNZD6',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Jehangir Hospital',
      city: 'Pune',
      area: 'Camp / Sassoon Road',
      address: '32, Sassoon Road, Camp, Pune – 411001',
      phone: '02066819999',
      mapsUrl: 'https://maps.app.goo.gl/Kx3QvfZ1rVgD4ByR7',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Deenanath Mangeshkar Hospital',
      city: 'Pune',
      area: 'Erandwane',
      address: 'Erandwane, Near Mhatre Bridge, Pune – 411004',
      phone: '02049152222',
      mapsUrl: 'https://maps.app.goo.gl/JsNPmKqbWmR9d7Bs6',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'KEM Hospital Pune',
      city: 'Pune',
      area: 'Rasta Peth',
      address: '489, Rasta Peth, Pune – 411011',
      phone: '02026127000',
      mapsUrl: 'https://maps.app.goo.gl/z2GqfmgJ7ECDWN7F8',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Noble Hospital',
      city: 'Pune',
      area: 'Hadapsar',
      address: '153, Magarpatta City Road, Hadapsar, Pune – 411013',
      phone: '02066801500',
      mapsUrl: 'https://maps.app.goo.gl/VRyauoCt2TL8Pfv57',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Poona Hospital & Research Centre',
      city: 'Pune',
      area: 'Sadashiv Peth',
      address: '27, Sadashiv Peth, Pune – 411030',
      phone: '02024330000',
      mapsUrl: 'https://maps.app.goo.gl/CDhMRWHKxFk9P8Wr9',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Inamdar Multispeciality Hospital',
      city: 'Pune',
      area: 'Fatima Nagar / Wanowrie',
      address: 'Sr. No. 15, Fatima Nagar, Wanowrie, Pune – 411040',
      phone: '02026821111',
      mapsUrl: 'https://maps.app.goo.gl/Sb1gqW6q7Nk8Ygtx7',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Sahyadri Hospital',
      city: 'Pune',
      area: 'Deccan / Karve Road',
      address: '30-C, Karve Road, Deccan Gymkhana, Pune – 411004',
      phone: '02067213000',
      mapsUrl: 'https://maps.app.goo.gl/CDTB4CxMvJDNGYua9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Aditya Birla Memorial Hospital',
      city: 'Pune',
      area: 'Chinchwad',
      address: 'Aditya Birla Hospital Marg, Chinchwad, Pune – 411033',
      phone: '02066800000',
      mapsUrl: 'https://maps.app.goo.gl/s4qbVmMQaAzDmJkk9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),

    // ════════════════════════════════════════════════
    //  KOCHI  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'Government Medical College Hospital Ernakulam',
      city: 'Kochi',
      area: 'Ernakulam / High Court Road',
      address: 'High Court Road, Ernakulam, Kochi – 682011',
      phone: '04842361440',
      mapsUrl: 'https://maps.app.goo.gl/5HEe3MTMS2n7P8j88',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Amrita Institute of Medical Sciences',
      city: 'Kochi',
      area: 'Edapally / Ponekkara',
      address: 'AIMS Ponekkara PO, Edapally, Kochi – 682041',
      phone: '04842801234',
      mapsUrl: 'https://maps.app.goo.gl/mjZvQvYaD34vJrFW9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Lakeshore Hospital',
      city: 'Kochi',
      area: 'Nettoor / Maradu',
      address: 'Nettoor P.O., Maradu, Ernakulam, Kochi – 682040',
      phone: '04844200100',
      mapsUrl: 'https://maps.app.goo.gl/b7K2bQEL3pSDuF1o8',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'Aster Medcity',
      city: 'Kochi',
      area: 'Cheranalloor / Kuttisahib Road',
      address: 'Kuttisahib Road, South Chittoor P.O., Cheranalloor, Kochi – 682027',
      phone: '04846699999',
      mapsUrl: 'https://maps.app.goo.gl/4nzPpbNkKE7dCZ1Z7',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'PVS Memorial Hospital',
      city: 'Kochi',
      area: 'Kaloor',
      address: 'NH Bypass Junction, Kaloor, Kochi – 682017',
      phone: '04842536181',
      mapsUrl: 'https://maps.app.goo.gl/bJrJrmcxuAEzXhvt8',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Renai Medicity',
      city: 'Kochi',
      area: 'Palarivattom',
      address: 'Palarivattom P.O., Kochi – 682025',
      phone: '04842888000',
      mapsUrl: 'https://maps.app.goo.gl/3gEQ4nMSCAZiQdFRA',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'VPS Lakeshore Hospital',
      city: 'Kochi',
      area: 'Nettoor',
      address: 'NH 47 - Bye Pass, Nettoor, Kochi – 682040',
      phone: '04844200100',
      mapsUrl: 'https://maps.app.goo.gl/HxqbKTaJkzpz3Ry77',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Ernakulam General Hospital',
      city: 'Kochi',
      area: 'High Court Road',
      address: 'High Court Road, Ernakulam, Kochi – 682016',
      phone: '04842363600',
      mapsUrl: 'https://maps.app.goo.gl/F1wqfAbEbXiJyq4UA',
      specialties: [HospitalSpecialty.general],
    ),
    Hospital(
      name: 'Sunrise Hospital',
      city: 'Kochi',
      area: 'Kakkanad',
      address: 'NH 49, Kakkanad, Kochi – 682030',
      phone: '04842340000',
      mapsUrl: 'https://maps.app.goo.gl/uvXnWFRhEFhEMXiX6',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'KIMS Health',
      city: 'Kochi',
      area: 'Thiruvananthapuram Road',
      address: 'NH Bypass, Anayara P.O., Thiruvananthapuram – 695029',
      phone: '04712524400',
      mapsUrl: 'https://maps.app.goo.gl/JRvMVGjBujrCQCWN6',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),

    // ════════════════════════════════════════════════
    //  KOLKATA  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'SSKM Hospital (PG Hospital)',
      city: 'Kolkata',
      area: 'Bhowanipore / AJC Bose Road',
      address: '244, AJC Bose Road, Bhowanipore, Kolkata – 700020',
      phone: '03322041211',
      mapsUrl: 'https://maps.app.goo.gl/wy7KTzFEJB3JW5yk8',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Apollo Gleneagles Hospital',
      city: 'Kolkata',
      area: 'Kadapara / Canal Circular Road',
      address: '58, Canal Circular Road, Kadapara, Kolkata – 700054',
      phone: '03323203040',
      mapsUrl: 'https://maps.app.goo.gl/z63aHvkS7Z2BYJNK9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Medica Superspecialty Hospital',
      city: 'Kolkata',
      area: 'Mukundapur',
      address: '127, Mukundapur, EM Bypass, Kolkata – 700099',
      phone: '03340404040',
      mapsUrl: 'https://maps.app.goo.gl/NX5Bpb2FmkFREuXd9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Fortis Hospital Anandapur',
      city: 'Kolkata',
      area: 'Anandapur / EM Bypass',
      address: '730, Anandapur, EM Bypass, Kolkata – 700107',
      phone: '03366284444',
      mapsUrl: 'https://maps.app.goo.gl/tVXAKbAmCFPi2d4h6',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.oncology],
    ),
    Hospital(
      name: 'RG Kar Medical College Hospital',
      city: 'Kolkata',
      area: 'Shyambazar',
      address: '1, Khudiram Bose Sarani, Shyambazar, Kolkata – 700004',
      phone: '03325551876',
      mapsUrl: 'https://maps.app.goo.gl/Vxhud7RQ3rqYTD7i7',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
    Hospital(
      name: 'Woodlands Hospital',
      city: 'Kolkata',
      area: 'Alipur / Ballygunge',
      address: '8/5, Alipur Road, Kolkata – 700027',
      phone: '03340901000',
      mapsUrl: 'https://maps.app.goo.gl/JNXDG1cS5k3Y5KXGA',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'AMRI Hospital Salt Lake',
      city: 'Kolkata',
      area: 'Salt Lake / Sector II',
      address: 'JC-16 & 17, Sector III, Salt Lake, Kolkata – 700098',
      phone: '03364608000',
      mapsUrl: 'https://maps.app.goo.gl/pbRUzmGwgEGmjbxH8',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.neurology],
    ),
    Hospital(
      name: 'Rabindranath Tagore International Heart Institute',
      city: 'Kolkata',
      area: 'Mukundapur',
      address: '124, Mukundapur, EM Bypass, Kolkata – 700099',
      phone: '03366800000',
      mapsUrl: 'https://maps.app.goo.gl/AjRivGJzwHoVZV4Y7',
      specialties: [HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Peerless Hospital',
      city: 'Kolkata',
      area: 'Panchasayar',
      address: '360, Panchasayar, Kolkata – 700094',
      phone: '03324615000',
      mapsUrl: 'https://maps.app.goo.gl/uLfN4GvhxY4vJuRX9',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Desun Hospital',
      city: 'Kolkata',
      area: 'Kasba / EM Bypass',
      address: 'EM Bypass Connector, Kasba, Kolkata – 700107',
      phone: '03340060000',
      mapsUrl: 'https://maps.app.goo.gl/Xjwv6E8EEqGVbKx1A',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.trauma],
    ),

    // ════════════════════════════════════════════════
    //  JAIPUR  (10 hospitals)
    // ════════════════════════════════════════════════

    Hospital(
      name: 'SMS Medical College & Hospital',
      city: 'Jaipur',
      area: 'Milap Nagar / JLN Marg',
      address: 'JLN Marg, Milap Nagar, Jaipur – 302004',
      phone: '01412518888',
      mapsUrl: 'https://maps.app.goo.gl/uPdCBnQYVpFLwCeXA',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Fortis Escorts Hospital',
      city: 'Jaipur',
      area: 'Malviya Nagar / JLN Marg',
      address: 'JLN Marg, Malviya Nagar, Jaipur – 302017',
      phone: '01412547000',
      mapsUrl: 'https://maps.app.goo.gl/WFxQz3v3cBWAFqYs9',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Narayana Multispeciality Hospital',
      city: 'Jaipur',
      area: 'Sector 28, Pratap Nagar',
      address: 'Sector 28, Pratap Nagar, Jaipur – 302033',
      phone: '01424110000',
      mapsUrl: 'https://maps.app.goo.gl/gV5JfMaK1M5CKtAr6',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Mahatma Gandhi Hospital',
      city: 'Jaipur',
      area: 'Sitapura',
      address: 'RIICO Industrial Area, Sitapura, Jaipur – 302022',
      phone: '01412771000',
      mapsUrl: 'https://maps.app.goo.gl/HaJX27Y4LzE6h6b28',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.maternity],
    ),
    Hospital(
      name: 'Apex Hospital',
      city: 'Jaipur',
      area: 'Malviya Nagar',
      address: 'SP-4 & 6, Malviya Industrial Area, Malviya Nagar, Jaipur – 302017',
      phone: '01413500505',
      mapsUrl: 'https://maps.app.goo.gl/r3w2K6JdK42a4Csi9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.orthopedics],
    ),
    Hospital(
      name: 'Eternal Hospital',
      city: 'Jaipur',
      area: 'Jagatpura',
      address: '46, Jawahar Lal Nehru Marg, Jagatpura, Jaipur – 302017',
      phone: '01414104104',
      mapsUrl: 'https://maps.app.goo.gl/T7vEDjWW9fcmqyLa6',
      specialties: [HospitalSpecialty.cardiac, HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Santokba Durlabhji Memorial Hospital',
      city: 'Jaipur',
      area: 'Bhawani Singh Road',
      address: 'Bhawani Singh Road, Jaipur – 302015',
      phone: '01412566251',
      mapsUrl: 'https://maps.app.goo.gl/YcePjDGwLfCcTxWT7',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Manipal Hospital Jaipur',
      city: 'Jaipur',
      area: 'Sector 5, Vidhyadhar Nagar',
      address: 'Sector 5, Vidhyadhar Nagar, Jaipur – 302039',
      phone: '01416755555',
      mapsUrl: 'https://maps.app.goo.gl/RXqr4DV4rQoAdB9B9',
      specialties: [HospitalSpecialty.multiSpecialty, HospitalSpecialty.cardiac],
    ),
    Hospital(
      name: 'Rukmani Birla Hospital',
      city: 'Jaipur',
      area: 'Gopalpura Bypass Road',
      address: 'Gopalpura Bypass Road, Near Triveni Flyover, Jaipur – 302018',
      phone: '01414455100',
      mapsUrl: 'https://maps.app.goo.gl/Kqmy6sDJB7AXAFGP7',
      specialties: [HospitalSpecialty.multiSpecialty],
    ),
    Hospital(
      name: 'Sawai Man Singh Hospital',
      city: 'Jaipur',
      area: 'Lalkothi / Tonk Road',
      address: 'Tonk Road, Lalkothi, Jaipur – 302004',
      phone: '01412517941',
      mapsUrl: 'https://maps.app.goo.gl/fXVFMmYwqmvPhCqU6',
      specialties: [HospitalSpecialty.general, HospitalSpecialty.trauma],
    ),
  ];

  // ── Filter helpers ────────────────────────────────

  /// All unique city names in the list.
  static List<String> get cities {
    final seen = <String>{};
    return all.map((h) => h.city).where(seen.add).toList()..sort();
  }

  /// All unique area names for a given city.
  static List<String> areasForCity(String city) {
    final seen = <String>{};
    return all
        .where((h) => h.city == city)
        .map((h) => h.area)
        .where(seen.add)
        .toList()
      ..sort();
  }

  /// Filter by city, area and/or specialty. Null = no filter on that field.
  static List<Hospital> filter({
    String? city,
    String? area,
    HospitalSpecialty? specialty,
    String? query,
  }) {
    return all.where((h) {
      if (city != null && h.city != city) return false;
      if (area != null && h.area != area) return false;
      if (specialty != null && !h.specialties.contains(specialty)) return false;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        if (!h.name.toLowerCase().contains(q) &&
            !h.city.toLowerCase().contains(q) &&
            !h.area.toLowerCase().contains(q) &&
            !h.address.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }
}