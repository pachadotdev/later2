clean:
	@Rscript -e 'devtools::clean_dll(".");'

check:
	@$(MAKE) clean
	@Rscript -e 'devtools::check("./", error_on = "error")'

STANDARDS := cxx11 cxx14 cxx17 cxx20 cxx23
COMPILERS := gcc clang

define run-check
check-$(1)-$(2):
	@echo "Checking C++ code with $(1) standard and $(2) compiler"
	@$$(MAKE) install
	@if [ "$(2)" = "clang" ]; then export USE_CLANG=1; else unset USE_CLANG; fi; \
	./scripts/check_prepare.sh "$(1)" "$(2)"; \
	if ! ./scripts/check_run.sh "$(1)" "$(2)"; then \
		echo "Check failed"; \
		./scripts/check_restore.sh "$(1)" "$(2)"; \
		exit 1; \
	fi; \
	./scripts/check_restore.sh "$(1)" "$(2)"
endef

$(foreach std,$(STANDARDS),$(foreach comp,$(COMPILERS),$(eval $(call run-check,$(std),$(comp)))))
$(foreach std,$(STANDARDS),$(foreach comp,$(COMPILERS),$(eval $(call run-bench,$(std),$(comp)))))
$(foreach std,$(STANDARDS),$(eval check-$(std)-glang: check-$(std)-clang))
$(foreach std,$(STANDARDS),$(eval bench-$(std)-glang: bench-$(std)-clang))
$(foreach comp,$(COMPILERS) glang,$(eval check-cxx23-$(comp): check-cxx11-$(comp)))
$(foreach comp,$(COMPILERS) glang,$(eval bench-cxx23-$(comp): bench-cxx11-$(comp)))

clang_format=`which clang-format-21`

format: $(shell find . -name '*.h') $(shell find . -name '*.hpp') $(shell find . -name '*.cpp')
	@${clang_format} -i $?

build-r-devel:
	@echo "Building R-devel from source"
	./scripts/build_r_devel.sh

check-devel:
	@echo "Checking with R-devel (CXX23, gcc)"
	./scripts/check_r_devel.sh cxx23 gcc
