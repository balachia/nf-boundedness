library(data.table)
library(parallel)

rm(list=ls())

setwd('~/Data/nf')

dt <- fread('all-ratings.txt')
valid.dt <- fread('valid_movies_2014.csv')

setnames(valid.dt, 'id', 'movie_id')
setkey(dt, movie_id)
setkey(valid.dt, movie_id)

dt <- dt[valid.dt]
# dt[, rd := strptime(rating_date, format='%Y-%m-%d')]

# dt <- dt[order(movie_id, rating_date)]
setkey(dt, movie_id)

ec <- ecdf(valid.dt[, unique(movie_id)])
valid.seq <- sort(valid.dt[, unique(movie_id)])
resdts <- mclapply(valid.seq,
                   mc.cores = 60, mc.preschedule=FALSE,
                   FUN=function (x) {
                       print(ec(x))
                       res <- dt[J(x), list(rating = rating,
                                            rd = as.Date(rating_date))]
                       res[, week_id := 100*year(rd) + week(rd)]
                       res[, month_id := 100*year(rd) + month(rd)]
                       res[, quarter_id := 100*year(rd) + quarter(rd)]
                       res
                   })
dt <- rbindlist(resdts)
setkey(dt, movie_id)

saveRDS(dt, 'valid-ratings.Rds')

# by week
setkey(dt, movie_id, week_id)
week.dt <- dt[, list(rating_mean=mean(rating),
                     rating_sd=sd(rating),
                     rating_pop=.N), by=list(movie_id, week_id)]
all.week.dt <- dt[, list(all_pop = .N), by=week_id]
week.dt <- merge(week.dt, all.week.dt, by='week_id', all.x=TRUE)

# by month
setkey(dt, movie_id, month_id)
month.dt <- dt[, list(rating_mean=mean(rating),
                     rating_sd=sd(rating),
                     rating_pop=.N), by=list(movie_id, month_id)]
all.month.dt <- dt[, list(all_pop = .N), by=month_id]
month.dt <- merge(month.dt, all.month.dt, by='month_id', all.x=TRUE)

# by quarter
setkey(dt, movie_id, quarter_id)
quarter.dt <- dt[, list(rating_mean=mean(rating),
                     rating_sd=sd(rating),
                     rating_pop=.N), by=list(movie_id, quarter_id)]
all.quarter.dt <- dt[, list(all_pop = .N), by=quarter_id]
quarter.dt <- merge(quarter.dt, all.quarter.dt, by='quarter_id', all.x=TRUE)

saveRDS(week.dt, 'valid-ratings-week.Rds')
saveRDS(month.dt, 'valid-ratings-month.Rds')
saveRDS(quarter.dt, 'valid-ratings-quarter.Rds')

