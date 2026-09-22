\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{gmcmthesis}[2026/09/22 GMCM paper class]
\RequirePackage{iftex}
\RequireXeTeX
\LoadClass[UTF8,a4paper,zihao=-4,fontset=none,scheme=plain,oneside]{ctexart}
\input{settings/packages.tex}
\input{settings/fonts.tex}
\input{settings/format.tex}

\makeatletter
\ExplSyntaxOn
\tl_new:N \g_gmcm_keywords_tl
\box_new:N \l_gmcm_toc_number_box
\box_new:N \l_gmcm_toc_page_box
\dim_new:N \l_gmcm_toc_number_dim
\int_new:N \l_gmcm_toc_level_int
\cs_set:Npn \toclevel@section {0}
\cs_set:Npn \toclevel@subsection {1}
\cs_set:Npn \toclevel@subsubsection {2}
\cs_set:Npn \toclevel@paragraph {3}
\cs_set:Npn \toclevel@subparagraph {4}
\cs_new_eq:NN \gmcm_unset_title: \@title
\AtBeginDocument
  {
    \hypersetup{pdfauthor={},pdfsubject={},pdfkeywords={}}
    \cs_if_eq:NNF \@title \gmcm_unset_title:
      { \hypersetup{pdftitle={\@title}} }
  }

\NewDocumentCommand \keywords { m }
  { \tl_gset:Nn \g_gmcm_keywords_tl {#1} }

\cs_new_protected:Npn \gmcm_label:n #1
  { { \normalfont \lishu \fontsize{18bp}{23.4bp}\selectfont #1 } }

\NewDocumentCommand \makecover { O{cover/cover.pdf} }
  {
    \clearpage
    \hypersetup{pageanchor=false}
    \includepdf[pages=1,pagecommand={\thispagestyle{empty}}]{#1}
    \clearpage
    \hypersetup{pageanchor=true}
  }

\RenewDocumentCommand \maketitle { }
  {
    \clearpage
    \pagenumbering{arabic}
    \pagestyle{plain}
    \pdfbookmark[0]{摘要}{abstract}
    \vspace*{8.475bp}
    \noindent
    \includegraphics[width=\textwidth]{cover/abstract-header.pdf}
    \par
    \vspace{38.316bp}
    \noindent
    \hbox_to_wd:nn { \textwidth }
      {
        \rlap{\gmcm_label:n{题\hspace{9bp}目：}}
        \hfil
        \parbox[t]{\dim_eval:n{\textwidth-140bp}}
          {
            \centering
            \normalfont\heiti\fontsize{16bp}{24bp}\selectfont
            \@title\par
          }
        \hfil
      }
    \par
    \vspace{46.8bp}
  }

\RenewDocumentEnvironment { abstract } { }
  {
    \par
    \noindent
    \makebox[\linewidth][c]{\gmcm_label:n{摘\hspace{9bp}要：}}
    \par
    \vspace{8bp}
    \normalfont\songti\normalsize
    \ignorespaces
  }
  {
    \par
    \addvspace{12bp}
    \group_begin:
    \hangindent=72bp
    \hangafter=1
    \noindent
    \gmcm_label:n{关键词：}
    \nobreak
    \tl_use:N \g_gmcm_keywords_tl
    \par
    \group_end:
    \clearpage
    \int_compare:nNnT {\value{page}} > {3}
      { \ClassWarning{gmcmthesis}{Abstract~exceeds~two~pages} }
  }

\cs_new_protected:Npn \gmcm_toc_measure:w \numberline #1#2\q_stop
  {
    \hbox_set:Nn \l_gmcm_toc_number_box {#1}
    \dim_set:Nn \l_gmcm_toc_number_dim
      { \box_wd:N \l_gmcm_toc_number_box }
    \int_compare:nNnT {\l_gmcm_toc_level_int} > {1}
      { \dim_add:Nn \l_gmcm_toc_number_dim {6bp} }
  }

\cs_new_protected:Npn \gmcm_toc_measure_link:w
  \Hy@toclinkstart #1\Hy@toclinkend\q_stop
  {
    \tl_if_head_eq_meaning:nNT {#1} \numberline
      { \gmcm_toc_measure:w #1\q_stop }
  }

\cs_new_protected:Npn \gmcm_toc_line:nnnn #1#2#3#4
  {
    \group_begin:
    \normalfont\songti\fontsize{10.5bp}{15.6bp}\selectfont
    \int_set:Nn \l_gmcm_toc_level_int {#1}
    \int_compare:nNnT {#1} = {1} {\heiti}
    \dim_zero:N \l_gmcm_toc_number_dim
    \tl_if_head_eq_meaning:nNTF {#3} \Hy@toclinkstart
      { \gmcm_toc_measure_link:w #3\q_stop }
      {
        \tl_if_head_eq_meaning:nNT {#3} \numberline
          { \gmcm_toc_measure:w #3\q_stop }
      }
    \cs_set_protected:Npn \numberline ##1
      { \hb@xt@\@tempdima{##1\hfil} }
    \hbox_set:Nn \l_gmcm_toc_page_box {\normalfont #4}
    \cs_set:Npx \@pnumwidth
      { \dim_eval:n {\box_wd:N \l_gmcm_toc_page_box + 2bp} }
    \@dottedtocline{#1}{#2}{\l_gmcm_toc_number_dim}{#3}{#4}
    \group_end:
  }

\RenewDocumentCommand \l@section { m m }
  { \gmcm_toc_line:nnnn {1}{0bp}{#1}{#2} }
\RenewDocumentCommand \l@subsection { m m }
  { \gmcm_toc_line:nnnn {2}{21bp}{#1}{#2} }
\RenewDocumentCommand \l@subsubsection { m m }
  { \gmcm_toc_line:nnnn {3}{42bp}{#1}{#2} }

\RenewDocumentCommand \tableofcontents { }
  {
    \clearpage
    \pdfbookmark[0]{目录}{contents}
    \section*{目录}
    \@starttoc{toc}
    \clearpage
  }

\RenewDocumentCommand \bibsection { } { \section{参考文献} }
\RenewDocumentCommand \appendix { } { \section{附录} }
\ExplSyntaxOff
\makeatother
\endinput
