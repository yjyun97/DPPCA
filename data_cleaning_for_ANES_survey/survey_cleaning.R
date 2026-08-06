##------------------------------------------------------------------------------
## Loads libraries

library(tidyverse)
library(stringr)

##------------------------------------------------------------------------------
## Loads data 

# loads data from questionnaire.txt (information about questions)
d_q = read.table("questionnaire.txt", 
                 sep = "\t", header = T)
vec_c = d_q[, "question_category"] # extracts vector of categories
vec_v = d_q[, "variable_name"] # extracts vector of variable names
# loads data from survey_orig.csv (actual data available from the ANES website)
d = read.csv("survey_orig.csv")
print(paste0("There are ", dim(d)[1], " data points."))

##------------------------------------------------------------------------------
## 1. Removes data points with incomplete responses 

ind_complete = which(d["sample_type"] == "Weighted complete" | 
                       d["sample_type"] == "Unweighted complete")
d1 = d[ind_complete, ] 
print(paste0("There are ", dim(d1)[1], " complete data points."))

##------------------------------------------------------------------------------
## 2. Extracts labels

ind_l = which(vec_c == "labels")
d_l = d1[, vec_v[ind_l]]

n = dim(d_l)[1]
vec_l = rep(0, n)
for(i in 1:n) {
  if (d_l[i, 1] == "Democrat" | d_l[i, 2] == "Democrat") {
    vec_l[i] = "Democrat"
  } else if (d_l[i, 1] == "Republican" | d_l[i, 2] == "Republican") {
    vec_l[i] = "Republican"
  } else if (d_l[i, 1] == "Independent" | d_l[i, 2] == "Independent") {
    vec_l[i] = "Independent"
  } else {
    vec_l[i] = "Other"
  }
}
d_l = data.frame(
  IID = rownames(d1), 
  party = vec_l
)

##------------------------------------------------------------------------------
## 3. (1) Removes features that don't correspond to questions in the 
##        questionnaire
##    (2) Removes features corresponding to to_keep = 0 in quetionnaire.txt 
##        (includes labels)

# (1)
d2 = d1[, 8:274]
d2 = d2 %>% select(-all_of(c("tolnew", "tolold", "educ", "race", "hispanic")))
# (2)
vec_to_remove = vec_v[which(d_q[, "to_keep"] == 0)]
d2 = d2 %>% select(-all_of(vec_to_remove))

##------------------------------------------------------------------------------
## Creates vectors of feature names for continuous, categorical, and ordinal 
## variables 

# features to keep 
vec_ord = vec_v[which(vec_c == "ord")] # ordinal
vec_cat = vec_v[which(vec_c == "cat")] # categorical
vec_cont = vec_v[which(vec_c == "cont")] # continuous
# verifies that all features have been accounted for
vec_all = c(vec_ord, vec_cat, vec_cont)
print(c(setdiff(colnames(d2), vec_all), setdiff(vec_all, colnames(d2))))

##------------------------------------------------------------------------------
## 4. (1) Removes data points with "inapplicable, legitimate skip" or 
##        "No Answer" for ordinal and continuous features 
##    (2) Updates the vector of labels accordingly 

ind_complete = apply(d2, 1, 
                  function(x) {sum(x == "inapplicable, legitimate skip") == 0 &
                      sum(x == "No Answer") == 0})
d3 = d2[ind_complete, ]
print(paste0("There are ", sum(ind_complete == 0), " such data points."))
n = dim(d3)[1] # redefines n
d_l = d_l[ind_complete, ] # updates the vector of labels

##------------------------------------------------------------------------------
## 5. Converts continuous variables to numeric values 

d4 = d3 %>% 
  mutate(across(all_of(vec_cont), as.numeric))

##------------------------------------------------------------------------------
## 6. Converts ordinal variables to numeric values 

d5 = d4 %>% 
  mutate(secure_parents = 
           recode(secure_parents, 
                  "Easier than for my parents" = 1,
                  "About the same as my parents" = 2,
                  "Harder than for my parents" = 3))
d5 = d5 %>% 
  mutate(partic_vote = 
           recode(partic_vote, 
                  "Extremely important" = 1,
                  "Very important" = 2,
                  "Moderately important" = 3, 
                  "Slightly important" = 4, 
                  "Not at all important" = 5))
d5 = d5 %>% 
  mutate(partic_protest = 
           recode(partic_protest, 
                  "Approve very strongly"  = 1,
                  "Approve moderately"  = 2,
                  "Approve a little" = 3, 
                  "Neither approve nor disapprove" = 4, 
                  "Disapprove a little" = 5, 
                  "Disapprove moderately" = 6, 
                  "Disapprove very strongly" = 7))
key_imp = c("Extremely important" = 1, "Very important" = 2, 
            "Moderately important" = 3, "Slightly important" = 4, 
            "Not at all important" = 5)
d5 = d5 %>% 
  mutate(across(c(imp_immig, imp_jobs, imp_costliv, 
                  imp_climate, imp_abort, imp_gun, 
                  imp_crime, imp_gaza, imp_votright, 
                  imp_schteach, imp_antisem, imp_ukraine, 
                  imp_islamop), ~ recode(., !!!key_imp)))
d5 = d5 %>% 
  mutate(highered_bias = 
           recode(highered_bias, 
                  "Strong liberal bias" = 1, "Some liberal bias" = 2, 
                  "No political bias" = 3, "Some conservative bias" = 4, 
                  "Strong conservative bias" = 5))
d5 = d5 %>% 
  mutate(highered_approve = 
           recode(highered_approve, 
                  "Approve strongly" = 1, "Approve somewhat" = 2, 
                  "Neither approve nor disapprove" = 3, 
                  "Disapprove somewhat" = 4, "Disapprove strongly" = 5))
d5 = d5 %>% 
  mutate(police_safe = 
           recode(police_safe, 
                  "Mostly safe" = 1, "Somewhat safe" = 2, 
                  "Neither safe nor unsafe" = 3, "Somewhat unsafe" = 4, 
                  "Mostly unsafe" = 5))
d5 = d5 %>% 
  mutate(police_confid = 
           recode(police_confid, 
                  "A great deal" = 1, "A lot" = 2, 
                  "A moderate amount" = 3, "A little" = 4, 
                  "None at all" = 5))
d5 = d5 %>% 
  mutate(police_number = 
           recode(police_number, 
                  "Decreased a lot" = 1, "Decreased a little" = 2, 
                  "Kept about the same" = 3, "Increased a little" = 4, 
                  "Increased a lot" = 5))
d5 = d5 %>% 
  mutate(crime_selfplc = 
           recode(crime_selfplc, 
                  "1 Address the social problems that cause crime" = 1, 
                  "2" = 2, "3" = 3, "4" = 4, "5" = 5, "6" = 6, 
                  "7 Make sure criminals are caught, convicted, and punished" = 7))
key_treatcrime = c("Extremely serious" = 1, "Very serious" = 2, 
                   "Moderately serious" = 3, "Slightly serious" = 4,
                   "Not a crime" = 5)
d5 = d5 %>% 
  mutate(across(c(treatcrime_theft, treatcrime_marij, treatcrime_camp, 
                  treatcrime_abort, treatcrime_firearm), 
                ~ recode(., !!!key_treatcrime)))
d5 = d5 %>% 
  mutate(border_patrol = 
           recode(border_patrol, 
                  "Increased a lot" = 1, "Increased somewhat" = 2, 
                  "Kept the same" = 3, "Decreased somewhat" = 4, 
                  "Decreased a lot" = 5))
d5 = d5 %>% 
  mutate(border_milit = 
           recode(border_milit, 
                  "Strongly favor" = 1, "Somewhat favor" = 2, 
                  "Neither favor nor oppose" = 3, 
                  "Somewhat oppose" = 4, 
                  "Strongly oppose" = 5))
d5 = d5 %>% 
  mutate(border_legal = 
           recode(border_legal, 
                  "A lot easier" = 1, "Somewhat easier" = 2, 
                  "About the same" = 3, 
                  "Somewhat harder" = 4, 
                  "A lot harder" = 5))
key_aid= c("Strongly favor" = 1, "Somewhat favor" = 2, 
           "Neither favor nor oppose" = 3, "Somewhat oppose" = 4, 
           "Strongly oppose" = 5)
d5 = d5 %>% 
  mutate(across(c(aid_ukraine, aid_israel, aid_palest), 
                ~ recode(., !!!key_aid)))
d5 = d5 %>% 
  mutate(tol_freespeech = 
           recode(tol_freespeech, 
                  "Extremely" = 1, "Very" = 2, 
                  "Moderately" = 3, 
                  "Somewhat" = 4, 
                  "Not at all" = 5))
d5 = d5 %>% 
  mutate(felonserve_fedoff = 
           recode(felonserve_fedoff, 
                  "Favor" = 1, "Neither favor nor oppose" = 2, 
                  "Oppose" = 3))
d5 = d5 %>% 
  mutate(trans_health = 
           recode(trans_health, 
                  "Strongly favor" = 1, "Somewhat favor" = 2, 
                  "Neither favor nor oppose" = 3, 
                  "Somewhat oppose" = 4, 
                  "Strongly oppose" = 5))
key_trans = c("Strongly support" = 1, "Somewhat support" = 2, 
              "Neither support nor oppose" = 3, "Somewhat oppose" = 4, 
              "Strongly oppose" = 5)
d5 = d5 %>% 
  mutate(across(c(trans_sportgirl, trans_sportboy), 
                ~ recode(., !!!key_trans)))
key_raceadvt = c("More advantages" = 1, 
                 "About equal advantages and disadvantages" = 2, 
                 "More disadvantages" = 3)
d5 = d5 %>% 
  mutate(across(c(raceadvt_white, raceadvt_black, 
                  raceadvt_hispanic, raceadvt_asian), 
                ~ recode(., !!!key_raceadvt)))
key_resent = c("Agree strongly" = 1, "Agree somewhat" = 2, 
                  "Neither agree nor disagree" = 3, 
                  "Disagree somewhat" = 4, 
                  "Disagree strongly" = 5)
d5 = d5 %>% 
  mutate(across(c(resent_genertns, resent_workway, 
                  resent_deserve, resent_tryhard),
                ~ recode(., !!!key_resent)))
key_sexism = c("Agree strongly" = 1, 
               "Agree somewhat" = 2, 
               "Neither agree nor disagree" = 3, 
               "Disagree somewhat" = 4, 
               "Disagree strongly" = 5)
d5 = d5 %>% 
  mutate(across(c(sexism_bprotect, sexism_hinnoc, sexism_hpower, 
                  sexism_bdiff, sexism_bhetero), 
                ~ recode(., !!!key_sexism)))
key_empath = c("Describes me extremely well" = 1, 
               "Describes me very well" = 2, 
               "Describes me slightly well" = 3, 
               "Describes me moderately well" = 4, 
               "Does not describe me well at all" = 5)
d5 = d5 %>% 
  mutate(across(c(empath_concern, empath_perspect), 
                ~ recode(., !!!key_empath)))
key_school = c("A great deal" = 1, 
               "A lot" = 2, 
               "A moderate amount" = 3, 
               "A little" = 4, 
               "None at all" = 5)
d5 = d5 %>% 
  mutate(across(c(school_gender, school_racism), 
                ~ recode(., !!!key_school)))
d5 = d5 %>% 
  mutate(secular_reason = 
           recode(secular_reason, 
                  "Reason and evidence" = 1, 
                  "Both equally" = 2, 
                  "Religious beliefs" = 3))
key_prej = c("A great deal" = 1, "A lot" = 2, 
             "A moderate amount" = 3, "A little" = 4, "None at all" = 5)
d5 = d5 %>% 
  mutate(across(c(prej_muslims, prej_jews), ~ recode(., !!!key_prej)))
d5 = d5 %>% 
  mutate(empsat_paidoff = 
           recode(empsat_paidoff, 
                  "Much more than expected" = 1, 
                  "A little more than expected" = 2, 
                  "About as much as expected" = 3, 
                  "A little less than expected" = 4, 
                  "Much less than expected" = 5))
d5 = d5 %>% 
  mutate(abrtpre_abrtself = 
           recode(abrtpre_abrtself, 
                  "1 Abortion should always be permitted without restrictions" 
                  = 1, 
                  "2" = 2, 
                  "3" = 3, 
                  "4" = 4, 
                  "5" = 5, 
                  "6" = 6, 
                  "7 Abortion should never be permitted" = 7))

##------------------------------------------------------------------------------
## 7. Converts categorical features with two features to numeric
## and those with more than two features to Boolean encoding

vec_cat_two = NULL
vec_cat_many = NULL
for (i in 1:length(vec_cat)) {
  col_ = vec_cat[i]
  num_unique = length(unique(d5[, col_]))
  if (num_unique > 2) {
    vec_cat_many = c(vec_cat_many, col_)
  } else {
    vec_cat_two = c(vec_cat_two, col_)
  }
}

# converts categorical features with two features to numeric
d6 = d5 %>%
  mutate(across(all_of(vec_cat_two), ~ as.integer(.x == unique(.x)[1])))

# converts categorical features with more than two features to Boolean encoding
d7 = d6  
for (i in 1:length(vec_cat_many)) {
  col_ = vec_cat_many[i]
  d7 = d7 %>%
    mutate(val = rep(1, n))
  d7 = d7 %>%
    pivot_wider(
      names_from = col_, 
      values_from = "val", 
      values_fill = 0, 
      names_glue = paste0(col_, ".", "{", col_, "}")
    )
} 
print(paste0("There are ", dim(d7)[2], " features in total."))

##------------------------------------------------------------------------------
## Checks that the entries of the data frame are numeric

p = dim(d7)[2]
print(paste0("All columns are numeric: ", 
             sum(apply(d7, 2, is.numeric)) == p))
print(paste0("The dimension of the final dataset is (", n, ",", p, ")."))

##------------------------------------------------------------------------------
## Adds an IID column to keep track of the individuals

d7 = d7 %>% 
  mutate(IID = rownames(d7)) %>%
  relocate(IID)

##------------------------------------------------------------------------------
## Saves data

write.table(d7, file = "data/survey.txt", row.names = F, col.names = T)
write.table(d_l, file = "data/survey_labels.txt", row.names = F, 
            col.names = T)

##------------------------------------------------------------------------------