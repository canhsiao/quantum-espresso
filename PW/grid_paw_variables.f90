module grid_paw_variables
  !
  !   WARNINGS:
  !
  ! NO spin-orbit
  ! NO EXX
  ! NO Parallelism
  ! NO rinner > 0
  !
  USE kinds,      ONLY : DP
  USE parameters, ONLY : lqmax, nbrx, npsx, nqfx, ndmx
  !
  implicit none
  public!              <===
  save

  LOGICAL, PARAMETER :: really_do_paw = .true.

  ! Analogous to okvan in  "uspp_param" (Modules/uspp.f90)
  LOGICAL :: &
       okpaw              ! if .TRUE. at least one pseudo is PAW

  ! Analogous to tvanp in "uspp_param" (Modules/uspp.f90)
  LOGICAL :: &
       tpawp(npsx)            ! if .TRUE. the atom is of PAW type

  ! Analogous to qfunc in "uspp_param" (Modules/uspp.f90)
  REAL(DP), TARGET :: &
       pfunc(ndmx,nbrx,nbrx,npsx), &! AE: \phi_{mu}(|r|)-\phi_{nu}(|r|)
       ptfunc(ndmx,nbrx,nbrx,npsx)  ! PS: \tilde{\phi}_{mu}(|r|)-\tilde{\phi}_{nu}(|r|)

  REAL(DP), TARGET :: &
       augfun(ndmx,nbrx,nbrx,0:lqmax,npsx) 
  ! Analogous to qq in "uspp_param" (Modules/uspp.f90)
  REAL(DP), ALLOCATABLE, TARGET :: &
       pp(:,:,:),             &! the integrals of p functions in the solid
       ppt(:,:,:)              ! the integrals of pt functions in the solid

  ! Analogous to qrad in "us" (PW/pwcom.f90)
  REAL(DP), ALLOCATABLE, TARGET :: &
       prad(:,:,:,:),         &! radial FT of P functions
       ptrad(:,:,:,:)          ! radial FT of \tilde{P} functions

  ! Products \Sum_k (P_ij(k)*P_ij'(k))/k**2
  COMPLEX(DP), ALLOCATABLE, TARGET :: &
       prodp(:,:,:),              &! AE product in reciprocal space
       prodpt(:,:,:),             &! PS product in reciprocal space
       prod0p(:,:,:),             &! k=0 AE product in reciprocal space
       prod0pt(:,:,:)              ! k=0 PS product in reciprocal space

!! NEW-AUG !!
  ! Moments of the augmentation functions
  REAL (DP) :: &
       r2(ndmx,npsx)    ! r**2 logarithmic mesh
  REAL (DP) :: &
       augmom(nbrx,nbrx,0:6,npsx)     ! moments of PAW augm. functions
  INTEGER :: &
       nraug(npsx)                 ! augm. functions cutoff parameter
!! NEW-AUG !!

  ! Analogous to rho in "scf" (PW/pwcom.f90) + index scanning atoms
  REAL(DP), ALLOCATABLE, TARGET :: &
       rho1(:,:,:),             &! 1center AE charge density in real space
       rho1t(:,:,:)              ! 1center PS charge density in real space
!!! No more needed since ptfunc already contains the augmentation charge qfunc
!!!    rho1h(:,:,:)              ! 1center compensation charge in real space

  ! Analogous to vr in "scf" (PW/pwcom.f90) + index scanning atoms
  REAL(DP), ALLOCATABLE, TARGET :: &
       vr1(:,:,:),        &! the Hartree+XC potential in real space of rho1
       vr1t(:,:,:)         ! the Hartree+XC potential in real space of rho1t

  ! Analogous to qq in "uspp_param" (Modules/uspp.f90)
  REAL(DP), ALLOCATABLE, TARGET :: &
       int_r2pfunc(:,:,:),   &! Integrals of r^2 * pfunc(r) (AE)
       int_r2ptfunc(:,:,:)    ! Integrals of r^2 * pfunc(r) (PS)

  ! Analogous to rho_atc in "atom" (Modules/atom.f90)
  REAL(DP), TARGET :: &
       aerho_atc(ndmx,npsx),        &! radial AE core charge density
       psrho_atc(ndmx,npsx)          ! radial PS core charge density          
  
  ! Analogous to rho_core in "scf" (PW/pwcom.f90)
  REAL(DP), ALLOCATABLE, TARGET :: &
       aerho_core(:,:),            &! AE core charge density in real space
       psrho_core(:,:)              ! PS core charge density in real space

  ! Analogous to vloc_at in "uspp_param" (Modules/uspp.f90)
  REAL(DP), TARGET :: &
      aevloc_at(ndmx,npsx),               &! AE descreened potential
      psvloc_at(ndmx,npsx)                 ! PS descreened potential

  ! Analogous to vloc in "vlocal" (PW/pwcom.f90)
  REAL(DP), ALLOCATABLE, TARGET :: &
       aevloc(:,:),            &! AE local 1-c potential for each atom type
       psvloc(:,:)              ! PS local 1-c potential for each atom type
  !
  REAL(DP), ALLOCATABLE :: &
       radial_distance(:)     ! radial distance from na (minimum image conv)

  ! Analogous to vltot in "scf" (PW/pwcom.f90)
  REAL(DP), ALLOCATABLE, TARGET :: &
       aevloc_r(:,:),            &! AE local potential in real space
       psvloc_r(:,:)              ! PS local potential in real space

  ! One-center energies
  REAL(DP), ALLOCATABLE, TARGET :: &
       ehart1 (:),                & ! Hartree energy (AE)
       etxc1  (:),                & ! XC: energy (AE)
       vtxc1  (:),                & ! XC: Int V*rho (AE)
       ehart1t(:),                & ! Hartree energy (PS)
       etxc1t (:),                & ! XC: energy (PS)
       vtxc1t (:)                   ! XC: Int V*rho (PS)

  ! Analogous to dion in "uspp_param" (Modules/uspp.f90)
  REAL(DP) :: &
       kdiff (nbrx,nbrx,npsx)                ! Kinetic energy differences

  ! Analogous to deeq in "uspp_param" (Modules/uspp.f90)
  REAL(DP), ALLOCATABLE :: &
       dpaw_ae(:,:,:,:),         &! AE D: D^1_{ij}         (except for K.E.)
       dpaw_ps(:,:,:,:)           ! PS D: \tilde{D}^1_{ij} (except for K.E.)

  ! TMP analogous to rhonew in PW/electrons.f90
  REAL(DP), ALLOCATABLE, TARGET :: &
       rho1new(:,:,:),             &! new 1center AE charge density in real space
       rho1tnew(:,:,:)              ! new 1center PS charge density in real space
  ! new vectors needed for mixing of augm. channel occupations
  REAL(DP), ALLOCATABLE :: &
       becnew(:,:,:)       ! new augmentation channel occupations

  ! analogous to deband and descf in PW/electrons.f90
  REAL(DP) ::  deband_1ae, deband_1ps, descf_1ae, descf_1ps
  
end module grid_paw_variables
