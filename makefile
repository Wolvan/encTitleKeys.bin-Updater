NAME = "$(OUTFILE_NAME)"
DESCRIPTION = "$(OUTFILE_NAME) for freeShop"
AUTHOR = "MatMaf & Wolvan"

ASSET_DIR = assets
BUILDTOOLS_DIR = buildtools
BUILD_DIR = build
TMP_DIR = $(BUILD_DIR)/tmp
SRC_DIR = script
OUTFILE_NAME = encTitleKeysUpdater

build: all
clean: makedirectories
init: clean
production: tar
dist: tar

tar: all
	mkdir "$(TMP_DIR)/tar"
	mkdir "$(TMP_DIR)/tar/3ds"
	cp -r "$(BUILD_DIR)/$(OUTFILE_NAME)" "$(TMP_DIR)/tar/3ds"
	cp "$(BUILD_DIR)/$(OUTFILE_NAME).cia" "$(TMP_DIR)/tar/$(OUTFILE_NAME).cia"
	cp "$(BUILD_DIR)/$(OUTFILE_NAME).3ds" "$(TMP_DIR)/tar/$(OUTFILE_NAME).3ds"
	tar cf "$(BUILD_DIR)/$(OUTFILE_NAME).tar" -C "$(TMP_DIR)/tar" . --xform='s!^\./!!'
	tar --delete --file="$(BUILD_DIR)/$(OUTFILE_NAME).tar" .
	rm -rf "$(TMP_DIR)/tar"

makedirectories: cleanfiles
	@echo Making build directory structure
	mkdir $(BUILD_DIR)
	mkdir $(TMP_DIR)
cleanfiles:
	@echo Cleaning up previous builds
	rm -rf $(BUILD_DIR)
	
banner: $(ASSET_DIR)/audio.wav $(ASSET_DIR)/banner.png $(ASSET_DIR)/icon.png
	@echo Making banner
	$(BUILDTOOLS_DIR)/bannertool makebanner -i "$(ASSET_DIR)/banner.png" -a "$(ASSET_DIR)/audio.wav" -o "$(TMP_DIR)/banner.bin"
	$(BUILDTOOLS_DIR)/bannertool makesmdh -i "$(ASSET_DIR)/icon.png" -s $(NAME) -l $(DESCRIPTION) -p $(AUTHOR) -o "$(TMP_DIR)/icon.bin"
romfs:
	@echo Making romfs
	$(BUILDTOOLS_DIR)/3dstool -cvtf romfs "$(TMP_DIR)/romfs.bin" --romfs-dir "$(SRC_DIR)"

all: clean 3ds cia 3dsxpack
	@echo Cleaning up temp files
	rm -rf "$(TMP_DIR)"
	mkdir $(TMP_DIR)
3ds: banner romfs
	@echo Building .3ds
	$(BUILDTOOLS_DIR)/makerom -f cci -o "$(BUILD_DIR)/$(OUTFILE_NAME).3ds" -rsf "$(BUILDTOOLS_DIR)/workarounds/3ds_workaround.rsf" -target d -exefslogo -elf "$(BUILDTOOLS_DIR)/lpp3ds/lpp-3ds.elf" -icon "$(TMP_DIR)/icon.bin" -banner "$(TMP_DIR)/banner.bin" -romfs "$(TMP_DIR)/romfs.bin"
cia: banner romfs
	@echo Building .cia
	$(BUILDTOOLS_DIR)/makerom -f cia -o "$(BUILD_DIR)/$(OUTFILE_NAME).cia" -elf "$(BUILDTOOLS_DIR)/lpp3ds/lpp-3ds.elf" -rsf "$(BUILDTOOLS_DIR)/workarounds/cia_workaround.rsf" -icon "$(TMP_DIR)/icon.bin" -banner "$(TMP_DIR)/banner.bin" -exefslogo -target t -romfs "$(TMP_DIR)/romfs.bin"
3dsx: banner romfs
	@echo Building .3dsx
	rm -rf $(BUILD_DIR)/$(OUTFILE_NAME)
	cp -r "$(SRC_DIR)" "$(BUILD_DIR)/$(OUTFILE_NAME)"
	cp "$(TMP_DIR)/icon.bin" "$(BUILD_DIR)/$(OUTFILE_NAME)/$(OUTFILE_NAME).smdh"
	cp "$(BUILDTOOLS_DIR)/lpp3ds/lpp-3ds.3dsx" "$(BUILD_DIR)/$(OUTFILE_NAME)/$(OUTFILE_NAME).3dsx"
3dsxpack: 3dsx
	mkdir "$(TMP_DIR)/3ds"
	cp -r "$(BUILD_DIR)/$(OUTFILE_NAME)" "$(TMP_DIR)/3ds"
	tar cf "$(BUILD_DIR)/$(OUTFILE_NAME).3dsx.tar" -C "$(TMP_DIR)" 3ds
	rm -rf "$(TMP_DIR)/3ds"
