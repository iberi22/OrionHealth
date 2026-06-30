// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs
// Portions Ported from OpenMed: https://github.com/maziyarpanahi/openmed/blob/master/openmed/core/labels.py

/// Canonical PII/PHI label taxonomy.
/// Ported from OpenMed (Apache 2.0).
///
/// This module provides a single [canonicalLabels] taxonomy in lowerCamelCase
/// and a [normalizeLabel] helper that maps various input forms to its canonical name.
library;

// People-related entities
const String person = 'PERSON';
const String firstName = 'FIRST_NAME';
const String lastName = 'LAST_NAME';
const String middleName = 'MIDDLE_NAME';
const String prefix = 'PREFIX';
const String username = 'USERNAME';

// Contact
const String email = 'EMAIL';
const String phone = 'PHONE';
const String url = 'URL';

// Location
const String location = 'LOCATION';
const String streetAddress = 'STREET_ADDRESS';
const String buildingNumber = 'BUILDING_NUMBER';
const String zipCode = 'ZIP_CODE';
const String zipcode = 'ZIPCODE';
const String gpsCoordinates = 'GPS_COORDINATES';
const String ordinalDirection = 'ORDINAL_DIRECTION';
const String country = 'COUNTRY';
const String state = 'STATE';
const String city = 'CITY';

// Time
const String date = 'DATE';
const String dateOfBirth = 'DATE_OF_BIRTH';
const String time = 'TIME';
const String age = 'AGE';

// Identifiers
const String idNum = 'ID_NUM';
const String ssn = 'SSN';
const String npi = 'NPI';
const String medicalRecordNumber = 'MEDICAL_RECORD_NUMBER';
const String healthPlanId = 'HEALTH_PLAN_ID';
const String accountNumber = 'ACCOUNT_NUMBER';
const String password = 'PASSWORD';
const String pin = 'PIN';
const String apiKey = 'API_KEY';

// Financial
const String creditCard = 'CREDIT_CARD';
const String creditCardIssuer = 'CREDIT_CARD_ISSUER';
const String cvv = 'CVV';
const String iban = 'IBAN';
const String bic = 'BIC';
const String amount = 'AMOUNT';
const String currency = 'CURRENCY';
const String bitcoinAddress = 'BITCOIN_ADDRESS';
const String ethereumAddress = 'ETHEREUM_ADDRESS';
const String litecoinAddress = 'LITECOIN_ADDRESS';
const String maskedNumber = 'MASKED_NUMBER';

// Demographics
const String gender = 'GENDER';
const String eyeColor = 'EYE_COLOR';
const String height = 'HEIGHT';
const String weight = 'WEIGHT';

// Work
const String organization = 'ORGANIZATION';
const String jobTitle = 'JOB_TITLE';
const String jobDepartment = 'JOB_DEPARTMENT';
const String occupation = 'OCCUPATION';

// Tech
const String ipAddress = 'IP_ADDRESS';
const String macAddress = 'MAC_ADDRESS';
const String userAgent = 'USER_AGENT';
const String vin = 'VIN';
const String licensePlate = 'LICENSE_PLATE';
const String vehicleRegistration = 'VEHICLE_REGISTRATION';
const String imei = 'IMEI';

// Medical specific
const String patientId = 'PATIENT_ID';
const String providerId = 'PROVIDER_ID';
const String drugName = 'DRUG_NAME';
const String diagnosisCode = 'DIAGNOSIS_CODE';
const String procedureCode = 'PROCEDURE_CODE';
const String labResult = 'LAB_RESULT';
const String vitalSign = 'VITAL_SIGN';
const String allergy = 'ALLERGY';
const String condition = 'CONDITION';
const String insuranceId = 'INSURANCE_ID';

const String other = 'OTHER';

const Set<String> canonicalLabels = {
  person,
  firstName,
  lastName,
  middleName,
  prefix,
  username,
  email,
  phone,
  url,
  location,
  streetAddress,
  buildingNumber,
  zipCode,
  zipcode,
  gpsCoordinates,
  ordinalDirection,
  country,
  state,
  city,
  date,
  dateOfBirth,
  time,
  age,
  idNum,
  ssn,
  npi,
  medicalRecordNumber,
  healthPlanId,
  accountNumber,
  password,
  pin,
  apiKey,
  creditCard,
  creditCardIssuer,
  cvv,
  iban,
  bic,
  amount,
  currency,
  bitcoinAddress,
  ethereumAddress,
  litecoinAddress,
  maskedNumber,
  gender,
  eyeColor,
  height,
  weight,
  organization,
  jobTitle,
  jobDepartment,
  occupation,
  ipAddress,
  macAddress,
  userAgent,
  vin,
  licensePlate,
  vehicleRegistration,
  imei,
  patientId,
  providerId,
  drugName,
  diagnosisCode,
  procedureCode,
  labResult,
  vitalSign,
  allergy,
  condition,
  insuranceId,
  other,
};

const Map<String, String> aliasMap = {
  // People
  "name": person,
  "person": person,
  "patient": person,
  "doctor": person,
  "fullname": person,
  "firstname": firstName,
  "givenname": firstName,
  "lastname": lastName,
  "surname": lastName,
  "familyname": lastName,
  "middlename": middleName,
  "prefix": prefix,
  "title": prefix,
  "username": username,
  "userhandle": username,

  // Contact
  "email": email,
  "emailaddress": email,
  "phone": phone,
  "phonenumber": phone,
  "telephone": phone,
  "fax": phone,
  "url": url,
  "urlpersonal": url,
  "website": url,
  "personalurl": url,

  // Location
  "location": location,
  "city": city,
  "state": state,
  "country": country,
  "county": location,
  "region": location,
  "place": location,
  "address": streetAddress,
  "street": streetAddress,
  "streetaddress": streetAddress,
  "secondaryaddress": streetAddress,
  "buildingnumber": buildingNumber,
  "zipcode": zipCode,
  "zip_code": zipCode,
  "zip": zipCode,
  "postcode": zipCode,
  "postalcode": zipCode,
  "gpscoordinates": gpsCoordinates,
  "gps": gpsCoordinates,
  "ordinaldirection": ordinalDirection,

  // Time
  "date": date,
  "dateofbirth": dateOfBirth,
  "dob": dateOfBirth,
  "birthdate": dateOfBirth,
  "time": time,
  "age": age,

  // Identifiers
  "idnum": idNum,
  "id": idNum,
  "identifier": idNum,
  "medicalrecordnumber": medicalRecordNumber,
  "mrn": medicalRecordNumber,
  "nationalid": idNum,
  "cpf": idNum,
  "cnpj": idNum,
  "nir": idNum,
  "steuerid": idNum,
  "codicefiscale": idNum,
  "dni": idNum,
  "nie": idNum,
  "bsn": idNum,
  "aadhaar": idNum,
  "npi": npi,
  "ssn": ssn,
  "socialsecuritynumber": ssn,
  "accountnumber": accountNumber,
  "accountname": accountNumber,
  "bankaccount": accountNumber,
  "password": password,
  "pin": pin,
  "apikey": apiKey,

  // Financial
  "creditcard": creditCard,
  "creditdebitcard": creditCard,
  "creditcardnumber": creditCard,
  "creditcardissuer": creditCardIssuer,
  "cvv": cvv,
  "iban": iban,
  "bic": bic,
  "swift": bic,
  "amount": amount,
  "currency": currency,
  "currencycode": currency,
  "currencyname": currency,
  "currencysymbol": currency,
  "bitcoinaddress": bitcoinAddress,
  "ethereumaddress": ethereumAddress,
  "litecoinaddress": litecoinAddress,
  "maskednumber": maskedNumber,

  // Demographics
  "gender": gender,
  "sex": gender,
  "eyecolor": eyeColor,
  "height": height,
  "weight": weight,

  // Work
  "organization": organization,
  "company": organization,
  "employer": organization,
  "jobtitle": jobTitle,
  "jobdepartment": jobDepartment,
  "department": jobDepartment,
  "occupation": occupation,
  "profession": occupation,

  // Tech
  "ipaddress": ipAddress,
  "ip": ipAddress,
  "macaddress": macAddress,
  "useragent": userAgent,
  "vin": vin,
  "vrm": vehicleRegistration,
  "licenseplate": licensePlate,
  "vehicleregistration": vehicleRegistration,
  "imei": imei,

  // Medical specific aliases
  "patientid": patientId,
  "providerid": providerId,
  "drugname": drugName,
  "diagcode": diagnosisCode,
  "diagnosiscode": diagnosisCode,
  "proccode": procedureCode,
  "procedurecode": procedureCode,
  "labresult": labResult,
  "vitalsign": vitalSign,
  "allergy": allergy,
  "condition": condition,
  "insuranceid": insuranceId,
  "healthplanid": healthPlanId,
};

final RegExp _bioesPrefixRe = RegExp(r"^[BIES]-");

String _stripBioesPrefix(String label) {
  return label.replaceFirst(_bioesPrefixRe, "");
}

String _key(String label) {
  final stripped = _stripBioesPrefix(label.trim());
  return stripped.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "");
}

/// Normalize an entity label to the canonical taxonomy.
///
/// Accepts various formats:
/// - snake_case (first_name)
/// - UPPERCASE (FIRSTNAME)
/// - BIOES-tagged (B-PERSON, I-EMAIL)
/// - Mixed case with separators (First-Name, First Name)
String normalizeLabel(String label, {String lang = "en"}) {
  if (label.isEmpty) {
    return other;
  }
  final key = _key(label);
  if (key.isEmpty) {
    return other;
  }
  final canonical = aliasMap[key];
  if (canonical != null) {
    return canonical;
  }

  final upper = label
      .toUpperCase()
      .replaceAll("-", "_")
      .replaceAll(" ", "_")
      .replaceAll(RegExp(r"[^A-Z0-9_]"), "");
  if (canonicalLabels.contains(upper)) {
    return upper;
  }
  return other;
}

/// Static class providing access to PII labels for use with PII detection.
/// Maps shorthand property names (e.g., date, ssn, email) to canonical constants.
class PiiLabel {
  PiiLabel._();

  static String get date => date;
  static String get ssn => ssn;
  static String get email => email;
  static String get phoneNumber => phone;
  static String get url => url;
  static String get ipv4 => ipAddress;
  static String get ipv6 => ipAddress;
  static String get macAddress => macAddress;
  static String get streetAddress => streetAddress;
  static String get postcode => zipCode;
  static String get fullName => person;
  static String get organization => organization;
  static String get creditCard => creditCard;
  static String get password => password;
  static String get npi => npi;
  static String get mrn => medicalRecordNumber;
  static String get driverLicense => idNum;
  static String get passportNumber => idNum;
  static String get encounterNumber => idNum;
  static String get insuranceId => insuranceId;
  static String get accountNumber => accountNumber;
  static String get routingNumber => accountNumber;
}

const Map<String, Map<String, dynamic>> piiEntityMeta = {
  person: {
    'category': 'PII',
    'description': 'Full name of a person',
    'color': 'blue',
  },
  firstName: {
    'category': 'PII',
    'description': 'First name of a person',
    'color': 'blue',
  },
  lastName: {
    'category': 'PII',
    'description': 'Last name of a person',
    'color': 'blue',
  },
  middleName: {
    'category': 'PII',
    'description': 'Middle name of a person',
    'color': 'blue',
  },
  prefix: {
    'category': 'PII',
    'description': 'Prefix or title (e.g. Mr, Ms, Dr)',
    'color': 'blue',
  },
  username: {
    'category': 'PII',
    'description': 'Username or handle',
    'color': 'blue',
  },
  email: {
    'category': 'PII',
    'description': 'Email address',
    'color': 'blue',
  },
  phone: {
    'category': 'PII',
    'description': 'Phone or fax number',
    'color': 'blue',
  },
  url: {
    'category': 'PII',
    'description': 'URL or website address',
    'color': 'blue',
  },
  location: {
    'category': 'PII',
    'description': 'Geographic location',
    'color': 'green',
  },
  streetAddress: {
    'category': 'PII',
    'description': 'Street address',
    'color': 'green',
  },
  buildingNumber: {
    'category': 'PII',
    'description': 'Building or house number',
    'color': 'green',
  },
  zipCode: {
    'category': 'PII',
    'description': 'Zip or postal code',
    'color': 'green',
  },
  zipcode: {
    'category': 'PII',
    'description': 'Zip or postal code',
    'color': 'green',
  },
  gpsCoordinates: {
    'category': 'PII',
    'description': 'GPS coordinates',
    'color': 'green',
  },
  ordinalDirection: {
    'category': 'PII',
    'description': 'Ordinal direction (e.g. North, South)',
    'color': 'green',
  },
  country: {
    'category': 'PII',
    'description': 'Country name',
    'color': 'green',
  },
  state: {
    'category': 'PII',
    'description': 'State or province name',
    'color': 'green',
  },
  city: {
    'category': 'PII',
    'description': 'City name',
    'color': 'green',
  },
  date: {
    'category': 'PII',
    'description': 'Specific date',
    'color': 'cyan',
  },
  dateOfBirth: {
    'category': 'PII',
    'description': 'Date of birth',
    'color': 'cyan',
  },
  time: {
    'category': 'PII',
    'description': 'Specific time',
    'color': 'cyan',
  },
  age: {
    'category': 'PII',
    'description': 'Age of a person',
    'color': 'cyan',
  },
  idNum: {
    'category': 'PII',
    'description': 'Identification number',
    'color': 'red',
  },
  ssn: {
    'category': 'PII',
    'description': 'Social Security Number',
    'color': 'red',
  },
  npi: {
    'category': 'MEDICAL',
    'description': 'National Provider Identifier',
    'color': 'purple',
  },
  medicalRecordNumber: {
    'category': 'PHI',
    'description': 'Medical Record Number (MRN)',
    'color': 'purple',
  },
  healthPlanId: {
    'category': 'PHI',
    'description': 'Health plan beneficiary number',
    'color': 'purple',
  },
  accountNumber: {
    'category': 'FINANCIAL',
    'description': 'Bank or other account number',
    'color': 'orange',
  },
  password: {
    'category': 'PII',
    'description': 'Password',
    'color': 'red',
  },
  pin: {
    'category': 'PII',
    'description': 'Personal Identification Number',
    'color': 'red',
  },
  apiKey: {
    'category': 'PII',
    'description': 'API key or token',
    'color': 'red',
  },
  creditCard: {
    'category': 'FINANCIAL',
    'description': 'Credit or debit card number',
    'color': 'orange',
  },
  creditCardIssuer: {
    'category': 'FINANCIAL',
    'description': 'Credit card issuing bank',
    'color': 'orange',
  },
  cvv: {
    'category': 'FINANCIAL',
    'description': 'Credit card verification value',
    'color': 'orange',
  },
  iban: {
    'category': 'FINANCIAL',
    'description': 'International Bank Account Number',
    'color': 'orange',
  },
  bic: {
    'category': 'FINANCIAL',
    'description': 'Bank Identifier Code (SWIFT)',
    'color': 'orange',
  },
  amount: {
    'category': 'FINANCIAL',
    'description': 'Monetary amount',
    'color': 'orange',
  },
  currency: {
    'category': 'FINANCIAL',
    'description': 'Currency name or symbol',
    'color': 'orange',
  },
  bitcoinAddress: {
    'category': 'FINANCIAL',
    'description': 'Bitcoin wallet address',
    'color': 'orange',
  },
  ethereumAddress: {
    'category': 'FINANCIAL',
    'description': 'Ethereum wallet address',
    'color': 'orange',
  },
  litecoinAddress: {
    'category': 'FINANCIAL',
    'description': 'Litecoin wallet address',
    'color': 'orange',
  },
  maskedNumber: {
    'category': 'PII',
    'description': 'Masked identification number',
    'color': 'grey',
  },
  gender: {
    'category': 'PII',
    'description': 'Gender or sex',
    'color': 'teal',
  },
  eyeColor: {
    'category': 'PII',
    'description': 'Eye color',
    'color': 'teal',
  },
  height: {
    'category': 'PII',
    'description': 'Height',
    'color': 'teal',
  },
  weight: {
    'category': 'PII',
    'description': 'Weight',
    'color': 'teal',
  },
  organization: {
    'category': 'PII',
    'description': 'Organization or company name',
    'color': 'indigo',
  },
  jobTitle: {
    'category': 'PII',
    'description': 'Job title',
    'color': 'indigo',
  },
  jobDepartment: {
    'category': 'PII',
    'description': 'Job department',
    'color': 'indigo',
  },
  occupation: {
    'category': 'PII',
    'description': 'Occupation or profession',
    'color': 'indigo',
  },
  ipAddress: {
    'category': 'PII',
    'description': 'IP address',
    'color': 'brown',
  },
  macAddress: {
    'category': 'PII',
    'description': 'MAC address',
    'color': 'brown',
  },
  userAgent: {
    'category': 'PII',
    'description': 'Browser user agent string',
    'color': 'brown',
  },
  vin: {
    'category': 'PII',
    'description': 'Vehicle Identification Number',
    'color': 'brown',
  },
  licensePlate: {
    'category': 'PII',
    'description': 'Vehicle license plate number',
    'color': 'brown',
  },
  vehicleRegistration: {
    'category': 'PII',
    'description': 'Vehicle registration details',
    'color': 'brown',
  },
  imei: {
    'category': 'PII',
    'description': 'Mobile device IMEI number',
    'color': 'brown',
  },
  patientId: {
    'category': 'PHI',
    'description': 'Unique identifier for a patient',
    'color': 'purple',
  },
  providerId: {
    'category': 'MEDICAL',
    'description': 'Unique identifier for a provider',
    'color': 'purple',
  },
  drugName: {
    'category': 'MEDICAL',
    'description': 'Name of a drug or medication',
    'color': 'purple',
  },
  diagnosisCode: {
    'category': 'PHI',
    'description': 'Medical diagnosis code (e.g. ICD-10)',
    'color': 'purple',
  },
  procedureCode: {
    'category': 'PHI',
    'description': 'Medical procedure code (e.g. CPT)',
    'color': 'purple',
  },
  labResult: {
    'category': 'PHI',
    'description': 'Laboratory test result',
    'color': 'purple',
  },
  vitalSign: {
    'category': 'PHI',
    'description': 'Vital sign measurement',
    'color': 'purple',
  },
  allergy: {
    'category': 'PHI',
    'description': 'Allergy information',
    'color': 'purple',
  },
  condition: {
    'category': 'PHI',
    'description': 'Medical condition',
    'color': 'purple',
  },
  insuranceId: {
    'category': 'PHI',
    'description': 'Medical insurance policy ID',
    'color': 'purple',
  },
  other: {
    'category': 'OTHER',
    'description': 'Other non-categorized entity',
    'color': 'grey',
  },
};
