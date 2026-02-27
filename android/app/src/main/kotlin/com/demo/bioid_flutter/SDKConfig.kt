package com.demo.bioid_flutter

/**
 * Centralised SDK license key configuration for the BioID Flutter Android layer.
 *
 * Keys sourced from .env/android_development_keys.txt (Android development environment).
 */
object SDKConfig {

    /**
     * License key for the Sybrin **Identity SDK**. Used to initialise [SybrinIdentity] in
     * [MainActivity].
     */
    const val IDENTITY_KEY =
            "bRdpOKxSHF9GHxn5agAfINftl2Ai6noDR65470W3Ch3DQ2KIgHzLORKVHIk9osH0KZTaz0csxeJh0cMY/oj9nlfk6AETOFEWYNpjpImIKEq99gRtyvDE6wR8a0ZNElLZGHSG0elM3qhjVCvwyZ56h4FiyAvK3z1IyZyhK674Atjvi/asyHLJGFtA6MQ++6ojyitdvi0bsei1Wr1AoboO4hAic55BVMYFynZJLAS/WVoT+YCCivdGti48D/fI+XoAbIRGCzlZUC6V4IkkInkatbs7ZPK8naxFhRjxbZv5DcnGHrAQsO8U0mrDTTpe8bL8OtcB2PvL9VgxqfKM7OEPWtZ42Hnr+7TWwszckJAN9+u6fMqp/Tnhk9udhbmuXC6ShSg8X0vCgzB/dz91kUBYpgpRHnBRE0JyxvKbHyjoyhXZ3y3pLWVTGZTRxeOKFLMYdzfbg1+FgAun6bjYnTnTUsQ2FCHMjTwCYcC138QSlXhV26varT2kfIhPiz2kSCp9A6/5YA1fiK+AjAvs3bK0EcPfBO8mXyuOU+oioDfz1ol6MZ6JSv0/E3NTc9getAMRn3tZFabzWaA+BJMVQdC/xSSTTb8TiALcPJk1ngIkWa5iIJs3/txT9gJpMFr92P3t2DJR9x6U6liQqqxbjkifxSbv7XJOdEssJBauK7P6ftVyiazrwZFZnBsLqwn3LnuIOi21AelJlh8sEjYdGnuulS90ay61mWFF2kuLNDVNWl4PTlkVmvktVrpNYoZuSDhjxhu85nvlgQvZVAKaqawFfpSioWXtbDsJsZ/JXPzbqSvIXrD9PLar++TUgKhdfXZO3zG/PJ3oAD+LrY3yFGDs7GQ2QGKesrkfo5K7sZbRAf7d4HF/R6Zqmq1avHULCjXENHD5kf8eMcLrZfbMwvK5b/ifXdGH4hIEmlUfne3UT4inl4MGeTkRFUL5E/95B9Qu8fg135xDn+DTshBKDlLxfhZs93xp7QYL0cydEeySLQw="
    /**
     * License key for the Sybrin **Biometrics SDK** (liveness + facial comparison). Used to
     * initialise both [SybrinLivenessDetection] and [SybrinFacialComparison].
     */
    const val BIOMETRICS_KEY =
            "bRdpOKxSHF9GHxn5agAfINftl2Ai6noDR65470W3Ch3DQ2KIgHzLORKVHIk9osH0/0j7+E+fI/TPzhYBqMoW4RO5K4hiQzlu4iWCUXpWR0ein398opsS3vZmhiwXumgkMLTS9dmmp6q4gf8P5TS0ZXBYH88G0vHLWwFAUCOfu9Bl6h9ZXdRhQN2dC2lYXLrT+1TwxfZYYnc0ax7qitS3+iqPIMU2raXxqbSe8hbM2oCGhOSAdYeHy0DMP/+x6ZwsLV1S68YUrGvnHdA58TAPBwGWMHyrkq5cxgVYqbYUz1hoyvWCBBC6+XC02wcy7cu1kscUpqO7jrgM4ca/HSLK5IPhYkiG0Sn5s8w7wXsHlg3pT+OLYhSaaPrWMNTE73eKfKa9ePUlCV7ADMyPJkus/9B3weYeGKdk1Nr3pU4q+6ibmBUmnyOJgNsop+EcnAZRWF//Z+MSERJf8kw4ZPferEh+zfexeStT0JMoaupSRxW3TSPSagQPJD+uOn6O9AwG1qu/MouoeoqxoaNd3UMl8fWzbRpH0z7zwDxihotKEXZAdMQYLcK4Uig16oPOCPiVBPJh1Migntehan/ePF82PQMvRorAmr56GsKNgIB9Je+QRLGmpkx/O+3qroxtgwIKVwTaQXRUeqORPeVYEbq6BwiJ3cWkFurMgY5kHjfL5gbHc1VRmytu+eJ0/hA/E3/59Cv2lNhB5PzI9a0CiMWjv4bAqyaQ+NrSRN2oE6hOLnf7K/pc3NHkOnqZUgBz9q3fbHQvhJmOj0bWvcB9vYZlFLd35GlDL5x8fgxRDVJ0fR11mKCDUo3f7YuAdU4PdD50f6zhTshSjcLKoyp+sXf+s3cr5SnVAO8MwZH6amlo2XEnh13X5Qpc/3H5eTzCTKvueRdrVngBvRbxkBtBc7XPI116nrFLMg5wj2hKhzwS6RiFdINvFI+Q9MmKjgLqqmgFWyxUnvvAxai/gD3M6QF/FWWbs9Ogt8qyb22o9YOyoisGMTJI/MAg/BFIuc7LFR59MvS37lnW9U+rEVIK3JD7w5fvShLjUxNjAVwCo5wKTs4="
}
