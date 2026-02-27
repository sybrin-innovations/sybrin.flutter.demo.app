/// Static catalog mirroring the SDK's Document.java enum.
///
/// Maps each country (display name + ISO code) to its list of supported
/// documents. The [docEnum] string must match the Java enum name exactly —
/// it is sent to Android as the "document" argument to scanDocument().
library;

class CountryEntry {
  final String name;
  final String isoCode; // two-letter ISO used for flag emoji
  final List<DocEntry> documents;
  const CountryEntry(this.name, this.isoCode, this.documents);

  /// Unicode flag emoji derived from the ISO code.
  String get flag {
    if (isoCode.isEmpty) return '🌐';
    return isoCode.toUpperCase().runes
        .map((c) => String.fromCharCode(c + 0x1F1A5))
        .join();
  }
}

class DocEntry {
  final String label;       // human-readable
  final String docEnum;     // must match Document.<Java enum name>
  const DocEntry(this.label, this.docEnum);
}

/// The full catalog. Order matches Document.java.
const List<CountryEntry> kIdentityCatalog = [
  CountryEntry('South Africa', 'ZA', [
    DocEntry('ID Card',    'SouthAfricaIDCard'),
    DocEntry('Passport',   'SouthAfricaPassport'),
    DocEntry('Green Book', 'SouthAfricaGreenBook'),
  ]),
  CountryEntry('Philippines', 'PH', [
    DocEntry('ID Card',                 'PhilippinesIdCard'),
    DocEntry('Passport',                'PhilippinesPassport'),
    DocEntry('Driver\'s License',       'PhilippinesDriversLicense'),
    DocEntry('Postal ID',               'PhilippinesPostalId'),
    DocEntry('PhilHealth Card',         'PhilippinesHealthInsuranceCard'),
    DocEntry('PRC ID',                  'PhilippinesIdProfessionalRegulationCommissionCard'),
    DocEntry('SSS ID',                  'PhilippinesIdSocialSecurityID'),
    DocEntry('Seaman\'s Book',          'PhilippinesSeafarerIdentificationRecordBook'),
    DocEntry('UMID',                    'PhilippinesUnifiedMultipurposeID'),
  ]),
  CountryEntry('Kenya', 'KE', [
    DocEntry('ID Card',             'KenyaIdCard'),
    DocEntry('Passport',            'KenyaPassport'),
    DocEntry('Maisha Card',         'KenyaMaisha'),
    DocEntry('Foreign Certificate', 'KenyaForeignCertificate'),
    DocEntry('Birth Certificate',   'KenyaBirthCertificate'),
    DocEntry('Military ID',         'KenyaMilitaryId'),
  ]),
  CountryEntry('Tanzania', 'TZ', [
    DocEntry('ID Card',           'TanzaniaIdCard'),
    DocEntry('Passport',          'TanzaniaPassport'),
    DocEntry('Driver\'s License', 'TanzaniaDriversLicense'),
    DocEntry('Voter Card',        'TanzaniaVoterCard'),
    DocEntry('Birth Certificate', 'TanzaniaBirthCertificate'),
  ]),
  CountryEntry('Uganda', 'UG', [
    DocEntry('ID Card',  'UgandaIdCard'),
    DocEntry('Passport', 'UgandaPassport'),
  ]),
  CountryEntry('Ghana', 'GH', [
    DocEntry('ID Card',  'GhanaIDCard'),
    DocEntry('Passport', 'GhanaPassport'),
  ]),
  CountryEntry('Germany', 'DE', [
    DocEntry('Passport', 'GermanyPassport'),
  ]),
  CountryEntry('USA', 'US', [
    DocEntry('Passport',          'USAPassport'),
    DocEntry('Driver\'s License', 'USACaliforniaDriversLicense'),
  ]),
  CountryEntry('Generic', '', [
    DocEntry('Passport', 'GenericPassport'),
  ]),
];
