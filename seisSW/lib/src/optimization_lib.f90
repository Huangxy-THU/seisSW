
!! main subroutines for optimization scheme
!! created by Yanhua O. Yuan ( yanhuay@princeton.edu)
!! copyright

!!!!!!!!!!!!!!!! OPTIMIZATION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine SD(g_new, NSTEP, p_new)
!! steepest descent method
  double precision, dimension(*), intent(in) :: g_new
  integer, intent(in) :: NSTEP
  double precision, dimension(*), intent(out) :: p_new

  !! initialization 
  p_new (1:NSTEP) = 0.0

 !! SD 
  p_new(1:NSTEP) = - g_new(1:NSTEP)

end subroutine SD

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine NLCG(g_new, g_old, p_old, NSTEP, CG_method, cgstep, p_new)
!! non-linear conjugate method
!! NOTES :: The biggest threat to the CG method is a loss of conjugacy in the search vectors 
!! one way is to periodically restart the CG method
 use user_parameters
  implicit none

  double precision, dimension(*), intent(in) :: g_new, g_old, p_old
  integer, intent(in) :: NSTEP
  character(len=2), intent(in) :: CG_method
  integer, intent(out) :: cgstep
  double precision, dimension(*), intent(out) :: p_new


  double precision :: beta
  double precision :: top, bot  
  
  !! initialization 
  p_new (1:NSTEP) = 0.0
  cgstep = cgstep+1

 !! beta formula  
    select case (CG_method)
       case ("FR") ! Fletcher-Reeves 
         top = sum(g_new(1:NSTEP) * g_new(1:NSTEP))
         bot = sum(g_old(1:NSTEP) * g_old(1:NSTEP))
         beta = top / bot
       case ("PR") ! Polak-Ribiere 
         top = sum(g_new(1:NSTEP) * (g_new(1:NSTEP)-g_old(1:NSTEP)))
         bot = sum(g_old(1:NSTEP) * g_old(1:NSTEP)) 
         beta = top / bot
       case ("HS") ! Hestenes-Stiefel 
         top = sum(g_new(1:NSTEP) * (g_new(1:NSTEP)-g_old(1:NSTEP)))
         bot = -1.0 * sum(p_old(1:NSTEP) * (g_new(1:NSTEP)-g_old(1:NSTEP)))
         beta = top / bot
       case ("DY") ! Dai-Yuan: 
         top = sum(g_new(1:NSTEP) * g_new(1:NSTEP))
         bot = -1.0 * sum(p_old(1:NSTEP) * (g_new(1:NSTEP)-g_old(1:NSTEP)))
         beta = top / bot
  case default
      print*, 'CG_method must be among "FR"/"PR"/"HS"/"DY" ...';
      stop
  end select

   ! handle loss of conjugacy that results from the non-quadratic terms 
    if(beta<=0.0) then 
      print*, 'restarting NLCG ... [negative beta]'
      beta = 0.0  
      cgstep = 1
    elseif (dot_product(p_new(1:NSTEP), g_new(1:NSTEP)) > 0.0) then 
      print*, 'restarting NLCG ... [not a descent direction]' 
      beta = 0.0 
      cgstep = 1
   elseif (abs(dot_product(g_new(1:NSTEP), g_old(1:NSTEP)) &
          / dot_product(g_new(1:NSTEP), g_new(1:NSTEP))) > CG_threshold ) then 
      print*, 'restarting NLCG ... [loss of conjugacy]'
      beta = 0.0
      cgstep = 1
    endif  !! restart NLCG  

   !! search direction 
    p_new(1:NSTEP) = - g_new(1:NSTEP) + beta * p_old(1:NSTEP)
 
 
end subroutine NLCG

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine LBFGS(Dm, Dg, g_new, NSTEP, m, BFGS_step, p_new)
!! Quasi-Newton method (L-BFGS)
 use user_parameters
  implicit none

  integer, intent(in) :: NSTEP, m
  double precision, intent(in) :: Dm(NSTEP,m),Dg(NSTEP,m)
  double precision, dimension(*), intent(in) :: g_new
  integer, intent(out) :: BFGS_step ! for next iter
  double precision, dimension(*), intent(out) :: p_new

  double precision, dimension(m) :: alpha, beta, rho 
  integer :: i 
  double precision, dimension(NSTEP) :: q, z  
  double precision :: invH

  !! initialization 
  p_new (1:NSTEP) = 0.0

  !!  initialization 
  q(1:NSTEP) = g_new(1:NSTEP) 

!! the first loop
  do i = 1, m 
     rho(i) = 1.0/dot_product(Dg(1:NSTEP,i),Dm(1:NSTEP,i))
     alpha(i) = rho(i) * dot_product(Dm(1:NSTEP,i), q(1:NSTEP))
     q(1:NSTEP) = q(1:NSTEP) - alpha(i) * Dg(1:NSTEP,i)
     invH = dot_product(Dg(1:NSTEP,1), Dm(1:NSTEP,1)) / &
            dot_product(Dg(1:NSTEP,1), Dg(1:NSTEP,1))
     z(1:NSTEP)  =  invH * q(1:NSTEP)
  enddo

!! the second loop 
  do i =  m, 1, -1 
     beta(i) = rho(i) * dot_product(Dg(1:NSTEP,i), z(1:NSTEP))
     z(1:NSTEP) = z(1:NSTEP) + (alpha(i) -beta(i)) * Dm(1:NSTEP,i)
  enddo

!! restart L-BFGS
   if ( dot_product(g_new(1:NSTEP), -z(1:NSTEP)) &
          / dot_product(g_new(1:NSTEP), g_new(1:NSTEP)) > 0.0 ) then
      print*, 'restarting L-BFGS ... [not the descent direction]'
      p_new(1:NSTEP) = - g_new(1:NSTEP)
      BFGS_step = 1
   else
      !! L-BFGS search direction 
      p_new(1:NSTEP) = - z(1:NSTEP)
      BFGS_step = BFGS_step+1
   endif

end subroutine LBFGS

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine matrix2vector(matrx,NSTEP,mdim,vector)
!! convert gradient or model matrix to 1D vector containing rho, Vp, Vs
use user_parameters
implicit none 
    
    integer, intent(in) :: NSTEP,mdim
    double precision, intent(in) :: matrx(NSTEP,mdim)
    double precision, dimension(*), intent(out) :: vector

   if(mdim==5) then ! gradient
         vector(1:NSTEP) = matrx(1:NSTEP,gdim_rho) 
         vector(NSTEP+1:2*NSTEP) = matrx(1:NSTEP,gdim_vp)
         vector(2*NSTEP+1:3*NSTEP) = matrx(1:NSTEP,gdim_vs)
   elseif(mdim==6) then ! model
         vector(1:NSTEP) = matrx(1:NSTEP,mdim_rho)
         vector(NSTEP+1:2*NSTEP) = matrx(1:NSTEP,mdim_vp)
         vector(2*NSTEP+1:3*NSTEP) = matrx(1:NSTEP,mdim_vs)
   else 
     print*,'mdim must be 5 (gradient/kernel) or 6(model)'     
     stop
   endif

end subroutine matrix2vector

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine vector2matrix(vector,NSTEP,mdim,matrx)
!! convert 1D vector to 2D gradient or model matrix containing rho, Vp, Vs
use user_parameters
implicit none

    integer, intent(in) :: NSTEP,mdim
    double precision, intent(in) :: vector(3*NSTEP)
    double precision, intent(out) :: matrx(NSTEP,mdim)


  matrx(1:NSTEP,1:mdim)=0.0
   if(mdim==5) then ! gradient
         matrx(1:NSTEP,gdim_rho) = vector(1:NSTEP)
         matrx(1:NSTEP,gdim_vp) = vector(NSTEP+1:2*NSTEP) 
         matrx(1:NSTEP,gdim_vs) = vector(2*NSTEP+1:3*NSTEP)
   elseif(mdim==6) then ! model
         matrx(1:NSTEP,mdim_rho) = vector(2*NSTEP+1:3*NSTEP)
         matrx(1:NSTEP,mdim_vp) = vector(NSTEP+1:2*NSTEP)
         matrx(1:NSTEP,mdim_vs) = vector(2*NSTEP+1:3*NSTEP)
   else
     print*,'mdim must be 5 (gradient/kernel) or 6(model)'
     stop
   endif

end subroutine vector2matrix
 
