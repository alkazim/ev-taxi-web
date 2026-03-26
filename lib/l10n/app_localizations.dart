import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ml'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @fleets.
  ///
  /// In en, this message translates to:
  /// **'Fleets'**
  String get fleets;

  /// No description provided for @franchise.
  ///
  /// In en, this message translates to:
  /// **'Franchise'**
  String get franchise;

  /// No description provided for @evStations.
  ///
  /// In en, this message translates to:
  /// **'EV Stations'**
  String get evStations;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Sustainable\nTransport'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Experience the future of transportation with our all-electric fleet.'**
  String get heroSubtitle;

  /// No description provided for @planYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Journey'**
  String get planYourJourney;

  /// No description provided for @planYourJourneySub.
  ///
  /// In en, this message translates to:
  /// **'Calculate the best route with optimized charging stops along the way.'**
  String get planYourJourneySub;

  /// No description provided for @premierEVService.
  ///
  /// In en, this message translates to:
  /// **'India\'s Premier EV Service'**
  String get premierEVService;

  /// No description provided for @serviceInIndia.
  ///
  /// In en, this message translates to:
  /// **'Service in India'**
  String get serviceInIndia;

  /// No description provided for @bookARide.
  ///
  /// In en, this message translates to:
  /// **'Book a Ride'**
  String get bookARide;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @happyRiders.
  ///
  /// In en, this message translates to:
  /// **'Happy Riders'**
  String get happyRiders;

  /// No description provided for @evCars.
  ///
  /// In en, this message translates to:
  /// **'EV Cars'**
  String get evCars;

  /// No description provided for @states.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get states;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @nowHiring.
  ///
  /// In en, this message translates to:
  /// **'NOW HIRING'**
  String get nowHiring;

  /// No description provided for @monthlyAvg.
  ///
  /// In en, this message translates to:
  /// **'Monthly Avg'**
  String get monthlyAvg;

  /// No description provided for @activeDrivers.
  ///
  /// In en, this message translates to:
  /// **'Active Drivers'**
  String get activeDrivers;

  /// No description provided for @avgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get avgRating;

  /// No description provided for @driverProgram.
  ///
  /// In en, this message translates to:
  /// **'DRIVER PARTNER PROGRAM'**
  String get driverProgram;

  /// No description provided for @driveEarnGrow.
  ///
  /// In en, this message translates to:
  /// **'Drive. Earn.\nGrow with us.'**
  String get driveEarnGrow;

  /// No description provided for @joinNetwork.
  ///
  /// In en, this message translates to:
  /// **'Join E-CABBZ\'s fastest-growing taxi network. Flexible hours, guaranteed income, and full support from day one.'**
  String get joinNetwork;

  /// No description provided for @weeklyPayouts.
  ///
  /// In en, this message translates to:
  /// **'Weekly Payouts'**
  String get weeklyPayouts;

  /// No description provided for @weeklyPayoutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get paid every week directly to your bank.'**
  String get weeklyPayoutsDesc;

  /// No description provided for @flexibleHours.
  ///
  /// In en, this message translates to:
  /// **'Flexible Hours'**
  String get flexibleHours;

  /// No description provided for @flexibleHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'Work on your own schedule, any time.'**
  String get flexibleHoursDesc;

  /// No description provided for @support247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support247;

  /// No description provided for @support247Desc.
  ///
  /// In en, this message translates to:
  /// **'Dedicated driver support team always on call.'**
  String get support247Desc;

  /// No description provided for @evProvided.
  ///
  /// In en, this message translates to:
  /// **'EV Provided'**
  String get evProvided;

  /// No description provided for @evProvidedDesc.
  ///
  /// In en, this message translates to:
  /// **'Drive a company EV or bring your own.'**
  String get evProvidedDesc;

  /// No description provided for @applyAsDriver.
  ///
  /// In en, this message translates to:
  /// **'Apply as Driver'**
  String get applyAsDriver;

  /// No description provided for @ourOffices.
  ///
  /// In en, this message translates to:
  /// **'OUR OFFICES'**
  String get ourOffices;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in Touch With Us'**
  String get getInTouch;

  /// No description provided for @spreadAcrossSouthIndia.
  ///
  /// In en, this message translates to:
  /// **'We are spread across South India to serve you better.\nFind your nearest office or contact us directly.'**
  String get spreadAcrossSouthIndia;

  /// No description provided for @headquarters.
  ///
  /// In en, this message translates to:
  /// **'HEADQUARTERS'**
  String get headquarters;

  /// No description provided for @mainHotline.
  ///
  /// In en, this message translates to:
  /// **'Main Hotline'**
  String get mainHotline;

  /// No description provided for @generalEnquiry.
  ///
  /// In en, this message translates to:
  /// **'General Enquiry'**
  String get generalEnquiry;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @workingHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sat: 9 AM – 7 PM'**
  String get workingHoursDesc;

  /// No description provided for @stateOffices.
  ///
  /// In en, this message translates to:
  /// **'State Offices'**
  String get stateOffices;

  /// No description provided for @stateOfficesDesc.
  ///
  /// In en, this message translates to:
  /// **'Administrative offices across our operating states'**
  String get stateOfficesDesc;

  /// No description provided for @partnerWithUs.
  ///
  /// In en, this message translates to:
  /// **'PARTNER WITH US'**
  String get partnerWithUs;

  /// No description provided for @franchiseOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Franchise Opportunities'**
  String get franchiseOpportunities;

  /// No description provided for @joinEVRevolution.
  ///
  /// In en, this message translates to:
  /// **'Join the EV revolution. Choose your investment level and grow with India\'s premier electric mobility network.'**
  String get joinEVRevolution;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @megaFranchise.
  ///
  /// In en, this message translates to:
  /// **'Mega Franchise'**
  String get megaFranchise;

  /// No description provided for @masterFranchise.
  ///
  /// In en, this message translates to:
  /// **'Master Franchise'**
  String get masterFranchise;

  /// No description provided for @superFranchise.
  ///
  /// In en, this message translates to:
  /// **'Super Franchise'**
  String get superFranchise;

  /// No description provided for @stateLevelOps.
  ///
  /// In en, this message translates to:
  /// **'STATE LEVEL OPERATIONS'**
  String get stateLevelOps;

  /// No description provided for @districtGroupOps.
  ///
  /// In en, this message translates to:
  /// **'DISTRICT GROUP OPERATIONS'**
  String get districtGroupOps;

  /// No description provided for @fleetManagement.
  ///
  /// In en, this message translates to:
  /// **'FLEET MANAGEMENT'**
  String get fleetManagement;

  /// No description provided for @ourEVFleet.
  ///
  /// In en, this message translates to:
  /// **'OUR EV FLEET'**
  String get ourEVFleet;

  /// No description provided for @fleetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium electric vehicles powering your journey'**
  String get fleetSubtitle;

  /// No description provided for @drivingFuture.
  ///
  /// In en, this message translates to:
  /// **'Driving the Future of Mobility'**
  String get drivingFuture;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 E-CABBZ PRIVATE LIMITED. All rights reserved.'**
  String get copyright;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @liveSupport.
  ///
  /// In en, this message translates to:
  /// **'Live Support'**
  String get liveSupport;

  /// No description provided for @noOfficesFound.
  ///
  /// In en, this message translates to:
  /// **'No offices in this category yet.'**
  String get noOfficesFound;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @powerLabel.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get powerLabel;

  /// No description provided for @batteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get batteryLabel;

  /// No description provided for @topSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Top Speed'**
  String get topSpeedLabel;

  /// No description provided for @chargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get chargeLabel;

  /// No description provided for @compactSUV.
  ///
  /// In en, this message translates to:
  /// **'COMPACT SUV'**
  String get compactSUV;

  /// No description provided for @midSizeSUV.
  ///
  /// In en, this message translates to:
  /// **'MID-SIZE SUV'**
  String get midSizeSUV;

  /// No description provided for @mpv.
  ///
  /// In en, this message translates to:
  /// **'MPV'**
  String get mpv;

  /// No description provided for @premiumCrossover.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM CROSSOVER'**
  String get premiumCrossover;

  /// No description provided for @hatchback.
  ///
  /// In en, this message translates to:
  /// **'HATCHBACK'**
  String get hatchback;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @stepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Step Completed'**
  String get stepCompleted;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dob;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// No description provided for @landmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmarkLabel;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'SIGNATURE'**
  String get signature;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateLabel;

  /// No description provided for @previousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous Step'**
  String get previousStep;

  /// No description provided for @submitAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Submit & Continue'**
  String get submitAndContinue;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @whereWeOperate.
  ///
  /// In en, this message translates to:
  /// **'WHERE WE OPERATE'**
  String get whereWeOperate;

  /// No description provided for @availableAcross.
  ///
  /// In en, this message translates to:
  /// **'Available Across '**
  String get availableAcross;

  /// No description provided for @fourStates.
  ///
  /// In en, this message translates to:
  /// **'4 States'**
  String get fourStates;

  /// No description provided for @inSouthIndia.
  ///
  /// In en, this message translates to:
  /// **' in South India'**
  String get inSouthIndia;

  /// No description provided for @expandingNetwork.
  ///
  /// In en, this message translates to:
  /// **'Expanding our clean mobility network to more cities every month.'**
  String get expandingNetwork;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get availableNow;

  /// No description provided for @kerala.
  ///
  /// In en, this message translates to:
  /// **'Kerala'**
  String get kerala;

  /// No description provided for @godsOwnCountry.
  ///
  /// In en, this message translates to:
  /// **'God\'s Own Country'**
  String get godsOwnCountry;

  /// No description provided for @keralaDescription.
  ///
  /// In en, this message translates to:
  /// **'Experience the serene backwaters, lush greenery, and vibrant culture of Kerala. Our EV taxis connect you seamlessly across Kochi, Trivandrum, and Kozhikode — clean, quiet, and comfortable.'**
  String get keralaDescription;

  /// No description provided for @keralaHighlights.
  ///
  /// In en, this message translates to:
  /// **'Kochi · Trivandrum · Kozhikode'**
  String get keralaHighlights;

  /// No description provided for @karnataka.
  ///
  /// In en, this message translates to:
  /// **'Karnataka'**
  String get karnataka;

  /// No description provided for @oneStateManyWorlds.
  ///
  /// In en, this message translates to:
  /// **'One State, Many Worlds'**
  String get oneStateManyWorlds;

  /// No description provided for @karnatakaDescription.
  ///
  /// In en, this message translates to:
  /// **'From the tech corridors of Bangalore to the royal heritage of Mysore, Karnataka offers a world of contrasts. Our EVs navigate every corner efficiently — zero emissions, zero compromise.'**
  String get karnatakaDescription;

  /// No description provided for @karnatakaHighlights.
  ///
  /// In en, this message translates to:
  /// **'Bangalore · Mysore · Mangalore'**
  String get karnatakaHighlights;

  /// No description provided for @tamilNadu.
  ///
  /// In en, this message translates to:
  /// **'Tamil Nadu'**
  String get tamilNadu;

  /// No description provided for @landOfTemples.
  ///
  /// In en, this message translates to:
  /// **'Land of Temples'**
  String get landOfTemples;

  /// No description provided for @tamilNaduDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover the ancient temples, bustling cities, and coastal beauty of Tamil Nadu. Whether it\'s a pilgrimage to Madurai or a business trip to Chennai, our EV fleet gets you there sustainably.'**
  String get tamilNaduDescription;

  /// No description provided for @tamilNaduHighlights.
  ///
  /// In en, this message translates to:
  /// **'Chennai · Coimbatore · Madurai'**
  String get tamilNaduHighlights;

  /// No description provided for @puducherry.
  ///
  /// In en, this message translates to:
  /// **'Puducherry'**
  String get puducherry;

  /// No description provided for @frenchRiviera.
  ///
  /// In en, this message translates to:
  /// **'The French Riviera of the East'**
  String get frenchRiviera;

  /// No description provided for @puducherryDescription.
  ///
  /// In en, this message translates to:
  /// **'Stroll through French colonial streets, pristine beaches, and spiritual ashrams. Puducherry\'s charm deserves a ride as elegant as the destination — our silent EVs blend right in.'**
  String get puducherryDescription;

  /// No description provided for @puducherryHighlights.
  ///
  /// In en, this message translates to:
  /// **'Pondicherry · Karaikal · Yanam'**
  String get puducherryHighlights;

  /// No description provided for @featureBackwater.
  ///
  /// In en, this message translates to:
  /// **'Backwater Routes'**
  String get featureBackwater;

  /// No description provided for @featureAirport.
  ///
  /// In en, this message translates to:
  /// **'Airport Transfers'**
  String get featureAirport;

  /// No description provided for @featureCityCommute.
  ///
  /// In en, this message translates to:
  /// **'City Commutes'**
  String get featureCityCommute;

  /// No description provided for @featureHillStation.
  ///
  /// In en, this message translates to:
  /// **'Hill Station Trips'**
  String get featureHillStation;

  /// No description provided for @featureTechPark.
  ///
  /// In en, this message translates to:
  /// **'Tech Park Shuttles'**
  String get featureTechPark;

  /// No description provided for @featureHeritage.
  ///
  /// In en, this message translates to:
  /// **'Heritage Tours'**
  String get featureHeritage;

  /// No description provided for @featureHeritageTownTours.
  ///
  /// In en, this message translates to:
  /// **'Heritage Town Tours'**
  String get featureHeritageTownTours;

  /// No description provided for @featureCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate Rides'**
  String get featureCorporate;

  /// No description provided for @featureWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend Getaways'**
  String get featureWeekend;

  /// No description provided for @featureTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple Circuit Rides'**
  String get featureTemple;

  /// No description provided for @featurePortCity.
  ///
  /// In en, this message translates to:
  /// **'Port City Transfers'**
  String get featurePortCity;

  /// No description provided for @featureITCorridor.
  ///
  /// In en, this message translates to:
  /// **'IT Corridor Commutes'**
  String get featureITCorridor;

  /// No description provided for @featureCoastal.
  ///
  /// In en, this message translates to:
  /// **'Coastal Drives'**
  String get featureCoastal;

  /// No description provided for @featureBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach Transfers'**
  String get featureBeach;

  /// No description provided for @featureAshram.
  ///
  /// In en, this message translates to:
  /// **'Ashram Visits'**
  String get featureAshram;

  /// No description provided for @featureScenic.
  ///
  /// In en, this message translates to:
  /// **'Scenic Coastal Rides'**
  String get featureScenic;

  /// No description provided for @chargingNetwork.
  ///
  /// In en, this message translates to:
  /// **'CHARGING NETWORK'**
  String get chargingNetwork;

  /// No description provided for @exploreSouthIndia.
  ///
  /// In en, this message translates to:
  /// **'Explore South India'**
  String get exploreSouthIndia;

  /// No description provided for @chargingNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'Find the nearest charging stations or plan your journey with optimized stops. High-speed charging at your fingertips.'**
  String get chargingNetworkDescription;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @reliable.
  ///
  /// In en, this message translates to:
  /// **'Reliable'**
  String get reliable;

  /// No description provided for @youLegend.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLegend;

  /// No description provided for @stationLegend.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get stationLegend;

  /// No description provided for @routeLegend.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLegend;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingLocation;

  /// No description provided for @findingStations.
  ///
  /// In en, this message translates to:
  /// **'Finding Stations...'**
  String get findingStations;

  /// No description provided for @planningRoute.
  ///
  /// In en, this message translates to:
  /// **'Planning Route...'**
  String get planningRoute;

  /// No description provided for @findNearest.
  ///
  /// In en, this message translates to:
  /// **'Find Nearest'**
  String get findNearest;

  /// No description provided for @planRoute.
  ///
  /// In en, this message translates to:
  /// **'Plan Route'**
  String get planRoute;

  /// No description provided for @megaRole.
  ///
  /// In en, this message translates to:
  /// **'Orchestrate the entire state\'s EV ecosystem.'**
  String get megaRole;

  /// No description provided for @megaInvestment.
  ///
  /// In en, this message translates to:
  /// **'High Investment  •  High ROI'**
  String get megaInvestment;

  /// No description provided for @megaFeature1.
  ///
  /// In en, this message translates to:
  /// **'Manage Master Franchises across districts'**
  String get megaFeature1;

  /// No description provided for @megaFeature2.
  ///
  /// In en, this message translates to:
  /// **'Establish State Headquarters & Infrastructure'**
  String get megaFeature2;

  /// No description provided for @megaFeature3.
  ///
  /// In en, this message translates to:
  /// **'Direct liaison with State Transport Ministry'**
  String get megaFeature3;

  /// No description provided for @megaFeature4.
  ///
  /// In en, this message translates to:
  /// **'Revenue share from ALL state operations'**
  String get megaFeature4;

  /// No description provided for @masterRole.
  ///
  /// In en, this message translates to:
  /// **'Lead operations across 2-5 key districts.'**
  String get masterRole;

  /// No description provided for @masterInvestment.
  ///
  /// In en, this message translates to:
  /// **'Medium Investment  •  Steady Growth'**
  String get masterInvestment;

  /// No description provided for @masterFeature1.
  ///
  /// In en, this message translates to:
  /// **'Oversee multiple Super Franchises'**
  String get masterFeature1;

  /// No description provided for @masterFeature2.
  ///
  /// In en, this message translates to:
  /// **'Manage District Offices & Hubs'**
  String get masterFeature2;

  /// No description provided for @masterFeature3.
  ///
  /// In en, this message translates to:
  /// **'Fleet monitoring & performance tracking'**
  String get masterFeature3;

  /// No description provided for @masterFeature4.
  ///
  /// In en, this message translates to:
  /// **'Driver recruitment & training coordination'**
  String get masterFeature4;

  /// No description provided for @superRole.
  ///
  /// In en, this message translates to:
  /// **'Own and maximize returns on a fleet of 10-30 EVs.'**
  String get superRole;

  /// No description provided for @superInvestment.
  ///
  /// In en, this message translates to:
  /// **'ROI: 18-25%  •  Break-even: 24-36 Mo'**
  String get superInvestment;

  /// No description provided for @superFeature1.
  ///
  /// In en, this message translates to:
  /// **'Direct Fleet Ownership & Asset Management'**
  String get superFeature1;

  /// No description provided for @superFeature2.
  ///
  /// In en, this message translates to:
  /// **'Requires 500-1500 sq ft Office + Parking'**
  String get superFeature2;

  /// No description provided for @superFeature3.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Maintenance (Battery/Cooling)'**
  String get superFeature3;

  /// No description provided for @superFeature4.
  ///
  /// In en, this message translates to:
  /// **'Charge point installation (Level 2/3)'**
  String get superFeature4;

  /// No description provided for @electricFleet.
  ///
  /// In en, this message translates to:
  /// **'100% ELECTRIC FLEET'**
  String get electricFleet;

  /// No description provided for @premiumTaxiService.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM TAXI SERVICE IN INDIA'**
  String get premiumTaxiService;

  /// No description provided for @classicHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Experience luxury and comfort with our elite electric vehicle fleet across India.'**
  String get classicHeroSubtitle;

  /// No description provided for @watchDemo.
  ///
  /// In en, this message translates to:
  /// **'Watch Demo'**
  String get watchDemo;

  /// No description provided for @ecabbzTaxi.
  ///
  /// In en, this message translates to:
  /// **'E-CABBZ TAXI'**
  String get ecabbzTaxi;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
