	parameter( maxnfreq = 20,radius = 6371,
     1             maxix = 500,maxiy = 500 )

	real*8    phsens(maxix,maxiy),      ampsens(maxix,maxiy)
	real*8 avgphsens(maxix,maxiy),   avgampsens(maxix,maxiy)
	real wgttemp(maxix,maxiy)

	real freq(maxnfreq),amplitude(maxnfreq)
	real kk,lamda
	real slo,sla,rlo,rla,dist,xout,yout
	character *70 outfn1,outfn2,spcfn

	write(*,*) 'input velocity'
c	只用一个统一的相速度
	read(*,*) phvel
	write(*,*) 'please input the spectral file'
	read(*,*) spcfn
c	write(*,*) 'please input the number of freq'
c	read(*,*) nfreq
	write(*,*) 'please input outfn of unsmoothed sens'
	read(*,*) outfn1
	write(*,*) 'please input outfn of smoothed sens'
	read(*,*) outfn2
	write(*,*) 'please input smooth len (degrees) '
	read(*,*)   scalelen 

c======输入的source和station==================
	write(*,*) 'please input dist form source to receiver(km)'
	read(*,*) dist
	slo=0
	sla=0
	rlo=dist/radius*180/(4.* atan(1.))
	rla=0
c=========================================

	open(10,file = spcfn)
	open(20,file = outfn1)
	open(30,file = outfn2)	

c	xbeg = -1500
c	xend =  1500
c	ybeg = -1500
c	yend =  1500
c	dx   =  10.
c	dy   =  10.
	xbeg = -1
	xend = floor(rlo)+2
	ybeg = -2
	yend = 2
	dx   =  0.01
	dy   =  0.01
	
	nx = (xend-xbeg)/dx + 1
	ny = (yend-ybeg)/dy + 1	 
c	write(30,100) nx,xbeg,dx
c	write(30,100) ny,ybeg,dy
c	write(20,100) nx,xbeg,dx
c	write(20,100) ny,ybeg,dy
100   format(I3, 2F8.1) 

c	atan 计算反正切
	pi = 4.* atan(1.)

	open(10,file = spcfn)
	  sumamp = 0.
	  read(10,*) nfreq
	do ifreq = 1, nfreq
	  read(10,*) freq(ifreq),amplitude(ifreq)
	  sumamp = sumamp + amplitude(ifreq)
	enddo
	
c	振幅的归一化，让不同周期的振幅加起来为1
	do ifreq = 1,nfreq
	   amplitude(ifreq) = amplitude(ifreq)/sumamp
	enddo
	
c	初始时把sensitivit置零
	do ix = 1,maxix
	do iy = 1,maxiy
	   phsens(ix,iy) = 0.
	avgphsens(ix,iy) = 0.
	   ampsens(ix,iy) = 0. 
	avgampsens(ix,iy) = 0.
	enddo
	enddo

c	总的sensitivity是各个频段的sensitivity叠加起来的
	do ifreq = 1, nfreq
c!	   write(*,*) ifreq
	 period = 1/freq(ifreq)
	 lamda = phvel*period
         kk = 2*pi/lamda*radius
c	从左向右扫过每一个格子
  	 do ix = 1,nx
	     x = (ix-1)*dx + xbeg
c========================CHANGE============================
c  	     delta1 = x
c========================CHANGE============================
	   do iy = 1,ny
	     y = (iy-1)*dy + ybeg
c	     if(x.eq.0 .and. y.eq.0) then 
c	       delta2 = sqrt(dx**2+dy**2)
c	     else
		   delta1 = sqrt((x-slo)**2+(y-sla)**2)*pi*radius/180
	       delta2 = sqrt((x-rlo)**2+(y-rla)**2)*pi*radius/180
		   delta=sqrt((slo-rlo)**2+(sla-rla)**2)*pi*radius/180
c	     endif
c========================CHANGE============================
cc formula from Ying Zhou et al., 2004, GJI 3-D sensitivity kernels for surface-wave observables
        phsens(ix,iy) = phsens(ix,iy)   + 
     1  amplitude(ifreq)*(-2)*kk**2*sin(kk*(delta1+delta2-delta)/radius+pi/4)
     1                 /sqrt(8*pi*kk*abs(sin(delta2/radius))*abs(sin(delta1/radius)))
     1                 *((dx*dy)*(pi/180)**2) 

	ampsens(ix,iy) = ampsens(ix,iy) +
     1  amplitude(ifreq)*(-2)*kk**2*cos(kk*(delta1+delta2-delta)/radius+pi/4)
     1                 /sqrt(8*pi*kk*abs(sin(delta2/radius))*abs(sin(delta1/radius)))
     1                 *sqrt(abs(sin((delta)/radius)))* ((dx*dy)*(pi/180)**2)
                    
	   enddo
	 enddo
	enddo	     




        alpha = 1./( (scalelen*pi*radius/180)**2 )
c  These limits below make no sense for convolving responses with Gaussian
c  smoothing - much too limited distance, might as well be raw kernels.
c	nxlimit = 20.
c	nylimit = 20. 
	nxlimit=5
	nylimit=5

         do ix = 1, nx
	 do iy = 1, ny
	   xout=(ix-1)*dx+xbeg
	   yout=(iy-1)*dy+ybeg

	   x = ((ix-1)*dx + xbeg)*pi*radius/180
	   y = ((iy-1)*dy + ybeg)*pi*radius/180
            wgtsum = 0
   
	   ixxbeg = ix-nxlimit
	   ixxend = ix+nxlimit
	   iyybeg = iy-nylimit
	   iyyend = iy+nylimit
           if( ix .le. nxlimit    ) ixxbeg = 1
	   if( ix .ge. (nx-nxlimit)) ixxend = nx
           if( iy .le. nylimit    ) iyybeg = 1
	   if( ix .ge. (ny-nylimit)) iyyend = ny
	
           do ixx = ixxbeg,ixxend
	   do iyy = iyybeg,iyyend
	      xx = ((ixx-1)*dx + xbeg)*pi*radius/180
	      yy = ((iyy-1)*dy + ybeg)*pi*radius/180
              distsq = alpha*((xx-x)**2+(yy-y)**2)
             if( distsq.lt. 80. ) then
               wgttemp(ixx,iyy) = exp(-distsq)
               wgtsum = wgtsum + wgttemp(ixx,iyy)
             else
               wgttemp(ixx,iyy) = 0.0
             endif
           enddo
	   enddo


           do ixx = ixxbeg,ixxend
	      do iyy = iyybeg,iyyend
	       avgphsens(ix,iy)   = avgphsens(ix,iy) + 
     1                     phsens(ixx,iyy)*wgttemp(ixx,iyy)/wgtsum
	      avgampsens(ix,iy)  = avgampsens(ix,iy) + 
     1                    ampsens(ixx,iyy)*wgttemp(ixx,iyy)/wgtsum
              enddo
	   enddo        
       write(20,*) xout,yout,  ampsens(ix,iy)
c	   write(30,*) x,y,avgphsens(ix,iy),avgampsens(ix,iy)
		write(30,*) xout,yout, avgampsens(ix,iy)
	 enddo
	 enddo		

	close (unit=30)
c       close (unit=20)
	write(*,*)"==computation finished"
	end

