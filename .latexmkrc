# Use platex and dvipdfmx for Japanese LaTeX
$latex = 'platex %O %S';
$dvipdf = 'dvipdfmx %O -o %D %S';
$pdf_mode = 5;  # Use platex + dvipdfmx
$pdflatex = 'internal';  # Disable pdflatex
$xelatex = 'internal';  # Disable xelatex
$lualatex = 'internal';  # Disable lualatex
$postscript_mode = 0;
$dvi_mode = 0;

