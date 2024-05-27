# OceanSea

## Release

Binary compiled for use with macOS can be found at the [**n3xB | Fatcrab**](https://n3xb.io/fatcrab.html) page.

## Tested Public Nostr Relays

As of May 27th 2024, the following public & free Nostr relays seems to work fine with the OceanSea app

* wss://nostr.roundrockbitcoiners.com
* wss://nostr.vulpem.com 
* wss://nostr.cercatrova.me
* wss://nostr.swiss-enigma.ch
* wss://nostr.cheeserobot.org

## Tested Signet Faucet

As of May 27th 2024, Signet coins can be received from [https://signetfaucet.com/](https://signetfaucet.com/)

## Dependency

To compile this Xcode project, the Fatcrab Trade Engine Library and the associated FFI is needed. This can be created by placing the OceanSea folder and the [*fatcrab-trading-ffi*](https://github.com/nobu-maeda/fatcrab-trading-ffi) project folders side by side, and then running ./build.sh from the [*fatcrab-trading-ffi*](https://github.com/nobu-maeda/fatcrab-trading-ffi) project.