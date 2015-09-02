" Vim Syntax File for Quantum Espresso
" Technically just fortran namelists, but this was a fun exercise.
" Andrew McAllister
" February 18th, 2015

syntax case ignore

" Regions
syn region namelistsBlock start="&" end="/" fold transparent contains=celNumber,namelists,flags,celWord

"Keywords
syn keyword namelists control system electrons ions cell 

syn keyword cardsBlock atomic_species
syn keyword cardsBlock atomic_positions k_points cell_parameters constraints
syn keyword cardsBlock occupations atomic_forces

syn keyword flags calculation title verbosity restart_mode wf_collect nstep iprint tstress tprnfor dt outdir wfcdir prefix lkpoint_dir max_seconds etot_conv_thr forc_conv_thr disk_io pseudo_dir tefield dipfield lelfield nberrycyc lorbm lberry gdir nppstr 
syn keyword flags ibrav celldm A B C cosAB cosAC cosBC nat ntyp nbnd tot_charge tot_magnetization starting_magnetization ecutwfc ecutrho ecutfock nr1 nr2 nr3 nr1s nr2s nr3s nosym nosym_evc noinv no_t_rev force_symmorphic use_all_frac occupations one_atom_occupations starting_spin_angle degauss smearing nspin noncolin ecfixed qcutz q2sigma input_dft exx_fraction screening_parameter exxdiv_treatment x_gamma_extrapolation ecutvcut nqx1 nqx2 nqx3 lda_plus_u lda_plus_u_kind Hubbard_U Hubbard_J0 Hubbard_alpha Hubbard_beta Hubbard_J(i,ityp) starting_ns_eigenvalue(m,ispin,I) U_projection_type edir emaxpos eopreg eamp angle1 angle2 constrained_magnetization fixed_magnetization lambda report lspinorb assume_isolated esm_bc esm_w esm_efield esm_nfit vdw_corr london london_s6 london_rcut xdm xdm_a1 xdm_a2
syn keyword flags electron_maxstep scf_must_converge conv_thr adaptive_thr conv_thr_init conv_thr_multi mixing_mode mixing_beta mixing_ndim mixing_fixed_ns diagonalization ortho_para diago_thr_init diago_cg_maxiter diago_david_ndim diago_full_acc efield efield_cart startingpot startingwfc tqr
syn keyword flags ion_dynamics ion_positions phase_space pot_extrapolation wfc_extrapolation remove_rigid_rot ion_temperature tempw tolp delta_t nraise refold_pos upscale bfgs_ndim trust_radius_max trust_radius_min trust_radius_ini w_1 w_2
syn keyword flags cell_dynamics press wmass cell_factor press_conv_thr cell_dofree

"Matches
"
" Integer with - + or nothing in front
 syn match celNumber contained '\d\+'
 syn match celNumber contained '[-+]\d\+'
" " Floating point number with decimal no E or e (+,-)
 syn match celNumber contained '\d\+\.\d*'
 syn match celNumber contained '[-+]\d\+\.\d*'
" " Floating point like number with E and no decimal point (+,-)
 syn match celNumber contained '[-+]\=\d[[:digit:]]*[eE][\-+]\=\d\+'
 syn match celNumber contained '\d[[:digit:]]*[eE][\-+]\=\d\+'
" " Floating point like number with E and decimal point (+,-)
 syn match celNumber contained '[-+]\=\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'
 syn match celNumber contained '\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'
 " Letters Highlighting
 syn match celWord contained '\'.*$'
 syn match celWord contained '\..*$'

" Highlighting
hi def link namelists Statement
hi def link cardsBlock Statement
hi def link flags Constant
hi def link celNumber Type
hi def link celWord Type
