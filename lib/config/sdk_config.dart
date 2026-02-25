/// SDK configuration for the BioID Flutter demo.
///
/// This file is the **single source of truth** for:
/// - Sybrin SDK license keys
/// - Feature flags (enable/disable individual SDK capabilities)
///
/// To configure the demo for a different environment:
/// 1. Replace the license key constants below with your keys.
/// 2. Toggle [SdkFeatureFlags] defaults to show/hide features on the home screen.
library;

// ---------------------------------------------------------------------------
// License Keys
// ---------------------------------------------------------------------------

/// Container for all Sybrin SDK license keys used in this demo.
///
/// These keys are the same ones used in the companion Android app's
/// `SDKLicense.kt`. Replace them here to target a different Sybrin environment.
class SdkLicenseKeys {
  SdkLicenseKeys._(); // prevent instantiation

  /// License key for the **Sybrin Identity SDK** (document scanning).
  /// Used to initialise [SybrinIdentity] on the Android side.
  static const String identityKey =
      'bRdpOKxSHF9GHxn5agAfIAqRW7oOhziGf3XNxTKPbdZiEVGn/X/tteysFuywxzuNt8Mq71Mk'
      'ainJz6hAroh+Fk4441tVybMTOpWD02ZjVYFotZ1JTiVPEN66ngR16w4HdQLGL+FwYXTgLcUz'
      'WWPa0K/FUfGBZxGObNUAp6UBJo79oPpblReB/BR+Gg5Fw7nUCla0plNXeBhE+VfLs2ow6+x'
      'kIsVzdbORyXtquKIO0NFXn/RIQ1Pms/MM9TYMPIBs9x7iSyGDCTswz8M8epmU+0cWN+slYe'
      'jcYkd9Nkqna3//T1IY2wN9QD0t/i1wc2UCbQvElsmqHH+bZmRRbtEJhcUiqEp4W4bh5wlsa'
      'xfG98zkd2jGYlItCdwUYYJ9jDVeLH4KkfSi579C3W32f9z0XLM7cQpE0BT5WPMBIUDiBRdi'
      'pHhSVAzIWrZa4XAfeyV4mJR8u+2B+GAgmRRabMcM9JxYMQzE1ugM1s5kWxNZepf9eW6nHbA'
      'AudZtWYVg+C3PkqXmwP+P0IbhWeV8yPI9rzdjiKvYoOPHEILIsm8r0seIwvh7xeASnuNXHA'
      'uBnnp5IZQFDmfZSFqYKcz1GEJwcbIb0/yINzWj0FEHcnTIs9FZXcpit23H1fU7brhRhBwss'
      'ceZ6r7MGBczW6K02DXdt5pTEZeLcibnqf+MB4Y1SSsnGNFSq1/n9twR+AmSbPDSfpvGUWX0I'
      'RKcK67FDcDmldMbQXGY4A4SzmdVP88ceoPtMzglzWJ/5QBCq2sXCG0/oVqs3NouHWm3+owm'
      'ED95bAZcp/k7UaP/mWaWSgyyKGN09zkgdxVDyzNj220Eku0gpJ8pZRy9Vqes5RGAsp9jPX++'
      'IXekczoHt5q+Y+QW1xmSpJGIviHK6iy4gHKf9jf8q5s/BwvFAZ3JHQGjeS2G29ajaIxutv'
      'NsS/pAaa1WJlbJLOdERS+J/7fLHfgYtHq2Lcj/ZrGiZdrbLq0fAUogwyzMLztW+kr2Bd3P/'
      'hI2YiEUIWB2A72W1zRYZRQKERRFzzjfSLvZPgoaamIkzG1OqA==';

  /// License key for the **Sybrin Biometrics SDK** (liveness + face comparison).
  /// Used to initialise both [SybrinLivenessDetection] and [SybrinFacialComparison].
  static const String biometricsKey =
      'bRdpOKxSHF9GHxn5agAfIAqRW7oOhziGf3XNxTKPbdZiEVGn/X/tteysFuywxzuN5Gv+fUQl'
      '9fGPumV3BX6I6FTGxBkzKBHDTvHkLoqb3lIb7sHD59PZF4O41TA81rRY9LeHVhx6+g2Z5dS'
      'fxGd+D2OUSQO9cP3D2bmVE8+PAXdkA7TTX0MTZD4Hb8pn3POtMryB0P4qmbITki9lkc+yYe'
      'n3VS2Derx8KxVitsk/XvGP475TLMAnppMhdXcp6vBGunIwBt/YeXUioldbYGKZHahRoqs3rZb'
      '+PvUKDb/xoFCaYhaEpDQ3lZ6PBvtzbWEy8am3O983P77bJlCmfNe12mEmd/oN5XJyHiQ0pH'
      'nXkMj46MffnDUQPh/HuDq1ctaxgRcAbpbS9W8siZr3ddPm5DfTC+pv7Y/nCpLusSJutUQez'
      'lNb7lcM9faTVhZhh8c9DmhZ0HB0jFKc0EtOpapimT8ZSn0MPQykEG1NR/xxUKPEZ8EuC/E8'
      'Dkx3ZxunMvdQFqhEoWyyc1tYCBoLFDUmbQeQ2otU6v41g+T+yO71DaYUkyDmWWeKzDxGSiY'
      'XRj+o3jpaYhK9Ojix5eJYVmONtScA15qj6jrv7GctQoBJ3CVlEUdS0DWG5nGeMAbHhtdP9X'
      '14v7m37LpJsh+vRde+UknYO9UziAp01fViFIZsQQ5U++BL29Wxa62HgjRNR4d5SBElBMIaB'
      't7rprZ9i/zuPWrkjHrMY4Utn6I9syvLVXxPQS5OjUkbTVJ3AxYItq0G6kMn09S9k4VGFiVb'
      'y4ZTewbEI3n6CUVXJzabHZSH8PvMZ7ZkZ0rRoivT8A225b8Sl8+035Qmk9Iu1ZwPPG+oJeT'
      'PIaXF1BUtl2cFUug/p+INmSjZccjTV2e2kYvTDhGJKLxgaCjQ4xGW8l14vESwNTFaxIU1XC'
      'q2k4XoylpZj9o1k6dB1Q4OkA0OMMw/aBfq+wPwgDBJmF2EpJ6sCzlJ0tgMCoDjn3viyEG5W'
      'y9Dxfo3+uYNxUsJuqGWxP77bOUvzs0zHdvFucIH/gBryq3QeTA2PU+xlLeXGVftiyvnVZza'
      '8+tjJXlS/kDMrDMQ0War';
}

// ---------------------------------------------------------------------------
// Feature Flags
// ---------------------------------------------------------------------------

/// Controls which SDK features are exposed in the demo app UI.
///
/// These defaults determine what is **enabled on first launch**.
/// Users can change them at runtime via the Settings screen
/// (persisted with [SharedPreferences]).
class SdkFeatureFlags {
  /// Whether the Green Book (South African old ID book) scanning feature is enabled.
  final bool enableGreenBook;

  /// Whether the South African Passport scanning feature is enabled.
  final bool enablePassport;

  /// Whether the South African ID Card scanning feature is enabled.
  final bool enableIdCard;

  /// Whether the Passive Liveness Detection feature is enabled.
  final bool enableLiveness;

  /// Whether the Facial Comparison feature is enabled.
  /// Note: This requires at least one liveness/identity scan to have
  /// produced a portrait image first.
  final bool enableFaceCompare;

  const SdkFeatureFlags({
    // Identity features off by default – enable in Settings to test
    this.enableGreenBook = false,
    this.enablePassport = false,
    this.enableIdCard = false,
    // Biometrics on by default
    this.enableLiveness = true,
    this.enableFaceCompare = true,
  });

  /// Creates a copy of this config with the specified fields replaced.
  SdkFeatureFlags copyWith({
    bool? enableGreenBook,
    bool? enablePassport,
    bool? enableIdCard,
    bool? enableLiveness,
    bool? enableFaceCompare,
  }) {
    return SdkFeatureFlags(
      enableGreenBook: enableGreenBook ?? this.enableGreenBook,
      enablePassport: enablePassport ?? this.enablePassport,
      enableIdCard: enableIdCard ?? this.enableIdCard,
      enableLiveness: enableLiveness ?? this.enableLiveness,
      enableFaceCompare: enableFaceCompare ?? this.enableFaceCompare,
    );
  }

  /// Converts feature flags to/from [SharedPreferences] keys.
  static const String _kGreenBook = 'feature_greenbook';
  static const String _kPassport = 'feature_passport';
  static const String _kIdCard = 'feature_idcard';
  static const String _kLiveness = 'feature_liveness';
  static const String _kFaceCompare = 'feature_facecompare';

  /// Serialises to a [Map] for persisting in [SharedPreferences].
  Map<String, bool> toMap() => {
        _kGreenBook: enableGreenBook,
        _kPassport: enablePassport,
        _kIdCard: enableIdCard,
        _kLiveness: enableLiveness,
        _kFaceCompare: enableFaceCompare,
      };

  /// Deserialises from a [Map] loaded from [SharedPreferences].
  factory SdkFeatureFlags.fromMap(Map<String, bool> map) => SdkFeatureFlags(
        enableGreenBook: map[_kGreenBook] ?? false,
        enablePassport: map[_kPassport] ?? false,
        enableIdCard: map[_kIdCard] ?? false,
        enableLiveness: map[_kLiveness] ?? true,
        enableFaceCompare: map[_kFaceCompare] ?? true,
      );
}
