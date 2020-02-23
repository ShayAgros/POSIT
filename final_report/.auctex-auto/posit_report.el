(TeX-add-style-hook
 "posit_report"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "10pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=1.2in")))
   (add-to-list 'LaTeX-verbatim-environments-local "VerbatimOut")
   (add-to-list 'LaTeX-verbatim-environments-local "SaveVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "Verb*")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "Verb")
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "geometry"
    "graphicx"
    "amsmath"
    "fancyvrb")
   (LaTeX-add-labels
    "sec:introduction"
    "sec:floatingpoints"
    "eq:1"
    "fig:ieee754"
    "sec:floatscaveats"
    "sec:accuracyproblem"
    "sec:gran-range-probl"
    "prec_value"
    "sec:wast-repr"
    "sec:posit"
    "sec:relatedwork"
    "sec:rationalnumbers"
    "sec:increasefloat"))
 :latex)

