rm(list=ls())
hablar::set_wd_to_script_path()

# 
library(tidyverse)
read_with_block <- function(file) {
  df <- read_csv(file)  
  block_num <- str_extract(basename(file), "\\d{3}|\\d{2}$")
  df <- df %>%
    mutate(block_number = block_num)
  return(df)
}

# load data
perp_numb <- '4MP'
data_path <- paste0("./Pilot_data/sub", perp_numb)
file_paths <- list.files(data_path, pattern = "mainblock", full.names = TRUE)
d <- map_dfr(file_paths, read_with_block)
d$block_number <- as.numeric(d$block_number)

# -------------------------------------------------------------------------
# estimate SDT parameters
# prepare for analysis
str(d)

d <- d %>% mutate(
  s = ifelse(Realface_response==80, 0, 1),
  r = ifelse(Realface_response==1 | Hallucination_response==1, 1, 0),
  conf = case_when(
    !(is.na(Realface_confidence)) & Realface_confidence<50 ~ Realface_confidence,
    !(is.na(Hallucination_confidence)) & Hallucination_confidence<50 ~ Hallucination_confidence,
    .default = NA)) %>%
  mutate(
    correct = ifelse(s==r,1,0)) %>%
  select(s,r,conf,correct)

# type-1 parameters
m_0 <- glm(r ~ s, family=binomial("probit"), data=d)
summary(m_0)
d_prime <- coef(m_0)["s"]
criterion <-  -coef(m_0)["(Intercept)"]

# -------------------------------------------------------------------------
# estimate type-2 parameters

# custom function using an approach similar to Fleming jags code or Maniscalco & Lau
fit_meta_d <- function(d, d_prime_type1) {
  # Subset to trials where r==1 (since conf is only available for r=1)
  d_yes <- subset(d, r == 1 & !is.na(conf))
  if(nrow(d_yes) == 0L) {
    stop("No trials with r == 1 found, cannot fit meta-d.")
  }
  
  # Identify the number of confidence levels used
  # e.g. if used levels are 1,2,3,4, we have K=4 categories => we need K-1=3 criteria
  conf_levels <- sort(unique(d_yes$conf))
  K <- length(conf_levels)
  
  # We'll map each confidence rating to an integer in 1..K
  # (in case conf_levels are something like c(1,3,5) we still want them coded 1..3)
  d_yes$conf_idx <- match(d_yes$conf, conf_levels)
  
  # Build negative log-likelihood function
  # param = c(meta_d, c1, c2, ..., c_{K-1})
  nll_fun <- function(param) {
    # param[1] = meta_d
    # param[2..(K)] = K-1 confidence criteria, in ascending order
    meta_d_est <- param[1]
    crits      <- param[2:length(param)]  # length = K-1
    
    # Impose an ordering constraint c1 < c2 < ... by manually sorting
    # or adding a penalty if they violate. A simple way is to define:
    crits_sorted <- sort(crits)
    
    # The negative log-likelihood:
    nll <- 0
    
    for(i in seq_len(nrow(d_yes))) {
      is_correct <- d_yes$correct[i]
      c_idx      <- d_yes$conf_idx[i]
      
      # mean of the relevant meta-distribution
      mean_i <- ifelse(is_correct == 1, meta_d_est, 0) 

      # boundaries for confidence c_idx:
      # c0 = -Inf, cK = +Inf
      lower_b <- if(c_idx == 1) -Inf else crits_sorted[c_idx - 1]
      upper_b <- if(c_idx == K) +Inf else crits_sorted[c_idx]
      
      # Probability mass in this interval:
      p_i <- pnorm(upper_b, mean = mean_i, sd = 1) - 
        pnorm(lower_b, mean = mean_i, sd = 1)
      
      # negative log-likelihood
      # add small constant to avoid log(0) overflow
      nll <- nll - log(p_i + 1e-12)
    }
    
    return(nll)
  }
  
  # As initial guess for meta-d', we can use the type-1 d' 
  init_meta_d <- d_prime_type1 
  
  # We have K-1 meta-criteria to guess. For instance, 
  # you could guess them evenly spaced around 0. 
  init_criteria <- seq(-1, 1, length.out = (K - 1))
  
  init_param <- c(init_meta_d, init_criteria)
  
  # finally ptimize the neg log-likelihood
  fit <- optim(
    par = init_param,
    fn  = nll_fun,
    method = "BFGS",
    control = list(maxit = 2000, reltol = 1e-8)
  )
  
  # best-fitting parameters
  best_par   <- fit$par
  meta_d_MLE <- best_par[1]
  crits_MLE  <- sort(best_par[2:length(best_par)])
  
  # results
  out <- list(
    meta_d     = meta_d_MLE,
    meta_d_ratio = meta_d_MLE / d_prime_type1,
    criteria   = crits_MLE,
    convergence = fit$convergence,
    LL   = - fit$value  # log-likelihood
  )
  return(out)
}

fit_meta_d(d, d_prime )

# -------------------------------------------------------------------------
# Alternative simpler approach!

# this is possible because we have confidence only for signal-present trials!
# since we are looking only at "yes" response trials, the presence of the signal 
# also determine the correctness of the response.
# Because of this we can fit an ordinal (cumulative) probit model for confidence 
# with s (signal-presence) as the predictor, and this is essentially the same as 
# modeling confidence with "correct vs. incorrect" as the predictor in a meta-d' 
# framework. The fitted slope for s in the ordinal probit model will map directly 
# onto the single-sided meta-d' value

# if 'conf' is numeric, you should convert it to an ordered factor:
d_yes <- subset(d, r == 1 & !is.na(conf))
d_yes$conf_factor <- factor(d_yes$conf, ordered = TRUE)

library(ordinal)  # for clm

# Fit an ordinal probit with 's' as the predictor
fit <- clm(conf_factor ~ s, data = d_yes, link = "probit")
summary(fit)

# this is equivalent to the meta-d' estimated above
fit$coefficients["s"]

# note that for participants that used only 2 rating levels this should be
# instead another probit GLM, as the above may give an error
# that is the below should be > 2
length(unique(d_yes$conf))
# if not the meta-d can be estimated as
d_yes$conf_2 <- ifelse(d_yes$conf==max(d_yes$conf),1,0)
fit <- glm(conf_2 ~ s, data = d_yes, family =binomial(link = "probit"))
summary(fit)
# then this would be the meta-d
fit$coefficients["s"]




