This folder contains scripts which produce the figures in the paper "High-Dimensional Asymptotics of Differentially Private PCA" (https://arxiv.org/abs/2511.07270) by Youngjoo Yun and Rishabh Dudeja. 

#### Figures

The names of the files correspond to the figures in the paper. R files (.R extension) run the respective experiments and save the results into a user-specified folder, and the MATLAB files (.m extension) use these results to produce the figures in the paper. All of the .R scripts were written by us, and parts of the .m scripts were written by ChatGPT. All figures but Figures 3 and 6 consist of one .R and one .m file each. 

- [Figure 3] Figure 3 requires running four .R files: **Figure3_empirical_samples.R**, **Figure3_empirical.R**, **Figure3_theoretical.R**, **Figure3_thresholds.R**. **Figure3_empirical_samples.R** samples from the exponential mechanism, which are then used in **Figure3_empirical.R** to generate the empirical values in the figure. Hence, the former should be run before the latter. **Figure3_theoretical.R** generates the theoretical values in the figure, and **Figure3_thresholds.R** generates the values at which the phase transitions occur and correspond to the vertical dotted lines in the figure. 
- [Figure 6] Figure 6 requires running three .R files (**Figure6_empirical_samples.R**, **Figure6_empirical.R**, **Figure6_theoretical.R**), and the dependence among the files are analogous to those of FIgure 3 above.

Note that we ran **Figure3_empirical_samples.R** and **Figure6_empirical_samples.R** on a cluster at the Center for High Throughput Computing [1]. Additionally, in Figures 1, 4, and 7, for purposes of visualizations, we apply Procrustes rotation to the matrix of sampled noisy eigenvectors to align it with its true counterpart. To do so, we use the R package **EFA.dimensions**. 

#### Functions

The .R files that run the experiments call functions from the file **functions.R**, which contains functions that sample from the Gibbs distribution (or the Exponential Mechanism), preprocesses the datset, computes estimation error, tradeoff functions, etc. Explanation for each function is included in the codes, along with relevant citations. In particular, for sampling from the Gibbs distribution, we use the R function **rbing.matrix.gibbs** from the R package **rstiefel**, written by Hoff [2]. 

#### Cleaning the ANES survey dataset

This section complements the description in Appendix H of the paper, which provides a description of the ANES survey dataset [3]. The questionnaire (pdf) and the responses (csv) can be downloaded from the website https://electionstudies.org/data-center/2024-pilot-study/. The folder **data_cleaning_for_ANES_survey** contains the files listed below:

- **questionnaire.txt**: We use the questionnaire from the website to manually create this file. It consists of each question from the questionnaire, along with the question number and associated variable name (which matches the one provided in the responses data), which we store in separate columns. Moreover, we add a column named **question_category**, where we record our manually assigned category. Examples of the categories include **followup** (to denote questions that depend on other quesitons), **identity** (questions asking about one's habits or demographic information), **cont** (shorthand for continuous variable), and **cat** (shorthand for categorical variable). The column **to_keep** consists of Boolean encoding indicating whether we include the question in the dataset or not. 
- **questionnaire.R**: This script reads in the file **questionnaire.txt** and produces two text files, which consists of lists of questions that we keep and remove (in separate files). The text files are in the LATEX format and can be copy-and-pasted to a LATEX renderer and compiled for readability. 
- **survey_cleaning.R**: This script reads in the file **questionnaire.txt** and produces the ANES survey dataset along with the corresponding labels. 

[1]. Center for High Throughput Computing. Center for high throughput computing, 2006. URL
https://chtc.cs.wisc.edu/.

[2] P. D. Hoff. Simulation of the matrix Bingham–von Mises–Fisher distribution, with applications to multivariate and relational data. Journal of Computational and Graphical Statistics, 18(2): 438–456, 2009.

[3] American National Election Studies. Anes 2024 pilot study. Dataset and documentation, 2024. URL https://electionstudies.org/data-bcenter/2024-bpilot-bstudy/. March 19, 2024 version. 