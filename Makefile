FILE_SIZE_LIMIT_MB = 100
#LARGE_FILES := $(shell find ./gds -type f -name "*.gds")
LARGE_FILES += $(shell find . -type f -size +$(FILE_SIZE_LIMIT_MB)M -not -path "./.git/*")

LARGE_FILES_XZ := $(addsuffix .xz, $(LARGE_FILES))

ARCHIVES := $(shell find . -type f -name "*.xz")
ARCHIVE_SOURCES := $(basename $(ARCHIVES))

$(LARGE_FILES_XZ): %.xz: %
	@if ! [ $(suffix $<) == ".xz" ]; then\
		xz -6 --threads=$(shell nproc) $< > /dev/null &&\
		echo "$< -> $@";\
	fi


# This target compresses all files larger than $(FILE_SIZE_LIMIT_MB) MB
.PHONY: compress
compress: $(LARGE_FILES_XZ)
	@echo "Files larger than $(FILE_SIZE_LIMIT_MB) MBytes are compressed!"


$(ARCHIVE_SOURCES): %: %.xz
	@xz --decompress $< &&\
	echo "$< -> $@";\


.PHONY: uncompress
uncompress: $(ARCHIVE_SOURCES)
	@echo "All files are uncompressed!"