!
! Copyright (C) 2002 CP90 group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!

module van_parameters
  implicit none
  save
  !     nlx = combined angular momentum (for s,p,d states: nlx=9)
  !     lix = max angular momentum l+1 (lix=3 if s,p,d are included)
  !     lx  = max 2*l+1
  !     mx  = 2*lx-1
  integer, parameter:: lix=3, nlx=9, lx=2*lix-1, mx=2*lx-1
end module van_parameters

module bhs
  !     analytical BHS pseudopotential parameters
  use parameters, only: nsx
  implicit none
  save
  real(kind=8) rc1(nsx), rc2(nsx), wrc1(nsx), wrc2(nsx), &
       rcl(3,nsx,3), al(3,nsx,3), bl(3,nsx,3)
  integer lloc(nsx)
end module bhs

module core
  implicit none
  save
  !     nlcc = 0 no core correction on any atom
  !     rhocb = core charge in G space (box grid)
  integer nlcc
  real(kind=8), allocatable:: rhocb(:,:)
end module core

module cvan
  !     ionic pseudo-potential variables
  use parameters, only: nsx
  use van_parameters
  implicit none
  save
  !     ap  = Clebsch-Gordan coefficients (?)
  !     lpx = max number of allowed Y_lm
  !     lpl = composite lm index of Y_lm
  real(kind=8) ap(25,nlx,nlx)
  integer lpx(nlx,nlx),lpl(nlx,nlx,mx)
  !     nvb    = number of species with Vanderbilt PPs
  !     nh(is) = number of beta functions, including Y_lm, for species is
  !     ish(is)= used for indexing the nonlocal projectors betae
  !              with contiguous indices inl=ish(is)+(iv-1)*na(is)+1
  !              where "is" is the species and iv=1,nh(is)
  !     nhx    = max value of nh(np)
  !     nhsavb = total number of Vanderbilt nonlocal projectors
  !     nhsa   = total number of nonlocal projectors for all atoms
  integer nvb, nhsavb, ish(nsx), nh(nsx), nhsa, nhx
  !     nhtol: nhtol(ind,is)=value of l for projector ind of species is
  !     indv : indv(ind,is) =beta function (without Y_lm) for projector ind
  !     indlm: indlm(ind,is)=Y_lm for projector ind
  integer, allocatable:: nhtol(:,:), indv(:,:), indlm(:,:)
  !     beta = nonlocal projectors in g space without e^(-ig.r) factor
  !     qq   = ionic Q_ij for each species (Vanderbilt only)
  !     dvan = ionic D_ij for each species (Vanderbilt only)
  real(kind=8), allocatable:: beta(:,:,:), qq(:,:,:), dvan(:,:,:)
end module cvan

module dft_mod
  implicit none
  save
  integer lda, blyp, becke, bp88, pw91, pbe
  parameter (lda=0, blyp=1, becke=2, bp88=3, pw91=4, pbe=5)
  integer dft
end module dft_mod

module elct
  use electrons_base, only: nspin, nel, nupdwn, iupdwn
  use electrons_base, only: n => nbnd, nx => nbndx
  implicit none
  save
  !     f    = occupation numbers
  !     qbac = background neutralizing charge
  real(kind=8), allocatable:: f(:)
  real(kind=8) qbac
  !     nspin = number of spins (1=no spin, 2=LSDA)
  !     nel(nspin) = number of electrons (up, down)
  !     nupdwn= number of states with spin up (1) and down (2)
  !     iupdwn=      first state with spin (1) and down (2)
  !     n     = total number of electronic states
  !     nx    = if n is even, nx=n ; if it is odd, nx=n+1
  !            nx is used only to dimension arrays
  !     ispin = spin of each state
  integer, allocatable:: ispin(:)
  !
end module elct

module gvec

  use cell_base, only: tpiba, tpiba2
  use reciprocal_vectors, only: &
        ng => ngm, &
        ngl => ngml, &
        ng_g => ngmt, &
        gl, g, gx, g2_g, mill_g, mill_l, ig_l2g, igl, bi1, bi2, bi3

  !     tpiba   = 2*pi/alat
  !     tpiba2  = (2*pi/alat)**2
  !     ng      = number of G vectors for density and potential
  !     ngl     = number of shells of G

  !     G-vector quantities for the thick grid - see also doc in ggen 
  !     g       = G^2 in increasing order (in units of tpiba2=(2pi/a)^2)
  !     gl      = shells of G^2           ( "   "   "    "      "      )
  !     gx      = G-vectors               ( "   "   "  tpiba =(2pi/a)  )
  !
  !     g2_g    = all G^2 in increasing order, replicated on all procs
  !     mill_g  = miller index of G vecs (increasing order), replicated on all procs
  !     mill_l  = miller index of G vecs local to the processors
  !     ig_l2g  = "l2g" means local to global, this array convert a local
  !               G-vector index into the global index, in other words
  !               the index of the G-v. in the overall array of G-vectors
  !     bi?     = base vector used to generate the reciprocal space
  !
  !     np      = fft index for G>
  !     nm      = fft index for G<
  !     in1p,in2p,in3p = G components in crystal axis
  !
  implicit none
  save
  integer,allocatable:: np(:), nm(:), in1p(:),in2p(:),in3p(:)

end module gvec


module ncprm

  use parameters, only: nsx, mmaxx, nqfx=>nqfm, nbrx, lqx=>lqmax
  use van_parameters
  implicit none
  save
!
!  lqx  :  maximum angular momentum of Q (Vanderbilt augmentation charges)
!  nqfx :  maximum number of coefficients in Q smoothing
!  nbrx :  maximum number of distinct radial beta functions
!  mmaxx:  maximum number of points in the radial grid
! 

!  ifpcor   1 if "partial core correction" of louie, froyen,
!                 & cohen to be used; 0 otherwise
!  nbeta    number of beta functions (sum over all l)
!  kkbeta   last radial mesh point used to describe functions
!                 which vanish outside core
!  nqf      coefficients in Q smoothing
!  nqlc     angular momenta present in Q smoothing
!  lll      lll(j) is l quantum number of j'th beta function

  integer ifpcor(nsx), nbeta(nsx), kkbeta(nsx), &
       nqf(nsx), nqlc(nsx), lll(nbrx,nsx)

!  rscore   partial core charge (Louie, Froyen, Cohen)
!  dion     bare pseudopotential D_{\mu,\nu} parameters
!              (ionic and screening parts subtracted out)
!  betar    the beta function on a r grid (actually, r*beta)
!  qqq      Q_ij matrix
!  qfunc    Q_ij(r) function (for r>rinner)
!  rinner   radius at which to cut off partial core or Q_ij
!
!  qfcoef   coefficients to pseudize qfunc for different total
!              angular momentum (for r<rinner)
!  rucore   bare local potential

  real(kind=8)    rscore(mmaxx,nsx), dion(nbrx,nbrx,nsx), &
       betar(mmaxx,nbrx,nsx), qqq(nbrx,nbrx,nsx), &
       qfunc(mmaxx,nbrx,nbrx,nsx), rucore(mmaxx,nbrx,nsx), &
       qfcoef(nqfx,lqx,nbrx,nbrx,nsx), rinner(lqx,nsx)
!
! qrl       q(r) functions
!
  real(kind=8) qrl(mmaxx,nbrx,nbrx,lx,nsx)

!  mesh     number of radial mesh points
!  r        logarithmic radial mesh
!  rab      derivative of r(i) (used in numerical integration)
!  cmesh    used only for Herman-Skillman mesh (old format)

  integer mesh(nsx)
  real(kind=8)    r(mmaxx,nsx), rab(mmaxx,nsx), cmesh(nsx)
end module ncprm

module pseu
  implicit none
  save
  !    rhops = ionic pseudocharges (for Ewald term)
  !    vps   = local pseudopotential in G space for each species
  real(kind=8), allocatable:: rhops(:,:), vps(:,:)
end module pseu

module qgb_mod
  implicit none
  save
  complex(kind=8), allocatable::  qgb(:,:,:)
end module qgb_mod

module qradb_mod
  implicit none
  save
  real(kind=8), allocatable:: qradb(:,:,:,:,:)
end module qradb_mod

module timex_mod
  implicit none
  save
  integer maxclock
  parameter (maxclock=32)
  real(kind=8) cputime(maxclock), elapsed(maxclock)
  integer ntimes(maxclock)
  character(len=10) routine
  dimension routine(maxclock)
  data routine / 'total time',  &
                 'initialize',  &
                 '  formf   ',  &
                 '  rhoofr  ',  &
                 '  vofrho  ',  &
                 '  dforce  ',  &
                 '  calphi  ',  &
                 '  ortho   ',  &
                 '  updatc  ',  &
                 '  graham  ',  &
                 '  newd    ',  &
                 '  calbec  ',  &
                 '  prefor  ',  &
                 '  strucf  ',  &
                 '  nlfl    ',  &
                 '  nlfq    ',  &
                 '  set_cc  ',  &
                 '   rhov   ',  &
                 '   nlsm1  ',  &
                 '   nlsm2  ',  &
                 '   forcecc',  &
                 '     fft  ',  &
                 '     ffts ',  &
                 '     fftw ',  &
                 '     fftb ',  &
                 '     rsg  ',  &
                 'setfftpara',  &
                 'fftscatter',  &
                 'reduce    ',  &
                 'test1     ','test2     ','test3     ' /

end module timex_mod

module wfc_atomic
  use parameters, only:nsx
  use ncprm, only:mmaxx
  implicit none
  save
  !  nchix=  maximum number of pseudo wavefunctions
  !  nchi =  number of atomic (pseudo-)wavefunctions
  !  lchi =  angular momentum of chi
  !  chi  =  atomic (pseudo-)wavefunctions
  integer nchix
  parameter (nchix=6)
  real(kind=8) chi(mmaxx,nchix,nsx)
  integer lchi(nchix,nsx), nchi(nsx)
end module wfc_atomic

module work1
  implicit none
  save
  complex(kind=8), allocatable, target:: wrk1(:)
end module work1

module work_box
  implicit none
  save
  complex(kind=8), allocatable, target:: qv(:)
end module work_box

module work_fft
  implicit none
  save
  complex(kind=8), allocatable:: aux(:)
end module work_fft

module work2
  implicit none
  save
  complex(kind=8), allocatable, target:: wrk2(:,:)
end module work2

! Variable cell
module derho
  implicit none
  save
  complex(kind=8),allocatable:: drhog(:,:,:,:)
  real(kind=8),allocatable::     drhor(:,:,:,:)
end module derho

module dener
  implicit none
  save
  real(kind=8) detot(3,3), dekin(3,3), dh(3,3), dps(3,3), &
  &       denl(3,3), dxc(3,3), dsr(3,3)
end module dener

module dqgb_mod
  implicit none
  save
  complex(kind=8),allocatable:: dqgb(:,:,:,:,:)
end module dqgb_mod

module dpseu
  implicit none
  save
  real(kind=8),allocatable:: dvps(:,:), drhops(:,:)
end module dpseu

module cdvan
  implicit none
  save
  real(kind=8),allocatable:: dbeta(:,:,:,:,:), dbec(:,:,:,:), &
                             drhovan(:,:,:,:,:)
end module cdvan

module pres_mod
  use gvecw, only: agg => ecutz, sgg => ecsig, e0gg => ecfix
  implicit none
  save
  real(kind=8),allocatable:: ggp(:)
end module pres_mod

