library(data.table)
library(parallel)

rm(list=ls())

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
setkey(m.dt, movie_id)

ptm <- proc.time()
resdts <- mclapply(valid.seq, mc.cores=60, mc.preschedule=FALSE,
    FUN=function(x) {
        mean.mc <- lm(rating_mean ~ mcount, data=m.dt[J(x)])
        mean.nmc <- lm(rating_mean ~ nmcount, data=m.dt[J(x)])
        mean.mf <- lm(rating_mean ~ mfrac, data=m.dt[J(x)])
        cat(ec(x), '::', (proc.time() - ptm)[3], '\n')
        data.table(movie_id=x,
                   mc.cons=mean.mc$coef[1],
                   mc.b=mean.mc$coef[2],
                   nmc.cons=mean.nmc$coef[1],
                   nmc.b=mean.nmc$coef[2],
                   mf.cons=mean.mf$coef[1],
                   mf.b=mean.mf$coef[2]
                   )
    })
print(proc.time() - ptm)
resdt <- rbindlist(resdts)

saveRDS(resdt, 'traj-month.Rds')
