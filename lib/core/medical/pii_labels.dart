// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs
// Portions Ported from OpenMed: https://github.com/maziyarpanahi/openmed/blob/master/openmed/core/labels.py

/// Canonical PII/PHI label taxonomy.
/// Ported from OpenMed (Apache 2.0).
///
/// This module provides a single [CANONICAL_LABELS] taxonomy in UPPER_SNAKE_CASE
/// and a [normalizeLabel] helper that maps various input forms to its canonical name.

// People-related entities
const String PERSON = 'PERSON';
const String FIRST_NAME = 'FIRST_NAME';
const String LAST_NAME = 'LAST_NAME';
const String MIDDLE_NAME = 'MIDDLE_NAME';
const String PREFIX = 'PREFIX';
const String USERNAME = 'USERNAME';

// Contact
const String EMAIL = 'EMAIL';
const String PHONE = 'PHONE';
const String URL = 'URL';

// Location
const String LOCATION = 'LOCATION';
const String ADDRESS = 'STREET_ADDRESS';
const String STREET_ADDRESS = 'STREET_ADDRESS';
const String BUILDING_NUMBER = 'BUILDING_NUMBER';
const String ZIP_CODE = 'ZIP_CODE';
const String ZIPCODE = 'ZIPCODE';
const String GPS_COORDINATES = 'GPS_COORDINATES';
const String ORDINAL_DIRECTION = 'ORDINAL_DIRECTION';
const String COUNTRY = 'COUNTRY';
const String STATE = 'STATE';
const String CITY = 'CITY';

// Time
const String DATE = 'DATE';
const String DATE_OF_BIRTH = 'DATE_OF_BIRTH';
const String TIME = 'TIME';
const String AGE = 'AGE';

// Identifiers
const String ID_NUM = 'ID_NUM';
const String SSN = 'SSN';
const String NPI = 'NPI';
const String MEDICAL_RECORD_NUMBER = 'MEDICAL_RECORD_NUMBER';
const String HEALTH_PLAN_ID = 'HEALTH_PLAN_ID';
const String ACCOUNT_NUMBER = 'ACCOUNT_NUMBER';
const String PASSWORD = 'PASSWORD';
const String PIN = 'PIN';
const String API_KEY = 'API_KEY';

// Financial
const String CREDIT_CARD = 'CREDIT_CARD';
const String CREDIT_CARD_ISSUER = 'CREDIT_CARD_ISSUER';
const String CVV = 'CVV';
const String IBAN = 'IBAN';
const String BIC = 'BIC';
const String AMOUNT = 'AMOUNT';
const String CURRENCY = 'CURRENCY';
const String BITCOIN_ADDRESS = 'BITCOIN_ADDRESS';
const String ETHEREUM_ADDRESS = 'ETHEREUM_ADDRESS';
const String LITECOIN_ADDRESS = 'LITECOIN_ADDRESS';
const String MASKED_NUMBER = 'MASKED_NUMBER';

// Demographics
const String GENDER = 'GENDER';
const String EYE_COLOR = 'EYE_COLOR';
const String HEIGHT = 'HEIGHT';
const String WEIGHT = 'WEIGHT';

// Work
const String ORGANIZATION = 'ORGANIZATION';
const String JOB_TITLE = 'JOB_TITLE';
const String JOB_DEPARTMENT = 'JOB_DEPARTMENT';
const String OCCUPATION = 'OCCUPATION';

// Tech
const String IP_ADDRESS = 'IP_ADDRESS';
const String MAC_ADDRESS = 'MAC_ADDRESS';
const String USER_AGENT = 'USER_AGENT';
const String VIN = 'VIN';
const String LICENSE_PLATE = 'LICENSE_PLATE';
const String VEHICLE_REGISTRATION = 'VEHICLE_REGISTRATION';
const String IMEI = 'IMEI';

// Medical specific
const String PATIENT_ID = 'PATIENT_ID';
const String PROVIDER_ID = 'PROVIDER_ID';
const String DRUG_NAME = 'DRUG_NAME';
const String DIAGNOSIS_CODE = 'DIAGNOSIS_CODE';
const String PROCEDURE_CODE = 'PROCEDURE_CODE';
const String LAB_RESULT = 'LAB_RESULT';
const String VITAL_SIGN = 'VITAL_SIGN';
const String ALLERGY = 'ALLERGY';
const String CONDITION = 'CONDITION';
const String INSURANCE_ID = 'INSURANCE_ID';

const String OTHER = 'OTHER';

const Set<String> CANONICAL_LABELS = {
  PERSON, FIRST_NAME, LAST_NAME, MIDDLE_NAME, PREFIX, USERNAME,
  EMAIL, PHONE, URL,
  LOCATION, STREET_ADDRESS, BUILDING_NUMBER, ZIP_CODE, ZIPCODE, GPS_COORDINATES,
  ORDINAL_DIRECTION, COUNTRY, STATE, CITY,
  DATE, DATE_OF_BIRTH, TIME, AGE,
  ID_NUM, SSN, NPI, MEDICAL_RECORD_NUMBER, HEALTH_PLAN_ID, ACCOUNT_NUMBER,
  PASSWORD, PIN, API_KEY,
  CREDIT_CARD, CREDIT_CARD_ISSUER, CVV, IBAN, BIC, AMOUNT, CURRENCY,
  BITCOIN_ADDRESS, ETHEREUM_ADDRESS, LITECOIN_ADDRESS, MASKED_NUMBER,
  GENDER, EYE_COLOR, HEIGHT, WEIGHT,
  ORGANIZATION, JOB_TITLE, JOB_DEPARTMENT, OCCUPATION,
  IP_ADDRESS, MAC_ADDRESS, USER_AGENT, VIN, LICENSE_PLATE, VEHICLE_REGISTRATION, IMEI,
  PATIENT_ID, PROVIDER_ID, DRUG_NAME, DIAGNOSIS_CODE, PROCEDURE_CODE,
  LAB_RESULT, VITAL_SIGN, ALLERGY, CONDITION, INSURANCE_ID,
  OTHER,
};

const Map<String, String> ALIAS_MAP = {
  // People
  "name": PERSON,
  "person": PERSON,
  "patient": PERSON,
  "doctor": PERSON,
  "fullname": PERSON,
  "firstname": FIRST_NAME,
  "givenname": FIRST_NAME,
  "lastname": LAST_NAME,
  "surname": LAST_NAME,
  "familyname": LAST_NAME,
  "middlename": MIDDLE_NAME,
  "prefix": PREFIX,
  "title": PREFIX,
  "username": USERNAME,
  "userhandle": USERNAME,

  // Contact
  "email": EMAIL,
  "emailaddress": EMAIL,
  "phone": PHONE,
  "phonenumber": PHONE,
  "telephone": PHONE,
  "fax": PHONE,
  "url": URL,
  "urlpersonal": URL,
  "website": URL,
  "personalurl": URL,

  // Location
  "location": LOCATION,
  "city": CITY,
  "state": STATE,
  "country": COUNTRY,
  "county": LOCATION,
  "region": LOCATION,
  "place": LOCATION,
  "address": STREET_ADDRESS,
  "street": STREET_ADDRESS,
  "streetaddress": STREET_ADDRESS,
  "secondaryaddress": STREET_ADDRESS,
  "buildingnumber": BUILDING_NUMBER,
  "zipcode": ZIP_CODE,
  "zip_code": ZIP_CODE,
  "zip": ZIP_CODE,
  "postcode": ZIP_CODE,
  "postalcode": ZIP_CODE,
  "gpscoordinates": GPS_COORDINATES,
  "gps": GPS_COORDINATES,
  "ordinaldirection": ORDINAL_DIRECTION,

  // Time
  "date": DATE,
  "dateofbirth": DATE_OF_BIRTH,
  "dob": DATE_OF_BIRTH,
  "birthdate": DATE_OF_BIRTH,
  "time": TIME,
  "age": AGE,

  // Identifiers
  "idnum": ID_NUM,
  "id": ID_NUM,
  "identifier": ID_NUM,
  "medicalrecordnumber": MEDICAL_RECORD_NUMBER,
  "mrn": MEDICAL_RECORD_NUMBER,
  "nationalid": ID_NUM,
  "cpf": ID_NUM,
  "cnpj": ID_NUM,
  "nir": ID_NUM,
  "steuerid": ID_NUM,
  "codicefiscale": ID_NUM,
  "dni": ID_NUM,
  "nie": ID_NUM,
  "bsn": ID_NUM,
  "aadhaar": ID_NUM,
  "npi": NPI,
  "ssn": SSN,
  "socialsecuritynumber": SSN,
  "accountnumber": ACCOUNT_NUMBER,
  "accountname": ACCOUNT_NUMBER,
  "bankaccount": ACCOUNT_NUMBER,
  "password": PASSWORD,
  "pin": PIN,
  "apikey": API_KEY,

  // Financial
  "creditcard": CREDIT_CARD,
  "creditdebitcard": CREDIT_CARD,
  "creditcardnumber": CREDIT_CARD,
  "creditcardissuer": CREDIT_CARD_ISSUER,
  "cvv": CVV,
  "iban": IBAN,
  "bic": BIC,
  "swift": BIC,
  "amount": AMOUNT,
  "currency": CURRENCY,
  "currencycode": CURRENCY,
  "currencyname": CURRENCY,
  "currencysymbol": CURRENCY,
  "bitcoinaddress": BITCOIN_ADDRESS,
  "ethereumaddress": ETHEREUM_ADDRESS,
  "litecoinaddress": LITECOIN_ADDRESS,
  "maskednumber": MASKED_NUMBER,

  // Demographics
  "gender": GENDER,
  "sex": GENDER,
  "eyecolor": EYE_COLOR,
  "height": HEIGHT,
  "weight": WEIGHT,

  // Work
  "organization": ORGANIZATION,
  "company": ORGANIZATION,
  "employer": ORGANIZATION,
  "jobtitle": JOB_TITLE,
  "jobdepartment": JOB_DEPARTMENT,
  "department": JOB_DEPARTMENT,
  "occupation": OCCUPATION,
  "profession": OCCUPATION,

  // Tech
  "ipaddress": IP_ADDRESS,
  "ip": IP_ADDRESS,
  "macaddress": MAC_ADDRESS,
  "useragent": USER_AGENT,
  "vin": VIN,
  "vrm": VEHICLE_REGISTRATION,
  "licenseplate": LICENSE_PLATE,
  "vehicleregistration": VEHICLE_REGISTRATION,
  "imei": IMEI,

  // Medical specific aliases
  "patientid": PATIENT_ID,
  "providerid": PROVIDER_ID,
  "drugname": DRUG_NAME,
  "diagcode": DIAGNOSIS_CODE,
  "diagnosiscode": DIAGNOSIS_CODE,
  "proccode": PROCEDURE_CODE,
  "procedurecode": PROCEDURE_CODE,
  "labresult": LAB_RESULT,
  "vitalsign": VITAL_SIGN,
  "allergy": ALLERGY,
  "condition": CONDITION,
  "insuranceid": INSURANCE_ID,
  "healthplanid": HEALTH_PLAN_ID,
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
    return OTHER;
  }
  final key = _key(label);
  if (key.isEmpty) {
    return OTHER;
  }
  final canonical = ALIAS_MAP[key];
  if (canonical != null) {
    return canonical;
  }

  final upper = label.toUpperCase()
      .replaceAll("-", "_")
      .replaceAll(" ", "_")
      .replaceAll(RegExp(r"[^A-Z0-9_]"), "");
  if (CANONICAL_LABELS.contains(upper)) {
    return upper;
  }
  return OTHER;
}

const Map<String, Map<String, dynamic>> PII_ENTITY_META = {
  PERSON: {
    'category': 'PII',
    'description': 'Full name of a person',
    'color': 'blue',
  },
  FIRST_NAME: {
    'category': 'PII',
    'description': 'First name of a person',
    'color': 'blue',
  },
  LAST_NAME: {
    'category': 'PII',
    'description': 'Last name of a person',
    'color': 'blue',
  },
  MIDDLE_NAME: {
    'category': 'PII',
    'description': 'Middle name of a person',
    'color': 'blue',
  },
  PREFIX: {
    'category': 'PII',
    'description': 'Prefix or title (e.g. Mr, Ms, Dr)',
    'color': 'blue',
  },
  USERNAME: {
    'category': 'PII',
    'description': 'Username or handle',
    'color': 'blue',
  },
  EMAIL: {
    'category': 'PII',
    'description': 'Email address',
    'color': 'blue',
  },
  PHONE: {
    'category': 'PII',
    'description': 'Phone or fax number',
    'color': 'blue',
  },
  URL: {
    'category': 'PII',
    'description': 'URL or website address',
    'color': 'blue',
  },
  LOCATION: {
    'category': 'PII',
    'description': 'Geographic location',
    'color': 'green',
  },
  STREET_ADDRESS: {
    'category': 'PII',
    'description': 'Street address',
    'color': 'green',
  },
  BUILDING_NUMBER: {
    'category': 'PII',
    'description': 'Building or house number',
    'color': 'green',
  },
  ZIP_CODE: {
    'category': 'PII',
    'description': 'Zip or postal code',
    'color': 'green',
  },
  ZIPCODE: {
    'category': 'PII',
    'description': 'Zip or postal code',
    'color': 'green',
  },
  GPS_COORDINATES: {
    'category': 'PII',
    'description': 'GPS coordinates',
    'color': 'green',
  },
  ORDINAL_DIRECTION: {
    'category': 'PII',
    'description': 'Ordinal direction (e.g. North, South)',
    'color': 'green',
  },
  COUNTRY: {
    'category': 'PII',
    'description': 'Country name',
    'color': 'green',
  },
  STATE: {
    'category': 'PII',
    'description': 'State or province name',
    'color': 'green',
  },
  CITY: {
    'category': 'PII',
    'description': 'City name',
    'color': 'green',
  },
  DATE: {
    'category': 'PII',
    'description': 'Specific date',
    'color': 'cyan',
  },
  DATE_OF_BIRTH: {
    'category': 'PII',
    'description': 'Date of birth',
    'color': 'cyan',
  },
  TIME: {
    'category': 'PII',
    'description': 'Specific time',
    'color': 'cyan',
  },
  AGE: {
    'category': 'PII',
    'description': 'Age of a person',
    'color': 'cyan',
  },
  ID_NUM: {
    'category': 'PII',
    'description': 'Identification number',
    'color': 'red',
  },
  SSN: {
    'category': 'PII',
    'description': 'Social Security Number',
    'color': 'red',
  },
  NPI: {
    'category': 'MEDICAL',
    'description': 'National Provider Identifier',
    'color': 'purple',
  },
  MEDICAL_RECORD_NUMBER: {
    'category': 'PHI',
    'description': 'Medical Record Number (MRN)',
    'color': 'purple',
  },
  HEALTH_PLAN_ID: {
    'category': 'PHI',
    'description': 'Health plan beneficiary number',
    'color': 'purple',
  },
  ACCOUNT_NUMBER: {
    'category': 'FINANCIAL',
    'description': 'Bank or other account number',
    'color': 'orange',
  },
  PASSWORD: {
    'category': 'PII',
    'description': 'Password',
    'color': 'red',
  },
  PIN: {
    'category': 'PII',
    'description': 'Personal Identification Number',
    'color': 'red',
  },
  API_KEY: {
    'category': 'PII',
    'description': 'API key or token',
    'color': 'red',
  },
  CREDIT_CARD: {
    'category': 'FINANCIAL',
    'description': 'Credit or debit card number',
    'color': 'orange',
  },
  CREDIT_CARD_ISSUER: {
    'category': 'FINANCIAL',
    'description': 'Credit card issuing bank',
    'color': 'orange',
  },
  CVV: {
    'category': 'FINANCIAL',
    'description': 'Credit card verification value',
    'color': 'orange',
  },
  IBAN: {
    'category': 'FINANCIAL',
    'description': 'International Bank Account Number',
    'color': 'orange',
  },
  BIC: {
    'category': 'FINANCIAL',
    'description': 'Bank Identifier Code (SWIFT)',
    'color': 'orange',
  },
  AMOUNT: {
    'category': 'FINANCIAL',
    'description': 'Monetary amount',
    'color': 'orange',
  },
  CURRENCY: {
    'category': 'FINANCIAL',
    'description': 'Currency name or symbol',
    'color': 'orange',
  },
  BITCOIN_ADDRESS: {
    'category': 'FINANCIAL',
    'description': 'Bitcoin wallet address',
    'color': 'orange',
  },
  ETHEREUM_ADDRESS: {
    'category': 'FINANCIAL',
    'description': 'Ethereum wallet address',
    'color': 'orange',
  },
  LITECOIN_ADDRESS: {
    'category': 'FINANCIAL',
    'description': 'Litecoin wallet address',
    'color': 'orange',
  },
  MASKED_NUMBER: {
    'category': 'PII',
    'description': 'Masked identification number',
    'color': 'grey',
  },
  GENDER: {
    'category': 'PII',
    'description': 'Gender or sex',
    'color': 'teal',
  },
  EYE_COLOR: {
    'category': 'PII',
    'description': 'Eye color',
    'color': 'teal',
  },
  HEIGHT: {
    'category': 'PII',
    'description': 'Height',
    'color': 'teal',
  },
  WEIGHT: {
    'category': 'PII',
    'description': 'Weight',
    'color': 'teal',
  },
  ORGANIZATION: {
    'category': 'PII',
    'description': 'Organization or company name',
    'color': 'indigo',
  },
  JOB_TITLE: {
    'category': 'PII',
    'description': 'Job title',
    'color': 'indigo',
  },
  JOB_DEPARTMENT: {
    'category': 'PII',
    'description': 'Job department',
    'color': 'indigo',
  },
  OCCUPATION: {
    'category': 'PII',
    'description': 'Occupation or profession',
    'color': 'indigo',
  },
  IP_ADDRESS: {
    'category': 'PII',
    'description': 'IP address',
    'color': 'brown',
  },
  MAC_ADDRESS: {
    'category': 'PII',
    'description': 'MAC address',
    'color': 'brown',
  },
  USER_AGENT: {
    'category': 'PII',
    'description': 'Browser user agent string',
    'color': 'brown',
  },
  VIN: {
    'category': 'PII',
    'description': 'Vehicle Identification Number',
    'color': 'brown',
  },
  LICENSE_PLATE: {
    'category': 'PII',
    'description': 'Vehicle license plate number',
    'color': 'brown',
  },
  VEHICLE_REGISTRATION: {
    'category': 'PII',
    'description': 'Vehicle registration details',
    'color': 'brown',
  },
  IMEI: {
    'category': 'PII',
    'description': 'Mobile device IMEI number',
    'color': 'brown',
  },
  PATIENT_ID: {
    'category': 'PHI',
    'description': 'Unique identifier for a patient',
    'color': 'purple',
  },
  PROVIDER_ID: {
    'category': 'MEDICAL',
    'description': 'Unique identifier for a provider',
    'color': 'purple',
  },
  DRUG_NAME: {
    'category': 'MEDICAL',
    'description': 'Name of a drug or medication',
    'color': 'purple',
  },
  DIAGNOSIS_CODE: {
    'category': 'PHI',
    'description': 'Medical diagnosis code (e.g. ICD-10)',
    'color': 'purple',
  },
  PROCEDURE_CODE: {
    'category': 'PHI',
    'description': 'Medical procedure code (e.g. CPT)',
    'color': 'purple',
  },
  LAB_RESULT: {
    'category': 'PHI',
    'description': 'Laboratory test result',
    'color': 'purple',
  },
  VITAL_SIGN: {
    'category': 'PHI',
    'description': 'Vital sign measurement',
    'color': 'purple',
  },
  ALLERGY: {
    'category': 'PHI',
    'description': 'Allergy information',
    'color': 'purple',
  },
  CONDITION: {
    'category': 'PHI',
    'description': 'Medical condition',
    'color': 'purple',
  },
  INSURANCE_ID: {
    'category': 'PHI',
    'description': 'Medical insurance policy ID',
    'color': 'purple',
  },
  OTHER: {
    'category': 'OTHER',
    'description': 'Other non-categorized entity',
    'color': 'grey',
  },
};
