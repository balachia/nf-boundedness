clear
set more off

cd ~/Data/Netflix

insheet using traj-month.csv, clear

* rmean_mc_cons rmean_mc_b rmean_nmc_cons rmean_nmc_b rmean_mf_cons rmean_mf_b
* popfrac_mc_cons popfrac_mc_b popfrac_nmc_cons popfrac_nmc_b popfrac_mf_cons popfrac_mf_b
* lpopfrac_mc_cons lpopfrac_mc_b lpopfrac_nmc_cons lpopfrac_nmc_b lpopfrac_mf_cons lpopfrac_mf_b

drop v1
la var movie_id "movie id"

la var rmean_mc_cons "Mean rating: mean rating at movie's first day"
la var rmean_mc_b "Mean rating: daily change in mean rating"
la var rmean_nmc_cons "Mean rating: mean rating at movie's last day"
la var rmean_nmc_b "Mean rating: daily change in mean rating"
la var rmean_mf_cons "Mean rating: mean rating at movie's first day"
la var rmean_mf_b "Mean rating: total change in mean rating"

la var popfrac_mc_cons "Rating fraction: rating fraction at movie's first day"
la var popfrac_mc_b "Rating fraction: daily change in rating fraction"
la var popfrac_nmc_cons "Rating fraction: rating fraction at movie's last day"
la var popfrac_nmc_b "Rating fraction: daily change in rating fraction"
la var popfrac_mf_cons "Rating fraction: rating fraction at movie's first day"
la var popfrac_mf_b "Rating fraction: total change in rating fraction"

la var lpopfrac_mc_cons "Logit rating fraction: logit rating fraction at movie's first day"
la var lpopfrac_mc_b "Logit rating fraction: daily change in logit rating fraction"
la var lpopfrac_nmc_cons "Logit rating fraction: logit rating fraction at movie's last day"
la var lpopfrac_nmc_b "Logit rating fraction: daily change in logit rating fraction"
la var lpopfrac_mf_cons "Logit rating fraction: logit rating fraction at movie's first day"
la var lpopfrac_mf_b "Logit rating fraction: total change in logit rating fraction"

save traj-month, replace

clear


