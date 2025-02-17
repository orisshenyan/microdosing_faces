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
data_path <- "./Pilot_data/"
file_paths <- list.files(data_path, pattern = "mainblock", full.names = TRUE)
d <- map_dfr(file_paths, read_with_block)
d$block_number <- as.numeric(d$block_number)

# -------------------------------------------------------------------------
# estimate SDT parameters
# prepare for analysis
str(d)

d <- d %>% mutate(
  s = ifelse(Realface_response==80, 0, 1),
  r = ifelse(Realface_response==1 | Hallucination_response==1, 1, 0)) 

# standard approach

# Contingency Table
contingency_table <- table(d$r, d$s)
colnames(contingency_table) <- c("Signal Absent", "Signal Present")
rownames(contingency_table) <- c("No Response", "Response")
print(contingency_table)

# Extract values from table
H <- contingency_table["Response", "Signal Present"]  # Hits
M <- contingency_table["No Response", "Signal Present"]  # Misses
FA <- contingency_table["Response", "Signal Absent"]  # False Alarms
CR <- contingency_table["No Response", "Signal Absent"]  # Correct Rejections

# Compute proportions
hit_rate <- H / (H + M)
fa_rate <- FA / (FA + CR)

# Compute d-prime (d') and criterion (c)
d_prime <- qnorm(hit_rate) - qnorm(fa_rate)
criterion <- -qnorm(fa_rate)

# alternative more flexible GLM approach; see here: https://mlisi.xyz/files/SDT_GLM.pdf
m_0 <- glm(r ~ s, family=binomial("probit"), data=d)
summary(m_0)
d_prime <- coef(m_0)["s"]
criterion <-  -coef(m_0)["(Intercept)"]

# -------------------------------------------------------------------------
# settings
sigma <- 1   
alpha <- mean(d$s)

# support of random variable X (for plotting)
supp_x <- seq(-2,4,length.out=500) 

# calculate optima criterion
optimal_c <- 1/d_prime * log((1-alpha)/alpha) + d_prime/2
observed_c <- criterion 

# calculate probability density and scale by prior probability
fS <- alpha*dnorm(supp_x, mean=d_prime, sd=sigma)
fN <- (1-alpha)*dnorm(supp_x, mean=0, sd=sigma)

# plot 
pdf("SDT_plot_pilot.pdf", width=5, height=3)
par(cex=0.9, mar=c(4, 4, 1, 1) )
plot(supp_x, fS, type="l",lwd=3,col="black",xlab="X",ylab="p(X)", ylim=c(0, max(c(fS,fN))))
lines(supp_x, fN, lwd=3,col="dark grey")
abline(v=optimal_c,lwd=3,lty=1,col="red")
abline(v=observed_c,lwd=3,lty=1,col="blue")
legend("topleft",c("present","absent"),col=c("black","dark grey"),title="face:",lwd=3,,bty="n")
legend("topright",c("optimal","observed"),col=c("red","blue"),title="criterion:",lwd=3,bty="n")
dev.off()


