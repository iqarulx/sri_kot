# .PHONY: gen rebuild check get localize runDev runDevQa runDevStaging lines release apk

rerun:
	flutter clean
	flutter packages pub get
	flutter run

debug:
	flutter run --debug

release:
	flutter run --release

release_build:
	flutter build apk --release --no-tree-shake-icons
