# Defines environment variables.

# Andrew McAllister <mcala@umich.edu>
# loading personal functions
FPATH=${FPATH}:${HOME}/.functions

autoload scratch_find get_prefix get_pseudos get_wannier make_pbs_nersc make_pbs_flux qsubqe calc swap_env


# Ensure that a non-login, non-interactive shell has a defined environment.
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
