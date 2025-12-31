%%
%% Copyright (c) 2014 Shin'ya Ueoka <ibenza@i-beam.org>
%%

\NeedsTeXFormat{pLaTeX2e}
\ProvidesClass{jletteraddress}

\LoadClass[]{article}

\usepackage{plext}
\usepackage{xstring}
\usepackage{adjustbox}
\ifx\kanjiskip\undefined\else
  \usepackage{atbegshi}
  \ifx\ucs\undefined
    \ifnum 42146=\euc"A4A2
      \AtBeginShipoutFirst{\special{pdf:tounicode EUC-UCS2}}
    \else
      \AtBeginShipoutFirst{\special{pdf:tounicode 90ms-RKSJ-UCS2}}
    \fi
  \else
    \AtBeginShipoutFirst{\special{pdf:tounicode UTF8-UCS2}}
  \fi
  \usepackage[dvipdfmx]{hyperref}

  %% PDF string definitions for renmei commands (to avoid hyperref warnings)
  %% These provide safe text-only versions for PDF bookmarks and metadata
  \pdfstringdefDisableCommands{%
    \def\renmeitwo#1#2#3#4#5#6{#1 #2 #3 #4 #5 #6}%
    \def\renmeithree#1#2#3#4#5#6#7#8#9{#1 #2 #3 #4 #5 #6 #7 #8 #9}%
    \def\renmeitwowithspace#1#2#3#4#5{#1 #2 #3 #4 #5}%
    \def\renmeithreewithspace#1#2#3#4#5#6#7{#1 #2 #3 #4 #5 #6 #7}%
    \def\renmeifour#1#2#3#4#5#6#7#8#9{#1 #2 #3 #4 #5 #6 #7 #8 #9}%
  }

  %% Set a paper size for dvipdfmx
  \special{papersize=100truemm,148truemm}
\fi

%% Layouts
\setlength{\hoffset}{-1truein}
\setlength{\voffset}{-1truein}
\setlength{\oddsidemargin}{0pt}
\setlength{\evensidemargin}{0pt}
\setlength{\topmargin}{0pt}
\setlength{\topmargin}{0pt}
\setlength{\headheight}{0pt}
\setlength{\headsep}{0pt}
\setlength{\paperwidth}{100truemm}
\setlength{\paperheight}{148truemm}

\setlength{\tabcolsep}{0pt}
\setlength\tabbingsep{0pt}
\setlength{\unitlength}{1truemm} %

%% Temporary boxes for renmei display
\newbox\@renmei@tempbox
\newbox\@tempboxb
\newbox\@tempboxc
\newbox\@tempboxd
\newbox\@tempboxe
  \newdimen\@tempdimb
  \newdimen\@tempdimc
  \newdimen\@renmei@nameheight
  \newdimen\@renmei@totalheight
% Define empty macro for checking empty strings
\def\@renmei@empty{}


%% Sender macros
\def\sendername#1{\gdef\@sendername{#1}\gdef\@sendernamecmd{#1}}
\def\senderpostcode#1{\gdef\@senderpostcode{#1}}
\def\senderaddressa#1{\gdef\@senderaddressa{#1}}
\def\senderaddressb#1{\gdef\@senderaddressb{#1}}

%% Renmei command for multiple names (連名用コマンド)
%% Usage: \renmeitwo{surname1}{given_name1}{honorific1}{surname2}{given_name2}{honorific2}
%%        \renmeithree{surname1}{given_name1}{honorific1}{surname2}{given_name2}{honorific2}{surname3}{given_name3}{honorific3}
%%        \renmeifour{surname1}{given_name1}{honorific1}{surname2}{given_name2}{honorific2}{surname3}{given_name3}{honorific3}{surname4}{given_name4}{honorific4}
%% Each name is displayed vertically and aligned horizontally
%% Surname can be empty for names without surname

%% Define \renmeitwo for 2 names
\long\def\renmeitwo#1#2#3#4#5#6{%
  \@renmei@displaytwo{#1}{#2}{#3}{#4}{#5}{#6}%
}

%% Define \renmeithree for 3 names
\long\def\renmeithree#1#2#3#4#5#6#7#8#9{%
  \@renmei@displaythree{#1}{#2}{#3}{#4}{#5}{#6}{#7}{#8}{#9}%
}

%% Define \renmeifour for 4 names
%% Due to LaTeX's 9-parameter limit, we use a different structure:
%% \renmeifour{surname}{name1}{honorific1}{name2}{honorific2}{name3}{honorific3}{name4}{honorific4}
%% All names share the same surname (first parameter)
\long\def\renmeifour#1#2#3#4#5#6#7#8#9{%
  % All names share the same surname (#1)
  \@renmei@displayfour{#1}{#2}{#3}{#4}{#5}{#6}{#7}{#8}{#9}%
}

%% Define \renmeitwowithspace for 2 names when second name has no surname
%% Usage: \renmeitwowithspace{surname}{first_name}{first_honorific}{second_name}{second_honorific}
\long\def\renmeitwowithspace#1#2#3#4#5{%
  \@renmei@displaytwowithspace{#1}{#2}{#3}{#4}{#5}%
}

%% Define \renmeithreewithspace for 3 names when second name has no surname
%% Usage: \renmeithreewithspace{surname}{first_name}{first_honorific}{second_name}{second_honorific}{third_name}{third_honorific}
\long\def\renmeithreewithspace#1#2#3#4#5#6#7{%
  \@renmei@displaythreewithspace{#1}{#2}{#3}{#4}{#5}{#6}{#7}%
}

%% Define \renmeithreewithspace2 for 3 names when third name has no surname
%% Usage: \renmeithreewithspace2{surname2}{given_name2}{honorific2}{given_name3}{honorific3}{surname1}{given_name1}{honorific1}
%% Third name (left) has no surname, uses second name's surname
\long\def\renmeithreewithspace2#1#2#3#4#5#6#7#8{%
  \@renmei@displaythreewithspace2{#1}{#2}{#3}{#4}{#5}{#6}{#7}{#8}%
}

%% Define \renmeithreewithspaceboth for 3 names when both second and third names have no surname
%% Usage: \renmeithreewithspaceboth{surname1}{given_name2}{honorific2}{given_name3}{honorific3}{given_name1}{honorific1}
%% Both second and third names (left and middle) have no surname, use first name's surname
\long\def\renmeithreewithspaceboth#1#2#3#4#5#6#7{%
  \@renmei@displaythreewithspaceboth{#1}{#2}{#3}{#4}{#5}{#6}{#7}%
}

%% Display single name with vertical alignment
%% All names should have the same height for proper alignment
%% Name is displayed first, then honorific below it
%% #1: surname (can be empty)
%% #2: given name
%% #3: honorific
%% Improved version: Better alignment with height measurement
\def\@renmei@displayname#1#2#3{%
  % Display in vertical writing mode with proper alignment
  \vbox{%
    \hbox{%
      \parbox<t>[b]{10zw}{%
        \fontsize{27pt}{0pt}\selectfont
        % Display surname, given name, and honorific
        % If surname is empty, it will be empty string and won't display
        #1%
        \hskip1zw
        #2%
        \hskip1zw
        #3%
      }%
    }%
  }%
}

%% Display name with surname space above (for names without surname)
%% #1: full name (surname + given name) to match height, or just surname width
%% #2: given name
%% #3: honorific
%% Improved version: Better alignment with other columns
\def\@renmei@displaynamewithspace#1#2#3{%
  \vbox{%
    \hbox{%
      % Measure the full name to get its width (which becomes height in vertical writing)
      \setbox\@tempboxa=\hbox{\fontsize{27pt}{0pt}\selectfont #1}%
      % Add space matching the full name width at the top
      % Then display the given name and honorific below the space
      % Put space, name, and honorific in the same parbox to ensure vertical alignment
      \vbox{%
        \hbox{%
          \parbox<t>[b]{10zw}{%
            \fontsize{27pt}{0pt}\selectfont
            % Create space matching full name width at the top
            % In vertical writing, \hskip creates vertical spacing
            % \wd\@tempboxa is the width of the full name, which becomes height in vertical writing
            \hskip\wd\@tempboxa
            % Display the given name and honorific below the space
            #2%
            \hskip1zw
            #3%
          }%
        }%
      }%
    }%
  }%
}

%% Display two names
%% All columns should be aligned at the top (name part)
%% #1: surname1, #2: given_name1, #3: honorific1
%% #4: surname2, #5: given_name2, #6: honorific2
\def\@renmei@displaytwo#1#2#3#4#5#6{%
  % Measure height of name part (surname + given name, without honorific) for first column
  \setbox\@tempboxa=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #2%
    }%
  }%
  % Measure height of name part (surname + given name, without honorific) for second column
  \setbox\@tempboxb=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #4%
      \hskip1zw
      #5%
    }%
  }%
  % Display both columns
  % Use wider parbox to prevent name from wrapping to multiple columns
  \hbox{%
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #2%
      \hskip1zw
      #3%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #4%
      \hskip1zw
      #5%
      \hskip1zw
      #6%
    }%
  }%
}

%% Display two names with space for second name (when second name has no surname)
%% Left name (second) has no surname, right name (first) has surname
%% #1: surname from right name (first name)
%% #2: second name (given name only, displayed on left)
%% #3: second honorific
%% #4: first name given name (displayed on right)
%% #5: first honorific
\def\@renmei@displaytwowithspace#1#2#3#4#5{%
  % Measure height of name part for left column (given name only, no surname)
  \setbox\@tempboxa=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #2%
    }%
  }%
  % Measure height of name part for right column (surname + given name)
  % This is the first person's name (surname + given name), which will be the reference height
  \setbox\@tempboxb=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #4%
    }%
  }%
  % Display both columns
  % Use wider parbox to prevent name from wrapping to multiple columns
  \hbox{%
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      % Measure the surname width (which becomes height in vertical writing)
      \setbox\@tempboxe=\hbox{\fontsize{27pt}{0pt}\selectfont #1}%
      % Add space matching the surname width plus the gap between surname and given name (1zw)
      \hskip\wd\@tempboxe
      \hskip1zw
      % Display the given name
      #2%
      \hskip1zw
      #3%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #4%
      \hskip1zw
      #5%
    }%
  }%
}

%% Display three names
%% All columns should be aligned at the top (name part)
%% #1: surname1, #2: given_name1, #3: honorific1
%% #4: surname2, #5: given_name2, #6: honorific2
%% #7: surname3, #8: given_name3, #9: honorific3
\def\@renmei@displaythree#1#2#3#4#5#6#7#8#9{%
  % Measure height of name part (surname + given name, without honorific) for each column
  \setbox\@tempboxa=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #2%
    }%
  }%
  \setbox\@tempboxb=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #4%
      \hskip1zw
      #5%
    }%
  }%
  \setbox\@renmei@tempbox=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #7%
      \hskip1zw
      #8%
    }%
  }%
  % Display all columns
  % Use wider parbox to prevent name from wrapping to multiple columns
  \hbox{%
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #2%
      \hskip1zw
      #3%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #4%
      \hskip1zw
      #5%
      \hskip1zw
      #6%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #7%
      \hskip1zw
      #8%
      \hskip1zw
      #9%
    }%
  }%
}

%% Display three names with space for first name (when first name has no surname)
%% Left name (first) has no surname, middle and right names have surname
%% #1: surname from right name (third name)
%% #2: first name (given name only, displayed on left)
%% #3: first honorific
%% #4: second name given name (displayed in middle)
%% #5: second honorific
%% #6: third name given name (displayed on right)
%% #7: third honorific
\def\@renmei@displaythreewithspace#1#2#3#4#5#6#7{%
  % Measure height of name part (given name only, without honorific) for left column
  \setbox\@tempboxa=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #2%
    }%
  }%
  % Measure height of name part (surname + given name, without honorific) for middle column
  % This is the first person's name (surname + given name), which will be the reference height
  \setbox\@tempboxb=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #4%
    }%
  }%
  % Measure height of name part (surname + given name, without honorific) for right column
  \setbox\@renmei@tempbox=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #6%
    }%
  }%
  % Measure the surname width (which becomes height in vertical writing) for left column spacing
  \setbox\@renmei@tempbox=\hbox{\fontsize{27pt}{0pt}\selectfont #1}%
  % Display all columns
  \vbox{%
    \hbox{%
      % Left column: name part (aligned to right column's surname top)
      % Use wider parbox to prevent name from wrapping to multiple columns
      \vbox{%
        \hbox{%
          \parbox<t>[t]{30zw}{%
            \fontsize{27pt}{0pt}\selectfont
            \noindent
            % Add space matching the surname width plus the gap between surname and given name (1zw)
            \hskip\wd\@renmei@tempbox
            \hskip1zw
            % Display the given name
            #2%
            \hskip1zw
            #3%
          }%
        }%
      }%
      \hskip1.5truemm
      % Middle column: surname + name part (top aligned to match left name top)
      % Use wider parbox to prevent name from wrapping to multiple columns
      \vbox{%
        \hbox{%
          \parbox<t>[t]{30zw}{%
            \fontsize{27pt}{0pt}\selectfont
            \noindent
            #1%
            \hskip1zw
            #4%
            \hskip1zw
            #5%
          }%
        }%
      }%
      \hskip1.5truemm
      % Right column: surname + name part (top aligned to match left name top)
      % Use wider parbox to prevent name from wrapping to multiple columns
      \vbox{%
        \hbox{%
          \parbox<t>[t]{30zw}{%
            \fontsize{27pt}{0pt}\selectfont
            \noindent
            #1%
            \hskip1zw
            #6%
            \hskip1zw
            #7%
          }%
        }%
      }%
    }%
  }%
}

%% Display three names with space for third name (when third name has no surname)
%% Left name (third) has no surname, middle and right names have surname
%% #1: surname from second name (middle)
%% #2: second name given name (displayed in middle)
%% #3: second honorific
%% #4: third name (given name only, displayed on left)
%% #5: third honorific
%% #6: first name surname (displayed on right)
%% #7: first name given name (displayed on right)
%% #8: first honorific
\def\@renmei@displaythreewithspace2#1#2#3#4#5#6#7#8{%
  % Measure height of name part (given name only, without honorific) for left column
  \setbox\@tempboxa=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #4%
    }%
  }%
  % Measure height of name part (surname + given name, without honorific) for middle column
  \setbox\@tempboxb=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #2%
    }%
  }%
  % Measure height of name part (surname + given name, without honorific) for right column
  \setbox\@tempboxc=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #6%
      \hskip1zw
      #7%
    }%
  }%
  % Measure the surname width (which becomes height in vertical writing) for left column spacing
  \setbox\@renmei@tempbox=\hbox{\fontsize{27pt}{0pt}\selectfont #1}%
  % Display all columns
  % Use wider parbox to prevent name from wrapping to multiple columns
  \hbox{%
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      % Measure the surname width (which becomes height in vertical writing)
      \setbox\@tempboxd=\hbox{\fontsize{27pt}{0pt}\selectfont #1}%
      % Add space matching the surname width plus the gap between surname and given name (1zw)
      \hskip\wd\@tempboxd
      \hskip1zw
      % Display the given name
      #4%
      \hskip1zw
      #5%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #2%
      \hskip1zw
      #3%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #6%
      \hskip1zw
      #7%
      \hskip1zw
      #8%
    }%
  }%
}

%% Display three names with space for both second and third names (when both have no surname)
%% Left name (third) and middle name (second) have no surname, right name has surname
%% #1: surname from first name (right)
%% #2: second name (given name only, displayed in middle)
%% #3: second honorific
%% #4: third name (given name only, displayed on left)
%% #5: third honorific
%% #6: first name given name (displayed on right)
%% #7: first honorific
\def\@renmei@displaythreewithspaceboth#1#2#3#4#5#6#7{%
  % Measure height of name part (given name only, without honorific) for left column
  \setbox\@tempboxa=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #4%
    }%
  }%
  % Measure height of name part (given name only, without honorific) for middle column
  \setbox\@tempboxb=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #2%
    }%
  }%
  % Measure height of name part (surname + given name, without honorific) for right column
  \setbox\@tempboxc=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #6%
    }%
  }%
  % Display all columns
  % Use wider parbox to prevent name from wrapping to multiple columns
  \hbox{%
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      % Measure the surname width (which becomes height in vertical writing)
      \setbox\@tempboxd=\hbox{\fontsize{27pt}{0pt}\selectfont #1}%
      % Add space matching the surname width plus the gap between surname and given name (1zw)
      \hskip\wd\@tempboxd
      \hskip1zw
      % Display the given name
      #4%
      \hskip1zw
      #5%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      % Measure the surname width (which becomes height in vertical writing)
      \setbox\@tempboxd=\hbox{\fontsize{27pt}{0pt}\selectfont #1}%
      % Add space matching the surname width plus the gap between surname and given name (1zw)
      \hskip\wd\@tempboxd
      \hskip1zw
      % Display the given name
      #2%
      \hskip1zw
      #3%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #6%
      \hskip1zw
      #7%
    }%
  }%
}

%% Display four names
%% All columns should be aligned at the top (name part)
%% #1: surname (shared by all), #2: given_name1, #3: honorific1
%% #4: given_name2, #5: honorific2, #6: given_name3, #7: honorific3
%% #8: given_name4, #9: honorific4
%% Note: Due to LaTeX's 9-parameter limit, all names share the same surname
\def\@renmei@displayfour#1#2#3#4#5#6#7#8#9{%
  % Measure height of name part (surname + given name, without honorific) for each column
  \setbox\@tempboxa=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #2%
    }%
  }%
  \setbox\@tempboxb=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #4%
    }%
  }%
  \setbox\@renmei@tempbox=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #6%
    }%
  }%
  \setbox\@tempboxc=\hbox{%
    \parbox<t>[t]{10zw}{%
      \fontsize{27pt}{0pt}\selectfont
      #1%
      \hskip1zw
      #8%
    }%
  }%
  % Display all columns
  % Use wider parbox to prevent name from wrapping to multiple columns
  \hbox{%
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #2%
      \hskip1zw
      #3%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #4%
      \hskip1zw
      #5%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #6%
      \hskip1zw
      #7%
    }%
    \hskip1.5truemm
    \parbox<t>[t]{30zw}{%
      \fontsize{27pt}{0pt}\selectfont
      \noindent
      #1%
      \hskip1zw
      #8%
      \hskip1zw
      #9%
    }%
  }%
}

%% Make a address-side
\newcommand{\addaddress}[5] {
  % #1 : Receiver name
  % #2 : Receiver name suffix
  % #3 : Receiver postcode
  % #4 : Receiver address 1
  % #5 : Receiver address 2
  \clearpage
  \refstepcounter{section}
  \addcontentsline{toc}{section}{#1}
  \noindent %
  % Process renmei outside of picture environment if needed
  % Check if #2 (honorific) is empty - if so, it's a renmei case
  \def\renmei@temp{#2}%
  \def\renmei@empty{}%
  \ifx\renmei@temp\renmei@empty
    % Renmei case - process \renmei outside of picture environment
    % Store the command for later use
    \def\renmei@tempcmd{#1}%
    % Now expand it in a box to measure its size
    % Use \vbox for vertical writing mode
    \setbox\@tempboxa=\vbox{%
      \hbox{%
        \kanjiskip=.3zw\fontsize{27pt}{0pt}\selectfont%
        \renmei@tempcmd%
      }%
    }%
    \global\setbox\@tempboxa=\box\@tempboxa
    \global\def\renmei@tempcmd{#1}%
  \fi
  \begin{picture}(100,148)(0,0)%
    \put(43,136){ %
      \vtop to 8truemm{\vfil\hbox{\fontsize{15pt}{0pt}\selectfont%
        \hbox to 7truemm{\hfil\StrChar{#3}{1}\hfil}%
        \hbox to 7truemm{\hfil\StrChar{#3}{2}\hfil}%
        \hbox to 7truemm{\hfil\StrChar{#3}{3}\hfil}\hskip0.4truemm
        \hbox to 6.8truemm{\hfil\StrChar{#3}{4}\hfil}%
        \hbox to 6.8truemm{\hfil\StrChar{#3}{5}\hfil}%
        \hbox to 6.8truemm{\hfil\StrChar{#3}{6}\hfil}%
        \hbox to 6.8truemm{\hfil\StrChar{#3}{7}\hfil}%
    }\vfil}}
    \put(83,120){\fontsize{15pt}{0pt}\selectfont%
        \parbox<t>[t]{90truemm}{#4}}
    \put(75,120){\fontsize{15pt}{0pt}\selectfont%
        \parbox<t>[t]{90truemm}{\hfil#5}}
    \ifx\renmei@temp\renmei@empty
      % Renmei case - use pre-processed command
      % In vertical writing mode, box height becomes displayed width
      % Check if box height (displayed width) exceeds 90mm, if so use adjustbox
      % Each name is already wrapped in \parbox<t>[t], so they have the same anchor point as single name
      \@tempdima=\ht\@tempboxa
      % Calculate x position to center renmei names
      % Estimate number of names based on total width
      % Each name is about 10zw wide, plus 1.5truemm spacing between names
      % Two names: ~20zw + 1.5truemm ≈ 25zw
      % Three names: ~30zw + 3truemm ≈ 35zw
      % Four names: ~40zw + 4.5truemm ≈ 45zw
      \@tempdimb=50truemm
      % Estimate: if width is less than ~30zw, it's likely 2 names
      % If width is less than ~40zw, it's likely 3 names
      % Otherwise, it's 4 or more names
      \@tempdimc=30zw
      \ifdim\@tempdima<\@tempdimc
        % Two names: center the whole renmei at x=50mm, then shift left
        % x = 50mm - (width / 2) - 5mm (shift left)
        \@tempdimc=\@tempdima
        \divide\@tempdimc by 2
        \advance\@tempdimb by -\@tempdimc
        \advance\@tempdimb by -5truemm
      \else
        \@tempdimc=40zw
        \ifdim\@tempdima<\@tempdimc
          % Three names: center the middle name at x=50mm, then shift left
          % Left name + spacing = 10zw + 1.5truemm
          % Middle name center offset = (10zw + 1.5truemm) + (10zw / 2) = 15zw + 1.5truemm
          \@tempdimc=15zw
          \advance\@tempdimc by 1.5truemm
          \advance\@tempdimb by -\@tempdimc
          \advance\@tempdimb by -5truemm
        \else
          % Four or more names: center the whole renmei at x=50mm, then shift left
          \@tempdimc=\@tempdima
          \divide\@tempdimc by 2
          \advance\@tempdimb by -\@tempdimc
          \advance\@tempdimb by -5truemm
        \fi
      \fi
      % y position: shift down by 10mm
      \@tempdimc=120truemm
      \advance\@tempdimc by -10truemm
      \ifdim\@tempdima>90truemm
        % Width exceeds limit, use adjustbox to scale down
        \put(\@tempdimb,\@tempdimc){\kanjiskip=.3zw\fontsize{27pt}{0pt}\selectfont%
          \adjustbox{max width=90mm}{\renmei@tempcmd}%
        }%
      \else
        % No scaling needed, display at calculated position
        \put(\@tempdimb,\@tempdimc){\kanjiskip=.3zw\fontsize{27pt}{0pt}\selectfont%
          \renmei@tempcmd%
        }%
      \fi
    \else
      % Single name case
      % Position at original location (50mm from left)
      \put(50,120){\kanjiskip=.3zw\fontsize{27pt}{0pt}\selectfont%
        \parbox<t>[t]{90truemm}{\hfil#1\hskip1zw#2\hfil}%
      }%
    \fi
    \put(25,85){\fontsize{12pt}{0pt}\selectfont%
        \parbox<t>[t]{55truemm}{\@senderaddressa}}
    \put(19,85){\fontsize{12pt}{0pt}\selectfont%
        \parbox<t>[t]{55truemm}{\@senderaddressb}}
    % Check if sender name is renmei command by checking if it starts with \renmei
    % We check if the first token of @sendernamecmd is a renmei command
    \def\sender@isrenmei{0}%
    % Check if @sendernamecmd is empty first
    \def\sender@empty{}%
    \ifx\@sendernamecmd\sender@empty
      % Empty sender name - skip renmei check
    \else
      \begingroup
        % Extract the first token of @sendernamecmd and check if it's a renmei command
        \def\sender@checkrenmei##1##2\@nil{%
          \def\sender@firsttoken{##1}%
          \def\sender@renmeitwo{\renmeitwo}%
          \def\sender@renmeitwowithspace{\renmeitwowithspace}%
          \def\sender@renmeithree{\renmeithree}%
          \def\sender@renmeithreewithspace{\renmeithreewithspace}%
          \def\sender@renmeithreewithspace2{\renmeithreewithspace2}%
          \def\sender@renmeithreewithspaceboth{\renmeithreewithspaceboth}%
          \def\sender@renmeifour{\renmeifour}%
          \ifx\sender@firsttoken\sender@renmeitwo\gdef\sender@isrenmei{1}\fi
          \ifx\sender@firsttoken\sender@renmeitwowithspace\gdef\sender@isrenmei{1}\fi
          \ifx\sender@firsttoken\sender@renmeithree\gdef\sender@isrenmei{1}\fi
          \ifx\sender@firsttoken\sender@renmeithreewithspace\gdef\sender@isrenmei{1}\fi
          \ifx\sender@firsttoken\sender@renmeithreewithspace2\gdef\sender@isrenmei{1}\fi
          \ifx\sender@firsttoken\sender@renmeithreewithspaceboth\gdef\sender@isrenmei{1}\fi
          \ifx\sender@firsttoken\sender@renmeifour\gdef\sender@isrenmei{1}\fi
        }%
        \expandafter\sender@checkrenmei\@sendernamecmd\@nil
      \endgroup
    \fi
    \ifnum\sender@isrenmei=1
      % Renmei case for sender - process similar to recipient but scaled to 15pt
      % Store the command for later use
      \def\sender@renmei@tempcmd{\@sendernamecmd}%
      % Renmei commands are designed for 27pt (recipient), but sender uses 15pt
      % First measure at original 27pt size
      \setbox\@tempboxa=\vbox{%
        \hbox{%
          \kanjiskip=.3zw\fontsize{27pt}{0pt}\selectfont%
          \sender@renmei@tempcmd%
        }%
      }%
      \global\setbox\@tempboxa=\box\@tempboxa
      \global\def\sender@renmei@tempcmd{\@sendernamecmd}%
      % Calculate scaled width (27pt to 15pt scale factor: 15/27 ≈ 0.556)
      \@tempdima=\ht\@tempboxa
      \@tempdima=0.556\@tempdima
      % Calculate x position: position more to the left to avoid overlap with address
      % Position at 5mm from left edge to ensure no overlap with address2 (19mm)
      \@tempdimb=5truemm
      % Check if scaled width exceeds available space (55mm)
      % Use same y position as single name (85mm) and align at top
      \ifdim\@tempdima>55truemm
        % Width exceeds limit, use adjustbox to scale down further
        \put(\@tempdimb,85){\kanjiskip=0.3zw\fontsize{15pt}{0pt}\selectfont%
          \adjustbox{max width=55mm,scale=0.556,valign=t}{\sender@renmei@tempcmd}%
        }%
      \else
        % Scale the renmei command from 27pt to 15pt using adjustbox
        \put(\@tempdimb,85){\kanjiskip=0.3zw\fontsize{15pt}{0pt}\selectfont%
          \adjustbox{scale=0.556,valign=t}{\sender@renmei@tempcmd}%
        }%
      \fi
    \else
      % Single name case for sender
      % Position: center between left edge (0mm) and address left edge (19mm) = 9.5mm
      \put(9.5,85){\kanjiskip=0.3zw\fontsize{15pt}{0pt}\selectfont%
        \parbox<t>[t]{55truemm}{\hfil\@sendername}\hfil}
    \fi
    \put(4.5,25){ %
      \vtop to 6.5truemm{\vfil\hbox{\fontsize{12pt}{0pt}\selectfont%
        \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{1}\hfil}%
        \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{2}\hfil}%
        \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{3}\hfil}\hskip1truemm %
        \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{4}\hfil}%
        \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{5}\hfil}%
        \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{6}\hfil}%
        \hbox to 4truemm{\hfil\StrChar{\@senderpostcode}{7}\hfil}%
    }\vfil}}
  \end{picture} %
}
