/* AGT model 2 : Lin R + Lin E + Intercept
*  Author : vincent.valton@ucl.ac.uk
*/

data{
    int<lower=1> Ns; // number of subjects (strictly positive int)
    int<lower=0> Nx; // maximum number of trials (int)
    int<lower=1> Ni; // number of predictors (ignore for now and set to 1)
    array [Ns,Nx] int<lower=0,upper=1> y; // Responses (accept/refuse = 1 or 0) — 2D array of ints (rows: participant, columns: trials)

    matrix<lower=0>[Ns,Nx] x_rwd; // Matrix of reals containing the reward level for each participant and trial — (rows: participant, column: trial)
    matrix<lower=0>[Ns,Nx] x_eff;   // Matrix of reals containing the effort level for each participant and trial — (rows: participant, column: trial)
}

parameters{
	// Group-level parameters
	real muI;
	real muR;
	real muE;
	real<lower=0> sdI;
	real<lower=0> sdR;
	real<lower=0> sdE;

	// Subject-level parameters
	vector[Ns] nc_thetaI;
	vector[Ns] nc_thetaR;
	vector[Ns] nc_thetaE;
}

transformed parameters{
  vector[Ns] thetaI;
  vector[Ns] thetaR;
  vector[Ns] thetaE;

  thetaI =  muI + sdI * nc_thetaI;
  thetaR =  muR + sdR * nc_thetaR;
  thetaE =  muE + sdE * nc_thetaE;
}

model{
	muI ~ normal(0,10);
	muR ~ normal(0,10);
	muE ~ normal(0,10);

	sdI ~ cauchy(0,2.5);
	sdR ~ cauchy(0,2.5);
	sdE ~ cauchy(0,2.5);

	nc_thetaI ~ normal(0,1);
	nc_thetaR ~ normal(0,1);
	nc_thetaE ~ normal(0,1);

	for (i_subj in 1:Ns) {
		for (i_trial in 1:Nx) {
			y[i_subj,i_trial] ~ bernoulli_logit(  thetaI[i_subj]
                                         + x_rwd[i_subj,i_trial]*thetaR[i_subj]
                                         + x_eff[i_subj,i_trial]*thetaE[i_subj]);
		}
	}
}
generated quantities{
  array [Ns] real log_lik;

  for (i_subj in 1:Ns){
    log_lik[i_subj]=0;
    for (i_trial in 1:Nx) {
      log_lik[i_subj]=log_lik[i_subj]+bernoulli_logit_lpmf(y[i_subj,i_trial]|thetaI[i_subj]
                                                                             + x_rwd[i_subj,i_trial]*thetaR[i_subj]
                                                                             + x_eff[i_subj,i_trial]*thetaE[i_subj]);
    }
  }
}
