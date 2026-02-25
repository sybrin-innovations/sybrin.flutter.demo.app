package com.demo.bioid_flutter

/**
 * Centralised SDK license key configuration for the BioID Flutter Android layer.
 *
 * Keys sourced from .env/android_development_keys.txt (Android development environment).
 */
object SDKConfig {

    /**
     * License key for the Sybrin **Identity SDK**.
     * Used to initialise [SybrinIdentity] in [MainActivity].
     */
    const val IDENTITY_KEY =
        "bRdpOKxSHF9GHxn5agAfIDyDlTseRz6sYNe2ckFsn4JuL9Fw1GXlG11jzhJcBw2zPY6kjokqAkiLeW7+wcRz" +
        "XUoNhzBzfCnyF4mz7yy4Gb1DUNaNOX0k4OZm8Cj1TaydltQdfyobp5aQyrBJXdind+VDlH2x+AbPspA8W7qM" +
        "fSPxsYc78yJVNP5t0pMI4x/5So9rJyenavKuY9uOGrRUwSStdMhC6uPqFcwBglsvl4cbp17g+Bm6dSj6GeT5" +
        "c45Dr/alvGcILGa3mZtU9QRT/AW2CLUQakSVE783ScuONz0k40VjkGEaBARHDyZ0/pLwLhSQJSkrlhXfsVJMy" +
        "HXPn5eoPC+LAsE3tFbvWpl5PwhYrj8eH5FU0I67l9oMfnWxJ4mbw0JGY5gi3txxsSqojLui/3FSDEUVTgdxJh" +
        "cjAMsGDaU+kfC1xKbEO69nhF3UiZ53rqN9cYqntbr52iAeOAUaVIneudeYUkCaDxKgfWqzJ45LL7Rx32a5haS" +
        "zHN5Wzg01cLw38CfJ3k6LK4WGr4FYvPziVY87AxuxGWcPq4VgO5nC41FlbafepivrlSe4FKVboM838v1TXjYB" +
        "H3ykAjlWqK4sa1rULc6YdCEnvYmeJ+RxBxfd0q/Ij9fCiWXiQZPi4S3LlURHPXRgpVQ4n27ZDuEmZFyMbmlt" +
        "M4Go9F3fkq3ypYr5t3p4uayw9+U1hU03u2sQ7Ndz4aJd6BSWlPG0VCHT2HWyGmOWeG+leTkVR5BCxnmX3vV4" +
        "Qwl5btiVMsFyP3wiZCriD0R4GWs7RwLJ4g/mvxVtSEi5PUotFTPPqQqNeoLHf/D3+qN2UwEsSjuUQ1t9O2kR" +
        "6DU+9vT6V4Pc9FimqX2z8mEIMLTZHhCXg/758x4jEfvFjZazgs6q3GHVW2kQQSR2MyTm58S2Bphm9bJ25yNV" +
        "i6OSmPndZhAUl/AGn6hUBVr7DdevYxToXLNCWWCqCJ4kG+6TX/P19YUcMG74/LxVC7ufN46UmUQ="

    /**
     * License key for the Sybrin **Biometrics SDK** (liveness + facial comparison).
     * Used to initialise both [SybrinLivenessDetection] and [SybrinFacialComparison].
     */
    const val BIOMETRICS_KEY =
        "bRdpOKxSHF9GHxn5agAfIDyDlTseRz6sYNe2ckFsn4JuL9Fw1GXlG11jzhJcBw2zPY6kjokqAkiLeW7+wcRz" +
        "XUoNhzBzfCnyF4mz7yy4Gb1DUNaNOX0k4OZm8Cj1TaydltQdfyobp5aQyrBJXdind+VDlH2x+AbPspA8W7qM" +
        "fSPxsYc78yJVNP5t0pMI4x/5So9rJyenavKuY9uOGrRUwSStdMhC6uPqFcwBglsvl4cbp17g+Bm6dSj6GeT5" +
        "c45Dr/alvGcILGa3mZtU9QRT/AW2CLUQakSVE783ScuONz0k40VjkGEaBARHDyZ0/pLwLhSQJSkrlhXfsVJMy" +
        "HXPn5eoPC+LAsE3tFbvWpl5PwhYrj8eH5FU0I67l9oMfnWxJ4mbw0JGY5gi3txxsSqojLui/3FSDEUVTgdxJh" +
        "cjAMsGDaU+kfC1xKbEO69nhF3UiZ53rqN9cYqntbr52iAeOAUaVIneudeYUkCaDxKgfWqzJ45LL7Rx32a5haS" +
        "zHN5Wzg01cLw38CfJ3k6LK4WGr4FYvPziVY87AxuxGWcPq4VgO5nC41FlbafepivrlSe4FKVboM838v1TXjYB" +
        "H3ykAjlWqK4sa1rULc6YdCEnvYmeJ+RxBxfd0q/Ij9fCiWXiQZPi4S3LlURHPXRgpVQ4n27ZDuEmZFyMbmlt" +
        "M4Go9F3fkq3ypYr5t3p4uayw9+U1hU03u2sQ7Ndz4aJd6BSWlPG0VCHT2HWyGmOWeG+leTkVR5BCxnmX3vV4" +
        "Qwl5btiVMsFyP3wiZCriD0R4GWs7RwLJ4g/mvxVtSEi5PUotFTPPqQqNeoLHf/D3+qN2UwEsPACgYzcrOEaIV" +
        "y98v6ajGTcG02+yXvOUt88w6jJQEexJHaYmgpVjIF1ZV7CibjdGsnQns+D6RVhxukyi5XBCwyPU6StiXDQyVw" +
        "MlE5w2YWCI+/0VG/E9RSxg8AIVekx/WUzPMIQ8hHatSvQd7PZaZW+xxnP7w2LOL7oRZDzahqfFfmKaigHLoh" +
        "xH7Lfjbn5WdICNp+aB/fnw7LPoYG1fpQ=="
}
