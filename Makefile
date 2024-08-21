# .PHONY: gen genAll rebuild check get localize runDev runDevQa runDevStaging lines release apk

rerun:
	flutter clean
	flutter packages pub get
	flutter run

run:
	flutter run

release:
	flutter build apk --release --no-tree-shake-icons
