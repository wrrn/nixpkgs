{ texlive }:
texlive.withPackages (ps: [
  ps.everyshi
  ps.pdfbook2
  ps.pdfcrop
  ps.pdftex
  ps.pdfpages
  ps.geometry
  ps.pdfjam
  ps.latex
  ps.latex-bin
  ps.epstopdf-pkg
  ps.pdflscape
  # ps.eso-pic
  # ps.atbegshi
  # ps.pgf
  # ps.xcolor
  # ps.hyperref
  # ps.tools
  # ps.graphics
  # ps.graphics-def
  ps.etoolbox
])
