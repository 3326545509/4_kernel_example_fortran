program main
    
    integer:: imax_v, imax_k
    common imax_v,imax_k

    character *70 :: file_velocity, file_kernel,out_kernel,out_dlnA
    integer::   stat
    real::  slo,sla,rlo,rla,dist,dlnA
    real,allocatable:: velocity(:,:),kernel(:,:)
    integer:: j

    real::t1,t2
    call cpu_time(t1)

    ! arealomin=96
    ! arealamin=21
    ! delta_arc=0.5

    !if(1>2)then
    write(*,*) 'please input velocity file name'
    read(*,*) file_velocity
    write(*,*) 'please input kernel file name'
    read(*,*) file_kernel
    ! write(*,*) 'please input kernel rotated ouf file name'
    ! read(*,*) out_kernel
    write(*,*) 'please input slo,sla,rlo,rla,dist'
    read(*,*) slo,sla,rlo,rla,dist
    out_dlnA=file_kernel(1:17)//'.dlnA.txt'
    out_kernel=file_kernel//'_rotate'
 !   end if
!   =========test========
    ! str=file_kernel(1:17)//'.dlnA.txt'
    ! file_velocity='f_0.1950.phvel.txt'
    ! file_kernel='A.53059.kernel'
    ! out_kernel='out_kernel_test'
    ! slo=102.493
    ! sla=28.9926
    ! rlo=100.596
    ! rla=26.2944
    ! dist=352.735
!   =======================
    !计算文件的行数，并生成所需大小的数组
    write(*,*)slo,sla,rlo,rla,dist,file_kernel,file_velocity
    call count_row(file_velocity,imax_v)
    call count_row(file_kernel,imax_k)    
    allocate(velocity(imax_v,3))
    allocate(kernel(imax_k,3))
    !读取kernel和phase velocity数据
    call readfile(file_velocity,imax_v,velocity)
    call readfile(file_kernel,imax_k,kernel)
    !对kernel进行切割置零、旋转
    call zero_array(kernel,imax_k,dist)
    call rotate(kernel,slo,sla,rlo,rla)
    !输出旋转后的kernel
    open(unit=10,file=out_kernel)
    do j=1,imax_k,1
        write(10,*) kernel(j,1),kernel(j,2),kernel(j,3)
    end do
    close(10)
    !将kernel和phvel相乘相加
    call plus(kernel,velocity,dlnA)
    
    open(unit=10,file=out_dlnA)
    write(10,*)file_kernel,dlnA
    close(10)
    !filein "+kernel_filein+"\trotate theta: "+str(math.degrees(theta))+"\tdlnA= "+str(    dlnA)
    call cpu_time(t2)
    write(*,*)'cpu time:',t2-t1
end program main

subroutine plus(kernel,velocity,dlnA)
    implicit none
    integer:: imax_v,imax_k
    common imax_v,imax_k

    real,intent(in):: kernel(imax_k,3), velocity(imax_v,3)
    real,intent(out):: dlnA
    ! ke：单个点的上的kernel值
    real :: dv,ke,vlo,vla,klo,kla
    integer :: i,j
    real:: lomin_kernel_area,lomax_kernel_area,lamin_kernel_area,lamax_kernel_area
    
    dlnA=0

    lomin_kernel_area=minval(kernel(:,1))
    lomax_kernel_area=maxval(kernel(:,1))
    lamin_kernel_area=minval(kernel(:,2))
    lamax_kernel_area=maxval(kernel(:,2))
    do i=1,imax_v,1
        vlo =   velocity(i,1)
        vla =   velocity(i,2)
        if (vlo<lomin_kernel_area .or. vlo>lomax_kernel_area .or. vla<lamin_kernel_area .or. vla>lamax_kernel_area)cycle
        dv  =   (velocity(i,3)-3)/velocity(i,3)
        do j=1,imax_k,1
            klo =   kernel(j,1)
            kla =   kernel(j,2)
            ke  =   kernel(j,3)
            if (vlo-klo<=0.25 .and. vlo-klo>-0.25 .and. vla-kla<=0.25 .and. vla-kla>-0.25)then
                dlnA = dlnA + ke*dv
            end if
        end do
        !write(*,*)ke,dv
    end do
    write(*,*)dlnA
end subroutine plus

subroutine rotate(kernel,slo,sla,rlo,rla)
    implicit none
    integer:: imax_v,imax
    common imax_v,imax
    real,dimension(imax,3)::   kernel
    real,intent(in):: slo,sla,rlo,rla
    real:: theta,x1,y1
    integer:: i
    call rotateAngle(slo,sla,rlo,rla,theta)
    do i=1,imax,1
        x1=kernel(i,1)
        y1=kernel(i,2)
        kernel(i,1)=x1*cos(theta)-y1*sin(theta)+slo
        kernel(i,2)=x1*sin(theta)+y1*cos(theta)+sla
    end do
end subroutine rotate

subroutine rotateAngle(slo,sla,rlo,rla,theta)
    implicit none
    real,intent(in)::   slo,sla,rlo,rla
    real,intent(out)::  theta
    real::  rlo_temp,rla_temp

    rlo_temp=rlo-slo
    rla_temp=rla-sla
    if      (rlo_temp>0) then
        theta=atan(rla_temp/rlo_temp)
    else if (rlo_temp<0) then
        theta=atan(rla_temp/rlo_temp)+(4.*atan(1.))
    else if (abs(rlo_temp)<1e-6) then
        theta=0
    end if
end subroutine rotateAngle

subroutine zero_array(array,imax,dist)
    implicit none
    integer,intent(in)::    imax
    real,intent(in)::dist
    real,dimension(imax,3)::array
    integer::i
    real:: arcdist

    arcdist=dist/6371*180/3.14159265
    write(*,*)"arcdist=",arcdist
    do i=1,imax,1
        if( array(i,2)>1 .or. array(i,2)<-1 .or. isnan(array(i,3)) &
        .or. array(i,1)>arcdist+0.5 .or. array(i,1)<-0.5 ) then
            array(i,3)=0
        end if 
    end do
end subroutine zero_array

subroutine readfile(filein,imax,array)
    implicit none
    character(len=*),intent(in)::  filein
    integer,intent(in)::    imax
    real,dimension(imax,3),intent(out)::  array
    integer::   stat, i

    open(unit=40,file=filein)
    do i =1,imax,1
        read(40,*,iostat=stat) array(i,1),array(i,2),array(i,3)
    end do
    close(unit=40)
end subroutine readfile

subroutine count_row(filein,imax)
    implicit none
    character(len=*),intent(in)::    filein
    integer,intent(out)::   imax
    integer::   stat
    !临时变量，用以读取文件的时候储存读出的内容，然后用imax计数
    real::      a,b,c

    open(unit=40,file = filein)
    imax=0
    do while(.true.)
        read(40,*,iostat=stat)a,b,c
        if (stat/=0) exit
        imax=imax+1
    end do
    close(unit=40)
end subroutine count_row