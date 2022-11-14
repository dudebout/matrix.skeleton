# Create a tarball to upload on CTAN
#
# $(build_dir) is a staging area that can be easily cleaned. $(tar_dir) contains
# the subset of files that should be in the actual tarball.

tar_dir = matrix-skeleton
build_dir = build
version = 1.1

tar_content = README.md LICENSE
tar_content += example.tex example.pdf
tar_content += matrix.skeleton.tex matrix.skeleton.pdf
tar_content += pgflibrarymatrix.skeleton.code.tex tikzlibrarymatrix.skeleton.code.tex

tarball = $(tar_dir).tgz

pdflatex = pdflatex -output-dir $(build_dir) -halt-on-error

all: test $(tarball)

test: $(build_dir)/regression-tests.pdf

install: $(tarball)
	install -d $(PREFIX)
	install -m 644 $< $(PREFIX)

$(tarball): $(tar_content:%=$(tar_dir)/%)
	tar -czf $@ $(tar_dir)

$(build_dir):
	mkdir -p $(build_dir)

$(build_dir)/matrix.skeleton.tex: manual.tex $(build_dir)
	cp $< $@

$(build_dir)/matrix.skeleton.pdf: $(build_dir)/manual.pdf $(build_dir)
	cp $< $@

$(build_dir)/%.code.tex: %.code.tex $(build_dir)
	echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' > $@
	echo '% matrix.skeleton, version $(version)' >> $@
	echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' >> $@
	echo '' >> $@
	cat $< >> $@

$(build_dir)/%: % $(build_dir)
	cp $< $@

$(tar_dir):
	mkdir -p $(tar_dir)

$(tar_dir)/%: $(build_dir)/% $(tar_dir)
	mv $< $@

# Add author and license information to the README to satisfy CTAN's
# requirements. Additionally, replace links to files on the web with their
# equivalent inside the tarball.
$(build_dir)/README.md: README.md $(build_dir)
	cp $< $@
	echo '' >> $@
	echo 'Author: Nicolas Dudebout' >> $@
	echo 'License: ISC' >> $@
	echo 'Version: $(version)' >> $@
	sed -i 's#https://.*/\([^/]\+\)#\1#g' $@
	sed -i 's/matrix.skeleton-manual.pdf/manual.pdf/' $@
	sed -i 's/example.png/example.pdf/' $@


# Run pdflatex twice to get cross-references right.
$(build_dir)/%.pdf: %.tex $(build_dir)
	$(pdflatex) '\newcommand\versionnumber{$(version)} \input{$<}'
	$(pdflatex) '\newcommand\versionnumber{$(version)} \input{$<}'

clean:
	rm -f $(tarball) result
	rm -rf $(build_dir) $(tar_dir)
