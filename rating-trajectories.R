library(data.table)
library(parallel)

rm(list=ls())

logit <- function(x) { log(x) - log(1-x) }

setwd('~/Data/nf')

valid.dt <- fread('valid_movies_2014.csv')
dt <- readRDS('valid-ratings.Rds')
w.dt <- readRDS('valid-ratings-week.Rds')
m.dt <- readRDS('valid-ratings-month.Rds')
q.dt <- readRDS('valid-ratings-quarter.Rds')

# dt <- dt[order(movie_id, rating_date)]

valid.seq <- sort(valid.dt[, unique(id)])
ec <- ecdf(valid.seq)
# resdts <- mclapply(valid.seq,
#                    mc.cores=60, mc.preschedule=FALSE,
#                    FUN=function(x) {
#                         res <- dt[J(x), list(rating=rating,
#                                              daylapse=as.numeric(rd - min(rd)),
#                                              ndaylapse=as.numeric(rd - max(rd)),
#                                              timefrac=as.numeric(rd - min(rd)) / as.numeric(max(rd) - min(rd)))]
#                         print(ec(x))
#                         res
#                    })
# resdt <- rbindlist(resdts)
# setkey(resdt, movie_id)

# saveRDS(resdt, 'valid-ratings-')

m.dt[, month_num := floor(month_id / 100) * 12 + month_id %% 100]
m.dt[, mcount := month_num - min(month_num), by=movie_id]
m.dt[, nmcount := month_num - max(month_num), by=movie_id]
m.dt[, mfrac := mcount / (max(month_num) - min(month_num)), by=movie_id]
m.dt[, pop_frac := rating_pop / all_pop]
m.dt[, lpop_frac := logit(pop_frac)]
setkey(m.dt, movie_id)

ptm <- proc.time()
resdts <- mclapply(valid.seq, mc.cores=60, mc.preschedule=FALSE,
    FUN=function(x) {
        mean.mc <- lm(rating_mean ~ mcount, data=m.dt[J(x)])
        mean.nmc <- lm(rating_mean ~ nmcount, data=m.dt[J(x)])
        mean.mf <- lm(rating_mean ~ mfrac, data=m.dt[J(x)])

        popfrac.mc <- lm(pop_frac ~ mcount, data=m.dt[J(x)])
        popfrac.nmc <- lm(pop_frac ~ nmcount, data=m.dt[J(x)])
        popfrac.mf <- lm(pop_frac ~ mfrac, data=m.dt[J(x)])

        lpopfrac.mc <- lm(lpop_frac ~ mcount, data=m.dt[J(x)])
        lpopfrac.nmc <- lm(lpop_frac ~ nmcount, data=m.dt[J(x)])
        lpopfrac.mf <- lm(lpop_frac ~ mfrac, data=m.dt[J(x)])


        cat(ec(x), '::', (proc.time() - ptm)[3], '\n')
        data.table(movie_id=x,
                   rmean_mc_cons=mean.mc$coef[1],
                   rmean_mc_b=mean.mc$coef[2],
                   rmean_nmc_cons=mean.nmc$coef[1],
                   rmean_nmc_b=mean.nmc$coef[2],
                   rmean_mf_cons=mean.mf$coef[1],
                   rmean_mf_b=mean.mf$coef[2],
                   
                   popfrac_mc_cons=popfrac.mc$coef[1],
                   popfrac_mc_b=popfrac.mc$coef[2],
                   popfrac_nmc_cons=popfrac.nmc$coef[1],
                   popfrac_nmc_b=popfrac.nmc$coef[2],
                   popfrac_mf_cons=popfrac.mf$coef[1],
                   popfrac_mf_b=popfrac.mf$coef[2],
                   
                   lpopfrac_mc_cons=lpopfrac.mc$coef[1],
                   lpopfrac_mc_b=lpopfrac.mc$coef[2],
                   lpopfrac_nmc_cons=lpopfrac.nmc$coef[1],
                   lpopfrac_nmc_b=lpopfrac.nmc$coef[2],
                   lpopfrac_mf_cons=lpopfrac.mf$coef[1],
                   lpopfrac_mf_b=lpopfrac.mf$coef[2]
                   )
    })
print(proc.time() - ptm)
resdt <- rbindlist(resdts)

saveRDS(resdt, 'traj-month.Rds')
