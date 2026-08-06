##------------------------------------------------------------------------------
## Loads libraries

library(tidyverse)
library(stringr)

##------------------------------------------------------------------------------
## Loads data 

d = read.table("questionnaire.txt", sep = "\t", header = T)
n = dim(d)[1]

##------------------------------------------------------------------------------
## Extracts questions that are kept, by category 

# stores the questions that are kept into a list by category
list_q_ord = list() # ord
list_q_cat = list() # cat
list_q_cont = list() # cont
i_list_ord = 1
i_list_cat = 1
i_list_cont = 1
for (i in 1:n) {
  if (d[i, "to_keep"] == 1) {
    if ((d[i, "question_category"] == "ord")) {
      list_q_ord[[i_list_ord]] = str_c("\\textbf{", 
                                       toString(d[i, "question_num"]), 
                               "}. ", d[i, "question"])
      i_list_ord = i_list_ord + 1
    } else if (d[i, "question_category"] == "cat") {
      list_q_cat[[i_list_cat]] = str_c("\\textbf{", 
                                       toString(d[i, "question_num"]), 
                                   "}. ", d[i, "question"])
      i_list_cat = i_list_cat + 1
    } else if ((d[i, "question_category"] == "cont")) {
      list_q_cont[[i_list_cont]] = str_c("\\textbf{", 
                                         toString(d[i, "question_num"]), 
                                   "}. ", d[i, "question"])
      i_list_cont = i_list_cont + 1
    }
  }
}

# combines the questions into a single string by category
str_ord = ""
n_list_ord = length(list_q_ord)
for (i in 1:n_list_ord) {
  cur_q = list_q_ord[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
     str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_ord)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_ord = str_c(str_ord, cur_q)
}
str_cat = ""
n_list_cat = length(list_q_cat)
for (i in 1:n_list_cat) {
  cur_q = list_q_cat[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_cat)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_cat = str_c(str_cat, cur_q)
}
str_cont = ""
n_list_cont = length(list_q_cont)
for (i in 1:n_list_cont) {
  cur_q = list_q_cont[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_cont)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_cont = str_c(str_cont, cur_q)
}

# combines the strings from the three categories into one 
str_to_keep = str_c("\\tableofcontents\\section{Questions kept}", 
                    "\\subsection{Ordinal}", str_ord, 
                    "\\subsection{Categorical}", str_cat, 
                    "\\subsection{Continuous}", 
                    "We would like to get your feelings toward some of our 
                    political leaders and other people who are in the news 
                    these days. We will show the name of a person and we’d 
                    like you to rate that person using something we call the 
                    feeling thermometer. Ratings between 50 degrees and 100 
                    degrees mean that you feel favorable and warm toward the 
                    person. Ratings between 0 degrees and 50 degrees mean that 
                    you don’t feel favorable toward the person and that you 
                    don’t care too much for that person. You would rate the 
                    person at the 50 degree mark if you don’t feel particularly 
                    warm or cold toward the person. If we come to a person 
                    whose name you don’t recognize, you don’t need to rate 
                    that person. Just click ’Next’ and we’ll move on to the 
                    next one.\\\\",  str_cont)

# saves the strings 
write.table(str_to_keep, file = "questions_kept.txt", row.names = F, 
            col.names = F, quote = F)

##------------------------------------------------------------------------------
## Extracts questions that are removed, by category 

# stores the questions that are removed into a list by category
list_q_SA = list() # short_answer
list_q_FU = list() # followup
list_q_D = list() # depends
list_q_RS = list() # rand_subset
list_q_LI = list() # labels_indirect
list_q_I = list() # identity

i_list_SA = 1
i_list_FU = 1
i_list_D = 1
i_list_RS = 1
i_list_LI = 1
i_list_I = 1
for (i in 1:n) {
  if (d[i, "to_keep"] == 0) {
    if (d[i, "question_category"] == "short_answer") {
      list_q_SA[[i_list_SA]] = str_c("\\textbf{", 
                                       toString(d[i, "question_num"]), 
                                       "}. ", d[i, "question"])
      i_list_SA = i_list_SA + 1
    } else if (d[i, "question_category"] == "followup") {
      list_q_FU[[i_list_FU]] = str_c("\\textbf{", 
                                       toString(d[i, "question_num"]), 
                                       "}. ", d[i, "question"])
      i_list_FU = i_list_FU + 1
    } else if (d[i, "question_category"] == "depends") {
      list_q_D[[i_list_D]] = str_c("\\textbf{", 
                                         toString(d[i, "question_num"]), 
                                         "}. ", d[i, "question"])
      i_list_D = i_list_D + 1
    } else if (d[i, "question_category"] == "rand_subset") {
      list_q_RS[[i_list_RS]] = str_c("\\textbf{", 
                                   toString(d[i, "question_num"]), 
                                   "}. ", d[i, "question"])
      i_list_RS = i_list_RS + 1
    } else if (d[i, "question_category"] == "labels_indirect") {
      list_q_LI[[i_list_LI]] = str_c("\\textbf{", 
                                     toString(d[i, "question_num"]), 
                                     "}. ", d[i, "question"])
      i_list_LI = i_list_LI + 1
    } else if (d[i, "question_category"] == "identity") {
      list_q_I[[i_list_I]] = str_c("\\textbf{", 
                                     toString(d[i, "question_num"]), 
                                     "}. ", d[i, "question"])
      i_list_I = i_list_I + 1
    } 
  } 
}

# combines the questions into a single string by category
str_SA = ""
n_list_SA = length(list_q_SA)
for (i in 1:n_list_SA) {
  cur_q = list_q_SA[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_SA)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_SA = str_c(str_SA, cur_q)
}
str_FU = ""
n_list_FU = length(list_q_FU)
for (i in 1:n_list_FU) {
  cur_q = list_q_FU[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_FU)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_FU = str_c(str_FU, cur_q)
}
str_D = ""
n_list_D = length(list_q_D)
for (i in 1:n_list_D) {
  cur_q = list_q_D[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_D)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_D = str_c(str_D, cur_q)
}
str_RS = ""
n_list_RS = length(list_q_RS)
for (i in 1:n_list_RS) {
  cur_q = list_q_RS[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_RS)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_RS = str_c(str_RS, cur_q)
}
str_LI = ""
n_list_LI = length(list_q_LI)
for (i in 1:n_list_LI) {
  cur_q = list_q_LI[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_LI)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_LI = str_c(str_LI, cur_q)
}
str_I = ""
n_list_I = length(list_q_I)
for (i in 1:n_list_I) {
  cur_q = list_q_I[[i]]
  # Adds a line break 
  if(!(str_detect(cur_q, "end\\{enumerate\\}") | 
       str_detect(cur_q, "end\\{itemize\\}")) & (i != n_list_I)) {
    cur_q = str_c(cur_q, "\\\\")
  }
  str_I = str_c(str_I, cur_q)
}

# combines the strings from the three categories into one 
str_to_remove = str_c("\\tableofcontents\\section{Questions removed}", 
                    "\\subsection{Short-answer questions}", str_SA, 
                    "\\subsection{Follow-up to previous questions}", str_FU, 
                    "\\subsection{Dependent on previous questions}", str_D, 
                    "\\subsection{Questions asked to a random subset}", str_RS, 
                    "\\subsection{Questions that could contain label 
                    information}", str_LI, 
                    "\\subsection{Questions that are related to one's 
                    identity}", str_I)

# saves the strings 
write.table(str_to_remove, file = "questions_removed.txt", 
            row.names = F, 
            col.names = F, quote = F)

##------------------------------------------------------------------------------