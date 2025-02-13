MDTOOL=./tools/mdtool
XBUILD=xbuild
NS=MonoDevelop
N=WebSharper
# Version: First 3 numbers are the current WebSharper version,
# last digit is a revision number for the addin itself.
VER=3.5.14.0
NAME=$(NS).$(N)
PKG=repository/$(NAME)_$(VER).mpack
ADDIN_XML=MonoDevelop.WebSharper/$(NAME).addin.xml
CONF=Release
DLL=MonoDevelop.WebSharper/bin/$(CONF)/$(NAME).dll

.PHONY: main restore clean cleanall install uninstall release

main: $(PKG)

$(PKG): $(DLL)
	$(MDTOOL) --help # must be run at least once before doing `mdtool setup ...` \
	                 # (seemingly an mdtool bug)
	$(MDTOOL) setup pack $(DLL)
	mv *.mpack repository/

$(DLL): $(NAME) restore
	sed s/PACKAGEVERSION/$(VER)/g $(ADDIN_XML).template > $(ADDIN_XML)
	$(XBUILD) /p:Configuration=$(CONF)

install: $(PKG)
	$(MDTOOL) setup install -y $(PKG)

uninstall:
	$(MDTOOL) setup uninstall -y $(NAME)

clean:
	$(XBUILD) /p:Configuration=$(CONF) /target:Clean
	rm -rf $(PKG)
	rm -f $(ADDIN_XML)

cleanall: clean
	rm -rf packages/

packages:
	mono tools/NuGet.exe install FSharp.Compiler.Tools -o packages -excludeVersion -version 3.1.2.2
	mono tools/NuGet.exe install WebSharper.Templates -o packages -excludeVersion -prerelease

restore: packages

release: $(PKG)
	$(MDTOOL) setup rep-build repository/
