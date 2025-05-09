/* Pizzagalli model 2 : 'WSLS'
*  author: Alex Pike
*  email: alex.pike@ucl.ac.uk
*/

data {
     int<lower=1> N; 				//Number of subjects (strictly positive int)
     int<lower=1> T;  				//Number of trials (strictly positive int)
     int<lower=1> levels;     //Number of levels of congruence: set to 5

     array[N,T] int<lower=1,upper=2> choice; 		 // Array of ints containing the choice made for each trial and participant (i.e. whether they chose left or right) — (rows: participants, columns: trials)
     array[N,T] int<lower=0,upper=1> accuracy; //For whether they actually responded correctly (even if unrewarded)
     array[N,T] int<lower=-1,upper=1> rwd;		//Matrix of integers containing the reward received on a given trial (1 or 0) — (rows: participants, columns : trials)
     array[N,T] int<lower=1,upper=levels> congruence; //The congruence of the stimuli: should be integers from 1 to levels

     matrix[2,levels] Vinits;		//Matrix of reals containing the initial q-values for left and right for each congruence level - set to 0 in this model;
}

transformed data {
     matrix[2,levels] initV;
     initV = Vinits;
}

parameters {
     real mu;
     real<lower=0> sigma;

     vector[N] inv_temp_raw;
}

transformed parameters {
     vector<lower=0>[N] inv_temp;

     inv_temp = Phi_approx(mu + sigma*inv_temp_raw)*5;
}

model {
     mu ~ std_normal();
     sigma ~ cauchy(0,2.5);
     inv_temp_raw ~ std_normal();

     for (i in 1:N) {
             matrix [2,levels] v;

             v = initV;

             for (t in 1:T) {
             		vector [2] tempv;
                tempv = [v[1,congruence[i,t]],v[2,congruence[i,t]]]';
                choice[i,t] ~ categorical_logit( inv_temp[i] * tempv );
		            v[choice[i,t],congruence[i,t]] = v[choice[i,t],congruence[i,t]]+ (rwd[i,t]-v[choice[i,t],congruence[i,t]]);
             }

     }
}
generated quantities {
      vector [N] log_lik;

        for (i in 1:N) {
                  matrix [2,levels] v;

                  v = initV;
                  log_lik[i] = 0;

                  for (t in 1:T) {
                    vector [2] tempv;
                    tempv = [v[1,congruence[i,t]],v[2,congruence[i,t]]]';
                    log_lik[i] += categorical_logit_lpmf( choice[i,t] | inv_temp[i] * tempv );
                    v[choice[i,t],congruence[i,t]] = v[choice[i,t],congruence[i,t]]+ (rwd[i,t]-v[choice[i,t],congruence[i,t]]);
                  }
        }
}
